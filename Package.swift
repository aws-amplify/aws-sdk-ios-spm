// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.8"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"

enum BuildMode {
    case remote
    case localWithDictionary
    case localWithFilesystem
}

let localPath = "XCF"
let buildMode = BuildMode.remote

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "419a8bc9a8a87e9f186fc02e12c7683705be2a3122efb1ecf01717cdbe058d19",
    "AWSAppleSignIn": "6049a37ff6fa53a864c81e8dad0f65737b7b4d3f5f0c174ce0cd34dc7abc45c4",
    "AWSAuthCore": "42c6b99677bc610b8d6ac222c123a311fc7f6799a14286019809b0f503e862d9",
    "AWSAuthUI": "a9a0a8e7f96ad95d14ec068d4e83df2a2b9624b5a6a61a853008d70dc022bd1b",
    "AWSAutoScaling": "fee94156703314c84f47c538b3265ff1bc155b0a151a6634c0321dca47d20c68",
    "AWSChimeSDKIdentity": "3300e0912c00589c73c714f0a63c1a2b0e14680a7ad75ab8860a6ba53117505f",
    "AWSChimeSDKMessaging": "fd906848ad5a02b0b2075a84954a15f3f8f4c5fbbbb37cb974475243fa669e95",
    "AWSCloudWatch": "a885d1afb0a972f4d79cff219ab73ad9c4ddbd3514d166d53dfc58dbba21189b",
    "AWSCognitoAuth": "1def745a9a42281b5dda0933a6ba111a1d7d275a6de5cad340eafda323c5b06b",
    "AWSCognitoIdentityProvider": "4cd68e1f5de7956f42f572ed3c1a05ae54d96ab570a9a416e51b30487ebe32ac",
    "AWSCognitoIdentityProviderASF": "20364eedbccb7b79d2d427c4cc14b87a3405035f75cff40930bcb0f6dd0b248c",
    "AWSComprehend": "677dc7d3e0ff69f41872866db8a5b0098780893a71636efff44b9daff6c96cf0",
    "AWSConnect": "65a840543038715ce47d9a721a8a8697d972c3e91214309de39db315372efb2f",
    "AWSConnectParticipant": "95d0f61b32f30668502089469f90fbdff7fa14ceedacc3437430356ccaf70349",
    "AWSCore": "336829aa7d325aa8c9804689d81518b0f50c833e08fce72f9e3373b547c8244e",
    "AWSDynamoDB": "6bba452c78b3851e20c11da8f8a52ee88f02571efc396b80b4c86edbde97d7a3",
    "AWSEC2": "6e32c50e58ca63801f828adf3e73faed9847c21c9ecfcad2850665d7dbac9f97",
    "AWSElasticLoadBalancing": "e0bb6773d125124747ac364c911df5b1b1ff11bf6d36c0b7166a62ab289d2f1a",
    "AWSFacebookSignIn": "8652b6f411519597a226d357eb1e8f5d2602fcf48f390d2abdea4a9dc32ef4a8",
    "AWSGoogleSignIn": "c25e5e6b52c7a0e4dcdd62b4cf14a4ee6ffa3c1e17d78c9e145d19f41e1aa45b",
    "AWSIoT": "3e9acbfe59ffca755093f2bf66a8de215e52108bbf1314d48e59167c38ef8c51",
    "AWSKMS": "82666afb96444ebfcace754a1e876a858d2e999f60d500930c3ca141f756ec51",
    "AWSKinesis": "0710ce18aed8cb252baa5f7258120818ae10c13bd22241953f7c830bc7ecd876",
    "AWSKinesisVideo": "2aab0d7547de6db6da70e541c5e727dfc30cd2261d90e6b095beaabd6f2d3546",
    "AWSKinesisVideoArchivedMedia": "40a52f41c9619a7bc50956da73ecce5f6f6971ecaee6ea37fbb6efe2c83c2c8f",
    "AWSKinesisVideoSignaling": "04e89c1633f6242b128faae2f69a1c1809d9d84d40d1e69ec9efdc513a40b3a0",
    "AWSLambda": "6f5e72ef27a709f73ce89594a811fff5d032780727ba305a7b73049242ba872c",
    "AWSLex": "7ded7baa8cd6bf7a66c28fdb67375b339aa83bbef06ae5a835dd229e68af6fb5",
    "AWSLocationXCF": "3ebb2dde8cf92b36bde5ae24d53cb24a4bec31227aa7a64636ba3b152f03ab62",
    "AWSLogs": "59df7e187da0367d06943fe35d2362b529cd3356e4bde099088369b1f557e6cb",
    "AWSMachineLearning": "00be761e9e2bc586a2cb4b455a815143d30f78068b50900527c160bae342a3ac",
    "AWSMobileClientXCF": "7be6a6fb705e4934a78f2233202e3720f1030bbe9f52b6db0c6daab047086c87",
    "AWSPinpoint": "6711f51e5877d945e176790f3b8a389d7ab8dd7fd3ec01b55efcfc81aaed9201",
    "AWSPolly": "3e41d4ac75ad43b17d6c0a68be344f7ed223d629c3ce3b6f3ed47592fc665ceb",
    "AWSRekognition": "18d136e8e7c658a37daf414ecd60d77537b7d13cdea56ec79b763f67579cf503",
    "AWSS3": "f954ca8c2f8278d0bbad4fb04e569812806888d4804055bb02f899714d133102",
    "AWSSES": "3d944b1932a502207f7efbc200c1e42a5472bec25aaf268cb2b22032d46943be",
    "AWSSNS": "fdc6c11db8fef9d0618e5b5aa9910ec012d34d1cd6d2dddaac3688dd39950b39",
    "AWSSQS": "baf261c4844982218639e94cdb403873af65da99f1bea1ef676820d3757ccb3f",
    "AWSSageMakerRuntime": "4a70cc9d0bbe92ec1cd1e4db0dc0e24da92365c63fc86e05b49bf4da66337912",
    "AWSSimpleDB": "b0eebac4aec8ca430644e83c74ec9752ba688f69f76e15970a362a444db8c363",
    "AWSTextract": "32b41954fa325a2283b5b54a874b11976a27944f7e6c31d96767eb1d0a2c29b0",
    "AWSTranscribe": "feb9a4583b1f90b8138e6f996d931c532832dc9adc0da44ab1e32ab760d173df",
    "AWSTranscribeStreaming": "a517e33a47c68ef7d640efae1a1d7124b7f93ede1c7c89cda07caf68e04866e8",
    "AWSTranslate": "11febb7be5d754b583590b4c2d6247e4e8eda6de18a976a4a8cc460f5798d542",
    "AWSUserPoolsSignIn": "e0cd18cca3cdd7996e9ed88305284503ce37df44c8b005dec45cd4c84e67c32a"
]


