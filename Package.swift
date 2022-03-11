// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.3"

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
    "AWSAPIGateway": "f74252d0be5f3f150ba5129c1c7e5f56adfc6ee1d0b3201e0b2f6a137e7e9712",
    "AWSAppleSignIn": "faa7d5b661a890af26c164967feef60c5b3109c70df2bce0c2d2bab94dfa281f",
    "AWSAuthCore": "e143db787a913f7d853bcd61b6282d689cdc608b14c448f7543008a51c6a385c",
    "AWSAuthUI": "92e756705d1bd0402e4fc2add5c1514364db1397eae649201fc36c3cb12ba935",
    "AWSAutoScaling": "5d02bfcaa63285ef219743f2738b08e0b5f89f3ba0cdd6177ddbe4a7b334ee39",
    "AWSChimeSDKIdentity": "b9fa221e525e4cd770b74006ed658900712e3cd033550b37800e5c5991ef63d8",
    "AWSChimeSDKMessaging": "04356c8988bad939725f3b01ccdb7a23be78da9949e6a5d705202fb36416e58f",
    "AWSCloudWatch": "d6b85d96ceefa23d5361fb539e8322d32a53088e12041edfa864df39a6eef693",
    "AWSCognitoAuth": "d79c9a7ffcc6172aed34e6c9b11e9d3fa66d42ee3cf8204ba68ea2f74b552689",
    "AWSCognitoIdentityProvider": "5809dd4dd6adc468c844a93e28fc6c1b28a314a7e31b0d2072463bc320a7f67b",
    "AWSCognitoIdentityProviderASF": "1041f917b87bb743dbf2f199db8b001f7acad6474f338dc5fcbaf62c577fdcd8",
    "AWSComprehend": "16930e2d2e437304c959d4f8515e2272b6b1d357dc400ae8b92b486c71e415c1",
    "AWSConnect": "b255a4bf503fa007590cd3d8066e42bac3b415ca71b2f1fc06ca79f18e585c73",
    "AWSConnectParticipant": "680fdfe769975939cee80bd9e93b2884352ee5eb5b6cc901c95ddb6f7bb64b48",
    "AWSCore": "fc80da22bcf2d3e4e619ff8c991dccd2abfd99d6453cf1a08df0d3408c92de8e",
    "AWSDynamoDB": "a88f1ddc24a0fa150bcc48594492cc11ff29a37979d022d31ba8b036c3c97e00",
    "AWSEC2": "aeaa3aca861c8e36bc2c7f489ff710f1e41db2919f9ccfc233fdafe5348045e6",
    "AWSElasticLoadBalancing": "f1e084cf40793c1abb96dc9dbfd0b7a73a3cd773fb756378fe484c82a136a380",
    "AWSFacebookSignIn": "1fc50f2b3d8cd7d72e91be0a3821c0269535b6fcd16e620d6714eccce96a74f6",
    "AWSGoogleSignIn": "e70e30357927cee29c616e8827c4a72fb9be67239785ad2ae838b89b5083c4fe",
    "AWSIoT": "bffd3508a1e8e57b5a04642902dcb49a5d3e11d25ef140f9a45ec16c75609bfc",
    "AWSKMS": "a1bec138d4f518597eb04e29a212d0a05adb74d9b7a040c151b5c97c27b315c5",
    "AWSKinesis": "da931f77dcd5fe894d7f8126210e99c236aad701c9d07deeee4456ababf64ce3",
    "AWSKinesisVideo": "853020e11f3c6454ba9a3ee17b6db6556e372d74c0ca82e8b8d2510a72e6730d",
    "AWSKinesisVideoArchivedMedia": "04ba8d23a71a5f3c6c05f1ffe1a65fba3bbff4e6e0d6aea6bd3c12142344b53c",
    "AWSKinesisVideoSignaling": "42a2a507fda2a5ab03973c609a4f9f0eb7123ee0e38f138e8a1f45d37f272531",
    "AWSLambda": "1d4005c29873cfd07098f1f05271029cbda2156c8b4312c34144d2fa382adef8",
    "AWSLex": "87ccbeb342f8825744d4accc6a4c212b6f97cd1c1d71dd7349d473a492c6781a",
    "AWSLocationXCF": "eb3b796f4642c7aec52d2d32bded57427cc8b226ce88d92df621cd198a4c5ecc",
    "AWSLogs": "5b1826c4889b697723a7dfeac842c572c4b4cae62ee517714486c5e11af5fb24",
    "AWSMachineLearning": "40a3481c414ec4d431f1e1d898517e2e41b059c7c0c49079caaff8d4199e59ac",
    "AWSMobileClientXCF": "2321268b892437268db92f45002da179e0b8730245d669f85133fc6558237bbd",
    "AWSPinpoint": "d3941a69f9085f3885a5e38214488d7eedd1f6fd16748a117795a43c0f85522a",
    "AWSPolly": "3980e88b4b4b6d0fc63a82b859679e31d8bfbdfd1a2d08db2c2974cc415400fc",
    "AWSRekognition": "6769f0c7af56dc8ca86ef8efa808b942e0b1ada8c14f6ab45ccad46375bb10e0",
    "AWSS3": "b795be2c5b473ca5a491dc73b846d9724c8f3b0f92251a11654723f3424291f5",
    "AWSSES": "fbe5dacff6e0d2541c46e9156c12c26a4e76f457c48064aa23e0c69b0f5c3c58",
    "AWSSNS": "47f4258de03cd34d50d00cd3ce45a5b29eaac6b59aa0693952a01943e549b1a6",
    "AWSSQS": "3f6151a75d22bab3b500655e86b223b9306569ba718eb99296528ceacc7f7f74",
    "AWSSageMakerRuntime": "6438df653840312c468cf4db9200961be2bd09dc19fbcad35bc00f8d3a677a6d",
    "AWSSimpleDB": "106aed9507f70fbebaafac5f857a075a809cac7192bf93556e87b032e78e913c",
    "AWSTextract": "896c0723ff24487213d5e45a5c3367173ade88ac1d8cf3652fae8e66c8978c1c",
    "AWSTranscribe": "5ed9cecf3271307bd683c344cfae30158679faa9b3404b55f2984f4ac6218ada",
    "AWSTranscribeStreaming": "96096029b85e8f77196571e5ef6374e512208a4881f8472aab44db3fb28d9140",
    "AWSTranslate": "f5fbaf67b1c13c5ec3deb14856605bc03960f611b335bb575a882e812a270edb",
    "AWSUserPoolsSignIn": "abd84cf9056d24e6696e7a381c74fa6a97c544c9a97cdaaed5e3e4fa6554ecc5"
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
