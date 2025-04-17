#!/bin/bash

# Copyright 2020 - 2025, Damian Wrobel <dwrobel@ertelnet.rybnik.pl>
# SPDX-License-Identifier: GPL-2.0

set -euxo pipefail

# $ git remote -v
# origin	https://github.com/raspberrypi/linux.git (fetch)
# origin	https://github.com/raspberrypi/linux.git (push)
# stable	git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git (fetch)
# stable	git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git (push)

last_rebase=$(git log --format="%H %s" -n50 | grep ' Linux 6.' | head -n 1)

sha_tag=$(echo $last_rebase | awk '{print $1}')
sha_head=$(git rev-parse HEAD)

path_name="bcm270x-linux-rpi-6.12.y-$(c=${sha_head}; echo ${c:0:9}).patch.xz"

echo git diff ${sha_tag}..${sha_head} to ${path_name}
git diff ${sha_tag}..${sha_head} | xz -c9 > ${path_name}

micro_version=$(echo $last_rebase | awk '{print $3}')
micro_version=$(echo $micro_version | awk -F '.' '{print $3}')

kernel_dir=../fedberry-kernel-rpi-6.12.y

cp -a $path_name ${kernel_dir}/
(cd "${kernel_dir}" && ./update-spec.sh $micro_version $sha_head)
