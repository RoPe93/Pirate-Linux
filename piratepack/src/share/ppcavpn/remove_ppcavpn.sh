#!/bin/bash

set -e

curdir="$(pwd)"
cd
homedir="$(pwd)"
localdir="$homedir/.piratepack/ppcavpn"
cd "$localdir"

if [ -d ppcavpn ]
then
    cd "$curdir"
    "./remove_ppcavpn_file.sh"
fi

set +e
chmod -Rf u+rw "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*
rm -rf "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*
set -e
