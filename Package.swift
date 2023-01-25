// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.30.1"

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
    "AWSAPIGateway": "ab152487a391f931c2407d2ed16e4403ff79d91da1d7e73f8bf36190820a6a84",
    "AWSAppleSignIn": "7e3046f0d077d24792a04ebcc9d2584cdbd5b262ed8fb5aaf2bdde63589c351f",
    "AWSAuthCore": "f965812b661945fe63b43260660ff7ede3400380100210743582dec8bd81fd2c",
    "AWSAuthUI": "65b3710427440471b9025f3a0fd3fee62db601adf9298dc45cb9ff697504a683",
    "AWSAutoScaling": "9989ce8d23302cc9dd7ea8e02cf81f705c589b975823fa2d70002e15f07b7882",
    "AWSChimeSDKIdentity": "9f40f6af64507d222221e93b0e8f9eed3d86bbcc2ebe9185fb8267e19901312a",
    "AWSChimeSDKMessaging": "9afacfd99318837baefd040154b07435465c1522b0ca01217138043c1c4dce12",
    "AWSCloudWatch": "a7bb168504bedef850fb1613daab132b85157d4c532dd08e1c5e3866170c9180",
    "AWSCognitoAuth": "d4a7dafd9a243499fa217e7ee280ee6995ce7ffeb89cac5e60d846f7ace1c086",
    "AWSCognitoIdentityProvider": "61d5eb024017fd7f8a7a7a4b47ae5a61ed36634cfd7a605ce878da66f75f743a",
    "AWSCognitoIdentityProviderASF": "7c21415a273d43d2905e4c13b71ad41310e267a01d5fd054ed5444942ad799d1",
    "AWSComprehend": "b0e081908739484611ffd41258cae4971b54d122854e1e630c7638f16bd8019e",
    "AWSConnect": "fa4b487382aed47614956088120d63e2bee8e6fcee9a0021d3026c885e518141",
    "AWSConnectParticipant": "1dd8b45ad558e85214126f5d8ed70a5e5e4af89e8994e91ffaec8c17219f8ad7",
    "AWSCore": "efa0f2de72c7b6056332ba3ed2b557cd9f9cb3500b76c4111d7c433c7e692db8",
    "AWSDynamoDB": "62c54588b7a73550a47249c1db1485bf1011b502e3f2ccedf8683ae41ec65d07",
    "AWSEC2": "8965ed03271d472da8afdf0acf725ad85d7b4c0cb4301b92bcb0302920b4e130",
    "AWSElasticLoadBalancing": "783e8051e3ad4295bf6004113134303a1550d3970faeacdde49d7ee8ac424fc9",
    "AWSFacebookSignIn": "366b4f075186d6199bddd3e73f3d67496038f9ca0ba3fa5f6611ef4dacf490b3",
    "AWSGoogleSignIn": "534842af81f3844215364e6ce66b32d2402262d23191300c2c3b7ebdc932e50f",
    "AWSIoT": "03013c872cabb2be5506c64f13565ea9cb3a6577eb3917743e8887121b54eeff",
    "AWSKMS": "ab59974540b859742c5e6cf78bea16046d8daf002fb7c657b28aaa9b4fc92966",
    "AWSKinesis": "a684632c1a757a7743db117af13dbce5c8f99bda68fc4c38388a5f1f9f4fefe1",
    "AWSKinesisVideo": "bc9cfb480b115a39bf2382a9cb70e27a4f4a1a63fc3aed90b6979d552306e29e",
    "AWSKinesisVideoArchivedMedia": "54291e929af1b458a320d5d931d579b5adcf29d37dcaf1c80f56ce2838c587f3",
    "AWSKinesisVideoSignaling": "db2899c5888502461abda6e02c8732e3068dfef36779cd09a44ecfe33d23d70f",
    "AWSLambda": "c5896b3278264caf7bc1975f4333c1ad73ab269bc560a3f8d5393d3259139631",
    "AWSLex": "142a2c24714c880a5b69319e47383fcf3e6dec3f940613de962049783f4f5f9e",
    "AWSLocationXCF": "bf1c1f70e27545e5afe557fe1802602c8bd51a53d47b15e62c65fdc191fa3476",
    "AWSLogs": "cad2e9b03c22f0e0425a9164a5fa3efe6462da5bda17d45218fac0e9b3fa5c61",
    "AWSMachineLearning": "e1f414088fd13747b12fc2db3e0fc2984dd61540456baa8511d94ce69e8197e4",
    "AWSMobileClientXCF": "d64c05b26f9f1f1c03808bcb584a409d839c746b34b1838a9f0e1b0ff65bc744",
    "AWSPinpoint": "76def8f5d5ce0135c0f8fbe7ab3059c4056f95bb11a1eb082c35b122b7665b8c",
    "AWSPolly": "fdbdc2623d0335ce6f4da899694f88ff915c663a794e3de776b29904d10c2947",
    "AWSRekognition": "ddf7c980c60ebe2c3324eb251d51a8c9f2fe11e66fc2c81d893b77b8325e04e7",
    "AWSS3": "28e869758100e073cf9eb599670ff49938a08a516281b624dfeab6193503cced",
    "AWSSES": "61160c6757f4ae5281761c974760f89189d9b8bd93c9dd5cfad3a8058bb7004c",
    "AWSSNS": "0b114fc5de3ffa08d6fbf733a175891563a44b73741cab020723e5d9f38fc2ff",
    "AWSSQS": "67e8d9992a6c6a4de4a1a2c1b29ca20ed95b90a7b92e96005caecbe3ffe42549",
    "AWSSageMakerRuntime": "16f9b6e5d9146a5b793cfcd00abf8d3ea92d30681e07bb9bb7bfbdd133d7b57c",
    "AWSSimpleDB": "3991e6ea625a737b78c75d42b6fe6ce79bd5e16b94dc289613d6a97c4079f6a5",
    "AWSTextract": "b99072298d8ca8918ce0bc363f3734352720ba5aa46a09730bdfc7c7d01632cb",
    "AWSTranscribe": "801789fbd135bc309180669bbc7a84a4ae9228d5615abdf6681b0b7297baa787",
    "AWSTranscribeStreaming": "691f8d29bcd0317fe48aeb11c39e6488ff1d6d1c43a0ab232560467ce502bc13",
    "AWSTranslate": "785262686cb08eed961f41d3742c2696a3de015cbe183b80815f7b1d7efd5bcf",
    "AWSUserPoolsSignIn": "3f8c2d9cffe7873e685426e55041200d12add069795a36ea0c6d887d00917643"
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
