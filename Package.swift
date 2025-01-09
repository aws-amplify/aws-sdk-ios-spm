// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.39.0"

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
    "AWSAPIGateway": "1c74647c46f90df85eba8f761a44c2f9f10e7af7376fb8690f60da76d167ac78",
    "AWSAppleSignIn": "ad58b72348f1cf8049f857813ebbe87c0cebc0af620b068392111986583b355d",
    "AWSAuthCore": "0b1629bb59416f8193a7f77ebe972e7a42887cc533670f164f4476bda5eb9160",
    "AWSAuthUI": "65c63ab5da2884d0ea58f0120cf20b9e01561d636e7816f9c9ef48d23f9e4bce",
    "AWSAutoScaling": "3275e460233357f5eb996e7be36ec82ce70a4edcd6b9d29a53f204c5ef1314a5",
    "AWSChimeSDKIdentity": "9d55d851991c5e45ac8ade4d266d6099f384f108d6cf9d8b1c5ce4c39d43a9e2",
    "AWSChimeSDKMessaging": "923610144b5c162fdfb14d378c87252f8338cf6d606ee2ba2df911c4d49cfb17",
    "AWSCloudWatch": "53eb0949384dbc5b707f89df01ff7e5a641846b68cb2a74939b68babf63a6f8a",
    "AWSCognitoAuth": "8c76fdb5581c7dd78f8b31bd56df6b341563c501012761b101e4221bb7848123",
    "AWSCognitoIdentityProvider": "d8bc99557af220ab33be79e27ff63943cb163ce323dfe2b5bfeb4997675a684b",
    "AWSCognitoIdentityProviderASF": "98603cee6613c0cadc840610e82a8fcccb9b15811442c820dbce64b21d384482",
    "AWSComprehend": "0defed2ee92746f5587d8e7357c06aadca429a0e338039422eead24a4bbce617",
    "AWSConnect": "5ae7de27386e65bb4b9382cb17a77e0310c1f80231f04a0ef67ebbde121d5ccd",
    "AWSConnectParticipant": "ab954132a648867db96c1d487982a2e713d1272decffeb22a79dddb7506468e8",
    "AWSCore": "6006cbf79a36b337d7b25f1ce1993b5faa3f74ba5221d85540c45faef9fd5475",
    "AWSDynamoDB": "f7f4e7360164263e6088379e4812cd2f93e8ef5c96f849c3471f19930de136bc",
    "AWSEC2": "c6f99be1816f778a53e8d52bfff9dcf2d1d8973196da381e5e3e080a41be956c",
    "AWSElasticLoadBalancing": "20e367a2ed02c939eeee5cb788022ce397d52f6a6d92eb961375d84e5c3a0455",
    "AWSFacebookSignIn": "9549a8e96965516914dd9d3d487de5095a1a0fcc86d11a21953a94d95d0813a1",
    "AWSGoogleSignIn": "fc8a6f0434cb2fa4f60a3a175421b7a9e3f83aeea6d6697752044f7f0962b28a",
    "AWSIoT": "48677e32b4587f44773f9275aa2cc188f92bede8d93639e248181484e4be8fca",
    "AWSKMS": "f6c04dc62f913293e0d673a9882d07ff180a48f0f9df67fe4109a61d333d49a4",
    "AWSKinesis": "4f71caa7e762bdc2d332a4266f9e39e14b884af8a9218916081b1598f75972bb",
    "AWSKinesisVideo": "b4f9c1b840191976a3a69044302a449d7b4537d2a7ed0230220e7f594966550e",
    "AWSKinesisVideoArchivedMedia": "d8a692ff885dac58e917cb6265350442da3a14e62b6c8d7930652477b9d98e0e",
    "AWSKinesisVideoSignaling": "d26d6ee0549ca4c95d1b52cff8a42283f625f1a7fb10668cbae932e64ef9592c",
    "AWSKinesisVideoWebRTCStorage": "afa8d886a8a99751dadb3bcf4ef3ee1f50732a5e51f76d79ee5f281a755e005b",
    "AWSLambda": "04ad256f9f13716e1b452dd511f3f2349ff195ed509f83e92266b14046539f06",
    "AWSLex": "70e3aebe0b316a0673ed8244b4bb889ee21177910625c03243fb5d5089d61487",
    "AWSLocationXCF": "d29cae9f56fbb58a5520e4592d2978faa3b66993446aeb2e16f09db9c107db94",
    "AWSLogs": "60238085cceff4ec61079bcdfbbe176c1f0bbd023e22b02fe6ae008e23c6b622",
    "AWSMachineLearning": "449c63046c62a1668368402ef468d606057f852568e806841b697719e6a6295b",
    "AWSMobileClientXCF": "fdde7a2143e140e6c39561f2709da9d622ffae5742ec6014b9a66a59b4d43bab",
    "AWSPinpoint": "b5987aacdfcef0f4bfabdccc45f401aaca00077b95db9eb4819ad4b4582a6afb",
    "AWSPolly": "6340dc9edcdcb12a767b9cc166695e110ee7be9d8a540c19b7312b8272eba56f",
    "AWSRekognition": "7851f417e9dd6d91308bc22af219e2faf4aacb922d6a2a6c973972e47abdc0e3",
    "AWSS3": "835b4ddb46d14aa95e64e5eaa2b9dc17b2fd7fb1b56778566b7ae8ee65f00163",
    "AWSSES": "a6e1ac707e3e19378d1fdf70aa944f63721205b58d4cc35b1dc205170dc260ce",
    "AWSSNS": "631fd1ad4a62eb067ef739be344d3d3c969179953ad16989de633a5ff12717ff",
    "AWSSQS": "a20da54809df1bdfa18e9fa4ca4f297d3a09085a8fe34861cf621e910ff5bdf8",
    "AWSSageMakerRuntime": "e188663b0c70c6a809067b9e9f875821b859d49a20578d497d58dbd773b38087",
    "AWSSimpleDB": "8406fe8340f13ec506c331e54a9743777c9dec5409807011a6b8867f15b2ec24",
    "AWSTextract": "a475667d23e8d3e60252b5014431afd589712e899ae9be2e69ca6f0349850af7",
    "AWSTranscribe": "67ba47e2cad0203a10d44d26bef2a8a3d34b2aea8da4197621582b896e84ac1c",
    "AWSTranscribeStreaming": "697b23208d6777c06d25bade08375c680073186d5a760a5f15ac327fe2f105ac",
    "AWSTranslate": "1310e3196ce6547698f8f62527c28cd1dfce412ab98f17479abfb94de135a63b",
    "AWSUserPoolsSignIn": "ab33b4c75101a0886217a3e35a91bd05835bbd57713309521ccae5eedaa5e6b0"
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
