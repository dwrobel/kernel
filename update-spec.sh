#!/bin/bash

# Copyright 2020, Damian Wrobel <dwrobel@ertelnet.rybnik.pl>
# SPDX-License-Identifier: GPL-2.0

set -euxo pipefail

minor_version=$(grep -e '^%\(define base_sublevel\|global base_sublevel\)' kernel.spec | awk '{print $3}')

required_args=2

if [ $# -ne $required_args ]; then
   cat <<-EOD
	Invalid number of arguments. Expected: $required_args
	Usage:   $0 <kernel_micro_version> <new_git_sha>
	Example: $0 77 081eebdeccfd12e0aaba4b64c9f87b608777913b
	Note: Script expect the new patch file to be located in the current directory
	      e.g. bcm270x-linux-rpi-6.${minor_version}.y-<short_git_sha>.patch.xz
	EOD
    exit 1
fi

new_micro="$1"
new_gitsha="$2"

patch_to_remove=$(spectool --list-files kernel.spec | grep .patch.xz | grep ${minor_version}.y | awk '{print $2}')

new_gitsha9=${new_gitsha:0:9}
old_gitsha="${patch_to_remove##*-}"
old_gitsha="${old_gitsha%%.*}"
patch_to_add="${patch_to_remove/$old_gitsha/$new_gitsha9}"

git rm -f $patch_to_remove || true
git add $patch_to_add

sed -i -E "s/^(%define stable_update) [^ ]+/\1 $new_micro/" kernel.spec
sed -i -E "s/^(%global baserelease) [^ ]+/\1 0/" kernel.spec
sed -i -E "s/^(%global rpi_gitshort) [^ ]+/\1 ${new_gitsha9}/" kernel.spec

rpmdev-bumpspec -c "$(cat <<EOF
Update to stable kernel patch v6.${minor_version}.${new_micro}
- Sync RPi patch to git revision: $new_gitsha
EOF
)" kernel.spec

git add kernel.spec
git commit -s -m "$(cat <<EOF
Update to stable kernel patch v6.${minor_version}.${new_micro}

Sync RPi patch to git revision: ${new_gitsha}
EOF
)"
