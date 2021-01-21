# Swift Package Manager support for AWS SDK for iOS

The Swift Package Manager support for AWS iOS SDK provides the required Swift Manifest file that link to binary targets for the SDKs.

## Setup

To get started with the AWS SDK for iOS, check out the [Developer Guide for iOS](https://aws-amplify.github.io/docs/ios/start). You can set up the SDK and start building a new project, or you integrate the SDK in an existing project.

To use the AWS SDK for iOS, you will need the following installed on your development machine:

* Xcode 11.0 or later
* iOS 9 or later


## Adding AWS SDK iOS via Swift Package Manager

1. Open your project in Xcode 11.0 or above

2. Go to File -> Swift Packages -> Add Package Dependency...

3. Enter "https://github.com/aws-amplify/aws-sdk-ios-spm" into `Enter package repository URL`

4. Pick the latest version and click `Next`

5. Choose the packages that is required for the project and click `Finish`