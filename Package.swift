// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.30.4"

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
    "AWSAPIGateway": "6cb51e9c980664bc1196dca1e48e96de8a6d373e1314f26d77f59c9b61e42237",
    "AWSAppleSignIn": "d720ae104b840c9ad3b3d3bfa6e5d4528dab90563876a066cd2787055bffe006",
    "AWSAuthCore": "5a13ad93cc452ae54b006d0100869ebd4ea7928859147ce800057164b25b1891",
    "AWSAuthUI": "463c7d7b05307a7a34fe9e3853071e47a61e6bba6fb5c351649503782ab874fa",
    "AWSAutoScaling": "43ebeb723381edeb6f1cc0ade39e3689890959b3897e61af93ac792b6eac0e5d",
    "AWSChimeSDKIdentity": "249e911ee4a97f496a982f2ff5b11e86357371921c2fee020b17b278f8751a2a",
    "AWSChimeSDKMessaging": "fd5556be1eb2f66a9a247f01a7c4a0cb9559570045df51c2f03198ec391fdbc0",
    "AWSCloudWatch": "6c62bd6e95052c880b31119746e793a3397728c16407797d847b7722385520c0",
    "AWSCognitoAuth": "24569cfdedbbe4ac5b4b5dc0b2f3579ce07c0560965e7f31f459727850e28e54",
    "AWSCognitoIdentityProvider": "a21bc92a499b117256171df418b928d02c85553143c59f3f7467650fa306173d",
    "AWSCognitoIdentityProviderASF": "99a23fa80472f6be13c283212ba56fe9f197c25bfeb3517611926f1348f1f5df",
    "AWSComprehend": "f213444c496233dd74bb83aaf4417fb57d643d62a81b34e0feada40e8023839c",
    "AWSConnect": "813f017035da4b4dc0d263b87e59b1558d896153dae00d96c903cd6e4c8ef105",
    "AWSConnectParticipant": "443f959e707fa7196dcfdecfdf577363e3c432058dbfc9ecfda439b3bc896ae4",
    "AWSCore": "0106b480808ab9e3d7c8c43886b874927dcf45516e4e3282783def47994c6680",
    "AWSDynamoDB": "854f1549b5dd57785c7645e9eb44fae23168e79537d8ee7c686c3f65f3edf2da",
    "AWSEC2": "bfd0c3c4448c6ae58d44c7f2c54013bde47746f3b2ddd7a5b04ca33d88098d3b",
    "AWSElasticLoadBalancing": "e0f4934f13859aed2c3b74233b30d11db0c8d6b6f4a2439346512971eec1396d",
    "AWSFacebookSignIn": "f4504af3b37499e28e89b67fab337b73471699acc6c935332a7c1db825010428",
    "AWSGoogleSignIn": "07afeb76d727b4a58edaca9e70a7eb1d154b0ed12c926740a82d66a9b01b42b7",
    "AWSIoT": "16aebd2f671be546d299ec7afad199206ae6ad48e4d3015f3c5c8f958e541f00",
    "AWSKMS": "52d5704b653f3d6d0c818f798b62d9a5634fa4d5cf6b2f0e329ac8b03fb384dc",
    "AWSKinesis": "cc58ed1037dfccec834f019e47f91c900673e628a00006fffb430e1755aef0ae",
    "AWSKinesisVideo": "14b1d9bd943c2cf2c7699483fd7eda0b995ba85289fd6efe4b3504a00085c87c",
    "AWSKinesisVideoArchivedMedia": "f4f818759a05e6bac6f90f48ff94d649f6566e336de2f3736f35d3baf45ff1f4",
    "AWSKinesisVideoSignaling": "2902a17a56d87ec586b468cf14918c6da223abc0b45a0850c096beb2e6e225de",
    "AWSLambda": "4e3f96526ccec66fe2d1722340c06056ada5ac3764802fb079849e2dbaedd02c",
    "AWSLex": "41ef3593d85a41cc1fc9842be63fa1cf20f78583c5362ac74c0c2e00f1b6c970",
    "AWSLocationXCF": "7d24ea71bf321215cfbb034be89382e23959bc8e9731c44d7fd269c02882eb83",
    "AWSLogs": "827935039befc71a3838005a81b98dcd3ea40311808afb6a097bdd9290f66f51",
    "AWSMachineLearning": "d08194ce4febad5bea68f571ab3f5fa30a16ce1c65944cfd45c343092ac3f5ce",
    "AWSMobileClientXCF": "bb019a7b76cc03542b17231c54c696a608726b923c69a88f9e49e2258f9aab09",
    "AWSPinpoint": "1428380f33705da1445d65f9cfa41d5eb6684f97b206f68f416435222c4bd986",
    "AWSPolly": "6d19a6f90801e7a187dd556fc2ab2c7e5424f1b8de6647cfd5bf482e738f1526",
    "AWSRekognition": "9600a0bb3b84ce1b2ee2097e076338ef91c2c6fd139a8ca8b585504efe788ba4",
    "AWSS3": "27ac8a7c7d77f5eeb92372f80da0bc617a5b5e0f91c6f1d8dcee518a9336c6cd",
    "AWSSES": "9274b251c73e1301fd42b7abcc19db19c4b136bfa00cac96290c6e0511775360",
    "AWSSNS": "76bfc6ca8efa86047311b9a6b9e76a0810f1db668cf2055a8427839f93e392b5",
    "AWSSQS": "e66c16f38ee142a45482745528e536f4cd024aff0c22c815278e8a58cb8b0c37",
    "AWSSageMakerRuntime": "16bd625e39655d0ff8cd88ee2667ea1569a05a4a4b8cec7e7e881e216a37b6e5",
    "AWSSimpleDB": "2f486eaefd5862aea22d68ff659fed7f2565df50d15f6eeaad3a8c2e010dbeb7",
    "AWSTextract": "4ed855a672724e002593d105b3dc456f053aa53af33d690730f55fba78cb73a0",
    "AWSTranscribe": "5af7c743d7032cdef10036c3b63c53db78a3c05bbe9ad3f9e46f6b56fab9a49e",
    "AWSTranscribeStreaming": "3bb514b5977f8f2bd109ce765dd3413810fefe3a6f4d1fe4a2de8ddc9bf987b3",
    "AWSTranslate": "2540f701360104400de1b61d72c19eacea39365ff505b2e502de1553ddebb0a8",
    "AWSUserPoolsSignIn": "2aef5e6e588c132a1bcfbdcc5be9d216cf1e942c081d43d02f85b01bfbec521e"
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
