#!/bin/bash

set -e
cd source
mvn -P gsp generate-resources -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
mvn clean verify sonar:sonar -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository -Dsonar.host.url=${SONAR_URL}
