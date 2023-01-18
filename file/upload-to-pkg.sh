#!/usr/bin/env bash

SCRIPT_NAME=$(basename "$0")

function usage() {
    echo "./$SCRIPT_NAME <URL> <file_path>"
}

if [[ $# < 2 ]]; then
    usage
    exit 1
fi

URL=$1
FILE=$2

echo "uploading $FILE to $URL"

CSRF=$(curl -L $URL 2>/dev/null| grep '"token"' | sed 's:.*"token">\(.*\)</span>:\1:')
FILENAME=$(basename $FILE)
curl -XPOST $URL -H "Token: $CSRF" -H 'Upload: true'  -F "$FILENAME=@$FILE"

# usage: sh upload-to-pkg.sh http://pkg.4paradigm.com:81/iRM/OCR/models/ ocr-table-triton-v0.0.1.tar

