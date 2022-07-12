// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.12"

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
    "AWSAPIGateway": "1ba185c6153abb737b4a25bd60380ca9b8ed84bfa61d76b603df6e5f26c30417",
    "AWSAppleSignIn": "39afbd141b6dc94ab4353d7ffc2bb835573f6961cfd45b0280de32473a4a268f",
    "AWSAuthCore": "58f5b610b6701c1577077561dce7af159fcffb5d9761c42ba6d01e1727569c44",
    "AWSAuthUI": "3e6992d1e1f548b854289e819e830ef444f0da7eb47b86066c7445b42214fbe4",
    "AWSAutoScaling": "a732d0841344b5006918d9decfcf8e96a64e40762744d5743b666e360bfda5e9",
    "AWSChimeSDKIdentity": "7d00f7c70c4b357329ea54f40fb87c64db37507328b023fc83dcb77c643ad87a",
    "AWSChimeSDKMessaging": "98aac2e9b4c728093d1a6f2f6e7b10b47d194b10830859366448dc5fc61ff285",
    "AWSCloudWatch": "f3f7ccde36cfdbf3ff7461877aec38bc5d9fee9d4adfbf54bdaaf0d73554656e",
    "AWSCognitoAuth": "e0ebae7eab449cda4e705a4f9128f8052c1e8ff6d2323313dcb8bf69fcddf56c",
    "AWSCognitoIdentityProvider": "5cb90b2ab521245705f2d65a924eaabd21d40a70cb737845dbefe0b38773a251",
    "AWSCognitoIdentityProviderASF": "88719a8190e4e98c2ec4e2896292876ceca2b8b99e17fd7e3e25e5437127d78d",
    "AWSComprehend": "02fb2f86ad30f28816c843e32d8e0b18d1a217e891bb1bd3253b81ff9eb3ba1c",
    "AWSConnect": "17145e6f2da17337973dacd6fddea50980f3d7847eb5e72b12290b1575c7563a",
    "AWSConnectParticipant": "9df031fb8f2540ac08ab79e20570ccc19a6dae815270e6b8bef1f3019ebb0933",
    "AWSCore": "5da77c106523c1e23358eee7f0fa7086d5d5e23a5fc87026ce6090c52b17401a",
    "AWSDynamoDB": "deb0eed92f5287a31e2b00885723e44200f299094749d956d5016f67abb9dd70",
    "AWSEC2": "33efde7256eaf3e4a59a13b379985c777eb793d64bcb39878153c4287a34ab1b",
    "AWSElasticLoadBalancing": "79b896c872cc70c2a2b5c3c633477a933421a830847f9118ea580abdca020c41",
    "AWSFacebookSignIn": "479d63acf1d77ac7d61ba76fd7b7745d024a5a062fd36343dc25e0d747b1f0cf",
    "AWSGoogleSignIn": "40f57d6effc29e6e93bcc53486e7dc8d117573ef7f682ff8451c1b98ed6cee0e",
    "AWSIoT": "7116ada1e187fa74d3d9fda37bde7e7a0344c5a06aa90167f8bbdbfad124cb0f",
    "AWSKMS": "15ce7fae4ee9d96f2bc6a5bb718f215edb65a8bb8dd0ef006fdac7e0bc1d8ec1",
    "AWSKinesis": "07b7d47c6b0b66019dd8ff0a333909d97c6aa4ec245688ac6978dd1a5b2bf00d",
    "AWSKinesisVideo": "ee912649b9eeb4e95beaf253708a22e621091c7600d2c5bf610283e3cde81060",
    "AWSKinesisVideoArchivedMedia": "1866b8f47380a3333ba3b0ba2bb6d93c5ab47390461905a9f776218e1f585b44",
    "AWSKinesisVideoSignaling": "3007d12828903b678a4844ac657ed3c623042d0db15428ad8a306460e91bd644",
    "AWSLambda": "50859613a8cf31ec1c9a103a03b0819c5b4861336bcbb290dcdfbaf24a188ce2",
    "AWSLex": "39449814892d4c678f2552ff9691f89e610a45d6781381e4645628a3eefd64b6",
    "AWSLocationXCF": "3ac51967a59f0da056059e07eab3ba57fa9da7ee01b0d7c8d45192e1b1da1e29",
    "AWSLogs": "aa91421780e51731de01fbd136fe165cc32f9485fb9588804eea1b55223914aa",
    "AWSMachineLearning": "243c8e1e54db9bb8af3b6cc362fe0c0a77af6077cb708416ae020ac8bec29318",
    "AWSMobileClientXCF": "051c3d3eea5a0d60092628ee3ae5876e19bd85b450f5b34dc2b6394fac412107",
    "AWSPinpoint": "dfa951b5b22fca65469a57fe71d34987030c0968d0ce8b7ae21c94fe400dbd97",
    "AWSPolly": "2ae9b81bce325ab451a4d74d19c50de06447f38be9db91a699399fcd6b0a7b81",
    "AWSRekognition": "51c0b2a568c00a625131eebdd9d0f0c468b790fed8b1bc2f86898644547d9077",
    "AWSS3": "beb8d73b0a583fc05ce80eb511824cf5e269e25398f140e212487bcf2197d073",
    "AWSSES": "b1dbd1a3c03615ba5742c81f11ffcc4a5109a87d9b9f6a9f4d903a9e71279894",
    "AWSSNS": "45f545ea36b70f8defddafbe7ecf2ae67d1f85b2e5ed9664a1bc97751b73f02c",
    "AWSSQS": "abbe5715e5dd3454c565fc3bd217fc4ed6a94a3452e794c9a3bcf1a1b6fb880e",
    "AWSSageMakerRuntime": "0adbe7a27b4885faeddc845db28d66f24d1e3fd28c81a88ced8f9a4fa1c51bca",
    "AWSSimpleDB": "3181c5d0145492aa66cc0d18eec2fe782ba66573ad647abb01c80bce0efae500",
    "AWSTextract": "3c657fe760f9577e8ad9cc67e71af574088165aa8eaac2e39cab7f6ccb0f034b",
    "AWSTranscribe": "f745f766e292c664a6228b37988f5096eed4b4dfbb220408d8ef4ca4a0c4ac76",
    "AWSTranscribeStreaming": "961eac868241f38e7ab6d1a731ac30127e1c6a97525a2282cc0fd6cb5ae1fb0b",
    "AWSTranslate": "9b02d7e8ab65f3d8c6859399946cb903fd0bdaeb64d0d108e66a2b094f7df48c",
    "AWSUserPoolsSignIn": "0fe0a5ad3eef1ee2423b70437dc788ec145d4d9def0dd96bb2f7ca93f634b978"
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
