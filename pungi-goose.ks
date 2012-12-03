#############################################################################
#
# GoOSe 6 DVD/netinst .iso installer configuration
#
#############################################################################
#
# Use a part of 'iso' to define how large you want your isos.
# Only used when composing to more than one iso.
# Default is 670 (megs), CD size.
#part iso --size=4998

#############################################################################
# Add the repos you wish to use to compose here.  At least one of them needs group data.
repo --name=GoOSe-6 --baseurl=http://koji.gooselinux.org/releases/6/Everything/$basearch/os/
repo --name=GoOSe-6-src --baseurl=http://koji.gooselinux.org/releases/6/Everything/source/SRPMS/

#############################################################################
# Package manifest for the compose.  Uses repo group metadata to translate groups.
# (@base is added by default unless you add --nobase to %packages)
# (default groups for the configured repos are added by --default)
%packages --default
# core
@base

anaconda
goose-release
goose-logos

anaconda-yum-plugins
brltty
createrepo
dos2unix
dracut-fips
dracut-network
dumpet
ecryptfs-utils
edac-utils
gpm
isomd5sum
kernel*
logwatch


ntp
tcsh

-generic-logos
-glibc32
-kernel*debug*
-kernel*-devel*
-kernel-kdump*
-syslog-ng

# Desktop Packages
@x11
@legacy-x
@basic-desktop
@general-desktop
@kde-desktop
@desktop-debugging
@desktop-platform

alacarte
clutter
control-center-extra
corosync
corosynclib
cpufrequtils
esc
firefox
nautilus-open-terminal
nspluginwrapper
thunderbird
dejavu-lgc-sans-mono-fonts
dvgrab
dvipng
firstaidkit-gui
gconf-editor
gnome-games
gnome-pilot
gnome-pilot-conduits
kdebase-workspace-akonadi
kdebase-workspace-python-applet
krb5-auth-dialog
libmatchbox
libsexy
libXmu
libXp
libXxf86misc


# apps
@technical-writing
@eclipse
@internet-browser
@console-internet
@remote-desktop-clients
@system-admin-tools
@emacs
@tex
@graphics
@technical-writing

ctags-etags
dcraw
deltarpm
dtach
eclipse-mylyn*
-eclipse-mylyn-java
eclipse-pde
eclipse-subclipse-graph
emacs-auctex
emacs-gnuplot
emacs-nox
fetchmail
freeipmi
freeipmi-bmc-watchdog
freeipmi-ipmidetectd
ftp
gegl
gimp-data-extras
gimp-help
gimp-help-browser
gimp-libs
gutenprint-plugin
hardlink
ImageMagick
inkscape
ipmitool
irssi
jadetex
kdebase-libs
k3b
lftp
libesmtp
librelp
libsamplerate
libsane-hpaio
libsemanage-python
libspiro
libwmf
libwpd
libwpg
lsscsi
luci
lvm2-cluster

wireshark-gnome

# Devel packages
@additional-devel
@development
@desktop-platform-devel
@java-platform
@web-services

apr-devel
apr-util-devel
babel
bzr
chrpath
cmake
cups-devel
cups-lpd
db4-devel
dejagnu
devhelp
e2fsprogs-devel
ElectricFence
expat-devel
expect
fakechroot
file-devel
fuse-devel
gamin-devel
gc
gcc-gnat
gcc-objc*
gd
glade3
gmp-devel
gnome-common
gnome-devel-docs
gstreamer-plugins-base-devel
gtk2-devel-docs
gtkhtml2
httpd-devel
imake
iptables-devel
iptraf
iptstate
ipvsadm
kdebase-devel
kdebase-workspace-devel
kdegraphics-devel
kdelibs3-devel
kdelibs-apidocs
kdelibs-devel
kdemultimedia-devel
kdenetwork-devel
kdenetwork-libs
kdepim-devel
kdepim-libs
kdepimlibs-devel
kdesdk
kdesdk-devel
kdesdk-utils
kross-python
libaio-devel
libblkid-devel
libcap-devel
libconfig
libexif-devel
libglademm24
libgnat
libgnat-devel
libgphoto2-devel
libgudev1-devel
libhugetlbfs-devel
libieee1284-devel
libnl-devel
libobjc
libstdc++-docs
libsysfs
libtiff-devel
libtopology-devel
libudev-devel
libusb-devel
libuuid-devel
libvirt-devel
libvirt-java-devel
libXaw-devel
libxkbfile-devel
libXmu-devel
libXp-devel
libXpm-devel
libXScrnSaver-devel
libXv-devel
libXxf86misc-devel
lm_sensors-devel
log4cpp


