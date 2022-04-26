// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.7"

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
    "AWSAPIGateway": "3c794d8e2baac921136705d57d6b7590a48e2077a50b941363925a89309a381d",
    "AWSAppleSignIn": "e7b78ac870637e6a42067b8931d7a89f0ea007ba0c79a48977376ecdd5cd0cbb",
    "AWSAuthCore": "210c596dd15e239893d888f6a89965d92f6e7b3fcae6da36e9002e92ceec7d55",
    "AWSAuthUI": "833e9d0485b058a14bf95ed5115c4f7bddce923bef340ba8d97e12063316d7a3",
    "AWSAutoScaling": "2c33822f4ccf098556782e070c082bdc206acb5ffda716638a7cf2101646d111",
    "AWSChimeSDKIdentity": "469fb8d0db5b874881666cb52c2894decd72ab2bb69becb9cdbd7b9d43da47b4",
    "AWSChimeSDKMessaging": "893f1531d3114653cc6fe6e8e6d124f8e33880992ee496a8360afc7b835a2a0b",
    "AWSCloudWatch": "1e1a93d891962c2b06d7f59fa6e0a44d8b23b64910c38ecc6d369c5f114cdbed",
    "AWSCognitoAuth": "8ba4d32a0b5445c84e4816f904dbf2cf3c7e3dffff6c40e79ad5222cc71b698f",
    "AWSCognitoIdentityProvider": "9df985a258a9643b4cfdd5a05acab3a3f2e9587d574f22cd572bd3f2e85a93e9",
    "AWSCognitoIdentityProviderASF": "6d61175ae17aed787c0fa8f6eacf754cbddc09c4f90663893017e7252e75f484",
    "AWSComprehend": "f758484fb87c2c1abef12fff29f9d026d0c6fb2495768c51392a241acc6f7f44",
    "AWSConnect": "3be5bb686e53581bc8c5796dccf07826be8955d0d64b8a71179d8bfaa163de37",
    "AWSConnectParticipant": "bac1304495162bf21db3c099c2a1303019d5d60afd95a78b5fcb0d3b4edd2ac6",
    "AWSCore": "75c5ddc2d42d0abcca5087f5a454d4a9089ecb882d0c736852271d2d826357b6",
    "AWSDynamoDB": "f2c6bb0e3b4c456ba48b9414c05f6dd31c9c41e6a625ea60d709b4cb01fbca85",
    "AWSEC2": "88db59170fafc1a8d82740e78998170a7651067dad979c658403ca73a4a4dea3",
    "AWSElasticLoadBalancing": "e6a385154ff0a4cfb5c3a1facc4f55a7c173deeb123395892f1ee2fd9f331a95",
    "AWSFacebookSignIn": "90a5ef7b4b20d162ae5cbad479669ca5883cb8bb45318b5787d8172e30505845",
    "AWSGoogleSignIn": "bf0396de4f3f72ed47f3ac00982a85df91414ce15425b5ee57a9c5d37f1a964a",
    "AWSIoT": "610a77f382c2389b1ee8d559247d72cd3b3205fd1d815a1d3c8844aa819b32f0",
    "AWSKMS": "da15ce8672a23b219607766bde78fbaf7dc456adc78d40e7b4d1e2f1a2bcaa48",
    "AWSKinesis": "d95fe2283c27a68f97caafee262b7c25c295f97b46c4f531f3ed22f698c673f7",
    "AWSKinesisVideo": "9bb9fcd2925a92646faed864eadf6177738cfeee26f837ad04f83ba45713902c",
    "AWSKinesisVideoArchivedMedia": "35c2a6e448cae01ad817613933696f76204841795ef173eb63af024edec0256f",
    "AWSKinesisVideoSignaling": "6e1d42dc7caf12664e4dd194058beab0de78e2e8affea1022ac94f662a414d8d",
    "AWSLambda": "47e1d414917df02e1336cd410dc1bb52a3041a586a6c8b6252c49f3dc974f0df",
    "AWSLex": "c687968d029d31afa12942f7991ffd546d80d7c1b7619d84d4fcfaab7f08d865",
    "AWSLocationXCF": "6645beeff910e55d6b341a6994f8d57658b57355482d026e91c8f2b52a984fa1",
    "AWSLogs": "868321c380bae002817314053724e34e17fc392dcc4beee476d39103c44f7e2b",
    "AWSMachineLearning": "2105a1a3faeafd6bbe3b6e68ee53f941f48112c446d25fe691b7bbc7ac7c5dfc",
    "AWSMobileClientXCF": "a56ef97de3cc364ece3c29e5f9af67fb8080b59535fd78849c57172c198ac6dc",
    "AWSPinpoint": "d16d78558431603d43971d4c912053a9fc18fe3b7a241e066731499918c15fa0",
    "AWSPolly": "66b6fe109d4e8551cf68c86d18d435a7f503deb41f41179f2409720fb5c91e0b",
    "AWSRekognition": "340eaae77af80f3190e9d9c320af9b2b81a627a2c22fedfb4d149408664a5811",
    "AWSS3": "7894d2cff3ae5d2b8da9a2bfd80a19dccd935a5080d031214cca739df52e24ef",
    "AWSSES": "29b2d6460a5a57ebd0bb802e4dcb9e92a7ed1986eb386f03cf42d9ef04e51609",
    "AWSSNS": "5d4b8b52685964b2b1143d823905f3ae6516619202cfc1b87806a8f00c495b12",
    "AWSSQS": "0f18eeeea6e09ce84430f9f834087adf1e257bdaa4c7093693e0ffbac3d28c7e",
    "AWSSageMakerRuntime": "161dc9e6318a01552de40420a9b68e2ffac4b9f4af7f9cd48798c86b9d6ff546",
    "AWSSimpleDB": "ee2465d91a6bf600788819fb9062ea3cd429e71f50fb55d112073f2c41bfa80b",
    "AWSTextract": "31f79655c1a266369ded03457f3d23764d1c5d3f4f5e6aac500c15de90d155c1",
    "AWSTranscribe": "1f2ada30dd37494cafb9674a1e7e9a38ef841d3f52b76776cf76837cdd27cc06",
    "AWSTranscribeStreaming": "9daa3c84689af438b8a6ab35316f264d4abd247a652d687bb04da06bff0d3b4b",
    "AWSTranslate": "8efe33c9b2ae0c46e0254e019e8cf5118759c2b677ab5763c325affbd16a674d",
    "AWSUserPoolsSignIn": "3b3b465a70a25e7a6b43c3fe4d604c517583ae7efc2048a49c2749a526e9baa3"
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
