// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.13"

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
    "AWSAPIGateway": "2672d2f9a25f87f99a6c4ab3c4ac6509d6df9465c36b12a3654d4e4912bbc915",
    "AWSAppleSignIn": "bbd44f933dc0c0e3153a3c16081fb53a7519099c279064eb4df8e12b2a74d108",
    "AWSAuthCore": "751ed942f39d5c9d235103fd03774b124882ad8bd4c127eb1200e81149a2b7af",
    "AWSAuthUI": "813681880402851e4dec4275c5a8ff59e07beaf31c1543454f403431daad30fc",
    "AWSAutoScaling": "64979109c85ce0bccb0b7aaaee78ad780feded1a62dac1662c70f7538e5adf6f",
    "AWSChimeSDKIdentity": "b4e75f4b34e3792cd19637891187e79cd7c70bb0d68630905e0ed02f3a237ce6",
    "AWSChimeSDKMessaging": "f2f916d5e7d7eb79da4982388585a534b0d289d3e388399e35988b25e3b5c17c",
    "AWSCloudWatch": "70fd27efa2f62c14dbc0f2145ed6fd90b8b4f89b73034649730591c4a3aa05b9",
    "AWSCognitoAuth": "ac4051d723983849e04c198ca3dfc7368c4ab81919c9dcc7c3acf20482973c73",
    "AWSCognitoIdentityProvider": "3f81ce4b1e94427900c3aeec054b3f02064621b5b6d82c29bfd7d55f311dea66",
    "AWSCognitoIdentityProviderASF": "dc24ba6df38d94fffe956fbaf9649159c93c10a7baede75db5ac0a892f031ee4",
    "AWSComprehend": "eb6b53e69e6c4f73893a7f779a1378f582fed7435a432d9393a527b23ab61faa",
    "AWSConnect": "34e4554d54624cb32f6f2f03f7bb8282977451bd12189c09ac8ea3848e6c33f8",
    "AWSConnectParticipant": "02d98d07ccfc1d1fdaf1cc3ba9f7a6c149060beabf957ff82a8b2ab3cc89354e",
    "AWSCore": "15aa4e9ec074ceb54ff54567104236cf7a1831e4c26fae198c63a01cfce5e1cb",
    "AWSDynamoDB": "93187479ef8282a55689c7c3412fa315ade67465bc895bab2b3def51e62c9dd9",
    "AWSEC2": "118ead0c8fb42328c3b432825301cc7475c75eab056bd51a221cd488b60f5277",
    "AWSElasticLoadBalancing": "1d694e2fa20a2880f858382d223c09f9eb57ac8c7e1d352ea9dd243bc089cda2",
    "AWSFacebookSignIn": "dccfff8941c96a2a3bd81479ae2cf77d1bd9ffd02a9daab705625383842abf95",
    "AWSGoogleSignIn": "da26087aea1653c4864643b67fe02ae5b4f1f2c7cea6eb02f7acc32f9aebee3d",
    "AWSIoT": "297922ab4906972585296898b11af14d7d38d2404e46c89b74cc26e1ff09db8c",
    "AWSKMS": "fc136ee60349564db60cd66944152aac9b99e404ce3be15b6756b92b923572c7",
    "AWSKinesis": "0fe0831b73f3131bb3f80ca6748d6ffb3239e65782a988d66da8113cbde1d396",
    "AWSKinesisVideo": "6f42d8a421dd5063dcd7d7abc4cbe5872034e409bddde079e77a7edaeed0b41f",
    "AWSKinesisVideoArchivedMedia": "d1210e5dd1cab2f5b656347b112d5e5607d9599fbbf2021d9911a6ee623ac72d",
    "AWSKinesisVideoSignaling": "5b589a09eaa702fcd6ef6ddbe28c68b9cf5fd2939dd3068f1a591c651e8a3b83",
    "AWSLambda": "4a4a928e4e82f7f04d235a4d35c4ef6ab8159175692d138c7b259a5f9fc3a822",
    "AWSLex": "d35063e48cf75180cde90c167cb011b2c9cddc00c936e90db6609b4aa0eea342",
    "AWSLocationXCF": "99dd7da017d5d5dc0d528678abba6e4e077d06ea267355a2344f934214159971",
    "AWSLogs": "b52936af9b96f45785a709b8f440ca791b2e161313ddc76ead8416fe4f4c95c3",
    "AWSMachineLearning": "9de32d14466f69a127a905947f18f39dc531177c53438061d4455fd639fb00d8",
    "AWSMobileClientXCF": "1b7195728ef4f229e4bdf133d2e9bf1bd66f4ccd053f0579b83490372197edfc",
    "AWSPinpoint": "d75404ec25cb8160e865d580227ac590678e12862716222a35a9cc1eb8dd543f",
    "AWSPolly": "580f5b2cfd56626bb898be2f162269782c64edb2616d6e50094c6884b3d60bb7",
    "AWSRekognition": "0e9951504b96547855815d9bddf85b40f81c79eff49b3e665307be0dfb9162fd",
    "AWSS3": "8f9053b80d1c27083c39481e0b5b85489a4a21e7fc17b6a83bc2de688f0b73a5",
    "AWSSES": "2ca2a132d8a904b50dad72d22ac4974868cf1746c3b40a4fbf8967e8da1bb977",
    "AWSSNS": "e6253b88456cb6f3479a0fdb478473672a93502a6cea3c5d02e14580204fc807",
    "AWSSQS": "6555e1a09ee2e953691c2a4a3fb1f57bffff527f4b86c588f5d2a4e51346a8f1",
    "AWSSageMakerRuntime": "132679c2ae49f574a6fb891041a2ffab9092f109977dafc5f485d5f584e9d364",
    "AWSSimpleDB": "ed378858ea8862b4679a0a6d337f4e5c8b848a1aae62741e9b36cebaf720ee0a",
    "AWSTextract": "ac73c85b0da3b0dbc767ac55d8d79b78b5fe14376e7056de81eff1a45a69b8f1",
    "AWSTranscribe": "a6025c598eb02afea5f0df97d7d8b9e215bf12f9907fabe757357f0980a7c384",
    "AWSTranscribeStreaming": "1423c02cc9bc3044f98ee7d1e6c6559796d50f81eedacdf9190fa3bde92318ca",
    "AWSTranslate": "d21217d670aeb427be4dfb3320f907ffa238f02545c14a17cb9b8c7d6d04d34a",
    "AWSUserPoolsSignIn": "adfd13a1a26a4f059984913e4d3a402b8ef22364df8d269dbbe8c22705891ce1"
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
