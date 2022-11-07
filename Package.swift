// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.28.2"

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
    "AWSAPIGateway": "39cd438e823488daea1367e327a3985ec24c3226ce61a02c31c033f6ce1d6911",
    "AWSAppleSignIn": "36f478818be42980c2da79aa7ed1768cf0a24aa27288a627d3ba69711a94ffe5",
    "AWSAuthCore": "dc80e74b6d56d37bb7f4e8e77c65e62ae65825bf7f63f69354285501947678d0",
    "AWSAuthUI": "4e23f83e49849dbea247300656af0abb95a0041bcd06383c6f87ec6aaf3d6fa3",
    "AWSAutoScaling": "a9d0f96ec9b75c914bbb50754368cec52c2528979b272b1f815e845e4b0fb536",
    "AWSChimeSDKIdentity": "0bec3c21aed1df1e81e59c81db9171a93409aa741b9fd4d5e79325d49f8d0fd4",
    "AWSChimeSDKMessaging": "4d1a93511ff48fce4a21d79c8b66692ee697753b9075ada5a7ec7e51a19d0947",
    "AWSCloudWatch": "d7735069f9b910089a66e29c0a40a42986ac1e0eb7559f6a82b91ac2e06732fe",
    "AWSCognitoAuth": "ae84a66b8658a7007b212df6d53f24e3eef5d928a828cb05b7fa042b7862f02d",
    "AWSCognitoIdentityProvider": "66ce6fd3b49cb928f260525a302728a53ab36e39a2cf169812b98e5d4499a934",
    "AWSCognitoIdentityProviderASF": "1b2e2e33e7eae1e2501873c6430ac7f27254c9c715d6e19ecb58ed2c78213bb1",
    "AWSComprehend": "753b3676fe90ac736971e52f0a8c477604ded3c467da6bbcf52f525e6ad10dc5",
    "AWSConnect": "ad6e1a626f78df39a339b1747d7e682f7115db3201198c515ee7ea3b9a211338",
    "AWSConnectParticipant": "0234f0a2aa65682d134305d1ca02a1a116996753f073d02ad6f7e6d24f73e65e",
    "AWSCore": "9092d23492ac328e452ae67b30348947952be81d35f24370f1b2b2c03181b7df",
    "AWSDynamoDB": "41578e947f1b2781990dee156e07b532161d77c32a11e66c3a78ac6a03830f12",
    "AWSEC2": "545cedaf9634d29332be13e3c128e65369a9447c0ddaf405ccfeedcc61e664e0",
    "AWSElasticLoadBalancing": "655c4afe6af02f6989cca7b49b4ae86540c9d4091d1c87a6181f66f12dc36064",
    "AWSFacebookSignIn": "5a1c064d49e8d91b92fb0edf0ced32df4dadddaf75fd497141b51e3056302f50",
    "AWSGoogleSignIn": "7fbe6262bc79685aa24db43e38a6639b8bfb4ca23b7139a7439dd14958bc369b",
    "AWSIoT": "5f0eb6dea42c6326a292784fa4832380dcc5d4601cc6242965a4a898b4c9a1d2",
    "AWSKMS": "4f99c45536f18623be47bf71565dd7225fe4d2fcb94292ad6b79c872c07e53cb",
    "AWSKinesis": "31d8080dc77f0eb2041ff73f3bd5e05ac25a445411b88a823f77c9595deef077",
    "AWSKinesisVideo": "c0996a1a71447b25ff51fa8641b1ffda55bf2f2c4603f9fa72ba9ba41aaf1342",
    "AWSKinesisVideoArchivedMedia": "2c4a34421c6f194ebfde2a937476675169e4aa10afcf4c5b18ee71a7931e1ed0",
    "AWSKinesisVideoSignaling": "858be18735e83ddae0b4ee4543c3b1e87f06d4465eaa1c7fdc640ecdadd5d9a4",
    "AWSLambda": "0a2803e18e34bb489b669ef9a168ecfc649a962503a76e22b1d8b7dceb6c2f12",
    "AWSLex": "9f51ab665e58f708f28ba4df1b8e6bf34c0b1a54d40bd33de11f22f8f3a26f97",
    "AWSLocationXCF": "720885f514d18e242eb38abe249fdf0d6a8b9f6a6a83b98ac97ac497b518c8a7",
    "AWSLogs": "e173f808af1ba2d9d2fe4798c5f91685012e8e29768d6f515521e8af49c95915",
    "AWSMachineLearning": "3f7f14ed376f767648c3b0e17a3dbed0fbd2a3161cde89f92c1ef038baa0d659",
    "AWSMobileClientXCF": "e4c82b067226ed4ed374b09dcb077eea7279a1872450bbe562ebeee8b7aebe04",
    "AWSPinpoint": "dda777a4ba15426d666a857a1d10b4700e51db71822f5417a4e9855dab78bd61",
    "AWSPolly": "6fda4a5e84dcf71ba4a259ef9d2777bee2290642e863d387f58ee386fef6871c",
    "AWSRekognition": "210c7338cc3f63283ed3748daf50c17923e7b815bcd73a37e9cb5ebe9000159a",
    "AWSS3": "76d86e6ab335f174efb01a13978f9d39db01dea40cb9d375ddeb6072c4cda4b8",
    "AWSSES": "797acd1c16b38bfde5302e68870a394d4003e6c2530c59418676e30096acba3a",
    "AWSSNS": "5f0d6bf225fe61a96ceaded1c52c03794b65c34ee2a15d7354149a4673c3bd6b",
    "AWSSQS": "e68c3d4349c859a2d368ae45ee3549ddb9cb865444921ef4a2ec9ccd1c2e5947",
    "AWSSageMakerRuntime": "e83d03b33c1d44dd4f27b6a423f2f522d57d3d65de496fb6a0ab62229e74543e",
    "AWSSimpleDB": "ec699697662d0c74cf7710152f8fda49f134ff9ee2c090b926ce8c33c31de18f",
    "AWSTextract": "4cb864d8520f55ca173610f29abb3b8b0c2186c39a6b31c7840d57851469c7db",
    "AWSTranscribe": "674938f0200241dbb9a49e8d446f8c8212ac45a156ac68b7da1b05b0b453ee4e",
    "AWSTranscribeStreaming": "fb946272e63036fcf442c8695fb20e40269f167ce9625b92af2f225d5f080137",
    "AWSTranslate": "f396922cef57e6b000900b9efd68a222d0c273010b0a9aa39c3c88a4a92af8ad",
    "AWSUserPoolsSignIn": "1a8f389ac0ca20bf6f47624ccb702ed555e492436b39b43fec40676a10d874ce"
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
