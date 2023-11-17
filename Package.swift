// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.5"

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
    "AWSAPIGateway": "85795aa6d52de7b4890bcb692ed638c8c97982775f2ae21224f030ba67f15f08",
    "AWSAppleSignIn": "021945d487985262bf5683d536dfbc2d4b627db276141778028741b4e24f435c",
    "AWSAuthCore": "537fe8d0be64d26b470d15c3e32d2a8ebadebe3d005e3c7e041e083b09962ec0",
    "AWSAuthUI": "e48f69848851de4fb33369d7393a1d563677b59c4da8a2abc575751a9e5d6950",
    "AWSAutoScaling": "16f9ee5ca29e8586f005b9450b5faa1fd12b0ebfd54b9dd3cc706e5a25039d44",
    "AWSChimeSDKIdentity": "2dd6fb16d7df20f4d11450495b4a7b4aea19f974307be1bd10c0809757fa061d",
    "AWSChimeSDKMessaging": "8100e5a054df609410b1a1d8863dad2abaf94f9ab3de656dc1011d6a0b1207b0",
    "AWSCloudWatch": "c8499ef9320105e083fd251eb0201b6587307c04a7207a4bb29a78d8d1f00536",
    "AWSCognitoAuth": "2dd716d485b9ee19fc785046a7b15c2e573be5ab8ed3fa8b6d0d6498d7b0d59f",
    "AWSCognitoIdentityProvider": "f18fd950a22a4a4797e0ee791391a276a0c4d7f5f67e1cab5d3e52598e9b72e2",
    "AWSCognitoIdentityProviderASF": "2fac59e5b6c303c7b1e867e8b9b9db9b79c5eaa71d9c20b13171a324ae275746",
    "AWSComprehend": "889b65b1090b877c3ad5b0979c87ef4d4a6419ca2f67c49adb02993f70d90b34",
    "AWSConnect": "bf02f60f61b471f68119a43440a57b83a606a07beee64861e78a9b039af84498",
    "AWSConnectParticipant": "c066ea39ba4b91ec49dad10e3222516f434faeac1bfd8c60ceaa121bdbd91fa4",
    "AWSCore": "e101b765aa078f9c1c323180cad85acb39e5c21a42f3d5b563752e3d3b37aedc",
    "AWSDynamoDB": "befe86b0acdbe0fe15b806b42cbe84b4507e67d13c224ea8fdae1ca509be6b03",
    "AWSEC2": "aab1198b27cf70eaf6960cec888442e751e2e3417ee17cb24dd62009d6c53133",
    "AWSElasticLoadBalancing": "29361d973aa1636e418c02990740483913bfc0c0da3110c89e15d13c291380de",
    "AWSFacebookSignIn": "39ad777a1828295c866acc94b25c045fc921d637a92c05b70b2ac257bedec89b",
    "AWSGoogleSignIn": "edce0840825f77644acf414b6ca4376247acf7bc5c5b1820ac1f5f0cbf9fb8ee",
    "AWSIoT": "8b225bbac2205d23acfb12c55aa634af65ea150b0cda65e6670103e743a2b99d",
    "AWSKMS": "d228c036620f02779388c6964d79a1e41ebf3064b23fec9741233a3256af98b1",
    "AWSKinesis": "5a6df987d2557252eba39f496b9a0aa5e1b84a7b820b4e49107a9a482e59b0a9",
    "AWSKinesisVideo": "68a00cf6153ad85b9782a0b731bc3524671529b14f127cc230300f722a38e623",
    "AWSKinesisVideoArchivedMedia": "1e79c3712e4a1522e9d71001239ae2e2b4f3e521c08bf0d2d83b6dcdbaecd219",
    "AWSKinesisVideoSignaling": "eb707c5568afb93ea7669ecb66137fff21977c16f941ae7913ed12f4abb60d86",
    "AWSKinesisVideoWebRTCStorage": "b2e50dbc4d973e5fb366a104db726b16f2b3db89b1f6fd049714c428650df114",
    "AWSLambda": "e3463937ab4595c8abc5bff6d8ba1590b7b97d6554f11535ad57a296c54095a3",
    "AWSLex": "cd71cc4ba833d939d0e008b59598694c8050d7aa0a79267827c1d7463451474c",
    "AWSLocationXCF": "0bf51c7391ce9089a71716533726f74307c1efcbaa8b54560fe1143ea1c04840",
    "AWSLogs": "5705bc7e5969793953493680dc8c3c0ea0cf12c68101c5d1a29a25cc6fc98634",
    "AWSMachineLearning": "70ea88d3f7388a5fb80146f1bc31b034bd39c7ee2fef703eb0e20b6ce2898e74",
    "AWSMobileClientXCF": "b509e7e68c64a98d94db60b4a16797cf8c64a66c40b31f5944297888f86f7db2",
    "AWSPinpoint": "fea814055313ec56aee2e045446fbcfb815e041333f5cecff45295f80490a40e",
    "AWSPolly": "b552b34e18a7ed39ef58a1974583fcf384743db9d9d3601c4056a10ca1a6374c",
    "AWSRekognition": "21ba93f3046ce8901108eb25d7748f45ac0e671d9559775078bbc9c00151b28b",
    "AWSS3": "b625d669285d32c8db9e1380ce687a45cb30794b1acf06e0884b4ee0265e2506",
    "AWSSES": "31f0338189c8da3fb11b780184934d6abf270eacef7045c6ad0f54974364c10a",
    "AWSSNS": "475521ab89a0ba08ebd00b3a93d5f75e2247371e32b19931e04e76c9ef0a9c76",
    "AWSSQS": "4c04641e65cbb5f0b9563e51dfb33536aeaaa355b98eb21141524f22ff4e1b7c",
    "AWSSageMakerRuntime": "7018b2b63f39bc0334cac227870923b8313b2d8b3367730b418441250c195681",
    "AWSSimpleDB": "ce7dca5da935bfbc12498ee1893d443c855156023d215bd4555f94d247294b37",
    "AWSTextract": "09218b28e706b6a2aa2f81811d1390c58022a41ec3cda4543745568bed47681c",
    "AWSTranscribe": "451485dccd77f839cf70b41a7e5f9a9d4507a8305ed22dc584cd82a9be8ee60b",
    "AWSTranscribeStreaming": "67c3b4b707866dc5e9a07e9206c6fc613b7073984ec7ba5ac8ae80f110bc6a41",
    "AWSTranslate": "7fc156307a286df341eac513ae5ac9f74841926cf144ec679e5bcf0a7a7e037b",
    "AWSUserPoolsSignIn": "0ad3def82fb135ed0a4e96982494347c728784f43be860f079d687add9c50b81"
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
