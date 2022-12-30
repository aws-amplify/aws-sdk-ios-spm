// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.29.1"

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
    "AWSAPIGateway": "0c3c5a799c962535ce177a91ee03e6ebdaa03c88cf6967ccb16b1c064f04ba00",
    "AWSAppleSignIn": "e65b82fdd021b77b351d1f87b5d6d0338db959ac294a25ba0e68616387503060",
    "AWSAuthCore": "996f9eadf764125e984307110382d24b98eb1d00b3d98f854a55468e98395bb9",
    "AWSAuthUI": "687b457a02af65417fa46bccb1e209395fc057393f2b240c9e83bd2d235f41a6",
    "AWSAutoScaling": "cba41a13a0c4ae7a98948d58eb87861a05d0d75605c4ac751c92060929efd122",
    "AWSChimeSDKIdentity": "2db1aa5da92b6e77e5108ec5d1f771b43e9988dd207c7396ef8e163c1221a415",
    "AWSChimeSDKMessaging": "6bf65f318616700b486f9da8ab5e1f78efb5d2908e672b823aa74b016a1b893e",
    "AWSCloudWatch": "ba13c9b84652d5b229cc84195a1140582ca4439d27f11c1f5f0ae37ffeb020dd",
    "AWSCognitoAuth": "5359d95f56e8e41b749eb760d31aa0433ec940a5a30ae5fa6a5fa21af474e039",
    "AWSCognitoIdentityProvider": "46df5c50f1a09419d676d30723793814946b47309412321f693c6201619c8445",
    "AWSCognitoIdentityProviderASF": "f107f1c4e997df9a75aa4d1c0c0bcb68ad50456ef9388b44881d923286fa58aa",
    "AWSComprehend": "2e649d9c24fbc2bc74af98052a97c830ab75bc14b9a65155279985a0ee849d39",
    "AWSConnect": "ea8663052cab9417364e6be4236a1cb04ad72f8e983d7b8b72253f7bbd602fec",
    "AWSConnectParticipant": "fa4d84c3ed146b096c8f608c8362942074efb3ca621901c3fd4b75dd20258767",
    "AWSCore": "92e409b6efc6b3fa39de43154c3186eabda08352e454ff2a2f8a57e4b52fe058",
    "AWSDynamoDB": "f3fe8cd9d5657fdd4fe2531c7915903876a383e4409f28a56f7686c4e476ec41",
    "AWSEC2": "da892d835554ad42e305b090f0e908f7fb0470f296fe5759da33eb6b1a3e5605",
    "AWSElasticLoadBalancing": "f3341dce0afab20db38429a011677740153818f4694f1f38833656019960f624",
    "AWSFacebookSignIn": "a57b472d73b18adfc9f7b0ac25bafb12d62e7097f814b4d342152f7c9a7e60b9",
    "AWSGoogleSignIn": "fa6404e6094e10fba394e40b081a7983692fddb955ff7350359959aa7e445195",
    "AWSIoT": "c194a0790aa7f65dca55a75c8c2bdf0a79a0068e4270b794751df8f3c1d14c6c",
    "AWSKMS": "c18a08dfdfb27d6fde53c7861925d3dfe6f489259d46467d5e8d2d414989957d",
    "AWSKinesis": "80535644cf450c9b3c695eb342ee301d71c9b91220b2bfc1aa8aebf2e72e8885",
    "AWSKinesisVideo": "c7cff5d7b6a0c1c54be7e87d1a1616ac693365db06578e718e347c3970f847fc",
    "AWSKinesisVideoArchivedMedia": "f71eb5d2b1ec055b790ba87d51c6b200eda243cd091ce52a308fe081d874d40a",
    "AWSKinesisVideoSignaling": "3c8346387df5ddeac11f547fa701e8e5a1a6d6da78d706e0f0659eb93f925c45",
    "AWSLambda": "718cd01e6552b51e1070b7d2f31f6ce0d491689f47012d7f801fcb9784595d90",
    "AWSLex": "55b34ebe517eb9d1301635f656ed4c018fef67e44883e924287c7922ad0b7e8d",
    "AWSLocationXCF": "ab3b3fa820d8331cb55bac720c3617ab9d72f9988d43761e4352d2765e1d6a67",
    "AWSLogs": "2979d6104ab4332deffbb5f05bc8293fc263c2d0dd3160b71fa197e0801a21aa",
    "AWSMachineLearning": "808c4db2ff7bec4f21e7932195f6ba7ac977486a657ce328824a042563a86104",
    "AWSMobileClientXCF": "cfe1da975e19841968650e2774e679ac41ca01b56261738e4dacc80e9ea79701",
    "AWSPinpoint": "033a52336c1c88b54dec996b8fd9ec8bc3eaacc4d8aac942c45a0d462d4a0e7a",
    "AWSPolly": "55b1b3c4fc23775038568430bdca8fa3e85d539b6ad0e4ac01e144d0b086e6ee",
    "AWSRekognition": "2c2f9368dd8d58134b75e02575d8df2b599cb933d84a898b7c520ebdabed679d",
    "AWSS3": "998a78290ab9ab3bb3d8374158bfa094111a2832a40fddded679f811e163a619",
    "AWSSES": "92f3f2b52d635f9ae7936b6c33db8e5f819bd86142bb3935f8eb80a51691d4df",
    "AWSSNS": "62fe8122eb9eeb87820f4c493cf2b126dc2b7db7b31af948c28a15f7355943e9",
    "AWSSQS": "8b74811938409a994fb4660e6a26d821a1d0ef2b0014d39704508ca50c5757ae",
    "AWSSageMakerRuntime": "09e0e3d9a3fa5359e92a4ece71c81119b0860d892e93a1b5e37dd11e08b58c9e",
    "AWSSimpleDB": "a73c9ae5aad42169a7cec0b5fbf3c4943ab7fc6aa378f027cd2e9130e970ee12",
    "AWSTextract": "a3b1d1294946ae0581bc703c94e5251b35684830a5974fcfc57106aa83ccdce0",
    "AWSTranscribe": "edcc51cbad073f45aa187f5d4c7fff8463a68f2319d4f4502430dad2389c5d56",
    "AWSTranscribeStreaming": "90d801d1d443dc4ef796383fd75a86fd97d6b8c5d1b5db4780d38ac65f69d734",
    "AWSTranslate": "5dae5e944f8ee938b94d9f6ee9334bccb774eb442ec4d0a7c57356e16305334e",
    "AWSUserPoolsSignIn": "2a9462486bb94bcc1a60385e04b25ef4601548a017d8ad910a7d729e7c321d00"
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
