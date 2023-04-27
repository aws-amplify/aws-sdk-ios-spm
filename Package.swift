// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.31.0"

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
    "AWSAPIGateway": "61ff2f790ee8b2a7d6aae2dde2929563b1523032809bbabd56a8b2c09d0881bf",
    "AWSAppleSignIn": "acad295e617328417cb944905f527e3ffc38fa3905bbd69d55a9a1f316f17ed6",
    "AWSAuthCore": "3ebab6d8320c477459e6bdc93bcbd126e634a168ee3b93ef25acbd55b0fc9f69",
    "AWSAuthUI": "091e93330954ba66bea266382f2a0da2e053c9898c2b16373807360d786a12ac",
    "AWSAutoScaling": "6d83506c60c4749636c5958042235d586997373c04eaaf87becf3e1bfeb64ea0",
    "AWSChimeSDKIdentity": "ad8db931975012597ff2b6fcf9a16b2825cd0838fbcb0076ffcc42f7296f0e53",
    "AWSChimeSDKMessaging": "6f1e7f5a42181cbb8a4eb4173f8f39094715eba38b2ace8d4ad6969ac4669ac2",
    "AWSCloudWatch": "19aec5f6ae84da1f60b75dd2d53eb31770fa296ad9f5baf1579905411bb81cda",
    "AWSCognitoAuth": "f926244c20a7c526220db8f01e059b526053402f637f5f359680592326f5f39c",
    "AWSCognitoIdentityProvider": "7acb2d271c6786e1c1932c5ba910f26b75564122cee55b57c26d1a2fe3805b5f",
    "AWSCognitoIdentityProviderASF": "d0aa8b450cdbb424a6160e8c9c02e058b55b38275f8a642edd59dc173a918454",
    "AWSComprehend": "cce4266734c8646a96f55abd6d94bc2b86f0814d6e44633fdf7cc6f7282cd5d8",
    "AWSConnect": "e14b3c370140be980cd6ed1fb05a78fd9a82884e2a70e2152c4e0e9b4fdbe8e1",
    "AWSConnectParticipant": "c053f44cc37aedcbe1fd33d0bfcc526536b5e9f5979ecb4934ba7097dd99dd27",
    "AWSCore": "230392401bfbeaced3ffb51b975f561d5bc013e4fd95dd2df180d180bc437198",
    "AWSDynamoDB": "239aafd06573c7cb06b272c2703a9a8a6c0190b1131ac6e5041cdade84575a81",
    "AWSEC2": "60756209c15ebc1247efcf047e793449b0e99a5f99c159985961e815e1fa70c8",
    "AWSElasticLoadBalancing": "191ae480002df36164f9e22feb6d20a4b281321689fb06cb763331ea1947a319",
    "AWSFacebookSignIn": "221f6d904c122bc3547d10d19e54f42116b1af658686d033893eab5101aedc49",
    "AWSGoogleSignIn": "de3ff7f3542bbf280913cababddd2e8c5e39f3034dfaab4446157ab14fe11c63",
    "AWSIoT": "9e12df08940eb1ca20aec1f5d7a4362fd65b48e0294669fd1b443bcb2d3682a1",
    "AWSKMS": "47e897d0c42effaf608f10f6603212b261a67a60b5a38864e443e504ecda752f",
    "AWSKinesis": "7a911e1e1a356a1848685c1ba8870944928e6956187cd480b88125073cbd3eae",
    "AWSKinesisVideo": "c0abca0d7ef2a9364afdb7458319b9852f4b7daa44605dd7d81d2e8f6051d411",
    "AWSKinesisVideoArchivedMedia": "ef244d493c85d6383f86e54997e538890f68df3fd7031605a6700574f8e2546b",
    "AWSKinesisVideoSignaling": "72301cfa29d4c985875b46ab99ca0164def2eee398c2f4221b5cb81a39671f5b",
    "AWSLambda": "9822186d007b002b50211881551254a14b1eceda6526219efd67767e765ef484",
    "AWSLex": "a0f3a6eb22859b5e434024f696ca0c485351e7650a9589aa43395b4fe2b2e98f",
    "AWSLocationXCF": "ae3bb7e2f191438872dee7fbe8be8fc28181092fe718e0a6bd8ece1a6828868c",
    "AWSLogs": "dd4a1c47ed281472255a45778fdf83a9a79befd90d5ed0a754d48505bc41d0f4",
    "AWSMachineLearning": "aac1527af729d32b321180e55f0deabe0d68c15e03efef644b2d9442b9368f10",
    "AWSMobileClientXCF": "38a3508a37f3435411db63d199b00cc5a3b8564782a6784978b96c4e65cd96b4",
    "AWSPinpoint": "0ae39ff0e0260a2357cc919e66c47ab8f3e4e5accd6206f731a44c2943a27745",
    "AWSPolly": "7035600ed3a261535f83def62cf4948d1e5bcb1f85743aef527141b9a85590de",
    "AWSRekognition": "16c77118c7e25255930774c74bb53141c3ac5c7b67da520d946e7546b4c69fea",
    "AWSS3": "37ee215ee95c8caad19aa6625fae4a4dccbbe283bac594af7352e5d17aeccda5",
    "AWSSES": "0946e3b456dce9fd9584386ff3f07e528eb1250db8ef9515f36f562a2d974034",
    "AWSSNS": "1e591c8b0a736972983c5c4d953e3143e17043bed70f50d611671883a2057765",
    "AWSSQS": "eafd350c2642e0f7413c2ad7939642f0605d2e84a6d6393a0315af8443d1c4cd",
    "AWSSageMakerRuntime": "dee6e36933048086b016b91ceb4576d4cb070a6244fc65ebe621e58a72011a94",
    "AWSSimpleDB": "b68b522a18ba4369c7127e8ddce821bab2c42f8df486bc94901214363e646ab0",
    "AWSTextract": "2348193e7c33c320e3e2a352e79255d378f5c54cde8f4c9b5f949b5e6acce8ee",
    "AWSTranscribe": "713662e4a2fcd947cd0c812618dcfacf9ea68af985b7663c5edb155c3856831c",
    "AWSTranscribeStreaming": "d9f766914a245d6816f57da9dcf75f3b9e92b9c5a8f0a1ee17185f9a9c4a4a3b",
    "AWSTranslate": "a6f7bfbc0a77e05da94e9cb48f9596a985bea73c351a7d9d14f29f0e1bbdb669",
    "AWSUserPoolsSignIn": "4ac7a3cc71192435213948ba3051905002c436f541bf162b91b1c284d6c9eef9"
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
