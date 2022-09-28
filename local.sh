#!/bin/sh

# Uses aws-sdk-ios repo to create local copies of the XCF binaries
# so that modified source can be used to consume the SPM package.

export SOURCE_REPO_DIR=../aws-sdk-ios
export XCF_OUTPUT_DIR=xcframeworks/output/XCF

# clear the output
# rm -rf "${SOURCE_REPO_DIR}/${XCF_OUTPUT_DIR}"

if [ ! -d "${SOURCE_REPO_DIR}" ]; then
    echo "AWS SDK iOS repo is required: ${SOURCE_REPO_DIR}" 
    exit 0
fi

# builds packages and produces XCF files
pushd .
cd "${SOURCE_REPO_DIR}"
python3 ./CircleciScripts/create_xcframeworks.py
popd

# Copy XCF output into SPM repo
mkdir -p XCF
cp -Rp "${SOURCE_REPO_DIR}/${XCF_OUTPUT_DIR}" .

# Manually enable local repo when it is being used locally
echo "Update ${XCF_OUTPUT_DIR}/Package.swift to use local XCF files"
