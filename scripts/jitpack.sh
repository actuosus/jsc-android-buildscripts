#!/bin/bash -e

rm -rf $PWD/artifacts
mkdir -p $PWD/artifacts
curl "https://github.com/actuosus/jsc-android-buildscripts/releases/download/v260637.0.0/jsc_dist.zip" -L -o $PWD/artifacts/jsc.zip
unzip $PWD/artifacts/jsc.zip -d $PWD/artifacts
cp -Rf $PWD/artifacts/dist/ ~/.m2/repository/
