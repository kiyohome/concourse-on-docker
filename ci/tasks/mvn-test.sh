#!/bin/bash

set -e
cd source
mvn -P gsp generate-resources -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
mvn test -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
