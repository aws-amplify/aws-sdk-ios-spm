// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.40.1"

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
    "AWSAPIGateway": "0beb311c1d3dd22a017372a35e11d38f03c72ec7d49cefd2726d68e13ccd02d8",
    "AWSAppleSignIn": "14200dcdd0c49a4a41597dcc35c923b494e04b8373248c21205c738a324599b4",
    "AWSAuthCore": "5f3ee80b5a984142261b6ebe53a9ed6ebd18dc7eb832ae72fb2e62389bb61da5",
    "AWSAuthUI": "bffb998b9b5126af02cded35009df82b4d5dfdba189d5c4e850d9135f13ee60a",
    "AWSAutoScaling": "427f28bb584b1053bf45d03bc347b6b819b82b1ee6a17e817e088d30d9c690aa",
    "AWSChimeSDKIdentity": "e8f32da7140a53b87874d9ccbebe966e53ed3b29b62af6c2df622f25ec71c045",
    "AWSChimeSDKMessaging": "49eac8966f3816e5fc4176af99484b2d9348ea7fa89873ddd9d1726c39c6a65f",
    "AWSCloudWatch": "6569874b85f66d4e36d0db5102972d60a6d1ab5829694565db571556aa785a63",
    "AWSCognitoAuth": "ab73c1b0b7acd6223c7f6bb07e606608f3a4f517b972cf674b3a6276f9e2d19c",
    "AWSCognitoIdentityProvider": "8ab61415092101ae48ec4521b041c84846f75053216e632942bb428040d3a65e",
    "AWSCognitoIdentityProviderASF": "54d810803fd7e6820cde2a363fb323fea2f169a7b375ebda2785aa63783f3d86",
    "AWSComprehend": "cff9598f33074ea93eb5483b83cb95e4230bbd773cd7d83628429568ca2d6767",
    "AWSConnect": "fa7d3e3ed1af335faae3b9daeb2838952efdbf3c00b001aa7709d9d04d7ce49f",
    "AWSConnectParticipant": "753e2a857446c68bbb3b7ab778e82a6b09b1234a8c7bce9345051cda772f035c",
    "AWSCore": "9728be3737f362d0acf4f7f466c2ce98bf9b9e289639809d6bf53382cc21bcb6",
    "AWSDynamoDB": "afc042e2a607cdeebd9bfe235a8964b8b5d7994746c2d204344d191a5cda165b",
    "AWSEC2": "0fd03ece74d97dc896364cc76457bcb07fc82f7099962e02ef2537d4bb5ef951",
    "AWSElasticLoadBalancing": "381f337a7e9ed05cb1290a21f4d6aa859f756397ba768e637dead766a1e8bc69",
    "AWSFacebookSignIn": "7cd2a528931925f41d340cfca418dadd0dcf6fcfc8742592a49000fa9ed05e18",
    "AWSGoogleSignIn": "65ae0f3362f8fd4876b17e02604a5650d1480f33d8c55d1c3115fbcc3c7f7ec7",
    "AWSIoT": "ebea775fc5ea2f3a5f110dbd1c56ac182e96e9a158c7df68e6bcd7f1bbe3c252",
    "AWSKMS": "2e58d20d4a8b86155112a00fb3caebef64d82d9064073ab08ad6731fda6e1317",
    "AWSKinesis": "2745cf232053a709fb130fab9c272f620a94f68141bd5ce969a2c98caaa14e44",
    "AWSKinesisVideo": "9f724f89976f3833e20b0dbcf9f8caa0d5660b914701f1637269b30f289b51d7",
    "AWSKinesisVideoArchivedMedia": "acff37e8643fddb3fda5257ff9c763fc97612ed2458e5ddacf0d96f3fa8f6dba",
    "AWSKinesisVideoSignaling": "6ad079bb4e14ad2ceb7752851b7d3e89b3b1dac9aa3e877dbff187145f582e84",
    "AWSKinesisVideoWebRTCStorage": "484ade5fc4ad937896cde9961e2f137fb7c230f2d6d79d67c30c6735b60212c2",
    "AWSLambda": "b2013cb0338d5479d4257bf1c19252f20d676b8ce8885f5fd256bf964ba46100",
    "AWSLex": "66e2af93441032c59d958117dd8b02048f29424b11300fc461013f03797f7cec",
    "AWSLocationXCF": "60fc9a2c2db0fd5d1dff3328db11739c99661bfaaf7caa4f6ef882a09fb8b87f",
    "AWSLogs": "96b25e76d05f1baac96e86674c0b05f0bd479367c3e85b13ec8b5aac2faf2e0c",
    "AWSMachineLearning": "56ed026f7873a2be203c1f7e87131c522ace97c53536b51d2ed541f9bcad1911",
    "AWSMobileClientXCF": "d232f5fae9143d47cb715c5156faadd07244865407dc413b9ec36b0679071ebb",
    "AWSPinpoint": "ee6e39a219a0d1d8247da697d6d6551684718d97748abc50cea7713fdc6ade94",
    "AWSPolly": "4398b270a51b356f63c026f7a59b40d8a0d9f43a26f1229cb10c61d90d51b9e3",
    "AWSRekognition": "530dc73b61bf6878927ecee26feb97a760852dee59890b1cfb6f01620349a789",
    "AWSS3": "4cd0c9c5ffa6092bb6d22a248567439ecf6403a0b86edda245750677484aa14c",
    "AWSSES": "6063cb24ddf4874d8bf2f3f51c802542ba4138f1ada2a2468d0d191d01f15d77",
    "AWSSNS": "f4f67442a925f2d7fe79f605d344c93b94ec029c65f4c66a8dcdda2bf9a51304",
    "AWSSQS": "d0acf8a4c17d5e81de5a1de8dcc0a3f77d86cd097b731f0d590c0414b30fc03c",
    "AWSSageMakerRuntime": "a9e35eb1edf99d847f697d23a9762b20442357900e0d54b71e4e16b1cd6e1c2c",
    "AWSSimpleDB": "653756722790b70d5f73426cf064986a88c0bc3fdcb4c12ced2b711c7d3dec36",
    "AWSTextract": "8e1c32d5c09b8251b0c05168b9ecad5ea8e6d803d1b36182d552b5b681a42080",
    "AWSTranscribe": "0f03d1fa21ff848438dcb869324fbdd703819e0f994de57d9a1172f755ce856e",
    "AWSTranscribeStreaming": "792b5a0e7a18ca8a44114dde566b6b822b02e31d744540cdd0d675c7a63006ae",
    "AWSTranslate": "0533dd2905cb646db7968ace8d9615319aa26b52790debcdac7f5bb33ae8f217",
    "AWSUserPoolsSignIn": "53c926435a01dace29ee1c6053b5c35269bb90639c5771e2ddfd8776bcc7410f"
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
