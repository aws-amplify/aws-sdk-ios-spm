// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "1.99.3"

// Domain where the release artifacts are hosted.
let hostingDomain = "<TBD>"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "SHA256_CHECKSUM",
    "AWSAppleSignIn": "SHA256_CHECKSUM",
    "AWSAuthCore": "SHA256_CHECKSUM",
    "AWSAuthUI": "SHA256_CHECKSUM",
    "AWSAutoScaling": "SHA256_CHECKSUM",
    "AWSCloudWatch": "SHA256_CHECKSUM",
    "AWSCognitoAuth": "SHA256_CHECKSUM",
    "AWSCognitoIdentityProvider": "SHA256_CHECKSUM",
    "AWSCognitoIdentityProviderASF": "SHA256_CHECKSUM",
    "AWSComprehend": "SHA256_CHECKSUM",
    "AWSConnect": "SHA256_CHECKSUM",
    "AWSConnectParticipant": "SHA256_CHECKSUM",
    "AWSCore": "SHA256_CHECKSUM",
    "AWSDynamoDB": "SHA256_CHECKSUM",
    "AWSEC2": "SHA256_CHECKSUM",
    "AWSElasticLoadBalancing": "SHA256_CHECKSUM",
    "AWSFacebookSignIn": "SHA256_CHECKSUM",
    "AWSGoogleSignIn": "SHA256_CHECKSUM",
    "AWSIoT": "SHA256_CHECKSUM",
    "AWSKMS": "SHA256_CHECKSUM",
    "AWSKinesis": "SHA256_CHECKSUM",
    "AWSKinesisVideo": "SHA256_CHECKSUM",
    "AWSKinesisVideoArchivedMedia": "SHA256_CHECKSUM",
    "AWSKinesisVideoSignaling": "SHA256_CHECKSUM",
    "AWSLambda": "SHA256_CHECKSUM",
    "AWSLex": "SHA256_CHECKSUM",
    "AWSLocation": "SHA256_CHECKSUM",
    "AWSLogs": "SHA256_CHECKSUM",
    "AWSMachineLearning": "SHA256_CHECKSUM",
    "AWSMobileClientXCF": "516947ea6c9888cedf92f8ea66723b0836b5603d0bf24e21dc75caffefd43883",
    "AWSPinpoint": "SHA256_CHECKSUM",
    "AWSPolly": "SHA256_CHECKSUM",
    "AWSRekognition": "SHA256_CHECKSUM",
    "AWSS3": "SHA256_CHECKSUM",
    "AWSSES": "SHA256_CHECKSUM",
    "AWSSNS": "SHA256_CHECKSUM",
    "AWSSQS": "SHA256_CHECKSUM",
    "AWSSageMakerRuntime": "SHA256_CHECKSUM",
    "AWSSimpleDB": "SHA256_CHECKSUM",
    "AWSTextract": "SHA256_CHECKSUM",
    "AWSTranscribe": "SHA256_CHECKSUM",
    "AWSTranscribeStreaming": "SHA256_CHECKSUM",
    "AWSTranslate": "SHA256_CHECKSUM",
    "AWSUserPoolsSignIn": "SHA256_CHECKSUM"
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

