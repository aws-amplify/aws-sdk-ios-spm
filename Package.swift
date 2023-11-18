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
    "AWSAPIGateway": "a00150d3faaa9b20e488e712c64781cfd1e7aaebf1a0fb5e77aad0b14e3d7370",
    "AWSAppleSignIn": "405291a74a70ef286ba7efeb3199615b4955b54587114be35aaae9cc14b170e6",
    "AWSAuthCore": "962e489403640aa89f5e7d12ff6e31ee8b0cdea820f4a2b30bb491f0b10937ee",
    "AWSAuthUI": "8870b0baf34f7013c6067ed37099be3c1305719c66e9039661288a69b2d46706",
    "AWSAutoScaling": "16f4f68170489a419d04c451020fb5d1cccf241eac439cecba78fcf6d40bba47",
    "AWSChimeSDKIdentity": "7a5fbba4c641208a6362cc5fea4f8e6e0ca0d4cfa9c4e613c1675e416ef6a620",
    "AWSChimeSDKMessaging": "5c05953482e1bb535f25e13bbb48bff0529e38dedee93488a78939399f216aa6",
    "AWSCloudWatch": "7df2694eed36439adae3a5ad6de17ea2557cebf4eb554a11bb963a9fa2b00e06",
    "AWSCognitoAuth": "0ec733146493fe6bef9ceab9a6c5160adc9db1bbe91f50fc4e4ff7024a810621",
    "AWSCognitoIdentityProvider": "23f2cf0f605c9bccce79deb1b006ccd573bc49c4bdcb3ea45ddc3ad11a96f7c0",
    "AWSCognitoIdentityProviderASF": "d4790f1bd3bf1ffcee8b73756d93690e2adbbb754ad67e1d61b0418fe8f5ad75",
    "AWSComprehend": "a333f55b2517d26db16c018c19e1881749c9526359ae25196e7d9711ce304eff",
    "AWSConnect": "ab434c101f43eb03cc2c4d7e0e8ed142378dcc95aa680f0464facf08f3181c7d",
    "AWSConnectParticipant": "b3a9dc8d68a433fb3e01afd8afc7a19d2c5a6f118fc64cb4ff1f11966d7be2eb",
    "AWSCore": "f7a1a6dae27bb5724a0bcee5166f4182ccbbacad4cd5c202e4fc241eca10e9ad",
    "AWSDynamoDB": "b008b536e2f17b45ba87abe75839e9ddf614a4438ac2ef18862ba72626a680e1",
    "AWSEC2": "b4962f00c039611b98f5f94e3580771698ac2f4315ca0d3336557ae911fc3e62",
    "AWSElasticLoadBalancing": "60a8021eb9498b25cfb7e1caf7aae57d2e150ac8183e73aeea08ed5917ec6f60",
    "AWSFacebookSignIn": "a3d99ff25fc87ff838dd5b94ce80b081cbc7b8e6506e28431132931e7e60ce66",
    "AWSGoogleSignIn": "575da4be3f132c7de2821f5caf11198eee6dac6f0b04d054218456bd129d24b3",
    "AWSIoT": "7eb599ee5030907ad647980b9102eb9c36c0b99ce715e74fea6b47eb7ba8c921",
    "AWSKMS": "8ee2ba243801d16d8b646adce14456d4b16eaa454ee89c81a97483497e3b8f59",
    "AWSKinesis": "a0c100efa402d49256585b152bb9d65a4b1f430f479d3d89397cad14a90bc2a5",
    "AWSKinesisVideo": "7f90cea7fb26dd23edd4ac6c3367b20c041683b3a68dd95126883886046282e9",
    "AWSKinesisVideoArchivedMedia": "198c1a62dedd303a5bb9e8f3090904a7773b9e9f9977fd82349e683be4919b44",
    "AWSKinesisVideoSignaling": "fe543dda6eabc2c1edac2bda7f3c7b83fe9a45cb58d7d744c293a4a0f5d395f7",
    "AWSKinesisVideoWebRTCStorage": "c790966ea3ed0d7e07db702f19a8ff48bd006a45d4027ab6f6485c86abd82f5c",
    "AWSLambda": "4a1033898fe39f895bc6673e3244623e092d56f3fb4c14d2551c36e485496153",
    "AWSLex": "f5dd0c456b29b98f19213aa394a2a55b4d655fd0c371685e4599e6261fec1254",
    "AWSLocationXCF": "4bdff3ebb3ec1aea8be1d9a67c9b2b03cfac545f3b92f17b4a5d6cda6c7c5f9f",
    "AWSLogs": "5a1f74a107cbef6909351c82ac90b3eeddeeee2921481ee665560688dbaeb922",
    "AWSMachineLearning": "e7a89b10825d57b9e785ae46731d9ae00581512648a41ba7168ab92ac43da805",
    "AWSMobileClientXCF": "4b72101cf5bd201d9c2f8c535336acd7622587e913fc16e77b5c3b8c43105951",
    "AWSPinpoint": "6cae4431b33040a022114c1a6ee0ef3cff0783494c27a25440caa1d2b2373525",
    "AWSPolly": "37eaddae7189628cb361e9a396ec7e3bfe2191f0104ff5eaa859d899a95b811e",
    "AWSRekognition": "b735fb95d8c0812ed62f0a671c7ac282deed727671af25bb95f500f28af3ca18",
    "AWSS3": "63918394432a1322313bf1ba23641514a1247ffea22604c802d1f52935edffb4",
    "AWSSES": "3678a01fa7c3f676aa37d5fe13bf649e184ca46e3dfb55b8e0fa000b70a26bc6",
    "AWSSNS": "6a9b9f0a2c230774228a8e5df8c649a34d347bbda50539610c5bf25f01f7f9ef",
    "AWSSQS": "0d0aa82a7c1f1bfe6988a15c833cf2853b88c797777089a199bd2fc24edab405",
    "AWSSageMakerRuntime": "c4f2afca47106852389686ff2dd77ca135cff409d1ffffa22c36127fbd2473d3",
    "AWSSimpleDB": "a117984037d5aa01bf6a08d1d7e6ef112a536df4ed826055cfc52636bb13df3c",
    "AWSTextract": "31a8d709e9e56a3b5f82e3aad8cafe3e4712c3cfca7095e984ede26ca055c07f",
    "AWSTranscribe": "76b8b5ecee54f7e55598ee810d90eb3bf168b287d0acdf855711819f49d0aa15",
    "AWSTranscribeStreaming": "3185965c3bd6d727982bf66f76e3753a656d9c37e4b1129b5cad3c830e32ec8b",
    "AWSTranslate": "3b0d5c5fd8fdc660d0d24343384eeb1999dff30ed5ce756ef32c6fb8e5794525",
    "AWSUserPoolsSignIn": "33a867b100f1353476a75b58764f8d9412f1a7e7b04d7db81e76cdaa0d96ed04"
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
