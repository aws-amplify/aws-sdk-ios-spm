// swift-tools-version:5.3
import PackageDescription

let latestVersion = "2.22.0"

let hostingDomain = "<TBD>"

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

