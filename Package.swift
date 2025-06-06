// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.41.0"

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
    "AWSAPIGateway": "0758bee99cc91299d667eb3efbf17dd6c5bc3d32dd460d44d7e8dbc30bc82f1c",
    "AWSAppleSignIn": "07cba9e2138ec98d0b8d70f21c9ae812cfca65dabb72fea50c011bb21ac8fada",
    "AWSAuthCore": "4a6cc38b908282dbadc534efa5e342babf0830a74f492486db66485e0d6a48eb",
    "AWSAuthUI": "2af24e2fa30984b87b984d6d6bf77b2cc64d3f9b449436c073478c1342b6505f",
    "AWSAutoScaling": "01a2b1290c0958b424022c0577d0c929a94d3547cdeb476b21bfd07aeb602bef",
    "AWSChimeSDKIdentity": "b3fd2e6042f1ae2ac372cc669905c537e7b580ecb6919aab89f6158b198832dc",
    "AWSChimeSDKMessaging": "29250e734fde1f13e0a9203da3cceea1fc5ce84d562028d601db5ca16fe93e01",
    "AWSCloudWatch": "8eebeac0455941d32005f6833b19dcdcba6b8e8f602e75de5f279d9a5fe336d4",
    "AWSCognitoAuth": "a920cae18da05be6aa4b62a9c184dfaf36285cd8262dca2bfa428482f688df5c",
    "AWSCognitoIdentityProvider": "bedd65dca74dd4fdf649b9d29c31e74637f839c0f73e63999d30ca675973f792",
    "AWSCognitoIdentityProviderASF": "1171b85fc49464118b8bca6c9cfb529805eb207f4efc63e1127370dba5d11a30",
    "AWSComprehend": "969e7572d246ad2a87ba06211ac34c28b6fde837b6525bb47b1a6ac9ab87fe3e",
    "AWSConnect": "4d56f833d37c31ea3fa653d5cc32b52c6bd16da2bf833880d20852558be15828",
    "AWSConnectParticipant": "51287068e6faeda5240563354939001e302694556240e4a4b374667e5c4d8f88",
    "AWSCore": "8a42c3da7efdc47b7b7e40a3cac0f1c29bc7bd0020d630fc1bd31e29caffdb3c",
    "AWSDynamoDB": "e229c40dcd8f9e516f1da045a3ac23d001a53d217f9af6421bbce320a9b978cf",
    "AWSEC2": "3b44e7af8950509ada99de3dc69659dab0d75a224f37c888810cade48bfed10e",
    "AWSElasticLoadBalancing": "bbd3e570b07569a353a53171a6a684d44045259f13a4e46627bf342222a6c34d",
    "AWSFacebookSignIn": "1c39bbf5f19db61f0e8d5ad4c69af968fb58b486a78b243d465cc3c60c3e1f2d",
    "AWSGoogleSignIn": "7054b1dcbba18ab7cca253de0b64ba7cac9698c963b0ccbcf311280b9502b547",
    "AWSIoT": "e563b9e9c1bdefad41bfecaddd4bd1002cb26d7d5fe9fcf8931234fbdd9a2255",
    "AWSKMS": "4d8232c3634e18064472f9a19a92163a718bb1a6695bf19fc1bb008dbbf0c402",
    "AWSKinesis": "1c24ba5ab0d323f06c41f0eb8929e080a9d72c4c8ca71208c2ec2d8a3a36c902",
    "AWSKinesisVideo": "a909c4e29d65b3c7188975ecfd8b1de3727c927f9278c7d8a9bd19585fe1e516",
    "AWSKinesisVideoArchivedMedia": "476c0f55b35cf6ec86f23a73a81aae2acba648085ef825e14de3ebce7799fbc7",
    "AWSKinesisVideoSignaling": "dd4f4b80e9cfa08c47f744df4bf5d69256eb63bf0db1e4aedd9d4ffaa53234bd",
    "AWSKinesisVideoWebRTCStorage": "006eaa2bd14f5c154f75b00632fd0b7e9d414df653b3c64eaaba6da7329ac579",
    "AWSLambda": "789ce5058ebfa67dcd124d32ef3a371f370a450339b48cf4e71274e8a244a328",
    "AWSLex": "49b7c01c8844f35f6bd0f863a18e3ae783f47d6b4f88273c9e7e4847f8b1b456",
    "AWSLocationXCF": "4faf40a5e01edcbaf5ae055ee7e39c6cc412ec9cbda7e8f79f68d768919d6732",
    "AWSLogs": "7c1d9386a69dbc6219eab60ba5ac0f55d09148fe76d3a9a6198cc0a30b774581",
    "AWSMachineLearning": "967988a338dda0364bffd0283f6410bb1fa3719981ea0aa7413f0b16733331b1",
    "AWSMobileClientXCF": "f7c99e4d1047782648a1d84e43675b4452055a86cc19b3aa30dbcb0b61d64383",
    "AWSPinpoint": "3e2822d923f3e441e657c682a20a9ad3ebaa629676d2a172dbbc75f5396a6fab",
    "AWSPolly": "d885974c33d44236e385a399c55925d194dd105b9295c206502fe887952b5c9a",
    "AWSRekognition": "65894cf42538a9e6a7ce557f5993ca0c19b2e29f2cf864c4d5a5ff05d25a5aff",
    "AWSS3": "bb017dd3726ef20443c4bdfd171f852c35215939e751a0f8cf53c0c891df74f9",
    "AWSSES": "2cc3aaebea456ab3ae05825d03bc0090d71aa96eb8ccf131c4ba7b89e01b5098",
    "AWSSNS": "2fd65f7749498a8da2ca04d199af82022cc68e152231aa111727217a2d6e8e87",
    "AWSSQS": "6141c8ca77bbeffab283c120694f28647b68743216c0725a90cbe90fda144b7f",
    "AWSSageMakerRuntime": "1d71f5b08a5c3a50f01b76e639e3e2102de3ec5f36b1434f6266b3f022329338",
    "AWSSimpleDB": "36a8012646bf3442d0b70d2fadbeac81623a501215eb10bf5f06359ec6305407",
    "AWSTextract": "835d4e9ca194c3e1e9aad6ddc72b3a33b3c2e32904f97cd47bf6f17285ea1a14",
    "AWSTranscribe": "bb8d63289a66430cda69b84cf51a472b55db3544ea99aad1d0027fb4bc51cbcd",
    "AWSTranscribeStreaming": "69706894ace1e2586bb09fe3eba4b4d216c325c4d4bc1a3e24662f71263c20c1",
    "AWSTranslate": "2b9455a2c750fbb651294967908c9fc22dd4036e30e8dcc601cd25736e4248e3",
    "AWSUserPoolsSignIn": "fcb227126239c3142a57571659d715cabe9cb4c57919cbf89c90447b575e82c9"
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
