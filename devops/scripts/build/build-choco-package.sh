#!/bin/bash

if [ -f build.env ]; then
    source build.env
else
    echo "build.env file not found!"
    exit 1
fi

cd ./dist/${BUILD_PACKAGE_NAME} || exit 1
choco pack --outputdirectory "../choco" || exit 1
mv ../choco/${BUILD_PACKAGE_NAME}.${BUILD_PACKAGE_VERSION}.nupkg "../choco/${CHOCO_NUPKG_PACKAGE_NAME}" || exit 1
