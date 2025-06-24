# Swift Package Manager support for AWS SDK for iOS

This repository enables Swift Package Manager support for the AWS Mobile SDK for iOS by vending a Manifest file (`Package.swift`) that links to binary frameworks for the SDKs.

## Setup

To get started with the AWS SDK for iOS, check out the [Developer Guide for iOS](https://github.com/aws-amplify/aws-sdk-ios/blob/main/README.md#include-the-sdk-for-ios-in-an-existing-application). You can set up the SDK and start building a new project, or you integrate the SDK in an existing project.

To use the AWS SDK for iOS, you will need the following installed on your development machine:

* Xcode 11.0 or later
* iOS 12 or later

## Adding AWS SDK iOS via Swift Package Manager

1. Open your project in Xcode 11.0 or above

2. Go to **File** > **Swift Packages** > **Add Package Dependency...**

3. In the field **Enter package repository URL**, enter "https://github.com/aws-amplify/aws-sdk-ios-spm"

4. Pick the latest version and click **Next**.

    **NOTE:** The AWS Mobile SDK for iOS [does not follow Semantic Versioning](https://docs.amplify.aws/sdk/configuration/setup-options/q/platform/ios#aws-sdk-version-vs-semantic-versioning).

5. Choose the packages required for your project and click **Finish**

## Local Development

It you are using SPM to do development and are modifying the source in the AWS SDK iOS code base you will need to work with a locally built copy of the XCF files. Running `local.sh` will produce all of the XCF files and copy them to a directory in this repo so that `Package.swift` can be updated to reference them. Once the XCF files are in place change the value for `localPathEnabled` to `true` and the package will reference the local path. The Swift package can then be used locally with any changes made in the cloned copy of the aws-sdk-ios repo.

### Requirements

In order to do local development the XCF directory must be populated with the XCF files. These files can be generated from the aws-sdk-ios repo which is expected to be cloned alongside this repo. The Python script which is used to create the XCF files for deployment will be used to prepare these files which are then copied into a folder named XCF in this repo's directory. Then `Package.swift` can be changed to use the local path.

1. Clone aws-sdk-ios to the same directory as this repo
2. Run `local.sh` to prepare the XCF files (this can take a while)
3. Update `Package.swift` to set `buildMode` to `localWithDictionary` or `localWithFilesystem`

The `localWithDictionary` mode will use the list of packages in `Package.swift` while `localWithFilesystem` will read the filesystem for which packages are built and are found in the XCF folder. This option is useful when a subset of the packages are built which takes less time.
