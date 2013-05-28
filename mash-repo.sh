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

#./mash-repo.sh 6.0 Updates Final gold

VERSION=$1
STAGE=$2
SEQ=$3
CFG=$4

MAJOR=$(echo ${VERSION} | cut -f1 -d".")

STG_LOWER=$(echo ${STAGE} | tr '[A-Z]' '[a-z]')
SEQ_LOWER=$(echo ${SEQ} | tr '[A-Z]' '[a-z]')

BASE_DIR=/mnt/koji/releng/gl${MAJOR}
if [ "${STG_LOWER}" == "updates" ]; then
    if [ "${SEQ_LOWER}" != "final" ]; then
        OUTPUT_DIR=${BASE_DIR}/testing/${VERSION}/${STG_LOWER}-${SEQ_LOWER}/
    else
        OUTPUT_DIR=${BASE_DIR}/testing/${VERSION}/${STG_LOWER}-${SEQ_LOWER}/
    fi
elif [ "${STG_LOWER}" == "alpha" ]; then
    REL_DIR="sketchy"
    OUTPUT_DIR=${BASE_DIR}/${REL_DIR}/${VERSION}/${STG_LOWER}-${SEQ_LOWER}/
elif [ "${STG_LOWER}" == "beta" ] || [ "${SEQ_LOWER}" != "final" ]; then
    OUTPUT_DIR=${BASE_DIR}/testing/${VERSION}/${STG_LOWER}-${SEQ_LOWER}/
elif [ "${STG_LOWER}" == "final" ] || [ "${SEQ_LOWER}" == "final" ]; then
    OUTPUT_DIR=${BASE_DIR}/releases/${VERSION}/
fi

if [ ! -d ${OUTPUT_DIR} ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') $0: creating ${OUTPUT_DIR}"
    mkdir -p ${OUTPUT_DIR};
fi

if [ "${STG_LOWER}" == "updates" ]; then
    mash -o ${OUTPUT_DIR} ${CFG}
else
    mash -o ${OUTPUT_DIR} ${CFG} -f /mnt/koji/releng/comps-goose6-server.xml
fi

pushd ${OUTPUT_DIR} # &> /dev/null

if [ "${STG_LOWER}" == "updates" ]; then
    rsync -a ${CFG}/* .
    rm -rf ${CFG}
else
    rsync -a ${CFG}/* Everything/
    rm -rf ${CFG}
fi

popd # &> /dev/null

if [ "${STG_LOWER}" == "final" ] || [ "${SEQ_LOWER}" == "final" ]; then
    rm -f ${BASE_DIR}/${MAJOR}
    ln -s ${OUTPUT_DIR} /mnt/koji/releng/gl${MAJOR}/${MAJOR}
fi
