#!/bin/bash
rpmbuild -bs --define "_sourcedir `pwd`" --define "_srcrpmdir ." --define "_specdir `pwd`" --define "release 30" "$@" kernel.spec
