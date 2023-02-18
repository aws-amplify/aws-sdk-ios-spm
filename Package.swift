// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.30.2"

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
    "AWSAPIGateway": "dc46ec77e377a21a220ec38de49b77c7144511437717075133ad1a645d74e0d1",
    "AWSAppleSignIn": "05b209525379e71a19460ed8f28745c19095cd03895f0bedc972cc6f940f366f",
    "AWSAuthCore": "8de8494977533aefa7f7a766fa80f4e10a708abe22b40e82e1ba4c733bc59bda",
    "AWSAuthUI": "dca2e57dccb197a67ea1b66c9e0abb349df9cdc87545aabaf76ff54fa90460fd",
    "AWSAutoScaling": "7b669be05ed9169cdc6b3bdd0db256f5fb6b9b9487de94cd898b17037edc9420",
    "AWSChimeSDKIdentity": "028a418f1eef08e1e2106478076c0d0b5d27b99a74fe6f29128d70f51a2b68c7",
    "AWSChimeSDKMessaging": "45afb00d28b36cc1811b8582ddbf751f55d57c65cf4380f4ec6964eb732f0e6e",
    "AWSCloudWatch": "c6b960b981c235cbb1e0a46df6bf760ccdbcbec3d2501bedc735891bfff7aac7",
    "AWSCognitoAuth": "eb8ebd5ed43723ca901b1f2616a1cc25ef806f58edb867d399f4fe1e3860c635",
    "AWSCognitoIdentityProvider": "d9ec4b4d176021eb7bd566d1482891ff99b528f5413dfec05816ef89176b9e08",
    "AWSCognitoIdentityProviderASF": "42b83cb885bb6a19730d2f2d098abdc677661f18dc4940f5735bb77b8145b9ed",
    "AWSComprehend": "58ce4b6d06ef9692583c0fab77acc8ec84e4e69623cde40a2af68a85f864d5f2",
    "AWSConnect": "15542b429655e1375c72f2a4d70977d25646b60c57c8b7c9c13bd379f722dc76",
    "AWSConnectParticipant": "4f3c867e8e9eebb6cd0f0803ca1de25f2c376aaf55305487a63387e483581769",
    "AWSCore": "b0b6838077abbc74fa5722565b5110efc06b8b75d35a947d39a39337906681aa",
    "AWSDynamoDB": "762d9ce15687ab7d22bf0aa5d32f4e73085cbfcd765721d0d02e581a134e2e33",
    "AWSEC2": "3f24649ad6392290d48fcb3176925a25ccf0e75a9297d1e9037bb852813722fb",
    "AWSElasticLoadBalancing": "8dca2859fe38bd0523ec7f8b6bd16a02153d413d3e7bca49e0424c75688e04f5",
    "AWSFacebookSignIn": "7d67f7ae94205db11a9e0f5e68781b9a407e841f1ede2418a9e1b7e6fe8cdfe7",
    "AWSGoogleSignIn": "d0d964bd64a8e761407a746778e5f2484604473ddf6bca82716fbe4b85ff02b5",
    "AWSIoT": "8348d570055d75763e8299b173f426913687ad0e76e2b38d757349f6cbce5270",
    "AWSKMS": "2781edacb4c7f786e7bf73d896b7772f9b0ad8ca8b63f854f70401ba965fe6cc",
    "AWSKinesis": "7810b5fef8b7ba126272f9cad9e52eff218f63db922ece21ec9bed849fdd80fd",
    "AWSKinesisVideo": "e29a68e4454e7fd9ffea7cdde0463328da7f58a7c7b10c45fdb9a398cd680cde",
    "AWSKinesisVideoArchivedMedia": "9a4fed6cdfa19ed69d235470e7e7903229b25bd8ea79a191df0ba695efb17d28",
    "AWSKinesisVideoSignaling": "b4e960356a0d060350f872942a2637a54bfd0601b932d3a1169aec0f125022bf",
    "AWSLambda": "313d079d4f1c0e1e9eee40f0e32c76592caaa3e76681f71f1b2cfa48687c5c34",
    "AWSLex": "f95085893974c7f4a1c12118a9269b47c8af479024f3eccdecb8c5c8ffcd4e4d",
    "AWSLocationXCF": "feb0e3930b6fab9038ab7fe4fa645172067ca2ff04ce536011e1b3bd60118e35",
    "AWSLogs": "590b7f7d626d029ecd2af4c0995b7f6bbf098c1ec28d7df487615f817fcefa14",
    "AWSMachineLearning": "1c8b40a0d425f0c86c71c13f59c9d614556996a496ffb2d0b8811e75e2abace5",
    "AWSMobileClientXCF": "6b32a3edd1c80c56102b36fb3fc81f40f7b59a53f3d69d77c5ada406e409175b",
    "AWSPinpoint": "7a6cdd87ab50faa5996472934cc09be593a3f896c56ab41adad3c5f438e07bd0",
    "AWSPolly": "052e0423ae3da6a18acdc9337fbaa8cdca41eadb65204ab4a7d476ecc5290224",
    "AWSRekognition": "285b5499d6519bfdd23252e4a8e2fd07b3eba7d751b5de9cc3c2bde3fe2e9438",
    "AWSS3": "6d33ee8d748a051a2a24380158c9d35ce337d0b2ada885eae5abb05cf4648cae",
    "AWSSES": "d3c12173171df92b1792af2166664330d462b9f78cdda204bc0a5664f41234d3",
    "AWSSNS": "df6a3cde77b48fd5221f342c428055e52e3a5dfcbdd75ae9fd39a14c52a2833d",
    "AWSSQS": "e6814fb21f91b39dd37a9f1bcb419403e340560a2eef35adb0079fef8d86426f",
    "AWSSageMakerRuntime": "cc5001bcd168d5b8548c9d9ba7c0a0376170b9f52adf48f692ed675dba53d898",
    "AWSSimpleDB": "22ee202301b9b91cc498770ddeb6d18af76a4170788e78d4433242603175aa66",
    "AWSTextract": "310a62531ad2ba0b935f94bbfc07caf0922118bce0dcd2f167cf2af7b64e0529",
    "AWSTranscribe": "37a013fd1de4a682dbdf2825ac191b529b9849ad436e6366a8743d827df3558e",
    "AWSTranscribeStreaming": "4a123964ddedb45e63e72132e817534c855a647ea6a155a51b0962ab9fa9afe7",
    "AWSTranslate": "81cbf4a93b2d8d75b1f7246c3396065d1400dae8c2987d48ca48a9d0ebf756a7",
    "AWSUserPoolsSignIn": "42072426aeb4c5fd305020e917d092624ae98ef79ae09eef3b96aeb539f06433"
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
