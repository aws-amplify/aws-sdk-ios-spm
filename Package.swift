// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.34.2"

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
    "AWSAPIGateway": "7df54108b82cfa440a4041d3a54ba5ba8513e6dfcca77384bc602e6faa4f023d",
    "AWSAppleSignIn": "d9edbc6193a10fec8dc0bd564ca58a5f563e0c1573c9b2bee03f2a13bbfdd524",
    "AWSAuthCore": "5e7fb54b4a8fcbb90ee66638e314e18263a4d3befd60760a6d3558c2b9ebea44",
    "AWSAuthUI": "d23ba6ffc8710ffa74982de8aa622cbadae88e31ea877cb4c4bc94a63f3a13aa",
    "AWSAutoScaling": "b707d066579ba312652d604772974baf5a12f712aab91d10296ec06ef2ce4492",
    "AWSChimeSDKIdentity": "94d9bc8380db64d07cd0f623639a904f49b11195ea3904ec3420d5b9ceb5a8dc",
    "AWSChimeSDKMessaging": "1030322e7a5091480a5eb00a9d076904ef0191ed1b7096c2efc1a587849e5a73",
    "AWSCloudWatch": "6c037bf1b94d23672f9fc8dc711ac5f5d3d2830add572f9c3b11c38d00ef2178",
    "AWSCognitoAuth": "122a64d44bf8438ef782e9a28ad832f935fb7d9dd6e99a88a3da15bbc9ecd37e",
    "AWSCognitoIdentityProvider": "d3c2b187f38a0454242f0df152d1a8758050cff5c3cff4e8efbf25a963a0c19f",
    "AWSCognitoIdentityProviderASF": "a8f668ae7a097646320cb36bf265ebadfcab5fc83c19fa045badbf6137c07fb0",
    "AWSComprehend": "6381386a35cec3774e68b0aad1f7ee2944ea2851f7337f3aa6d10601cdbe04d2",
    "AWSConnect": "a78c497ea4ba8576dd343849ae3035bdacc646c7fb03560e11c8444b0d786e86",
    "AWSConnectParticipant": "99d559b27bae8a28b785cb4ece0f7db518d5ddf7b6357029ded4a2d723382baa",
    "AWSCore": "e3b30f044f546497116fc718867d05533bcd273716fc9accb75959ff1e9e93de",
    "AWSDynamoDB": "5ed75b192f548b9e7d191aaed036843812e9f9c0cdab6d2f20b21fa2e49af697",
    "AWSEC2": "3b4424ee7f020dfa1f46393fe667ca174ad49c2e3d962142e27f107dccf1b8e0",
    "AWSElasticLoadBalancing": "3afe8785c0d927e4e67d5f57460d0c280f8de3c596c2b724b4cccade4de3e5ff",
    "AWSFacebookSignIn": "a006a268eef414862449398f72beec25dd4c9f50d69e07c9a474aee935636f6b",
    "AWSGoogleSignIn": "3a05cd36810cb76ed4583d071485145ee5e1d685e7c35dc368abca4f17203def",
    "AWSIoT": "8fb9f93f243aa05591d1e2d18f902d79706fb6d1025cf6a5f05a2d7df67c35c8",
    "AWSKMS": "652783d344087e565b2a09daedfdb902383aff08e007c35bfd62bf5bd29a557f",
    "AWSKinesis": "fe151ff9d0a8cde28f746c7e2f3e6af83fc5ad5384f75d54c91e6581b520f628",
    "AWSKinesisVideo": "739584a4513a48039b588cf24f655f8484ced180b587a3993a64d9655919b5d5",
    "AWSKinesisVideoArchivedMedia": "e602848fb1dae08593244453ea890d6f61540c57d6a694b0a13c892b22d9ef08",
    "AWSKinesisVideoSignaling": "deefd5b5351ed57e491958e5265bfde9a6cef29fcad2c599320e1ef3ab90c00a",
    "AWSKinesisVideoWebRTCStorage": "0a2530576f74c517f00763b971dc9e11e23c6bc53aa3274bd7692d912e565e10",
    "AWSLambda": "eb1207412bca4966866c5b66166c6e9a8a5c7a50ed8dc54f921c7b88adb4f74b",
    "AWSLex": "58bdd4ef8bb43f68c8cb24e62ad1a0d2bc0d4e539363e94b334445ef8e48365c",
    "AWSLocationXCF": "9068bab841d338f73cf77306799e5c1bb0781c9871cc5e456e52273b52994533",
    "AWSLogs": "59b9ed0462cfad8254a4f5c8a7c55793c0aa384c55d05cf785fc4b58f3d7467a",
    "AWSMachineLearning": "74399c7da350032d38758207cb306170414363513aefae55e406cc2b5fc032a2",
    "AWSMobileClientXCF": "61dcc3d2fd3f092272d831e4fb7fbad01397d13b673978c85f6b67af971a0439",
    "AWSPinpoint": "f4d3700281c013c2d7fa99c18422d3e52765f7daed8069aa67b4b586e44c164d",
    "AWSPolly": "41ce468cd0e83dadb1f4454397b6773db56b4188cc720632a78b8d4dc36633de",
    "AWSRekognition": "ef95d75859c3a610b5b856d6a6de5e4fd8c5b9f9a8d2e5714141ce1787ca9cf0",
    "AWSS3": "86465643a00e293b0a706e7760dc9c1322d3f4c498d5369e9def93aa35acd141",
    "AWSSES": "6572c1b36af8d9eff3ab54ec7e16f0677d5f062b301dc30e50f14c987d4da689",
    "AWSSNS": "e5f1fbafd6530c0d940de89f7900b7fb8fec8c509d38af2e6077291ffc932a01",
    "AWSSQS": "627e4363466a192065d8b5fd5f3159a87852bb11c371e0d75c0ff890f59636fe",
    "AWSSageMakerRuntime": "94c873f85c0ae35911f7a408cfff24b2cdc4ebec15c1a23cf7a970fa30031411",
    "AWSSimpleDB": "c6874a27835800a59ebda5a732c565e6d2b24014c88a14e8987bd2ea545d34e9",
    "AWSTextract": "35bf00f8b9521238ca04169760466438d45d148e5a4d7931f78968de40e99981",
    "AWSTranscribe": "5e7edeaae91b5bef0f45f1f7d457ad5c6b053f4be99b310532a05e39e1b54e28",
    "AWSTranscribeStreaming": "edcdc537e0d9e503a8acb21a2235a3b2318cf98a45ce7ec2b984d471610c93f9",
    "AWSTranslate": "2cbb804270f2d838cec441cbf6704ecd3ad537f6e8a9e16fafe4b318640aea83",
    "AWSUserPoolsSignIn": "dbf0c8f1067d87beeee54fef92a2a42af5672229376b1421927140a153d08bb1"
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
    "AWSKinesisVideoWebRTCStorage": [.awsCore],
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
