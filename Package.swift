// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.5"

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
    "AWSAPIGateway": "0cbb5a0d5b4b8cab7fdb4a1d9c3fe343a154bae89ee354753ca729f62c6e1bed",
    "AWSAppleSignIn": "2ef4488ce5b609d2fef12fc4bd8c4a744864355d74a0665cc88023e66fc55829",
    "AWSAuthCore": "096d2536f9521757928dff7cd657f50f796d7778b7656d545013a473512bc871",
    "AWSAuthUI": "64b91e17e909e7afc58a9a7c94f2ba32abe92c3342948f1e577937fa55a561b3",
    "AWSAutoScaling": "a76e4aa94000f89fe76355b5ce8c1bbaa234f732e0fdf51fcc926d71cb166987",
    "AWSChimeSDKIdentity": "13b6ef580733c93ed5d388af0f8dfe103e869f7eec4c89f8d0c561012dec3e0c",
    "AWSChimeSDKMessaging": "665c7c223b49e5c9fa4d1b6566e62a1b764361afd0eb48b7312e8407fa4eea38",
    "AWSCloudWatch": "f3dc1cea50f82fd886659036ec22c1dbb859f85f7ce3f3268f8fa691273affec",
    "AWSCognitoAuth": "661aa610a7540a1313605930ee3441d2650cd65e90838874e050cea62569429e",
    "AWSCognitoIdentityProvider": "ec31e610f5d757f29cf858cad89d2b1a8b1cf19968f2a7b4aef5704e4ae62f46",
    "AWSCognitoIdentityProviderASF": "c0497bf0c94d349d9875c9c0580c9d31a866db19a248cbc29f0265f797524395",
    "AWSComprehend": "10de94b9d4f60052b39809ea541734e33e3bb2742437da8151ecd08b409ce8c3",
    "AWSConnect": "38ad167a43ce49bee9d5a764bb37c6bfda81f11d3d62d49afb3a83fc3ce6e650",
    "AWSConnectParticipant": "a9fb88216055c7d5b6bb2bc189c5ccca5c7a2969d323afa8e70efbe5339b5c62",
    "AWSCore": "ba263fbedc147a94e311da54d33a8561f0fe8f6f920f821d6f005cc5a8b9f8be",
    "AWSDynamoDB": "6cd32a493dca227e30214b62d8898ae67328983f3ce5a01260ff5f85dd66e0bb",
    "AWSEC2": "00281029f5f4975e9b1ac3f45ac225a9ddea72004c700b53b31af1b563a5f43e",
    "AWSElasticLoadBalancing": "044f6d63a1900c8545d80d37d13a2da4749260f520c32a07c5abf4fdfe715c3d",
    "AWSFacebookSignIn": "25219be3f3432d5506e4ce62b74726cdd7b637fa53fb2abf641ca900f301a1d2",
    "AWSGoogleSignIn": "ce013f82c0a96a5315bb655e939ec4d074cfa92d4a1ec85cb936314e2344b406",
    "AWSIoT": "e7b95c2446023a08dfcc09ecc660494b8838032ba4d0c4944f7aa5b729bae207",
    "AWSKMS": "708cbd23006d06722450f36caec2374c7a4aa2eb7cceb6da506e0524eaa145ce",
    "AWSKinesis": "78b005a6251832815ef6b834257a56e9f3a1836c94ba989170f12952ddf70ee7",
    "AWSKinesisVideo": "620e253e537db6c36352948d983a7d2182c75921d8f492a93f01234175dac5f1",
    "AWSKinesisVideoArchivedMedia": "4439b900f4d318ba52bb77ce69ddf59ab52d7bdc79a63b6aa3c241793e28a2dc",
    "AWSKinesisVideoSignaling": "4ca799901f9a94a48564a7ee66bb15883533cb609971a38b87c05782d7439878",
    "AWSLambda": "75d37d67a286767d25bc02ec26e9608e0f6b84f795a0d4b0e06caa56d01592ce",
    "AWSLex": "f5c15870019d2ae842ba906680e0f4ea85c505af0679e171ff5ab9d63dac9f30",
    "AWSLocationXCF": "598590e82b70485cfdd9dc76edc9e535d75d3ec2704f5ff5ee8dd5ddc5e5e428",
    "AWSLogs": "1a907cf2f4c83f5c966ffe1e9516882b833ac2a95bd17da574624d725c280fe3",
    "AWSMachineLearning": "866c6bab745b1492f4517a0bd0bd6aa2717abed76c3773d916b4ed41d186563d",
    "AWSMobileClientXCF": "80ba4d1d4883acb6b54876f09a1ba91023825635bf359082d6887c1151db542a",
    "AWSPinpoint": "d09d2a6835d1b9456d69b9d36328efad98cb48be8b2d559f56200a1176dc4944",
    "AWSPolly": "6c8f10ab001bf79047fd7a1b796d8fb4ed60c7c1d21badd43fa5f4122f90d4bc",
    "AWSRekognition": "57608e2e57a9a2a5810024ad3d68d803ab153492cd4598e2deb4f764d61f6ba3",
    "AWSS3": "559225028a6205a46774aaa2b732bbea711301beceaefb43b05baddb41a9c328",
    "AWSSES": "f281c9f06d49135a7c0553255637eadb3f808b63db04972ceecc12811f431791",
    "AWSSNS": "3423e655a779168959ca8f2a28567502bc10cda6bee4daa51b6fb3ec114da15a",
    "AWSSQS": "dadcc45a8b9c8ebd27f41989316794f78221cd53cf9120f0de9b99856641da1a",
    "AWSSageMakerRuntime": "ec66adbb3f192fd95eaa9cfb9eb4bdbe30f4d4ba264c1b55ce3157a5d1084226",
    "AWSSimpleDB": "71a3a2c43ab8a0c95dce4511ee3fe8a77b9a267a933ff9649b6ad178a530aeed",
    "AWSTextract": "29bfc083c148e1761680c0a2c9fd6391275a0eb88de713669839ee7a1772f52d",
    "AWSTranscribe": "e1b115bf34ecc639d3f11f1807e31e5e66429e5b2f59b75e46c7f1ad85d8d6c5",
    "AWSTranscribeStreaming": "f665d4eec3ad93c1e308207723a728d62b7dc5ec88c2eb95221d3773dd86571b",
    "AWSTranslate": "ddaa389594f3cbd91acb08c2e768f5e0d9d28171b078494ab95275436e86a73e",
    "AWSUserPoolsSignIn": "059a1ba2da6d1d260681621f79a7472360e32133e1801441b1b97289faba7c52"
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
