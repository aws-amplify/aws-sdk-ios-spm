// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.36.0"

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
    "AWSAPIGateway": "b9c4b6dc570b1fad95cb930fbdac37458066ee2536c7ec1adf740027c25e3986",
    "AWSAppleSignIn": "12415cdb45c723f8275aea1b50d17fa5bc2318d10dbeaca1568ecf745f52a27b",
    "AWSAuthCore": "83fc4c503561fda17c0c6f4b346b7a95f0a3f6d73c951c59181651ea07fe87a7",
    "AWSAuthUI": "981d4c790dced56b30ed7582cd839c8f1864ab91495afe7c9c58c9163c5e12bb",
    "AWSAutoScaling": "219147eb87876e97b0d63bb41ac7aed35979aef3c78bc761b0e8386a743d1417",
    "AWSChimeSDKIdentity": "19aae873efb1153d7ee096edfbadcaef9cdc2839fb8571a0f5d8e99bf8e2a0d9",
    "AWSChimeSDKMessaging": "bc32f286a94c01080ffb589965a09d191df44380e6c711e53d4f594df7365612",
    "AWSCloudWatch": "a3024ff8b60394365c5f8cdee4eef94dec9ac064b4c0ab5c5312b7cb943092b8",
    "AWSCognitoAuth": "e0c70a534d95bf212dfabe4a9360b136d9e615697361ca63d0ee62ebe66fdf4f",
    "AWSCognitoIdentityProvider": "c2b3e49542d571e03884e1ef7fd09eb64883c49e2407b5cba309570616e7e69f",
    "AWSCognitoIdentityProviderASF": "333b614986c10b073b9a852b498c789848ecbc39670662257482962007214e66",
    "AWSComprehend": "cd406a04dfc62277d7e4c1f6afa87471201fdf88fcadeb312b215478e81397fe",
    "AWSConnect": "f1a5d3d4f22aa5d804056c94d9ef869b034a63ab2b5bd2b94bf51903a23c0faf",
    "AWSConnectParticipant": "035b6fa154b097fdf9f7e7999a5b61d2bc7619d59ba39aab025b18d8f5a39cb0",
    "AWSCore": "c6b67eb55265a59186dfd6ecb5b53b3b915ceedeb9f378c1fd994c364cd41381",
    "AWSDynamoDB": "941f3bf321c89c99cab1b1c1e70d78fbdd395dc4b3bc9158bb9de090b1e9b1ac",
    "AWSEC2": "26a18e9aff98737fa0312175144d4b8c8bad3834c6da5629f4b4f1e821833e87",
    "AWSElasticLoadBalancing": "5a35e8599e2115c251bd60947dec41f691ccf2738098197487e3283085b0913a",
    "AWSFacebookSignIn": "822ee6ce49fda82548fbabbf6569755242c15c558b4884ad018544c27f58aba7",
    "AWSGoogleSignIn": "b016b6e8bc68d46c87d9ab302e95f93b89d8c93e897aaa3e827faff48294c3e4",
    "AWSIoT": "d93a24c62188f0d347ff8a11b9d1b34b92ede99dc6268228b81b127e1bec19c2",
    "AWSKMS": "6dbefd18c4914c29e52224883347895d30abc57d759635df0b18afc13b9d46de",
    "AWSKinesis": "fdd54b37efa6dcad955d6472bf39ed3fbf3d3ad1228ca24846b2e15c509e6e9d",
    "AWSKinesisVideo": "7d0da3111007b034b2a060db824e9c254507ad6219d8fa3a0da25b543d5fa03b",
    "AWSKinesisVideoArchivedMedia": "8fc4c1b393b91f84fbde3558f09403c59a0415d0ae97383b1534a51c1a05bf5c",
    "AWSKinesisVideoSignaling": "db3f546317d7c7e9283a9a0dd6febebd10dd298a50bb9a26599aaa5f4c7f853a",
    "AWSKinesisVideoWebRTCStorage": "4e7c5ad6127960bb7e5486ae0959fb6963e2f3efe80df241328d9d60a821336d",
    "AWSLambda": "ae126b3fce516206f5d169b6be6b7fd2ebde2592dc31bdf663ea556864f459c8",
    "AWSLex": "4bf0073f9326fe87a61def10646c3c818ca9c93b78745cf79263e9fb1847d50f",
    "AWSLocationXCF": "31328ff13cec9b284d3c046959ef9a62d9af26855a566e24c7cbd5b7a646cdab",
    "AWSLogs": "084460799d83b6ba5c9967c9afd2638035e5fbe78daf432a65c3adfd0611ce16",
    "AWSMachineLearning": "efdbc5f7e42470dc52560277833f687c4a4b8ee3e36279400065348c15096e90",
    "AWSMobileClientXCF": "8b97418b4db88d1d2dc68e2a99675eabf22ae2f6a18222c714afd0a014e156fa",
    "AWSPinpoint": "6376b3f49ed9f923c92ec106caf98ec843003fdcd359a1db0e47cb8eab129cd3",
    "AWSPolly": "4964001936579084cca9b4c76f0f4a9675e779ac4046bb9df1e477cea0f37e1b",
    "AWSRekognition": "6ff0baab3bd39fabaeaa7ed669796ad2538adaef4cec1321597bf2d240bbcac8",
    "AWSS3": "32b8940d3528b28afd06bf3cad6108e8bb4a22ed764898bb0af7bcf580b01ce6",
    "AWSSES": "13b7dcfa2a50f5ef2b42999b8f1bbad8a495d2f35f0c86586ed694b9e45c8b64",
    "AWSSNS": "c4568e47d0b27aef036090cb1421dcb64db515ef24b78b89f929a0592476327a",
    "AWSSQS": "4bf910d2c46e4741a4f0f3b087761cc1923a0ab627f071f7b42c050ca4b14dbd",
    "AWSSageMakerRuntime": "bf03175954ea776030812a8658d5cc8583d13dba2a3c6ccc6a9f38f79a05f96a",
    "AWSSimpleDB": "750afe4d7842a716a06dcce8d175bfd4ee2d1500b29f4ef4deed905c672a4349",
    "AWSTextract": "f24e0329f1a32af3bac58aa81e9c00c8a2c681eaff8bbbb88918343890db1a3b",
    "AWSTranscribe": "ee66cb2e788470965a935a9e0b705d319129a903bbc0393db068aefe46aa33ba",
    "AWSTranscribeStreaming": "8950287beceed623e9cf64b16858d4629e86869101e240b7868cd4d2f21bc661",
    "AWSTranslate": "52aa4e0347234fd503ef01403197f865ca6e5510d16ceeea2aee08930bcf8326",
    "AWSUserPoolsSignIn": "ea4a40b54aa29b4d2fad27c3874f1366a235b38ed6fa1bb86851c73623a8c835"
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
