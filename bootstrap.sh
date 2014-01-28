#!/bin/bash -e

LIBRARY_URL=http://ftp.moex.com/pub/ClientsAPI/ASTS/astsbridge-4.2.2.1134.zip

ARCHIVE=${LIBRARY_URL##*/}
VERSION=${LIBRARY_URL%.*}
VERSION=${VERSION##*-}

DIR=$(readlink -f $0)
DIR=${DIR%/*}

LIBDIR=embedded/linux64

if [ $# -eq 1 ]; then
    TMPDIR=$1
    echo "Using source directory: $TMPDIR"
else
    TMPDIR=$(mktemp -d)

    trap "rm -fr $TMPDIR" EXIT
    echo "Created temp directory: $TMPDIR"

    echo "Fetching $LIBRARY_URL"

    (cd $TMPDIR && curl -O -s $LIBRARY_URL)

    echo "Extracting $ARCHIVE"
    (cd $TMPDIR && unzip -q $ARCHIVE)
    (cd $TMPDIR/${LIBDIR} && tar zxf libmtesrl-linux-*)
fi

echo $VERSION > VERSION

mkdir -p ${DIR}/doc

# Files contain spaces, hence this type of surrogate loop
find ${TMPDIR}/doc -iname '*.pdf' -print0 | while read -d $'\0' -r file; do
    dest=${file##*/}
    dest=${dest// /-}
    dest=${dest//---/-}
    cp -v "$file" ${DIR}/doc/${dest}
done

mkdir -p ${DIR}/include
mkdir -p ${DIR}/lib

cp -v ${TMPDIR}/${LIBDIR}/*.h  ${DIR}/include
cp -v ${TMPDIR}/${LIBDIR}/*.so ${DIR}/lib
cp -v ${TMPDIR}/demo/MSVC/MteSrlTest.ini ${DIR}/lib
