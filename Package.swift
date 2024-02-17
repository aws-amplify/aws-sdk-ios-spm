// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.10"

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
    "AWSAPIGateway": "c8b02b5ae538e7ca4f48374babe748192f6488e4581c2a036c53dd8a7dd91471",
    "AWSAppleSignIn": "8a474eef9a371d29cc5126e08bbf284c1a996e20dd9b3123036cee994dbeefaa",
    "AWSAuthCore": "f459ad7c1c7588610cd2735de648f9329f7a47813c50c303012c9e0fa1f114bc",
    "AWSAuthUI": "ef081c6b71b1057e15b987716fd1ce55eb85fad9ee83c4f0cb8e6b2f2d19d6cc",
    "AWSAutoScaling": "2bcb6ba7332db3ff398cd405f2937e0bd1191f674ae9f0f2b17ac2ac374b50dd",
    "AWSChimeSDKIdentity": "1d5c25d00b28c153f705e844c247c84ed7c066774d56f2f56d9dce77cf848111",
    "AWSChimeSDKMessaging": "a330583287479f29eef8117355c5d46d183e6ca9d757aa431ddc168222fd7051",
    "AWSCloudWatch": "1cb9b6e8b4919d80edb4972e8dd677a3fdf4d946cc56f96a50dc19ae2a3ee55d",
    "AWSCognitoAuth": "33528c07228a3ec1632787679ead3dd8a3b55173ab51ea07c92aa0a28d92f993",
    "AWSCognitoIdentityProvider": "d7b90c55dd469b97362a0898bc668b86e495068e6401680f5e1066b471985f4a",
    "AWSCognitoIdentityProviderASF": "94fca79a2ec783b288f1c47d1bcf9c6bc5d5b5028125e0b6f7f23a16f48807b6",
    "AWSComprehend": "9e69354442b3825071ab28e3ab31aad94f02a1c58a1cee6ba018039ffe8494be",
    "AWSConnect": "03313aeda7f9bf9710639705898213b34949e1a1ab337a5e66658f0a4502ed2b",
    "AWSConnectParticipant": "cd0ebd3fc9a32d50d25bdc64cf69f77365567835cb01303b54ddef983c5a8fe6",
    "AWSCore": "4ad0713772b630934349a4887eb50831596db0f2efb253986b5096cc0ae50c54",
    "AWSDynamoDB": "80e30afb65287f8d8f91f46c170ccfdea5a227f8fd8db16a2bd5cb04d553f2e0",
    "AWSEC2": "ccda7e3d20a9819e5d650fdd9d745d7b3a70a2a53bc0e40e08ce5561eed5916a",
    "AWSElasticLoadBalancing": "0f640ac197ca31e6d5e6575ddbc905c70c6476d614dd84c65b579d0c5384f132",
    "AWSFacebookSignIn": "4e436d3c913d3e194ac983b50cdcee2e94d3be36f4da51843d32a186412f27cf",
    "AWSGoogleSignIn": "e7cffdd2ce1e5ca9d9d9dd72e5bbd5e6933e310ecb7aed895048cf39ec5d7658",
    "AWSIoT": "c39d783288441be0f9b7e1dd39b3c3dc5a27b216d9c2abc9d4ec9a99f5de8cc3",
    "AWSKMS": "98aace9ea1b810797a4a9789380a40ce80eaced03b0115573d3a0aca016827a0",
    "AWSKinesis": "9fc40cae23767d7b379b3b16d5870e0f17605364458dac911b009062a114ca48",
    "AWSKinesisVideo": "f11278ff9049bb1e23c0e35eb0e9b113a7c9fdf68abaa5471865c763229c8fad",
    "AWSKinesisVideoArchivedMedia": "7695c4b32b37141b9a4673f4e277f7c3554a66918f42015c9124a08e39b451dc",
    "AWSKinesisVideoSignaling": "bfed1da827301dd53fcab344535d7cc2c9d6b169297ec34338b677253e151e1f",
    "AWSKinesisVideoWebRTCStorage": "d706dcda4fe4db17604361bba29bc19c11ab186db1d7f89b0925d74e24579fc9",
    "AWSLambda": "dbdf67d87dbabf04221ce302acbe416cc6772e6a54fa0bdc05afec90fa69bd89",
    "AWSLex": "2710ac1fc589ddfcabcf1d28c0d6571cca9841b4acd83744dc0a67a0b33b766a",
    "AWSLocationXCF": "191ad075c591f85d516dcbc540b11d913fe872fefa53c4f0b5c3302cb9ea61a4",
    "AWSLogs": "cdf265c027e39691aec9ec502b7a3a001f3335c370dbe0bb96c592aeba8f931b",
    "AWSMachineLearning": "26d47569239ae2150a30b330fb68ea2038b38b007448a1e969fc66702f36b0be",
    "AWSMobileClientXCF": "e59f2646bd32dea886bf7d0e4e191c597a754bc73b76cc47a6bb8f89b8dc0747",
    "AWSPinpoint": "b62054286fec744b1d4b97cfd0c9e71d88d1833bb8708518700bc1d430d12223",
    "AWSPolly": "0dd2c4c4d83f75cf4cf775aaf0f7ec9b54d83d3b23ec8c94ff939ecfc195b83d",
    "AWSRekognition": "0c6903056237083d132a535d8633d9bc825938b334a2e036a8639266c2f0108e",
    "AWSS3": "a465b0ab1b67a9a31b85aa3dd110e3bc8f77bc7fdc949ee4dd956ebd00657536",
    "AWSSES": "38005012b16bf14b02718477a1e1bc6536e00f12c49ab03b72b64a288ade9973",
    "AWSSNS": "a3c879e222a3eb2268dd104846712eaab6e5d6f0c52e04bee886736a0da17a84",
    "AWSSQS": "0ae41b13d3129a87f258b63697a54a5f0c1d12e03fec97c3e99c3445fa976360",
    "AWSSageMakerRuntime": "8a07afef85c6f14869bbd9690714abe5194f207640431ae99341fd8f7e800c6c",
    "AWSSimpleDB": "91a24d20118f485315dab3d2d91e0d56547fe8e308b81a5a4d7f692d81d11b18",
    "AWSTextract": "d77ba2eaa4ba46ff43d390b194c86f62d2c3042b5a857c29dabe9dc006301ea3",
    "AWSTranscribe": "8ce4871a24cdeb60f22a0e926e49c60bb987af35fa8baacf6dfd69c4fb31f033",
    "AWSTranscribeStreaming": "26794095c313ec565b3f6e22a84739969501d120cc0777fd7d98c8e4aded3f27",
    "AWSTranslate": "cba86e69b00367eda62ff1128766cbb026486f93df2da0bb36d77d0a39bfb009",
    "AWSUserPoolsSignIn": "7c041e628837b08f014e7e8814f4d4f25b346f55a05ce4f31eeebcf66dda3e33"
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
