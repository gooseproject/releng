#/bin/bash

if [ $# -lt 4 ]; then
    echo "Usage: $0 <version> <stage> <sequence> <config>"
    echo "eg. $0 6.0 Alpha TC4 sketchy"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

VERSION=$1
STAGE=$2
SEQ=$3
CFG=$4

MAJOR=$(echo ${VERSION} | cut -f1 -d".")


BASE_DIR=/mnt/koji/releng/gl${MAJOR}
if [ "${STAGE}" == "Alpha" ]; then
    REL_DIR="sketchy"
    OUTPUT_DIR=${BASE_DIR}/${REL_DIR}/${VERSION}-${STAGE}-${SEQ}/
elif [ "${STAGE}" == "Beta" ] || [ "${SEQ}" != "Final" ]; then
    REL_DIR="${VERSION}"
    OUTPUT_DIR=${BASE_DIR}/${REL_DIR}/${STAGE}-${SEQ}/
else
    REL_DIR="${VERSION}"
    OUTPUT_DIR=${BASE_DIR}/${REL_DIR}/Final/
fi

if [ ! -d ${OUTPUT_DIR} ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') $0: creating ${OUTPUT_DIR}"
    mkdir -p ${OUTPUT_DIR};
fi

mash -o ${OUTPUT_DIR} ${CFG} -f /mnt/koji/releng/comps-goose6-server.xml

pushd ${OUTPUT_DIR} # &> /dev/null
rsync -a ${CFG}/* Everything/
rm -rf ${CFG}
popd # &> /dev/null

rm -f ${BASE_DIR}/${MAJOR}
ln -s ${OUTPUT_DIR} /mnt/koji/releng/gl${MAJOR}/${MAJOR}
