// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.36.6"

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
    "AWSAPIGateway": "7e3ad3d734e109ef8a58fa9ca4d691641065c063fa6a1b9a655dde07560388eb",
    "AWSAppleSignIn": "cd6d3f15e99add009356fd94c98223177db6bf4f8cfeb028ae9bf726d2c736f0",
    "AWSAuthCore": "30549f178191582ae53eb20ec189a06e4bc43764b3c06378daebe72eb1361b25",
    "AWSAuthUI": "e18c478dbc71196cf6529a468d1664fd550ad51cf30fee086fb24544786735b7",
    "AWSAutoScaling": "30b450ab3c9d7201870505de7b78731f8ca59378736f68045b3ae4c18433ddbc",
    "AWSChimeSDKIdentity": "89a24acbc7ad7e7cdf5a6ac37d4472548eefcbfe193e657a6189d5b38556d9ff",
    "AWSChimeSDKMessaging": "89664fba7659e2922e0c88c308d9d24773818608a87fadbe6d22f2062830d477",
    "AWSCloudWatch": "fbf9d8ca0c8daa7c64519e1c5c55b137941dc93d23eb1e73c71e2e82b53b82e9",
    "AWSCognitoAuth": "68af5d157f09418e13dd0088c3ed330b5e8a18bd957dbd2fee12f4cbf73976b5",
    "AWSCognitoIdentityProvider": "9b6704dcbaa5401b1662c16a74166d68240c6794be6581c795297319c08a741c",
    "AWSCognitoIdentityProviderASF": "36c1f117ae2f70b35361b022694edda32796d1b4988d3e33f9e504561cb01d23",
    "AWSComprehend": "4b68fe17d3c02a193bc8cd6292afc6b34179d0a220838684ff72778c7122678e",
    "AWSConnect": "2bfcff8b5c0e86b3aef6c9c8996c79c3da129742805ea3aae3788efc026b7504",
    "AWSConnectParticipant": "0b431bf55b7c9d60afd5008f046eca1af24aa9d5ffe2b6d73d50c319a4dc0e3b",
    "AWSCore": "f7773a9b0be489e6ec119ca8021d03e63f15871a642c6391c4571a65796b1b8b",
    "AWSDynamoDB": "1fd98a10a6a4556c299d1514e793e8d15abed7031ac9b06d3bfd32d5dcc6451c",
    "AWSEC2": "c75707b15b485a333ec6f8360115e016f2efa8c2b82410e71b38b763fd0b7ba8",
    "AWSElasticLoadBalancing": "cb2643536950ee644893830089bb5fd0a389ba5d0e74ad150a363dedf6733dc4",
    "AWSFacebookSignIn": "8f8c76d5f18e7cfe76f6678603db3109a663794a4329b789e76c287da5091439",
    "AWSGoogleSignIn": "70dafc1283586756f1e7fb6555e7053e9b8b5557c61b482b6383522386ec00d0",
    "AWSIoT": "0b775370ccb22f49924406b34f040726f12cf6a5ec385dac1b8c4caba2736637",
    "AWSKMS": "bf13f21d995208b8fe64c636f4f73eba58fcfee55819717566a3dd380ca41bf9",
    "AWSKinesis": "eb9be3dab186bdf9a57a1dc4672f51b39fafe549aa70d24e35a8e2f3f55453ae",
    "AWSKinesisVideo": "55ad1a5370419af050d7a011b2f0ea15a3de2194762584ce973a0256607227ac",
    "AWSKinesisVideoArchivedMedia": "bd4d20feacbfd7b7ce4f3a34dd52eb2152035fe009af6302a90c743da40b6b9a",
    "AWSKinesisVideoSignaling": "22231a8b6c47d33704bbbf0109c873adb397c96a27f5485b7eece013c0a94c66",
    "AWSKinesisVideoWebRTCStorage": "2c10f8f270d7c6308ec3be691a4938ba498cba97c88184a1a01bcc8456264837",
    "AWSLambda": "7c2df624030bfedc209e0041cea5a4c2353b4c9baf7bb42867c850008a55d980",
    "AWSLex": "48290d10b2748a08725329991d7dcf1ff7e05bbe099b85d3771a69bef818ab9b",
    "AWSLocationXCF": "87451e447e5d62559c8a5be052baa8de242c9cc378ab175305cb9be24eb9e151",
    "AWSLogs": "9904b898a45edcf1d7c285880d0b1e2a5a911586010457c2d95d72a114364e31",
    "AWSMachineLearning": "b1a1a02e6c2e950f52ff60280a84b986971b13424dec6f6cf49f3471a4aefe8f",
    "AWSMobileClientXCF": "fd59ff25ecac8f66743a5a55e0ef0984f9dcd7da1401e6d184cfcddb59eaf280",
    "AWSPinpoint": "7b60160d17a60c8ce5bafff6bcfffc0abc2d0c305cae93837a85e9ac8062eaca",
    "AWSPolly": "945447d1b7cc25e34a13ae8eefa23d668090f5405043937aa417213e59e5387c",
    "AWSRekognition": "d67defe6d29a4275a8504abdc4404f4c8f7865058182c77cf3a74e912be692de",
    "AWSS3": "9964363f5287d244cdee7520ceb513dfc9d0480a25c85ec5d3bc2155b8b31f80",
    "AWSSES": "2de1d9ab28856164b663bf291dce9111c0674dc295e722c2f1c4608ffd557b18",
    "AWSSNS": "08bc3d3b5f437366651dd93a89d3e6766c754aac5e86bb6c52a24add967f10fa",
    "AWSSQS": "152b667bbcf29978ba5a26463aeb7afd292b48fdb68aa20ade904b82929499a5",
    "AWSSageMakerRuntime": "29b226e5c9abe5d9abff6cf3132cc3d8b05a7b50998aaad526e8d7b5b663d20c",
    "AWSSimpleDB": "7bf783309231c8f307c78d1d62fc9b8fc0639012b8bee8661e28579251aa6900",
    "AWSTextract": "f902c5146dbd145bb8de2a17aed3f966fe835500ed3b8fd5f206b97a4b40cc69",
    "AWSTranscribe": "1cce24d854004a5ee0a62a80924ee9ca33d31ae53ea17b70e37bc229989f8147",
    "AWSTranscribeStreaming": "21bf275e1a05de6f4aff791ac68674625ad36c94f19530be26b5567117b25bab",
    "AWSTranslate": "48a00c6c3f9c914eaa7027fca9e9960d752b40794817c09ddd9fa594541e2c04",
    "AWSUserPoolsSignIn": "5ea2e8494744fe341bc0197c46f3db260daf4c4ff1953fbb179c4cc7150f5153"
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
