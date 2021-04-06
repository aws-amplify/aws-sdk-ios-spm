# Swift Package Manager support for AWS SDK for iOS

This repository enables Swift Package Manager support for the AWS Mobile SDK for iOS by vending a Manifest file (`Package.swift`) that links to binary frameworks for the SDKs.

## Setup

To get started with the AWS SDK for iOS, check out the [Developer Guide for iOS](https://aws-amplify.github.io/docs/ios/start). You can set up the SDK and start building a new project, or you integrate the SDK in an existing project.

To use the AWS SDK for iOS, you will need the following installed on your development machine:

* Xcode 11.0 or later
* iOS 9 or later


## Adding AWS SDK iOS via Swift Package Manager

1. Open your project in Xcode 11.0 or above

2. Go to **File** > **Swift Packages** > **Add Package Dependency...**

3. In the field **Enter package repository URL**, enter "https://github.com/aws-amplify/aws-sdk-ios-spm"

4. Pick the latest version and click **Next**.

    **NOTE:** The AWS Mobile SDK for iOS [does not follow Semantic Versioning](https://docs.amplify.aws/sdk/configuration/setup-options/q/platform/ios#aws-sdk-version-vs-semantic-versioning).

5. Choose the packages required for your project and click **Finish**