extension Target.Dependency {
    // Framework dependencies present in the SDK
    static let awsCore: Self = .target(name: "AWSCore")
    static let awsAuthCore: Self = .target(name: "AWSAuthCore")
    static let awsCognitoIdentityProviderASF: Self = .target(name: "AWSCognitoIdentityProviderASF")
    static let awsCognitoIdentityProvider: Self = .target(name: "AWSCognitoIdentityProvider")
}

let depdenencyMap: [String: [Target.Dependency]] = [
    "AWSAPIGateway": [.awsCore],
    "AWSAppleSignIn": [.awsCore, .awsAuthCore],
    "AWSAuthCore": [.awsCore],
    "AWSAuthUI": [.awsCore, .awsAuthCore],
    "AWSAutoScaling": [.awsCore],
    "AWSChimeSDKIdentity": [.awsCore],
    "AWSChimeSDKMessaging": [.awsCore],
    "AWSCloudWatch": [.awsCore],
    "AWSCognitoAuth": [.awsCore, .awsCognitoIdentityProviderASF],
    "AWSCognitoIdentityProvider": [.awsCore, .awsCognitoIdentityProviderASF],
    "AWSCognitoIdentityProviderASF": [.awsCore],
    "AWSComprehend": [.awsCore],
    "AWSConnect": [.awsCore],
    "AWSConnectParticipant": [.awsCore],
    "AWSCore": [],
    "AWSDynamoDB": [.awsCore],
    "AWSEC2": [.awsCore],
    "AWSElasticLoadBalancing": [.awsCore],
    "AWSFacebookSignIn": [.awsCore, .awsAuthCore],
    "AWSGoogleSignIn": [.awsCore, .awsAuthCore],
    "AWSIoT": [.awsCore],
    "AWSKMS": [.awsCore],
    "AWSKinesis": [.awsCore],
    "AWSKinesisVideo": [.awsCore],
    "AWSKinesisVideoArchivedMedia": [.awsCore],
    "AWSKinesisVideoSignaling": [.awsCore],
    "AWSLambda": [.awsCore],
    "AWSLex": [.awsCore],
    "AWSLocationXCF": [.awsCore],
    "AWSLogs": [.awsCore],
    "AWSMachineLearning": [.awsCore],
    "AWSMobileClientXCF": [.awsAuthCore, .awsCognitoIdentityProvider],
    "AWSPinpoint": [.awsCore],
    "AWSPolly": [.awsCore],
    "AWSRekognition": [.awsCore],
    "AWSS3": [.awsCore],
    "AWSSES": [.awsCore],
    "AWSSNS": [.awsCore],
    "AWSSQS": [.awsCore],
    "AWSSageMakerRuntime": [.awsCore],
    "AWSSimpleDB": [.awsCore],
    "AWSTextract": [.awsCore],
    "AWSTranscribe": [.awsCore],
    "AWSTranscribeStreaming": [.awsCore],
    "AWSTranslate": [.awsCore],
    "AWSUserPoolsSignIn": [.awsCognitoIdentityProvider, .awsAuthCore, .awsCore]
]


