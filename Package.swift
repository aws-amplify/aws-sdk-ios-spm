// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.6"

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
    "AWSAPIGateway": "136b43f2c7cbaa3714b78aa631e392320ee05311fc5cd11d6e93f82aeb338adc",
    "AWSAppleSignIn": "d2e3ad464838fddc064b439e5e160a1e6908cc8dd697ee056261ad533a149e67",
    "AWSAuthCore": "8082a6261c9a3e028a3689611eaa4dae548f1fbc9d5d9702bd992bbbaeb961a6",
    "AWSAuthUI": "971cdc55cb29efcc58898c7d07f00ce34df5e58da0c1aabd58b490d01d1c90b6",
    "AWSAutoScaling": "f35982cccf3ddfb49bca89f01ee067bd1a3b328766ec96e5307aaa02df57d435",
    "AWSChimeSDKIdentity": "2a912f730a3bb86669bdef0bcafbe5cd2d7d02401a05953a6e3d16d441e2acea",
    "AWSChimeSDKMessaging": "fd4de4c62aba558943018828bedf32f2d361c55699636ebcf396507084323a0b",
    "AWSCloudWatch": "635dc7f809217be5e753a2c720e0f6190d141a9f8a26426a507cab97a0e6921b",
    "AWSCognitoAuth": "cabcb92cb13b692f66efd2cf556ba16832096767cdabcd9171c20d74d320cfed",
    "AWSCognitoIdentityProvider": "863c78a5a1d43202369f17666517bd43c062926be07fc1ebf2bd5a9dc81209d7",
    "AWSCognitoIdentityProviderASF": "168029cf561a8cbb6944a1525030e014bc6c6b908be3af526a2c3c91ef82979f",
    "AWSComprehend": "e10078198f28d4753955eca33a308c62fc1e425f56ea7aaa8fd07a215cfce083",
    "AWSConnect": "dd3357ffd83ec36eb79c3d34ff1408bf295e16762e2ac48a435ccee70b78aaba",
    "AWSConnectParticipant": "8775b23ccb22d2298df4446fc30ffb00b0e72a2a817820efdb206f7b044361f7",
    "AWSCore": "7d493acc8ceb73bc69a32bb42b5d465002766c3378e4233aa09b5fda9632a313",
    "AWSDynamoDB": "7643491415bda8ea99b072e1b1425756b1aa47720a00d30e9b48da39be6838ac",
    "AWSEC2": "fa5e4c5e2f1e5facd673f0203fdf8a935d7bc1f0b64095d1f18800f060b63ba2",
    "AWSElasticLoadBalancing": "c1d13a5f50be4005c6edefbde5f95797d31afaa8d09b18302625b4d9101ef737",
    "AWSFacebookSignIn": "50d0125cf2e74772f630139595a22d8f6d75846c19a5dbaea042817bc3296daa",
    "AWSGoogleSignIn": "926f8a94dfc2b455c6a79df7f5561d4d9bb28426526befe77c8529fdbc12ca35",
    "AWSIoT": "ace14cf19c418781c33801450ce418e154707d9da4e2dcf00a14bea27d03d85b",
    "AWSKMS": "f35da1e1bb59734d0dc19600f454b475a8c97a8ccf24d21818d50fe031227651",
    "AWSKinesis": "60b7c3e5ba89dd0610f09440524af64df61086de86fc4a9204c5d4d4c89f458a",
    "AWSKinesisVideo": "d9b905a500748dd970ed44e11632fbfb9ac366fb34d481538155a6972989547f",
    "AWSKinesisVideoArchivedMedia": "d132d80ce4df2f58a8dc75061840809d8f21278834ae21d932bbd35216d92619",
    "AWSKinesisVideoSignaling": "2a04d1cf04bc794cb2d137c86aa22dc867c93e01e626533d94a1092e4d1c1740",
    "AWSLambda": "bd9af3528f27b96a7daba514dd81f79988c48c49f8fd7497660e85f1bf4ea806",
    "AWSLex": "6ffb379097ec5a0dad6077b4499353d1cc275ed4a82efb970138f9ab07a5772b",
    "AWSLocationXCF": "7ff0dfa168381b7c5961f51cf2f3e002f3b6928f9931c42a043d3500d94b544e",
    "AWSLogs": "a0ce9edd684a1e7b554f6a8e81c1887578e061da6a161993ea8f0de0e285f421",
    "AWSMachineLearning": "4499ea64d8fa90d5262adbfced09b991ad8e13a7751cc9954f438a30b5ff3009",
    "AWSMobileClientXCF": "a5d9a57da7f5400b53a2c527c91ca3ab64a1b8104cfe7e5c642736bb8b30d7e8",
    "AWSPinpoint": "bc4c286966a45363f50034c1de5f67f25a5dcdcceb2174096e90e70968ea51fc",
    "AWSPolly": "7c82cdbcf2bdd795250512d0e089b8236572ade730a88ae5db7ab2a8deab8040",
    "AWSRekognition": "813c4e2d711c6e6792d6d2cf0018d543fa094535d014540c19b6bafa267c8f07",
    "AWSS3": "3f4573141f876d3538c692e304e51c732776dfe17046b01ddae3dd961c6524ce",
    "AWSSES": "be64918d7796892d71c72326099909fc4b19fd38752013f5426dcf6abd78cda9",
    "AWSSNS": "d971494109c9ea153ac0bb4ff7a182f0ab10f122505558a0a5ceb98f88da2fa0",
    "AWSSQS": "7bd49b9e03a8f08fb00da04b4a1c9beb5fdac2779ba8095c0e95c9cf6af937c8",
    "AWSSageMakerRuntime": "0ca8cef61da070c08f03e1444d0ea394e56c843408eeee30487847047bc444d2",
    "AWSSimpleDB": "cf89c51b541b4f392656d6ae71d7aa3bc62ea2ea9f987558fbc875bc4cd7e36d",
    "AWSTextract": "29c273aaca311248b068f0948ea783bbf4d5771e8a12d7153a51dded4b0e2970",
    "AWSTranscribe": "c4a5a9805da7bc72271b811d5154b0fda7e6d424dd96d7d5fd8a0798dfc9a5e7",
    "AWSTranscribeStreaming": "281d06e71911408b70cb3cdeab1da60a48af979d81b531cc06a757cf05f13ee1",
    "AWSTranslate": "5348a86cfb98a7e13fbdd446f07b6be1d6eafa64c5c2d6774eaad6e44758c91b",
    "AWSUserPoolsSignIn": "1f7a003c3fcdf5cebc292b45f34613999fa2bd1ae71ee6c0792ff5f31952c77d"
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
