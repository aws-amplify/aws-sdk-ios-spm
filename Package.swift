// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "1.28.7"

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
    "AWSAPIGateway": "d0a7bc9896f9fed380ced88b4f7cd67fa12f4b82bfdacd1dd3b69434913f3246",
    "AWSAppleSignIn": "42f07c9160f9f52ba39e1c8c839a7813e56fc11a0ff15f8d10401076d6a5c7e5",
    "AWSAuthCore": "2974764a70203451fa8dea34493877c291bb8486ae18ad6cd49ef8ae6e86c021",
    "AWSAuthUI": "9cfdb5c287ce89e563c20a4670609c6b209a4cb306203561e6eb9c0b24687592",
    "AWSAutoScaling": "b4e3011a5988367345d08e1aa45c8507e161eedc501333cb484e96217be94db0",
    "AWSChimeSDKIdentity": "18303c800a7373abfd4e7de1316009633995800debcdab87b3163890fce636ac",
    "AWSChimeSDKMessaging": "d616236ac91dd1b99bd41727f29868e843c95f1c41d5a41ee2b38fbdae2c8af0",
    "AWSCloudWatch": "817aa001772cda121ae15d516df3241066347ceb410171825d1a0ed5fca15fae",
    "AWSCognitoAuth": "b54a4cf454fa82cda9c2879de1260c8f8e9404afa1d51eb2a615e1376290e2ff",
    "AWSCognitoIdentityProvider": "f814b6045f6663d2d381a93626a3f469d5ebadb17146f1e94060202d4e08c59c",
    "AWSCognitoIdentityProviderASF": "e858223126a484c3113a56f6e40bf3d5af79eab55070ceca32e643c857825704",
    "AWSComprehend": "5d66f4ae6775f4f61c6256594583b1f743ef5da6083ee07137082a20f1e7a40c",
    "AWSConnect": "c1e5e61ffc326ba98a7111cef129002714ff9c5f13e588b9238ad320e88ebfb1",
    "AWSConnectParticipant": "96289886a3644338060342c1f29fc4d18ea66501576c573b6fa14e518f11ae56",
    "AWSCore": "ec6e7bcf6d995515cdc93a08aaf38d875d3e74f8c141c4418ab2313088327a70",
    "AWSDynamoDB": "5be5b900ee3e81ea7505130b9ad5017b73b73e13ee715e112c9a9813b4ea2ab5",
    "AWSEC2": "08ed854d4148bd956273ff3638bbba9c4b4fb336c1ee96e82bc0de2f224da8d9",
    "AWSElasticLoadBalancing": "1267138f79f008e5cf88dbc8d7b9ba7c376d0cb037c77e2077d812037acb55de",
    "AWSFacebookSignIn": "c9c8d95bb3d0ca509885a45205e83cbd195b8ca9639bda77fa9db1cfebb28445",
    "AWSGoogleSignIn": "296390ec9198235820dbf8324618ba3ea2409af37f38637bfda5fe41f78a3f50",
    "AWSIoT": "57667ee122ce47ea75cfc58d765f1dc132787b2c921cd3e8d1478ad3ac315cfe",
    "AWSKMS": "817d18e2b684eb7d09414b1731ebea7e49fd8cedcd253e8ceb45c762b1dacbda",
    "AWSKinesis": "e0c32ae03cd17051492a7a3d89983d0550b1819934af60a0c2b3f51331c02b1b",
    "AWSKinesisVideo": "99bc450f524727336cb3af6dcc73d87990949b4d4696cec35266c3feea2fb006",
    "AWSKinesisVideoArchivedMedia": "d2541fd17429ed0d6a70d4d3069335c0338ee3bac73930d278cd5a90e7ccc095",
    "AWSKinesisVideoSignaling": "803f537799b44be60a2e5d8009ebfa96c60d952a62da95b3cef682ac4bc3e58a",
    "AWSLambda": "5a13de2b149158f6204e7d73020d7960adc4e3411d4c43083fcc3fd71fdcd96c",
    "AWSLex": "7abd1d960f72decd74d74c59b9e9a08c08b19ed55598892aa7a776ca1885fb7f",
    "AWSLocationXCF": "53ea11c818b11a5a54871ac5291c3eeca55d0b32541fa05296a59c864bc3fc85",
    "AWSLogs": "3203c6b721c2d36a0c78bd44d30d400c22b6205a2cae59a4fd867ea6580c5d7d",
    "AWSMachineLearning": "9daa35a8933dd5c39022bab9b00b0eff6ecbbbda0587b13a8ffc1f3468385118",
    "AWSMobileClientXCF": "14c9b32534e67cb282c547cd8dac55a4dbe803f056055936396e859cef5ccb1a",
    "AWSPinpoint": "2317937b87384d3820788a64ce8677788ab098501cb625be026065058ffa6c02",
    "AWSPolly": "f7f17dd9dbd49d1b582d897abf3a5e85ecb8a69675cc989d1802caba05d72913",
    "AWSRekognition": "4443b63d6460a62bea79b515c0cc1eb28d87dd48c19b7bb1001967461e2c2b9d",
    "AWSS3": "77d5689816bd1be5446b2fe1067c15447ddc7d613746ce17fcb16cff8192bbbd",
    "AWSSES": "dab46d98d5c18b0fdd6a7eece1629372d3b225f2cacfd5a796d92fc6b2801ca1",
    "AWSSNS": "522fb64d34fd2996c421623897c5e9813cf585e433c27a86766657b236647cb7",
    "AWSSQS": "7da713b0cf4f3237ac649e89440f9c36f7e6c171ec1e2a03ad7323cd169116b0",
    "AWSSageMakerRuntime": "710308394626cd9526b20d80f78364c743a556c28c764d640fafea96834a1d7b",
    "AWSSimpleDB": "cb2ffd17cbc8cc300286eb7a942d72933afd35b551ba44a720b3fa805c63aa31",
    "AWSTextract": "12ff558e18189f66372f25a182ec6974a66a215971a34ff134cbeb07edc7713b",
    "AWSTranscribe": "fde0dea216dbd64960fcb8f911958491d7572eb77258fec2b1501c120008d50d",
    "AWSTranscribeStreaming": "c3f177ca98bdd3ca0970e252e647af9426666e994504398cebf956378bdce8b2",
    "AWSTranslate": "f72641cfd7e8eea72db882bad1dbc02bf8714655f0d858f7a1a8489d64458b27",
    "AWSUserPoolsSignIn": "d5f3dfa894c3f947a34316f6bcf1c8fabe0585ca380cfc8023cc066159ede383"
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
