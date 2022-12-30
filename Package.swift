// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.29.0"

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
    "AWSAPIGateway": "9cfbf5f179348828a4df981b62ff9b5a3e83e35a54aa2863efd695d4a684fa0d",
    "AWSAppleSignIn": "789bae97c103c5ab4856a20e04a23236721311740f2a31a11e312ae59df51cc6",
    "AWSAuthCore": "82fe097646a470b0a7302704232689068a13487004b460a4ff702d147cbfd9be",
    "AWSAuthUI": "13570c808e9a793d81fc882afe52fc055cd7d623cfc3d9298ee2b1afcfc8c606",
    "AWSAutoScaling": "c9449ae9c123de219c5b06d51c0a976aa03e020a954622917e525c5ec7dd3641",
    "AWSChimeSDKIdentity": "0dfbc25e20335b95bf699bdfd5b0decd91287c052be7a595b93b9cd184b8ccfb",
    "AWSChimeSDKMessaging": "8ba1e304daece587fad6e431d7c8dc61c91ad4137b6e37e1987aa4d7b2588bd3",
    "AWSCloudWatch": "1fe1af5bad5eacfc4004fe745ce882bad211f9d26e7ed96ae17792dbdcc51800",
    "AWSCognitoAuth": "7c358a9f42ef492d7c624dc586d66a8e4fcab09887758088e658ca01ab949cfb",
    "AWSCognitoIdentityProvider": "236ebeddac5da78424e51d6661124b0cec131d984954052406707f55d31b09f8",
    "AWSCognitoIdentityProviderASF": "e871b1c3e9919d569c5b9c348eab651315ba4ff26dbbcfae0f1e13efaf50286d",
    "AWSComprehend": "b9d3d203b3a0b2a7bda1c49b63ace5b2a57b3dccc88b5cb6972fda99291bc5ba",
    "AWSConnect": "4c1b6ad721d831d835d9df07c0982f2afd9fec3dd4e4099361cbdc8cb7b23f4f",
    "AWSConnectParticipant": "7989a15be0ac0d68d5081a6bfd655c9690fbb1fd3cf41c7130774860f1de5923",
    "AWSCore": "c97b11d41140b42bdaac326a4509b9313d762fd26dfaf0aa9d7d3e6ee84878d6",
    "AWSDynamoDB": "13dae3fc0c498f556a4675ce5df11049db1f3dc829bab65fd2b25133c03e7286",
    "AWSEC2": "3242430d4a44ae960bfb843908079378515fdca967c0625bb0095118a47a2aa3",
    "AWSElasticLoadBalancing": "43486dec597a1242e38e4d675ad0eac64e3fc99ab0eaefeaee8179e29fb3580d",
    "AWSFacebookSignIn": "7baa78ed0d3e24a015387912d72c82957298e8ca6666f5b68753be4ab8c87081",
    "AWSGoogleSignIn": "5cefdab66290541bb41e8d3062a3c23cf84c070862a1d3655bffba41ae3d3d69",
    "AWSIoT": "dec93f330b196b20647e553b32520319cb0cdc4860f2e2c7d5f92dda51d6e31f",
    "AWSKMS": "d0b30ba1245f435e74df818aeab2ad6198ace2d9ece0891cf712ae3b2b18a603",
    "AWSKinesis": "ad8e28eb722362ee9f1ad4c73418ff1bb3c89efa13cbb17a92b7adfdb0b3241e",
    "AWSKinesisVideo": "07e502ccc3c31eaffbdf5386d896c030b30656d99fbbbb77aeeb3b2a9fac4386",
    "AWSKinesisVideoArchivedMedia": "dfe1bace9d467db79ae94babdab6f6ca8034a078303e8aa382c7a02165ecc9c5",
    "AWSKinesisVideoSignaling": "616adb796c4a93daafd49d18a966777d6a9c9eb39a6961dea1d4ccc09b58bf35",
    "AWSLambda": "b49ab59095f0340539f287c7d21d0d9aedcd2e5927410fdfa10dcccfc534202e",
    "AWSLex": "0e3691a5210ddb0d493e5ec0f4967bb4f911b261b5d2e0e388ef23ecbced1d4f",
    "AWSLocationXCF": "6370ebb996f57817dbb46e7a577e7be5ea2407d13d736f78bf2d889d523ed18a",
    "AWSLogs": "3cb34768395ad16669d8ea28f16f1981928bc16e1043cf6269dbc42121e228df",
    "AWSMachineLearning": "daa58f1cbcd56255642d2012adf2591ded8e1b7e681f2dec3c3d61619ada6625",
    "AWSMobileClientXCF": "ee1e8ba0af88ed999f32c4a003def954e72e8d4a3db68ecdfdf6baef76920a30",
    "AWSPinpoint": "50afcef9eea631fa1b0637c5aff4359184db5a89113a9b4bb00f72ef04d31a8f",
    "AWSPolly": "a5fa5f1f0c441c2bbd0dd9e15020159477615dcfa94f486b8bb6b72df9e45719",
    "AWSRekognition": "8e7121dbcd9b5992435337e6493bb4947eb0c42b823ab6124cc5689bde3fe397",
    "AWSS3": "488baad1ccc657285265be26434fdfc8ed601d5380dc5faff3e39d0d6a0ded4e",
    "AWSSES": "c0fa387096c71f377455fe3fc64b5f1a687bb8436cf83b56f5382768cc307aba",
    "AWSSNS": "f373ca8812f956708221e8812b64476bbab2f22e7b0035c71b65ef1442dab78e",
    "AWSSQS": "6cf78d385447adf16e32020091f08c66c6d517ecebe241865f167215e30a21de",
    "AWSSageMakerRuntime": "69cc615ff8f377c8fe060ef45ee543613e8ce41edd48f1e024b6742473d1c03c",
    "AWSSimpleDB": "92fbcb35d784b4706b836992f033c5a9c8a45d78e6b90fe1a10521be10a9d88a",
    "AWSTextract": "43c6eb66c06047281bd354bf62f4f9903987d02084df02b09314da6297bc888b",
    "AWSTranscribe": "1e2ed0acdc985060a7fa963db8b2cacb21c65aaf8e439db1c1fa225241d0230a",
    "AWSTranscribeStreaming": "04ef5b48da631ea8c986a1bf75a66fbe5bc6d0488315d7e0874a9a1a03a239b8",
    "AWSTranslate": "399fc42eae47c13007ed5aa417da7296be33d05c4e543d5438ed520ece9e137d",
    "AWSUserPoolsSignIn": "2c558ac74b44f72e0c09ec72d64613dc1e6b161d35a07b03a166c168b8f4be82"
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
