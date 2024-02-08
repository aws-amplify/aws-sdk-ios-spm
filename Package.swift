// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.9"

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
    "AWSAPIGateway": "6cad3ceec8e9fe38adee5f1fe1de96efd6a04dd4a6f52cafb3a56315da1cdb21",
    "AWSAppleSignIn": "c5948dede6fa7ea830d6b957b17830e01499a2d2d0be076397bf6cd401117590",
    "AWSAuthCore": "63fb7ac575e31d37c038d59f5af0f231943de8f835e408e3b0a5cf06eaa29ca0",
    "AWSAuthUI": "f446136774c83e4f7f2435b452691df40e3bdb25f823431eba2a04fc1204cf9b",
    "AWSAutoScaling": "554c15bcced249188302fabbf16d9174aa7df3980680a6625d4e902fe2032704",
    "AWSChimeSDKIdentity": "d74905235fbed7c1809560301a4aa363c62c18cdc6da9f0a49c77c91244278f1",
    "AWSChimeSDKMessaging": "309f926827633fbf1403bfdea338d4a4c0c49acb513c00dacde6a60b5d91eeab",
    "AWSCloudWatch": "212b4a1fd2b38aa167ba55528f9a94ec3570efd19f4a0b7dec8bf2aaf4468d4e",
    "AWSCognitoAuth": "42bf4bff4fdba5945424bd17db1fec5a98fcaaeef0f464127cc1328c00be8537",
    "AWSCognitoIdentityProvider": "25a7fb8f8d47afa289a61e7acb3caa835e1d244061e79f43ba7e658b9cc42bcb",
    "AWSCognitoIdentityProviderASF": "a0c7e7f5b21c7181c79a797d743847d78dced65e2e8012a1aed99d37d41d072f",
    "AWSComprehend": "ad0f4b6a5c9fda53a3c2babb700e3ec904cfbf1eaed7b759129f1601b64c635a",
    "AWSConnect": "725a40724fa919b487ec40615536a5dd2e4bd02fb8887657d9f955f1e6817d48",
    "AWSConnectParticipant": "fb1c887659b4515f44ebf7f5980aa1b1bfd34a43a52e9d96d980125778c20d90",
    "AWSCore": "7d7f8a79c88fc9e0b948c5d1839848dbc4c03665fe561e3ab028c8e8aa969f5e",
    "AWSDynamoDB": "f90d0c20dc32b3120591a639ea45ecb6c2976e768aa9cf62ead31b1c516283cf",
    "AWSEC2": "89ac2b809e313869fe51f282e8003fb94f4cfc22b7f62a08a38f69cb297c3cf2",
    "AWSElasticLoadBalancing": "7bf7de131470ea4fcc2f862ee6799e633eb2d0031ec1aa147eaa40fcddd2fbcd",
    "AWSFacebookSignIn": "00f02db5eb1028a5c0b7a7d3658828cf57ff8236e069182d56deb7e58585897c",
    "AWSGoogleSignIn": "63d6ebfc4de104a88d47a40c090c8ec6a9018d973864be7d13e40298f3f5ffba",
    "AWSIoT": "98e4fc1cea809be3e6c55e173cb5c47cfd19bcc3b7720e25d47a6e7a0b232736",
    "AWSKMS": "d9a332a1315c4b2d057e5e4c9c1183826c9718ff7bb53be76f78d60153344bdd",
    "AWSKinesis": "9f78524a90795f4a178e02b5e3dc097f9d1142779891576773eaca91907fd16b",
    "AWSKinesisVideo": "9ee9644b84dee07313732eaa40794c6d2e4c385e01f12ebefecbb187bc76c037",
    "AWSKinesisVideoArchivedMedia": "f7616bf398f359a01bae4f0c83cc7deb01105b9e82467b514e5517788e129bf1",
    "AWSKinesisVideoSignaling": "96b752a89da3e50b1e623e2b9bd19544a90b8ecafa1d9d5bf7fda9aca47774fb",
    "AWSKinesisVideoWebRTCStorage": "6c22fc90b6dfe8306a710ee1afa21ee33b1404548a2fd3ab764f1ff851147a37",
    "AWSLambda": "39685b03adb31274466dad30d169560395947371faa8bb611e98146446c05651",
    "AWSLex": "5940d76d31e121eec515b59d4d2f1e26b0201b0a5a8bfa02db25da57b532e393",
    "AWSLocationXCF": "45e566b3ecb2b5de5f605966d0d6e6b9ef17f2c7d317573eac9d8ffdda7bb897",
    "AWSLogs": "3f47b0d43cb016264a7445212fc6485dd75c9c71f8d165ff5da373843e379f5e",
    "AWSMachineLearning": "8a6fc95887b1f81fd61176029d3e65f61716fc9f2ddd153ee97c7e21dae6b9ce",
    "AWSMobileClientXCF": "02d947a843b9d75547d00c9020291dfb2031b58f758a4a743728a62594f123f4",
    "AWSPinpoint": "b40f72af907a90ba1da510122800e7637c96f8bf3ce97ad1844ec500002d1f67",
    "AWSPolly": "62989e9816fc1636d20ceb718fdfcad7d2de9c79bd3b7a0e4a2faca6b9240e63",
    "AWSRekognition": "6a074e28f2c8a2ab66c8c048948f54162cbd19555741ff9db2bf45690b10f0b8",
    "AWSS3": "a738ea6ffb7a24fc49b206555e192e9bdef37ea4349548338b69ec3f98046974",
    "AWSSES": "7959c2bdcb09632e97eadb35048c1f6ba6307234331d4cecd601e33e9169fad3",
    "AWSSNS": "4e7b90ea03779bd686f0ae7ee66306433fe0e6f1985f6e6db668558f3603aec2",
    "AWSSQS": "1be521ae52742560f61be4b36b84b6fc494d9fb6ff1f74cf480e81aa36d41868",
    "AWSSageMakerRuntime": "95e9964c307e4d75e2b6b22042ecad15b803e3f61a4deb820f6a258b577d79a7",
    "AWSSimpleDB": "5c4fbd4f6a340cc1ca063592f13ff4806d94707b2dc0b8fcb3e5a406feec2a08",
    "AWSTextract": "14c47cfb29d18bfa4bea2d1103ff52028d8633ba84995d22c707d0724198d3cb",
    "AWSTranscribe": "61294875c08aa4170ab2036dba7bac9565b112945e522a69a32d63d3036083de",
    "AWSTranscribeStreaming": "a8e13fd48374b6ab1f40cb1645ee0a84d27d4a06d39abd5cff01ebda3226153e",
    "AWSTranslate": "7f6724d9cbec5c617a5fc04734c2fc69b0bb74915e53213dba7e9402652201f8",
    "AWSUserPoolsSignIn": "03be4cdb025762b262a206a8271a7797c3a0f6d8b989ee3d10f35b27e66ac29d"
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