# Server packages
@server-platform
@network-server
@network-tools
@compat-libraries
@ftp-server
@mail-server
@mysql
@mysql-client
@postgresql
@postgresql-client
@graphical-admin-tools
@cifs-file-server
@databases
@web-server
@web-servlet
@php
@turbogears
@large-systems
@perl-runtime
@backup-client
@backup-server
@storage-client-multipath
@storage-server
@conflicts-server

arptables_jf
arpwatch
bacula-client
bind
bind-chroot
bind-dyndb-ldap
cman
cmirror
compat-dapl
compat-db
compat-db4*
compat-gcc-34*
compat-glibc-headers
compat-readline5
ctdb
cyrus-imapd
cyrus-imapd-utils
dhcp
db4-cxx
dialog
dlm-pcmk
dovecot-mysql
dovecot-pgsql
dovecot-pigeonhole
dropwatch
fence-agents
fence-virt*
freeradius
isns-utils
krb5-server
krb5-server-ldap
libdbi-dbd-mysql
libdbi-dbd-pgsql
libmemcached
libwsman1
libwvstreams
lksctp-tools


# Virt group
@virtualization
@virtualization-client
@virtualization-platform
@virtualization-tools

guestfish
libguestfs-java
libguestfs-mount
libguestfs-tools
libvirt-cim
libvirt-java
libvirt-qpid


# Useful miscellany
@fonts
@print-client
@input-methods
@directory-client
@network-file-system-client
@debugging
@hardware-monitoring
@performance
@security-tools
@smartcard
@scientific

amtu
arts-devel
atlas
audit-libs-python
audit-viewer
authd
automoc
avahi-gobject
avahi-tools
babl
bitmap-fixed-fonts
bitmap-lucida-typewriter-fonts
blas
bitk
btrfs-progs
cachefilesd
cjkuni-fonts-ghostscript
cluster-cim
cluster-glue
cluster-glue-libs
clusterlib
cluster-snmp
efax
environment-modules
febootstrap
finger*
flightrecorder
gdb-gdbserver
geoclue
ggz-base-libs
glibc-utils
gsl
hesinfo
hplip
hplip-gui
isdn4k-utils
kabi-whitelists
kabi-yum-plugins
kdebase-workspace-libs
krb5-appl-clients
krb5-pkinit-openssl
ksh
lapack
ldapjdk
libnetfilter_conntrack
libnfnetlink
lm_sensors
lrzsz
lslk


# Languages
@afrikaans-support
@albanian-support
@arabic-support
@armenian-support
@assamese-support
@basque-support
@belarusian-support
@bengali-support
@bhutanese-support
@burmese-support
@brazilian-support
@breton-support
@british-support
@bulgarian-support
@catalan-support
@chinese-support
@croatian-support
@czech-support
@danish-support
@dutch-support
@esperanto-support
@estonian-support
@ethiopic-support
@filipino-support
@finnish-support
@french-support
@gaelic-support
@galician-support
@georgian-support
@german-support
@greek-support
@gujarati-support
@hebrew-support
@hindi-support
@hungarian-support
@icelandic-support
@indonesian-support
@inuktitut-support
@irish-support
@italian-support
@japanese-support
@kannada-support
@kashmiri-support
@kashubian-support
@khmer-support
@konkani-support
@korean-support
@lao-support
@latvian-support
@lithuanian-support
@low-saxon-support
@macedonian-support
@malay-support
@malayalam-support
@maori-support
@marathi-support
@mongolian-support
@nepali-support
@northern-sotho-support
@norwegian-support
@oriya-support
@persian-support
@polish-support
@portuguese-support
@punjabi-support
@romanian-support
@russian-support
@serbian-support
@sindhi-support
@sinhala-support
@slovak-support
@slovenian-support
@somali-support
@southern-ndebele-support
@southern-sotho-support
@spanish-support
@swati-support
@swedish-support
@tagalog-support
@tamil-support
@telugu-support
@thai-support
@tibetan-support
@tsonga-support
@tswana-support
@turkish-support
@ukrainian-support
@urdu-support
@venda-support
@vietnamese-support
@walloon-support
@welsh-support
@xhosa-support
@zulu-support
cim-schema

# Size removals
-java-1.6.0-openjdk-src
-xorg-x11-docs
-java-1.5.0-gcj-src
-java-1.5.0-gcj-devel
-libgcj-src
-*javadoc*
%end

############################################################################
#
# end of config - add comments here
#
############################################################################
