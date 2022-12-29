// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.28.6"

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
    "AWSAPIGateway": "4b8599277fcd0972c8809d9a615ba810dc45958974fda8ed212d3b18bb8f9cf9",
    "AWSAppleSignIn": "ad9a64101490d04f86b981b9777d273b6e0d5acacd487a56f2dd15b3cc69480c",
    "AWSAuthCore": "857302478244468a4086bb3c1bec4c337e2f7ea14c2a095d8a2566c392977371",
    "AWSAuthUI": "5bd0607b55fcb29d4581eda4feb465fb6094f68469cb5c8dc9ea8b291bfc0f69",
    "AWSAutoScaling": "2d035dba1feeee2ea6bff1c3bd3e3b58c4cf5d354a76ece7dc6f1127e0ca1466",
    "AWSChimeSDKIdentity": "292a85c0363ce26ac5efafe3e9ac44bef47f27e43470cb7b77825dcdfbd7f196",
    "AWSChimeSDKMessaging": "d8f18102af59dd7c3343d309bfab55eff314412803ff826b19fbf2341e38783d",
    "AWSCloudWatch": "959c74c160cebca8bd56ef5fb21953eb88319c2eb5fd48634c12cab8ec0c8527",
    "AWSCognitoAuth": "13c969e6c34a407e9577a971e67aecbfb3e6c3b5f06abd13fc0adc825433493e",
    "AWSCognitoIdentityProvider": "893f49c9cc64b58527e25bbaa4286d923e4e8e2904756b734fb9527100718bf6",
    "AWSCognitoIdentityProviderASF": "0bd73755ce78016e06b2907386e3d27ccda5ed6350ffc0cbde4c448c07217744",
    "AWSComprehend": "0e9038880e3ab23337b07ac1adb62d25786068c33ceb94fb50865a45fa114b59",
    "AWSConnect": "6abff44ca8f6288f1c254a2a0c84c27901d71eb777c778112a855f49bff28c38",
    "AWSConnectParticipant": "72da1bee6b6de2922423206ef18ed085781100fb1958088efda83c16674fe41a",
    "AWSCore": "263446ecf9fdec6901ccd938e2dc62a77f83f6ef897bcfa58b16b15ea80a8066",
    "AWSDynamoDB": "ba806ba2893d04a779166b7becd923126c04449c585d882e7c319a730db8e72f",
    "AWSEC2": "30a5d116f31113e88442eca81475bb295de40f111806fda76cb8674095957947",
    "AWSElasticLoadBalancing": "11b84ea2a48670aaeacbe3f62c75100f4a953d9fb3b409e95dcf039222a49f09",
    "AWSFacebookSignIn": "a80a9af0dda5215e5a6371731eb33c64e73d7504e54602ad34f5707238dded3a",
    "AWSGoogleSignIn": "34da0c6be41fb736af643c4d5d92c2156a17a1e8c1c51692d8335f9e17419ca8",
    "AWSIoT": "53b27328201c37468c0002873ad4bcbc9f84a4023ebebdeffc689f84e10250ab",
    "AWSKMS": "ab6dde886a6b748c013bf61416bcbe7523730dbd71bf6257297b9e89c02c3463",
    "AWSKinesis": "87d67b57f334b1fe6afd3240b1029e53ffe289f0d37bb79f9e4983b74dd58f08",
    "AWSKinesisVideo": "fa8a3a5fd6a2440b24ec651f4feb08fa1874ac566c778606a49f9155c762e89c",
    "AWSKinesisVideoArchivedMedia": "61bb04b942d033bce9c6854f7f1a04d8bb18556f41fbdff87a1ee3110097785f",
    "AWSKinesisVideoSignaling": "97f1ae1365d18f1c419eda16d00dd42d33d89029039a3146fdbdfdd0ba10e3cc",
    "AWSLambda": "965615fd24a4c7fb733214483be2ca4cb29c571e73fdaccc7044e955ff40dbf3",
    "AWSLex": "2188fffbe903c3859555210882729bde3227818084db0085efd26ef3d4e6ce30",
    "AWSLocationXCF": "921a790954f47310a342731e4853083a177a78c4c03a4a8a0e1acfc23b9beef6",
    "AWSLogs": "8ee4f92f2a22fdc084b9c37896b2986e4cb7cda0aa012b7b2483086b35ec8346",
    "AWSMachineLearning": "0b3473ff497e92bcbac65a6ce74832ed52076cc8224561c064fcb3a89c0c4dd1",
    "AWSMobileClientXCF": "b777ef69b0c8deeaa1061d248b9ba1575f44f11b3acef49e8648ccd86e694734",
    "AWSPinpoint": "40673e57ad01ab3dbdb18ff8124998074c95ad06e9db9958fdfa9a96548ad4be",
    "AWSPolly": "fc33c5001cbc6e8b30032e76171660a2fcd620a46f22e27d7b56655758ceeb39",
    "AWSRekognition": "f5b99778bf34ca21b257945d67b48be1e37f8d99ee3f4d07f4f321b0bb20e375",
    "AWSS3": "6e285bae08ed73c552a1e8622eab41f7a70f10db4f8ffe4999d3abdbe79334fd",
    "AWSSES": "19f493be4ef2b895e7faebd8cf587d7dd30a77e3f4fb134518f498ab931be721",
    "AWSSNS": "b29d829b498512c1ae4d360fb714a415836d346790752dee73a5c73db25aca8b",
    "AWSSQS": "bf17167e8e6f7bf479ebd4fd79ab9e9e395c93dae459d30b9c0657b7001586c8",
    "AWSSageMakerRuntime": "9018be74df055b99b4b90ecd044f5c1295828b9e285682c158945c225e2b81fc",
    "AWSSimpleDB": "557753030131a2032ebbff2e7cc916b7347fde56cb10dc867bbaf54fd9248077",
    "AWSTextract": "b9ff72b33f8d6c5e98a783b8bf30de2c971da9a3e5f3781d58d77af8fa731d6d",
    "AWSTranscribe": "79fc5a8c9dbfb39dd878e14c1bacbd52c5c18f7e75696cc283984a035522dc3e",
    "AWSTranscribeStreaming": "088044ebf2ef55e5e1a2c35b0baed584e135ab55437625dafd732580f5a1935d",
    "AWSTranslate": "71b79ae400c490930ee64b2dc44f5fc0bddf0bc4aeb81f8b37ed8b67c80c14f8",
    "AWSUserPoolsSignIn": "503fe76583cb6cca8f796708928353bd9f8fa53123ebf61bafed06bce2dfd0be"
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
