// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.30.0"

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
    "AWSAPIGateway": "9398dbb6f9eeec96b066ace7015ff5505941611c2a42f8596bb6cf53849b8df2",
    "AWSAppleSignIn": "badbe85aa141a756bb4a06be4be2d94106ecebcbfed3b9eabc7eb229c5136c5f",
    "AWSAuthCore": "88fb701c9b77b935eb9cc7dfb8896c1e0da82746c5d5e01f0f44531bb56023f0",
    "AWSAuthUI": "38ae00a85dcb7aa057d72ab29f80b38a33082170c5492c52a5d7bb36d6766522",
    "AWSAutoScaling": "2c2a4f852ae009ce9fa591fbcd5d63eeefb6469ce2b1bee485fc54ea0d7e5db8",
    "AWSChimeSDKIdentity": "af88f6d351690584474e62ea69c47d52e6f29da2830ca7b53b2e1510e3fd3d5b",
    "AWSChimeSDKMessaging": "08781b18f54b3b1658b84729222138be249d1ba9f23078fe64a0d8090692f3b8",
    "AWSCloudWatch": "220016dd97690956ac3bf8432e279d8ccb46d519af8e92e623ff0306c954bd3b",
    "AWSCognitoAuth": "34b788fee2899136222b17c7496059178a91d6fa0b5e64bb49f8bb0da6c02ad2",
    "AWSCognitoIdentityProvider": "1f5641e7f5b2555107f3912e29d8a91377ad01702f8fe5cec356aacd93edceda",
    "AWSCognitoIdentityProviderASF": "00393e70ec9d512a4fd7574905bdd090020a9f6550f16e935acb12d6e6e1134c",
    "AWSComprehend": "fb294031efdc83ca100d983c437a6811f4f0d1c35de1f2c452ffc15cf91ea779",
    "AWSConnect": "98665c3734fdbb8830b4aa25b964805bae95240c44727d1e608b648e2856d612",
    "AWSConnectParticipant": "13336ed86a36dbb5d2aae9c1a065b305bf27e386371dec042d98eb41b8feb9c3",
    "AWSCore": "a3f96cbbbcd0f707adcb1e15a8e4a9ff3ab726ce0e4053f3b73fbc104542d529",
    "AWSDynamoDB": "9c90b54b500348f6c3d61df9e59c11b045f3d7ed60b2c95c13968a966951d0c1",
    "AWSEC2": "ef058f37672e705251c73fd26c56da7a7ae49965f206c666e85227b73a095a45",
    "AWSElasticLoadBalancing": "94ba73f649d45ad39316b1ce513814427a250d821ebe83112fa9119d4d02e86b",
    "AWSFacebookSignIn": "d308b28c7f2801d0b77c293239d9571c3bfba877fbcbf03e45c5e0331144c38d",
    "AWSGoogleSignIn": "16f2f706d0775c854640f1ffce020d72d034abb76b26008c78b72340edc7350c",
    "AWSIoT": "142383658c833ad7d73e5c37a94c95ad10fa32de26f6ca436130ad1b684ce270",
    "AWSKMS": "b4100d65706dd5505e8142893db12afcd764478b755a570851faa92d3f60bb4d",
    "AWSKinesis": "3b6a0d60cbfeeabe5a678cf667de7b2d88e6d58a1b5635df53f9bfe7c7380971",
    "AWSKinesisVideo": "e06517287deb4b8a9f6d088c63514e91a10049595e452a292684060d7781a064",
    "AWSKinesisVideoArchivedMedia": "e7ae979424c22858f94a969b9a5d5a5ebc0def5e7ab99ab6d11dcdab2fe4f552",
    "AWSKinesisVideoSignaling": "507bed33373179ac6ae4891e172ee0e81bc720644f48b1f4a26fbbf8f2cfa310",
    "AWSLambda": "665e26848bd3e1468d020390bcde38484150a08d67beb5bfbba2efe609da8750",
    "AWSLex": "5bd3b4d3fdaf58c41ca031a156c44b23c598ff29ec6827aa059444fff28c17fa",
    "AWSLocationXCF": "aff71e3f728a89e688bc8e06dd74e833b7e73da478615a8b6f38ad216f969754",
    "AWSLogs": "256109511b3d98fada18f501d588545b065b5d8a7659665462561079808e24d7",
    "AWSMachineLearning": "52c0c19bbc162d2bb8d220719e310ce5aff82ba16793c0b1a4121e7871f82e39",
    "AWSMobileClientXCF": "e810336887e51526a0e25f6564bcb430671a97f03eede496865b908faa2d30dd",
    "AWSPinpoint": "1586f66b34661d5a33d0d37751ed07668befe376ce6dfa1306e90a00591bd8f1",
    "AWSPolly": "27e8e9bea9242393aeaa471e899d35ee4124f07b2c23357b2e08279376022eb3",
    "AWSRekognition": "65b8031b1cd1dfce9395649a7e3ff684367839fc721fded2ed047da843618720",
    "AWSS3": "53cea4e9023c6cf4e0321e11d93bd29a134fd6745f348e3f0d917fe32797c053",
    "AWSSES": "7b534eb943dd8ce414f4611a49a01a8789ddb57a280380e2820de3cd286d2380",
    "AWSSNS": "e27db0e5d58b8f1bb9940c7a351914f2f8d5e5298bf73c1ebd84aca19407a8b2",
    "AWSSQS": "1c2ca9d2f22e892ffc36f446dcf4a3166e33d8f700472ffb89705722fdb25363",
    "AWSSageMakerRuntime": "69a51cd9f895a44afdf2e0fc02c78c349ebe81ebb8c477389d404fd1dd819df0",
    "AWSSimpleDB": "7570c9d181a194fd44d359d1bfaea41376a309d788960789ee0ec84c66bedbfb",
    "AWSTextract": "2ba7a4ac080e11be557fb50ec8a0d1bbc9442d5af2db08c6751a77064b4174a7",
    "AWSTranscribe": "d541be76771010b5b36c79dc94126887d199b06b9813d2c7c4d18d3a6dfd961e",
    "AWSTranscribeStreaming": "49b310f1d66763705a5a1dfe01a428a9893a962765c3b2ba3cea9210ea3a77ba",
    "AWSTranslate": "f5e6adfbdf2d02b290c8a4d2837bffdef7b3728323a913bb41eb03f30c26b421",
    "AWSUserPoolsSignIn": "30946ff634302d23ad4685e455a210bceed537b413834937d562241aa1901644"
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
