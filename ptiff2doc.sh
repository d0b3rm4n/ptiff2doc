#!/bin/bash
#
# Copyright (C) 2017 - Reto Zingg <g.d0b3rm4n@gmail.com>
#
# This file is part of ptiff2doc
#
# ptiff2doc is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# ptiff2doc is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#
# Todo:
#      - get rid of gscan2pdf dependency
#      - is there a better way to set the pdfinfo?
#

cleanup () {
    if [[ -n $TEMP_DIR ]] ; then
        rm -rf $TEMP_DIR
    fi
}

trap cleanup EXIT

usage() {
    cat <<EOF

    A script which makes use of GNU parallel to transform TIFF files
    into a PDF and/or a DJVU document.

    tesseract is used to perform a optical char regocnition (ocr)
    and add a hidden text layer to the document.

    Usage:
        $0 [OPTIONS] [FOLDER WITH TIFF FILES]

        [FOLDER WITH TIFF FILES]
            a folder with .tif files, if folder is ommited
            the current working directory (cwd) is used.

    Options [default value]:
        -h | --help          This help
        -b | --docname       The basename of the output document [book]
        -d | --dpi           DPI setting for c44 [300]
        -j | --djvu          Create .djvu
        -p | --pdf           Create .pdf
        -a | --author        Author to be set in .pdf/.djvu
        -t | --title         Title to be set in .pdf/.djvu
        -l | --language      Language setting for tesseract [deu]
                             See 'tesseract --list-langs' for supported languages
                             deu = German
                             eng = English
                             fin = Finnish
                             for mixed language documents 'deu+eng' is also possible

EOF

    # exit if any argument is given
    [[ -n "$1" ]] && exit 1
}

optionparser() {
    getopt --test > /dev/null
    if [[ $? -ne 4 ]]; then
        echo "'getopt --test' failed! Newer version of getopt needed."
        exit 1
    fi

    # parse command line options
    SHORT=hd:jpb:a:t:l:
    LONG=help,dpi:,djvu,pdf,docname:,author:,title:,language:

    PARSED=$(getopt --options ${SHORT} --longoptions ${LONG} --name "$0" -- "$@")
    if [[ $? -ne 0 ]]; then
        usage quit
    fi
    eval set -- "$PARSED"

    while true; do
        case "$1" in
            -h|--help)
                usage quit
                ;;
            -d|--dpi)
                DPI=$2
                shift 2
                ;;
            -j|--djvu)
                WANT_DJVU=1
                shift
                ;;
            -p|--pdf)
                WANT_PDF=1
                shift
                ;;
            -b|--docname)
                DOC_BASENAME=$2
                shift 2
                ;;
            -a|--author)
                AUTHOR=$2
                shift 2
                ;;
            -t|--title)
                TITLE=$2
                shift 2
                ;;
            -l|--language)
                TESS_LANG=$2
                shift 2
                ;;
            --) shift
                break
                ;;
            *)
                echo "Programming error"
                usage quit
                ;;
        esac
    done

    # check if tiff folder was given
    if [[ $# -eq 1 ]]; then
        TIFF_DIR=$(readlink -f $1)
    fi

}

###########################
# Main
###########################

WORK_DIR=$(pwd)
TIFF_DIR=${WORK_DIR}
TEMP_DIR="${WORK_DIR}/$(mktemp --directory .ptiff2doc.XXXXXXXXXX)"
SCRIPT_DIR=$(dirname $(readlink -f $0))
WANT_DJVU=0
WANT_PDF=0
DOC_BASENAME="book"
TITLE=""
AUTHOR=""
DJVU_DATE=$(date --rfc-3339='sec')
DPI=300
TESS_LANG="deu"

optionparser "$@"

cd ${TEMPDIR}

if [[ $WANT_DJVU -gt 0 || $WANT_PDF -gt 0 ]]; then
    echo "Run ocr on images ..."
    parallel tiffcp {},0 ${TEMP_DIR}/{/} ::: ${TIFF_DIR}/*.tif
    parallel tesseract {} ${TEMP_DIR}/{/.} -l ${TESS_LANG} -c tessedit_create_hocr=${WANT_DJVU} -c tessedit_create_pdf=${WANT_PDF} ::: ${TEMP_DIR}/*.tif
fi

if [[ $WANT_DJVU -gt 0 ]]; then
    echo "Create djvu document ..."
    parallel tifftopnm -byrow {} '>' ${TEMP_DIR}/{/.}.pnm ';' c44 -dpi ${DPI} ${TEMP_DIR}/{/.}.pnm ${TEMP_DIR}/{/.}.djvu ';' rm -rf ${TEMP_DIR}/{/.}.pnm ::: ${TEMP_DIR}/*.tif
    parallel ${SCRIPT_DIR}/hocr2djvutxt.pl {} ::: ${TEMP_DIR}/*.hocr
    parallel djvused {} -e "'select 1 ; set-txt ${TEMP_DIR}/{/.}.hocr.djvutxt_file'" -s ::: ${TEMP_DIR}/*.djvu
    djvm -create ${WORK_DIR}/${DOC_BASENAME}.djvu  ${TEMP_DIR}/*.djvu

    cat<<EOF > ${TEMP_DIR}/djvu-metadata
Producer	"djvulibre"
CreationDate	"${DJVU_DATE}"
ModDate	"${DJVU_DATE}"
Author	"${AUTHOR}"
Creator	"ptiff2doc"
Title	"${TITLE}"
EOF
    djvused ${WORK_DIR}/${DOC_BASENAME}.djvu -e "set-meta ${TEMP_DIR}/djvu-metadata" -s
fi

if [[ $WANT_PDF -gt 0 ]]; then
    echo "Create pdf document ..."
    pdfunite ${TEMP_DIR}/*.pdf ${WORK_DIR}/${DOC_BASENAME}.pdf
    ${SCRIPT_DIR}/pdfinfo-setter.pl --author "${AUTHOR}" --title "${TITLE}" ${WORK_DIR}/${DOC_BASENAME}.pdf
fi

cd ${WORK_DIR}

# clean up is done by EXIT trap

# vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