var frameworksOnFilesystem: [String] {
    let fileManager = FileManager.default
    let rootURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
    let xcfURL = rootURL.appendingPathComponent(localPath)
    let paths = (try? fileManager.contentsOfDirectory(atPath: xcfURL.path)) ?? []
    let frameworks = paths
        .filter { $0.hasSuffix(".xcframework") }
        .map { xcfURL.appendingPathComponent($0) }
        .map { $0.deletingPathExtension().lastPathComponent }
        .sorted()
    return frameworks
}

var frameworksFromDictionary: [String] {
    frameworksToChecksum.map { $0.key }.sorted()
}

let frameworks = buildMode == .localWithFilesystem ? frameworksOnFilesystem : frameworksFromDictionary

func createProducts() -> [Product] {
    let products: [Product]
    if buildMode != .remote {
        products = frameworks.map { Product.library(name: $0, targets: [$0]) }
    } else {
        products = frameworks.map { framework -> Product in
            if depdenencyMap[framework]!.isEmpty {
                return Product.library(name: framework, targets: [framework])
            }
            // If framework has dependencies, create a `<framework>-Target`
            // library that is used to link framework target with its dependencies
            return Product.library(name: framework, targets: ["\(framework)-Target"])
        }
    }
    return products
}

func createTarget(framework: String, checksum: String = "") -> Target {
    buildMode != .remote ?
        Target.binaryTarget(name: framework,
                            path: "\(localPath)/\(framework).xcframework") :
        Target.binaryTarget(name: framework,
                            url: "\(hostingUrl)\(framework)-\(latestVersion).zip",
                            checksum: checksum)
}

func createTargets() -> [Target] {
    let targets: [Target]
    if buildMode != .remote {
        targets = frameworks.map {
            createTarget(framework: $0)
        }
    } else {
        targets = frameworksToChecksum.flatMap { framework, checksum -> [Target] in
            var targets = [createTarget(framework: framework, checksum: checksum)]

            // If the framework has dependencies, create an additional target that links the
            // framework and its depedencies using the previously created product.
            if var dependencies = depdenencyMap[framework], !dependencies.isEmpty {
                dependencies.append(.target(name: framework))
                targets.append(
                    .target(
                        name: "\(framework)-Target",
                        dependencies: dependencies,
                        path: "DependantTargets/\(framework)-Target"
                    )
                )
            }
            return targets
        }
    }
    return targets
}

let products = createProducts()
let targets = createTargets()

let package = Package(
    name: "AWSiOSSDKV2",
    platforms: [
        .iOS(.v9)
    ],
    products: products,
    targets: targets
)
