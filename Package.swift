// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.14"

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
    "AWSAPIGateway": "c1e34435f8b2c88546f52fea4915ea3c1d86cd31270f7b95a5640516e13305af",
    "AWSAppleSignIn": "6d587c8afcf0e17565f0cdffc1056f33f67b089a74043b91e7ec3e6256398f2b",
    "AWSAuthCore": "a5fd492f8390e49aa1b57f16e65d446d9a1d7f3a0c90ace0f242c2d00b166cd5",
    "AWSAuthUI": "5da8a72d17d240512cf7035485ff83e1a1afe403ffff4e4875b408e41c7513d0",
    "AWSAutoScaling": "d562b636ef9a63e702d19d7bd74a3b5779b61214f6be853aaaad071588006ed4",
    "AWSChimeSDKIdentity": "ed2fdc6b18b3e8e4c69f0b5be0a043920c0f6ece409966c2e54cc747e02983ee",
    "AWSChimeSDKMessaging": "40f8bd0e19b0d21ec25daff3d8154d48f20d0d45472b04282b7ed63b70255fa4",
    "AWSCloudWatch": "643ae1da92e048c1a950f59037f26bd015219dc1106fc902332da0ecd9b5a23b",
    "AWSCognitoAuth": "e2ba097b7a21a817a84353a6d0b065202e75b8b40559a88cc94eb2ce95889035",
    "AWSCognitoIdentityProvider": "e0cf3a0255165f06b5daf5c0293b70a080efb7d39a03f4e926acea5ebac0afa1",
    "AWSCognitoIdentityProviderASF": "6967aee255686102dcb95d0d9deb622e533e0556145d4dbe91c2436ef134cd93",
    "AWSComprehend": "f8d8f10eccf6044255d543cb4e6b360889102e509a5a8e86697bdae3e1853d46",
    "AWSConnect": "01c58a4726eda5678754cb6354a5cb65a017dbbf806ed0d7e0ee843e18c2a099",
    "AWSConnectParticipant": "33feb74431bf572c47fd98d21530b1b31b2c987642af8d93bf4bc3c3d08c7521",
    "AWSCore": "c2740fb22a712b189215dcc3914561ede2af4a0b1576f00f1267cb126dbf1276",
    "AWSDynamoDB": "169b600370ad0733e2e303341f1403a6055a0e56975f20c5294e35b90beab413",
    "AWSEC2": "cd4f5f89a7ae1c05f0a30a59013f4293fbf26cee4ba4367c7de1c61572307865",
    "AWSElasticLoadBalancing": "831fd8f6382820bd047bae7505e0958a1a08a6f255cf5ec4af5eab22f90e4a64",
    "AWSFacebookSignIn": "3b50c67623f488a0de2aee9a9d07299e9114f19c484a7218a36056d705e64424",
    "AWSGoogleSignIn": "f7e6a3047959b5a14b16577331089d9d4365861cf1336ad37a86944ad407129f",
    "AWSIoT": "33d8f1a595163d799c0996fec2fd2b69f94794240b645dc9ddb2c09021a70948",
    "AWSKMS": "b15fd2342bfe972371bb7ac4dc494bf29e047f73983010a458d21ab04f64b4cc",
    "AWSKinesis": "f98e2f7b1940ed1876dd6e7e81d7f15f356c466f642b3b7dee427086b5c30be9",
    "AWSKinesisVideo": "0cd6189c4a3cf0b24e88a8d828646d2dde4b5aee83fe98c68d0b80e73b9f7089",
    "AWSKinesisVideoArchivedMedia": "001dab3859dd45d1bbaa422ea0276076fca62c3fc58904f2247eedd6cd97ef55",
    "AWSKinesisVideoSignaling": "81c4cf4ab20e243a03768ce86a6ef8d4fd89d245e19dba72cc3f47f09a76a5b3",
    "AWSLambda": "b0b8fdb977fe3ffa258384e3e43a2b57d2a722ba52b2aae1f369cbbf29db02b8",
    "AWSLex": "db54fe25c74d8e453da65041b24667e6f3631f5ee2dac537b95ddb75192953f4",
    "AWSLocationXCF": "cb7784dba0c5406c0fc4bf313fa1e3ec631f21e0cdcd85095c4a0c9dfa316adb",
    "AWSLogs": "011e0446beab1bbc626c54802aece3d410ed7a83b1ddc74e01788927e0ebdc08",
    "AWSMachineLearning": "9d50b1575c9281880cdc771ba689ba63303382a0e7be437c80213b9e8093ee8b",
    "AWSMobileClientXCF": "ba7e4106a081ff441f09467e823b35f031ba13c9802340e3179cd593b7441e07",
    "AWSPinpoint": "5069516c8092060f2f14fdcd556574c1b0f5282d799a4dddb18caa8819cd288f",
    "AWSPolly": "1f87f99fd6c3e87bb48aeac08be1233a05beb5ee456eeb939cab817c6c777f94",
    "AWSRekognition": "dc0585d47943e7a6b8f6a7fefc16c464955aa803594c0cd1bba8370e03e01357",
    "AWSS3": "df302065b1f6f65e53afe47234de4746632dab3d0c2efab1dac01251a5d87651",
    "AWSSES": "6d2b8d22653e23de009c3d4c5367b5064622d309717a21d265d3db4023aff70a",
    "AWSSNS": "9fbfaff218d029434d60e6f659e44b714b5c7b47c1153dacc6b60c92bff5b4c3",
    "AWSSQS": "736a65398d584df2bf1073ca9e033999939a4fc87acd4303bfd32ab008729fe8",
    "AWSSageMakerRuntime": "3d680b51c13a8f93af7824e40fdde2677f24dfce74483af26ebb5fd8b232365b",
    "AWSSimpleDB": "277685da9b3db5d4ba5aa56e8b5bd45d5ce77d1d7dd8cea99b6648a6cd058037",
    "AWSTextract": "734012db21a96e0b5985a4500a1214aa91ff8eb906c84a121face22783c2e071",
    "AWSTranscribe": "93d7d659921da3a429c76de603ea50601c9168ce900bcc216fab504548634e4c",
    "AWSTranscribeStreaming": "82dc6936a9d77f5a61a725fc42adf2e41e37d60b1c491bfc792f642bcf8c8e6f",
    "AWSTranslate": "b8e61ceb72a3a86718e9c426af52ed818ec681504a27c35b80fa5f3f1171ff47",
    "AWSUserPoolsSignIn": "b1dd050b7a8bb6989353b6059ffb0518bacfb0c8f4dd285faedde5905c6845d0"
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
