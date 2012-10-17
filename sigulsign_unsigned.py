#!/usr/bin/python
#
# sigulsign_unsigned.py - A utility to use sigul to sign rpms in koji
#
# Copyright (c) 2009 Red Hat
#
# Authors:
#     Jesse Keating <jkeating@redhat.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
# This program requires koji and sigul installed, as well as configured.

import os
import optparse
import sys
import koji
import getpass
import subprocess
import logging

errors = {}

status = 0
builds = []
rpmdict = {}
unsigned = []
loglevel = ''
passphrase = ''
KOJIHUB = 'https://koji.gooselinux.org/kojihub'
# Should probably set these from a koji config file
SERVERCA = os.path.expanduser('~/.koji/goose-server-ca.cert')
CLIENTCA = os.path.expanduser('~/.koji/goose-client-ca.cert')
CLIENTCERT = os.path.expanduser('~/.koji/goose.cert')
# Setup a dict of our key names as sigul knows them to the actual key ID
# that koji would use.  We should get this from sigul somehow.
KEYS = {'goose-6.0-alpha': {'id': '3a1a65b6', 'v3': True},
	'goose-6.0-beta': {'id': '1cdbbb39', 'v3': True},
        'epel-6': {'id': '0608b895', 'v3': True}}

def exit(status):
    """End the program using status, report any errors"""

    if errors:
        for type in errors.keys():
            logging.error('Errors during %s:' % type)
            for fault in errors[type]:
                logging.error('     ' + str(fault))

    sys.exit(status)

# Throw out some functions
def writeRPMs(status, batch=None):
    """Use the global rpmdict to write out rpms within.
       Returns status, increased by one in case of failure"""

    status = status
    count = 0
    workset = []
    # Use multicall for speed, but break it into chunks of 100
    # so that there is some sense of progress

    # Check to see if we want to write all, or just the unsigned.
    if not opts.write_all:
        if batch == None:
            rpms = [rpm for rpm in rpmdict.keys() if rpm in unsigned]
        else:
            rpms = batch
    else:
        rpms = rpmdict.keys()
    logging.info('Calling koji to write %s rpms' % len(rpms))
    kojisession.multicall = True
    for rpm in rpms:
        logging.debug('Writing out %s with %s, %s of %s' % (rpm, key,
                      rpms.index(rpm)+1, len(rpms)))
        kojisession.writeSignedRPM(rpm, KEYS[key]['id'])
        count += 1
        workset.append(rpm)

        if count > 100:
            # Get the results and check for any errors.
            results = kojisession.multiCall()
            for rpm, result in zip(workset, results):
                if isinstance(result, dict):
                    logging.error('Error writing out %s' % rpm)
                    errors.setdefault('Writing', []).append(rpm)
                    if result['traceback']:
                        logging.error('    ' + result['traceback'][-1])
                    status += 1

            # Reset the counter, workset, and multicall
            count = 0
            workset = []
            kojisession.multicall = True

    # We got to the end without getting all the way to 100
    else:
        # Get the results and check for any errors.
        results = kojisession.multiCall()
        for rpm, result in zip(workset, results):
            if isinstance(result, dict):
                logging.error('Error writing out %s' % rpm)
                errors.setdefault('Writing', []).append(rpm)
                if result['traceback']:
                    logging.error('    ' + result['traceback'][-1])
                status += 1

    return status


# Define our usage
usage = 'usage: %prog [options] key (build1, build2)'
# Create a parser to parse our arguments
parser = optparse.OptionParser(usage=usage)
parser.add_option('-v', '--verbose', action='count', default=0,
                  help='Be verbose, specify twice for debug')
parser.add_option('--tag',
                  help='Koji tag to sign, use instead of listing builds')
parser.add_option('--inherit', action='store_true', default=False,
                  help='Use tag inheritance to find builds.')
parser.add_option('--just-write', action='store_true', default=False,
                  help='Just write out signed copies of the rpms')
parser.add_option('--just-sign', action='store_true', default=False,
                  help='Just sign and import the rpms')
parser.add_option('--just-list', action='store_true', default=False,
                  help='Just list the unsigned rpms')
parser.add_option('--write-all', action='store_true', default=False,
                  help='Write every rpm, not just unsigned')
parser.add_option('--password',
                  help='Password for the key')
parser.add_option('--arch',
                  help='Architecture when siging secondary arches')
# Get our options and arguments
(opts, args) = parser.parse_args()

if opts.verbose <= 0:   
    loglevel = logging.WARNING
elif opts.verbose == 1:
    loglevel = logging.INFO 
else: # options.verbose >= 2
    loglevel = logging.DEBUG


logging.basicConfig(format='%(levelname)s: %(message)s',
                    level=loglevel)

# Check to see if we got any arguments
if not args:
    parser.print_help()
    sys.exit(1)

# Check to see if we either got a tag or some builds
if opts.tag and len(args) > 2:
    logging.error('You must provide either a tag or a build.')
    parser.print_help()
    sys.exit(1)

key = args[0]
logging.debug('Using %s for key %s' % (KEYS[key]['id'], key))
if not key in KEYS.keys():
    logging.error('Unknown key %s' % key)
    parser.print_help()
    sys.exit(1)

