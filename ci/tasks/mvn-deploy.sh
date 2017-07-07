#!/bin/bash

set -e
cd source
echo "<settings><servers><server><id>private-snapshot</id><username>${MVN_REPO_USERNAME}</username><password>${MVN_REPO_PASSWORD}</password></server><server><id>private-release</id><username>${MVN_REPO_USERNAME}</username><password>${MVN_REPO_PASSWORD}</password></server></servers></settings>" > settings.xml
mvn -P gsp generate-resources -s settings.xml -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
mvn deploy -s settings.xml -DskipTests=true -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
