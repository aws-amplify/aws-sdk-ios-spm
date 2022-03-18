// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.4"

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
    "AWSAPIGateway": "e174d94cda1579b1aea4cb02f6c13b9420da06d558b06974cbcb01a571fb277b",
    "AWSAppleSignIn": "dc9e102377731b1ee630f41944eebebc0800ef531bc8e3bed091ff0f2f0717d1",
    "AWSAuthCore": "852aed609ac60db9ac8466c1abe9356d027b42be2466b4852291768c7ddba239",
    "AWSAuthUI": "ff0476dce306593b377e57605fc15b74aa1fe5dfda3cd8a715535e702542ae30",
    "AWSAutoScaling": "e0b34f6fe46754951c49163a7d6435bf1980d4b68126a5ef3f87a8656139b534",
    "AWSChimeSDKIdentity": "02b1c60f76868b730281b5212c559f189db9ba4677ed9d0ea10936b01f6f8b9a",
    "AWSChimeSDKMessaging": "1974a6e0061a7ef4bd5b57fd78ba247b4f953dd9afecc2cb789335b3a89fbbb8",
    "AWSCloudWatch": "19dffc64d55cc5bd57af25987561b1ab506d66ed834d2c22ece97b24369ed2e0",
    "AWSCognitoAuth": "6624151b1f989d752bc6d3c8791b1d2ed27f6bf6ef24195f869f1fd118def7cf",
    "AWSCognitoIdentityProvider": "81f522940ed2b76eaabe8a5d079d351bc87ce2f4b84e6d5dac28e0bb87b4437e",
    "AWSCognitoIdentityProviderASF": "a07c5ea3adebe9b0ef6be58a7327f1183087798347c4d2f0ea3bd31d5897ded9",
    "AWSComprehend": "52ac27646dacb2b46f5d91fc43581b73e8afa0a0abd7c60ae0de7e20c0460fdc",
    "AWSConnect": "9fa154ec4c5526c164eaec48b3a41944cca31ef59f62aacf7347726ff7ca60ae",
    "AWSConnectParticipant": "24711a9541660e2278feb3523f9e8416c5f71e03cefc894ee30e719c806b1ede",
    "AWSCore": "6b5e49635a6eb3119e3c33aea5eed84e84eb9cd7ecb5b4820a891ab34b04a6b1",
    "AWSDynamoDB": "3fc68940332222e5a2358c5a8c3ac4cd9eb24ea8098ecf7df2e9ff7cd5e081bf",
    "AWSEC2": "15f66e9b737494d52d9fdd386ece8befae289ac6591f0da2aacae8199dcba1f8",
    "AWSElasticLoadBalancing": "0793069cd43a8b0ada547a9f3fc88d795b99b90e69e500e992d3115ee94210aa",
    "AWSFacebookSignIn": "92a98a7130091bc13ef81b0d9236c0575008db5eb18739488bf23304cbfef741",
    "AWSGoogleSignIn": "c5b040ff4accaaf23fb896a23213d4160023a2b2b7d62cdd3e9277a49c00aa3e",
    "AWSIoT": "d87db19d6bcf2689545272535ad3d6be9f64daf0fd533916f27bcfbab8af7e2f",
    "AWSKMS": "21975ec1d78f144d9e04793f8a73393cb274172a453c7446f994468d9e3eebf9",
    "AWSKinesis": "5f3551a3f5e8bf5bc992cc64dbafd388fb367f361fba36e65225e63c0c2af459",
    "AWSKinesisVideo": "2d3f5736e4844ab471e673dfc67997dd7060a4a15e278409438da0bf47079090",
    "AWSKinesisVideoArchivedMedia": "14fa146a13b2c8af265246187a8091f9150e97be8258a4f8ebbe2ce535d27667",
    "AWSKinesisVideoSignaling": "20f0dbf96012a817e797dce81a7ae280a67c87ee35f72dedd226b91995ce9679",
    "AWSLambda": "4f85844e62846e234044079dd5c12679a59bfef7a4bf0bdf019dd6a75e328324",
    "AWSLex": "03ce6fdd86e9fa8e614ac05d20940efa67c9bf79c3011af4a845ae6fe2a84cc8",
    "AWSLocationXCF": "1640cc78b3335dfdeb6566601813a7362e90d9c7d8b25bf818d7051ed3d4dfa8",
    "AWSLogs": "fd0a8ff37bd7b93a672a018ea9bf52ba7a4da16e6af33a8e4931a3fee3c4fd27",
    "AWSMachineLearning": "55478365db6b5deba36c7371b245f54eeb7f11243c6a1399cd7e30ce8250f48d",
    "AWSMobileClientXCF": "550997c705bdbd880d6e11d2278c496836657b40753b5f8c824f33de00e9769d",
    "AWSPinpoint": "6f255e11110cf370ae57f31a65fc2da6dcb6b5f19ac498be9bccc5a3275c47c2",
    "AWSPolly": "c34c9b62a67d2f4e224108e5e1591bc990a909eda47a894e371edf462dcf7759",
    "AWSRekognition": "0782c82b454d016708241a2cfedf10e0121e02e80accf18663459f5b377f07ea",
    "AWSS3": "b266b22357ba55c66817c56a74708718b5dbd0ded919bc376e3fe0caf4487e7d",
    "AWSSES": "921c670f43468be414581d9b4394824b9d7037c6c84db4d47a9cf9584557e26c",
    "AWSSNS": "01d57ff8f315b06226a0cc7ff614fe816f920da6313d8161967a1fbddc3fd902",
    "AWSSQS": "082af671937a10451c7d2dd66c4fa98c13dfd6057f2f025fa707d4032b4f2981",
    "AWSSageMakerRuntime": "dc55d9eb11eab88d21a90d3716e0cc303d62431e43d94170f2d8911c82dd1574",
    "AWSSimpleDB": "48043708b6945a053aa3c65d277eb61bbcfe19974ba5e1c8b258a2feb89e58ea",
    "AWSTextract": "d44f8909c43052522660380736aa4f74728a566813707f7c9cd9b28363540172",
    "AWSTranscribe": "10025ac368b0262cf6b75eeb2accb060ff163221b4d47e0627f0f41c65256004",
    "AWSTranscribeStreaming": "2a90482526f3c141b18a5ddaf54cf973af597ed58a08ad946399f4b597607bc1",
    "AWSTranslate": "29ead760d111f95890a0055cc55c6fbb84a451f8425afd5e69c8f5f403949dfe",
    "AWSUserPoolsSignIn": "3509a8f73862f3401085fd621aa2ae2096e492c49bff2727b3105950e1629d3f"
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