# Get the passphrase for the user if we're going to sign something
# (This code stolen from sigul client.py)
if not (opts.just_list or opts.just_write):
    if opts.password:
        passphrase = opts.password
    else:
        passphrase = getpass.getpass(prompt='Passphrase for %s: ' % key)
    # now try to check that the key is working
    command = ['sigul', '--batch', 'get-public-key', key]
    child = subprocess.Popen(command, stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)
    child.stdin.write(passphrase + '\0')
    ret = child.wait()
    if ret != 0:
        logging.error('Error validating passphrase for key %s' % key)
        sys.exit(1)

# Reset the KOJIHUB if the target is a secondary arch
if opts.arch:
    KOJIHUB = 'http://%s.koji.fedoraproject.org/kojihub' % opts.arch
# setup the koji session
logging.info('Setting up koji session')
kojisession = koji.ClientSession(KOJIHUB)
kojisession.ssl_login(CLIENTCERT, CLIENTCA, SERVERCA)

# Get a list of builds
# If we have a tag option, get all the latest builds from that tag,
# optionally using inheritance.  Otherwise take everything after the
# key as a build.
if opts.tag is not None:
    logging.info('Getting builds from %s' % opts.tag)
    builds = [build['nvr'] for build in
              kojisession.listTagged(opts.tag, latest=True,
                                     inherit=opts.inherit)]
else:
    logging.info('Getting builds from arguments')
    builds = args[1:]

logging.info('Got %s builds' % len(builds))

# sort the builds
builds = sorted(builds)

# Build up a list of rpms to operate on
# use multicall here to speed things up
logging.info('Getting build IDs from Koji')
kojisession.multicall = True
# first get build IDs for all the builds
for b in builds:
    # use strict for now to traceback on bad builds
    kojisession.getBuild(b, strict=True)
binfos = []
for build, result in zip(builds, kojisession.multiCall()):
    if isinstance(result, list):
        binfos.append(result)
    else:
        errors.setdefault('Builds', []).append(build)
        status += 1
        logging.error('Invalid n-v-r: %s' % build)

# now get the rpms from each build
logging.info('Getting rpms from each build')
kojisession.multicall = True
for [b] in binfos:
    kojisession.listRPMs(buildID=b['id'])
results = kojisession.multiCall()
# stuff all the rpms into our rpm list
for [rpms] in results:
    for rpm in rpms:
        rpmdict['%s.%s.rpm' % (rpm['nvr'], rpm['arch'])] = rpm['id']

logging.info('Found %s rpms' % len(rpmdict))

# Now do something with the rpms.

# If --just-write was passed, try to write them all out
# We try to write them all instead of worrying about which
# are already written or not.  Calls are cheap, restarting
# mash isn't.
if opts.just_write:
    logging.info('Just writing rpms')
    exit(writeRPMs(status))

# Since we're not just writing things out, we need to figure out what needs
# to be signed.

# Get unsigned packages
logging.info('Checking for unsigned rpms in koji')
kojisession.multicall = True
# Query for the specific key we're looking for, no results means
# that it isn't signed and thus add it to the unsigned list
for rpm in rpmdict.keys():
    kojisession.queryRPMSigs(rpm_id=rpmdict[rpm], sigkey=KEYS[key]['id'])

results = kojisession.multiCall()
for ([result], rpm) in zip(results, rpmdict.keys()):
    if not result:
        logging.debug('%s is not signed with %s' % (rpm, key))
        unsigned.append(rpm)

if opts.just_list:
    logging.info('Just listing rpms')
    print('\n'.join(unsigned))
    sys.exit(0)

logging.debug('Found %s unsigned rpms' % len(unsigned))

if opts.arch:
    # Now run the unsigned stuff through sigul
    command = ['sigul', '--batch', 'sign-rpm', '-k', opts.arch, '--store-in-koji', '--koji-only']
else:
    # Now run the unsigned stuff through sigul
    command = ['sigul', '--batch', 'sign-rpm', '--store-in-koji', '--koji-only']
# See if this is a v3 key or not
if KEYS[key]['v3']:
    command.append('--v3-signature')
command.append(key)

# run sigul
def run_sigul(rpms, batchnr):
    global status
    logging.debug('Running %s' % subprocess.list2cmdline(command + rpms))
    logging.info('Signing batch %s/%s with %s rpms' % (batchnr, (total+batchsize-1)/batchsize, len(rpms)))
    child = subprocess.Popen(command + rpms, stdin=subprocess.PIPE)
    child.stdin.write(passphrase + '\0')
    ret = child.wait()
    if ret != 0:
        logging.error('Error signing %s' % (rpms))
    	errors.setdefault('Signing', []).append(rpms)
    	status += 1

logging.info('Signing rpms via sigul')
total = len(unsigned)
batchsize = 1
batchnr = 0
rpms = []
for rpm in unsigned:
    rpms += [rpm]
    if len(rpms) == batchsize:
	batchnr += 1
	run_sigul(rpms, batchnr)
	rpms = []

if len(rpms) > 0:
    batchnr += 1
    run_sigul(rpms, batchnr)

# Now that we've signed things, time to write them out, if so desired.
if not opts.just_sign:
    exit(writeRPMs(status))

logging.info('All done.')
sys.exit(status)
