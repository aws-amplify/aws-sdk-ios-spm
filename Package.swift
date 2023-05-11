// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.32.0"

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
    "AWSAPIGateway": "1b97492c9b3e9c6d7557b9bbc276f1a4f8ef0b4b6c66a1f34548a61e25e4e857",
    "AWSAppleSignIn": "8eb1ffeafa6ae2e9dceaa12c026bb9c2370cf5dfb378b4ddcfa7166611a7a209",
    "AWSAuthCore": "9f01c9afa0215e96c4bc39401e7c5e2c3456858ae5d08e88feda6537836e6e62",
    "AWSAuthUI": "6318e8a70e5ee0b91c5b653ae330f38be55bbf68f1e47bcfb785eb810f1d6033",
    "AWSAutoScaling": "9a74384a2d17bff0998e7459bdc95d2f4a46a31bf24ba885bf8b4ad3fc7cae57",
    "AWSChimeSDKIdentity": "7cfa5346ea23490c7ea23845b59522aced341b5d2b5dc1171cb4eb6a4833c587",
    "AWSChimeSDKMessaging": "0b308449be5e4d8ef7fe75dc7bb232e4fdf76d04f2e0200be475a1d5b8c864c4",
    "AWSCloudWatch": "23a4e303382edb5df022ab6083671db709e1f12904b967ce689e583e199ddc88",
    "AWSCognitoAuth": "7eece3bd70c80e09e52953e87576185439185a9b7e676b7fbc8b47201578783c",
    "AWSCognitoIdentityProvider": "80c573ea18587db19fabb8f346ff0e95b860eb88c6fe55503f324d0597b40b07",
    "AWSCognitoIdentityProviderASF": "b8d61eb10b420f30037e59993025267d1067ea8c1b434a79c2156b2ac34e5c93",
    "AWSComprehend": "af2537c71e0593fced8d55d35e33ff75c9e19b0abfbc3dd8b83730016cfb0677",
    "AWSConnect": "664fc2ac766ddf12ce0cf9dc24bce36739e1e6406d8fb0c6c53792d79f03d698",
    "AWSConnectParticipant": "23b6b1b324fb7d8b3fdc839bcba31b58daedf601cd42868f1f553d02d4dacc70",
    "AWSCore": "61425e65c028e01a1e598800e8d67bae3fc05328b734f63215cd1a19cebd1066",
    "AWSDynamoDB": "96ae0ac269be71a6ab6ecadc40fbebb12d0e54f182f041a571acb24655fc381b",
    "AWSEC2": "28219b45d4cc925015fac87167bbf2a9b2c93bf21090bb851e0a15532df77d14",
    "AWSElasticLoadBalancing": "a0a3be674a1c07843b3a8e2b2cc05f0c92133065876d427656cc1d501cd4ffbc",
    "AWSFacebookSignIn": "a68a0b073219d86c007e53bfeb793cc191669924bad5f38cd1433a666514cb04",
    "AWSGoogleSignIn": "65b009c1084ccae9cad4a03eb077a24730d644c6ef14566ebddf3cd6d1906287",
    "AWSIoT": "4feaf690aba0f767217406a725c80a573e94425182bee37ffc35e4622f9a66cd",
    "AWSKMS": "7857e4edf50c56352217f9d6404c864d2647a56ce3058575a9a3f344b742c3d6",
    "AWSKinesis": "378ab11ee94ad0becdcd0014d573d156ac217cfa4d8783ce0528e4f018c314b6",
    "AWSKinesisVideo": "f82e82e3f2f3553cfc9e31a65fda3421e4bb1ace898de2e86a2c60ccc50edc96",
    "AWSKinesisVideoArchivedMedia": "14eb3795d0a778acdf1c87569cd0f00bb060b2d4fcc585941825310c0120c81c",
    "AWSKinesisVideoSignaling": "1e3206ecea86ad11683389de8fa9e9a90898c1e5cae5d745b7764edbfef0f013",
    "AWSKinesisVideoWebRTCStorage": "8471667cd5573b57b4cc9e7d94919f19a9b80b58926b68397232e9c6d6030d12",
    "AWSLambda": "c5f17a6bfe69eaa10b19281b9cbdbb7bf69dd7e878e18f897445021ea3633571",
    "AWSLex": "352a1725a12ba7985cf535e72b1e7427e5caa57bf655303fc0fef66bfeca5965",
    "AWSLocationXCF": "c3e677454278d5a28dfac5b3c198d53c44dd44756630d47de4884477af102086",
    "AWSLogs": "13fbae3e1e3a75dc8e1fa730ae40644e0eeb2e944381747d2126675738ddd38d",
    "AWSMachineLearning": "c3b5549e22b172043bbb1f6cc14604703e38fbeb124c9169a884ef7bf7b130d8",
    "AWSMobileClientXCF": "a8f79a480d772e8da9ceb04dfae8aab44a9ce1f20f4e422b521e27b2726db4f2",
    "AWSPinpoint": "2f589eaec9ebb7babb60884f84836f2cf742d46e148002f445b4fbc85c9869b2",
    "AWSPolly": "18ab530a33695b52c68d720e19742c14730a5e59a2abd72d3bbe5542b68ba272",
    "AWSRekognition": "7d9c56263a1d9d70bb90d395a11c4212233629e886c70ddbda040aa6495c2fac",
    "AWSS3": "6166a3af7c0df2bb69aefd017febe1b640dc8fd23ba9ed07bd56df981654a012",
    "AWSSES": "46d258132c388fd891fa3be775449832aa9601f22c395a341b981421b08b17e0",
    "AWSSNS": "0fe13351ab00800b496f61c1c1b4264f0b5818d8345c811bcf9c3343e20cf25e",
    "AWSSQS": "8c001938e4027da5eb7fc6168107e60cb98f43be6c63b4c2d5dbd3d51bcbe72e",
    "AWSSageMakerRuntime": "55b609e983b5a48e212fe228c8dd15f1ae9cf12beef0882c17c22034016d7b6f",
    "AWSSimpleDB": "a0288e290684a61fe6248d76c77a468c0ca573b10272742f09501bc57e5c7cac",
    "AWSTextract": "21d943d8307b6783b6fe4495b3deb06ebbcab1a0dc20a8c29dea32e9838397a6",
    "AWSTranscribe": "98aa24a5c5d23221b6812ac93008592921c486d7768e56af41b2593245509697",
    "AWSTranscribeStreaming": "6d4a551ce7c0910e9cee78ef93570b0125c5127a10f5d19acf3c719c654c8af7",
    "AWSTranslate": "b9c871488301f43782e06b96fca6527c856ebe58cb11c55de84700da41b399b8",
    "AWSUserPoolsSignIn": "f0b4a6ef88bc01361b625c7f31dab23b535e5def677962138e335b8c6da56609"
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
