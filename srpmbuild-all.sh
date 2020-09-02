#!/bin/bash
spectool -g kernel.spec && ./srpmbuild.sh && patch -p1 <kernel.diff && ./srpmbuild.sh && patch -p1 <kernel.diff -R && echo OK
#patch -p1 <kernel-preempt.diff && spectool -g kernel.spec && ./srpmbuild.sh && patch -p1 <kernel.diff && ./srpmbuild.sh && patch -p1 <kernel.diff -R && patch -p1 <kernel-preempt.diff -R && echo OK
