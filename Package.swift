// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.22.0"

// Domain where the release artifacts are hosted.
let hostingDomain = "<TBD>"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "",
    "AWSAppleSignIn": "",
    "AWSAuthCore": "",
    "AWSAuthUI": "",
    "AWSAutoScaling": "",
    "AWSCloudWatch": "",
    "AWSCognitoAuth": "",
    "AWSCognitoIdentityProvider": "",
    "AWSCognitoIdentityProviderASF": "",
    "AWSComprehend": "",
    "AWSConnect": "",
    "AWSConnectParticipant": "",
    "AWSCore": "",
    "AWSDynamoDB": "",
    "AWSEC2": "",
    "AWSElasticLoadBalancing": "",
    "AWSFacebookSignIn": "",
    "AWSGoogleSignIn": "",
    "AWSIoT": "",
    "AWSKMS": "",
    "AWSKinesis": "",
    "AWSKinesisVideo": "",
    "AWSKinesisVideoArchivedMedia": "",
    "AWSKinesisVideoSignaling": "",
    "AWSLambda": "",
    "AWSLex": "",
    "AWSLocation": "",
    "AWSLogs": "",
    "AWSMachineLearning": "",
    "AWSMobileClientXCF": "",
    "AWSPinpoint": "",
    "AWSPolly": "",
    "AWSRekognition": "",
    "AWSS3": "",
    "AWSSES": "",
    "AWSSNS": "",
    "AWSSQS": "",
    "AWSSageMakerRuntime": "",
    "AWSSimpleDB": "",
    "AWSTextract": "",
    "AWSTranscribe": "",
    "AWSTranscribeStreaming": "",
    "AWSTranslate": "",
    "AWSUserPoolsSignIn": ""
]

var products = frameworksToChecksum.keys.map {Product.library(name: $0, targets: [$0])}

var targets = frameworksToChecksum.map { framework, checksum in
    Target.binaryTarget(name: framework,
                        url: "\(hostingDomain)/\(framework)-\(latestVersion).zip",
                        checksum: checksum)
}

let package = Package(
    name: "AWSiOSSDKV2",
    platforms: [
        .iOS(.v9)
    ],
    products: products,
    targets: targets
)

