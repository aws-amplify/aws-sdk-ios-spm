// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.11"

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
    "AWSAPIGateway": "317ecbd99a10e32cffffb9931b32fe1da801dc646f3fa83abd411763b31574cd",
    "AWSAppleSignIn": "ff5d6af4dff669cbf9397e816f6542abc577e5a41365983bc63c85a2b182f950",
    "AWSAuthCore": "447ce16292111e33311ff6dd7b49cc8ef58eb45606827e32a6ef9b2aa9e1e6c0",
    "AWSAuthUI": "452004c7bdc675df0e7a111993892b7cee1681c0a9e9a68d9e7f6d5a4455b0b8",
    "AWSAutoScaling": "76676ca570e1986bc51709c4f921ffaadcd1beb8076166e4ba72eda2e7760ca3",
    "AWSChimeSDKIdentity": "ddf09bf457e22e83b15c68d28abdda95a98e9e02002b3afca98d28d631483d65",
    "AWSChimeSDKMessaging": "eb644d28373ce12c4f65f1e1eadbc5d1eac01151b758172b79ef07c56ee70bf8",
    "AWSCloudWatch": "f5d46949ec27571c8f262b30bdf62667bed4d9806addc49bf67c723625644941",
    "AWSCognitoAuth": "cd78008918a38a855fd2017a808e4433cc6c76f753e86547708bb8440e169814",
    "AWSCognitoIdentityProvider": "3373cbf92aecfe13a57b688666e63199639e6106db31005dda08d0634950aba0",
    "AWSCognitoIdentityProviderASF": "bd8d68d906397f7aa1e3bdac52c59db5ec5f63df4cad61ffa6cf55d294ee3671",
    "AWSComprehend": "37a8edce43c545f8f0f7be488d22041cba6261a9b112515ba6844eb442b2a2fd",
    "AWSConnect": "d027c7e92d6da406559505bea915e8d33283da2f3aa4ff0efee3873b0d3252f7",
    "AWSConnectParticipant": "14e2cc649be890d5835e64de47f88358488d344ae8599b81245f97486b982303",
    "AWSCore": "d3cd33bff5a6413f3dd1880c046ff2f80be1688e50233c5a8316aa35f49e98a6",
    "AWSDynamoDB": "3f746b8132bc984280cf749f6fd79a93ad320ca72802f6f41cf14e27f234fe78",
    "AWSEC2": "bc1a30a8145fb9af8f75516f64580c2b0c1849c542bdc3c933603b8d9b651add",
    "AWSElasticLoadBalancing": "78a6d2b560f24fe8aff6c58191a4cbdd47383ccaebb4dc2c80bfe0691bd53d2f",
    "AWSFacebookSignIn": "7454a70750a7662ebb2fa13b78793043eb0e0c273c8bec48d26597fc2e8f873f",
    "AWSGoogleSignIn": "360f9146f5c2f1fb60253e060e4d44647fd0aba8e4472fab08f7e4c0c8545fe5",
    "AWSIoT": "f5a096ed728379659c92c2118be6f287c466c2a05ecb5d0790a4261cfd3ba0ec",
    "AWSKMS": "488f427f3a7b2b8cd46b4eb5df16e0cdbe186cc8b5c3bd6254a7c5290d7c8d6a",
    "AWSKinesis": "865ca29ae1612bc7ba7ed59a913179107e21ef60a1f32d4212ee66c422c5e3a4",
    "AWSKinesisVideo": "0e460a1888a4aa8e99cb691c4b31c4aa5adff3de4eac55e0b2f4b58d772116a7",
    "AWSKinesisVideoArchivedMedia": "6c82628a192117900f3a2718de6a14baaaecaa05556ae5d9843ce7c35230677c",
    "AWSKinesisVideoSignaling": "1d45c57692cbbfaf5e34c17c0469bac8b61aa3cb3914c15ec218cd26508ca7b5",
    "AWSLambda": "d074dd89c8d770f12ee9e8ebd0667d457c85d73997b02376acdebfb447c0a9ce",
    "AWSLex": "4d3ee4dc875b7d0352959a88559c4e6eedaf73fa468bd694435306b00cb3d760",
    "AWSLocationXCF": "cfcf8d4d55eddf2926d0bdaddaa49b96813a43aa6bfa38291394811cac4ec21f",
    "AWSLogs": "785cebfb3dae2c806fa71bd852db99f3cf046acd6381a37429166f019ac5f908",
    "AWSMachineLearning": "ba672740d2db87864afe1b5d9deb6a1185f0e259b219868eda98c585feb5d5b2",
    "AWSMobileClientXCF": "9de20b21b74fc3a506a459f8f84b6756cc2224d11a12c49dd657a20b5375cf36",
    "AWSPinpoint": "0995ddefda7be20eb36c926bfe8a2bf8e12ea4b685070893609eefca1caad13a",
    "AWSPolly": "5203aeaabc99df024541793f68e416ebdc5c687b41a6d2620da1bef6d717f9a1",
    "AWSRekognition": "3ac9ffebeffd38c506c43e93332b78d896b2152c14722e4ac36db9ac2408c247",
    "AWSS3": "6dbe8b7b4a45486dafb4b96e27da42b0e69e4f7a0ad650cbaecad0abee618d12",
    "AWSSES": "c572dd9a5b9b471706ea1a9a66a87270e15ddb5c915f871e0693f2c5afb1d7bc",
    "AWSSNS": "5aa5eaee6c966b30b76562c6da0fe6b6950f2008b67221e0481e35a8ea84afc6",
    "AWSSQS": "61df95e5f5b0461726d5025e0778ed9ef0e5179b3f610ceb2e3e8e90c6fb307e",
    "AWSSageMakerRuntime": "35ca1eb73f47f7533fb61228161d577a7921c92e3d9177e1576c96214d58deed",
    "AWSSimpleDB": "06ab11153d0a33a03d508ed945a06b822f212c42f84e799a2af7a8eb1792d213",
    "AWSTextract": "98b2e9e5d0d895e028f41ec3e192ef6a5e34b13ff9771307dc25a0f2e4c2da6b",
    "AWSTranscribe": "5b7fe33e434b0c6cd7098af1f9f8f159cf366ad08a3571321568a0ce635c3bc5",
    "AWSTranscribeStreaming": "0d5213ff1d3b1785c6dc73e8ea4bb35bcf9a34b2f4432c71bad8744488b93a8b",
    "AWSTranslate": "9777bb42fd73c9fdd526b2b8085ce18a22442f5f922d7d5fb2eaef6c58eafbe2",
    "AWSUserPoolsSignIn": "5cb49da0f2bdef86abc5cf0cc9de18b89655a6aae7e17aa7e8de3125a32c41c6"
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
