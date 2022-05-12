// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.9"

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
    "AWSAPIGateway": "1b5b1a32c25fc5286598451307bd9fcb82da1accf79a0e08e6db1fcdb1ccc11c",
    "AWSAppleSignIn": "e8bb2b6570e28a9304be010c8b02c817283b7ead287cffc32d126470e78a878f",
    "AWSAuthCore": "faf4ba400bd468c97713089befed8f0e730a7ec83a422595e5bcc2faf637b3af",
    "AWSAuthUI": "f3450da87498ede966f9903c190ad333cbe21027bcd78e3e3a21f9f5e36171d4",
    "AWSAutoScaling": "8564e37898257d3cc65f0cbc5248df000d52183fb929bdb1b099c9624955349e",
    "AWSChimeSDKIdentity": "dfde584ba7eb4ff08b71fb8a01d46d5ba221cfdb6bf68119c32f7222a47c6be5",
    "AWSChimeSDKMessaging": "c7de9d449b314d82a82cec77b95d83a7619a8cd9219cf53a961957ecc538fb11",
    "AWSCloudWatch": "e803d87d79c75340c4b9d207e924d85c35b2c5a18ac03f887dca18f8297a8290",
    "AWSCognitoAuth": "fd8af6238c2f83d0c2f8dafbb34827b71194dbf5b21c366540ea826c3a9bcef6",
    "AWSCognitoIdentityProvider": "7995a7c04986afe40485c18eb42b952ff1ec97f3c1a8fad1cb685fa6b0f2c471",
    "AWSCognitoIdentityProviderASF": "52ab310559e29c3fa27b3d4985c76c6eade49c1c32be0e72fcfd3bfbdb4d1b78",
    "AWSComprehend": "bcf3313f7341eb5d164e462aa2143bc6b14d77a95a4134ed637f6d3f9a302c39",
    "AWSConnect": "46ae5a1f4be5003e8b5060871b32a179b6c07654a626f1fb9b88d1240282f080",
    "AWSConnectParticipant": "1e988640631408fad47ba77b705825bfb26f943126b906e6ecfea800a19319ff",
    "AWSCore": "7e80f181a4895ed0ec5e82ff84270b77a3f40a0419babe7775997d85e9fe59d3",
    "AWSDynamoDB": "b9f62cee2ff2325984e934a15597292c8909c9a143e69971f31f070df17e37a2",
    "AWSEC2": "d3c390e9b7a6199898d94a0412a597fcac167bfb06ebf1ac634ed27ef3f6feb5",
    "AWSElasticLoadBalancing": "b25c89183ead92783d077f6201ce84719ee52f4dc3f8e923760a283512521145",
    "AWSFacebookSignIn": "b6c45de8af294fdd08eb54c78a6074a480ace3a093d91e832ddcd8ef77057563",
    "AWSGoogleSignIn": "72c210640e6642433b49bfa650c5fc89d200afcf23ecdd29b786baa359b04beb",
    "AWSIoT": "13f582d5b55e241b3f3d42ddb6c71b04e46e574c5865bed394ad34c4c1f63193",
    "AWSKMS": "1c70fdb85d9023b006f975577be0a3f500e36bfb373456c22fccd3c8640b1734",
    "AWSKinesis": "8397bfbfb2c2e7f2f9b9daccf3132b4b1443fc3d4d10a62831c382c96fbfccdf",
    "AWSKinesisVideo": "b9dea7ccc3b15b5e352092ba76f865f4a2025a9b21aef571e5863d0a754b214c",
    "AWSKinesisVideoArchivedMedia": "dc5faa46d3a91da741fa70a1e96b5ece96b3029cc765d4865c4bdad7143f33f5",
    "AWSKinesisVideoSignaling": "f931aefd13305f29dfbcb575226beb203798876cbb23c93272ff7ac2782c2303",
    "AWSLambda": "42e3d7adc0688a3e582fd6cae7e7b7fb24c9d061ee97025361338acf5a403c87",
    "AWSLex": "6d9a8619887427a95b77d53bd1a139d8e307c7d95866c23cd4b72d5a9f6d7ecb",
    "AWSLocationXCF": "098d452805a48cdf7e817cd7efe8a2ccd5f98c0295f36ceb0bf357166c5d88b4",
    "AWSLogs": "3206a6d9aca7a47a836fb2cba2c91650f28a38d6c8f0830ab487cfd49b33f5d7",
    "AWSMachineLearning": "a03213e30ee46c634519203d242c9d31baedadce0215052815768e1559c67e1f",
    "AWSMobileClientXCF": "d84eaa4c6fe93e8847496dcf84f520238082f0413e6a6f8cd9553886dbc4ac08",
    "AWSPinpoint": "2fa78822685c62b91776934378b4dba11deaf472483b6ce73a38465764f82085",
    "AWSPolly": "74d34868ecf9237ab5bde22f34e0b5740297f68f66493bd144c91d72ed7ca80f",
    "AWSRekognition": "6ae59acbbe1abcd8b5114c8cad8615ca93bc7676437917ebff9f6f28c20104ac",
    "AWSS3": "83b01b8c268329cff744a1ced805c9faaf1cd40af36e9f7ec625d78bc3743501",
    "AWSSES": "d96b292f6d91ed6dc5413414269d01fd1e7c1ca1ec2e2a6344ee24329ddf0126",
    "AWSSNS": "746fb40c21e175b6d33a3c97e1cc93bcb1dcacae96c0691534450cccc76b43ce",
    "AWSSQS": "826df84629b97a8bb15474463c3e4a939161e7a349e99e57dd80cf7ef1a1b041",
    "AWSSageMakerRuntime": "f8a8c4ed234f95aef915afe8800de72af3618ba0b9a2d00766e1dbdf8ed886b1",
    "AWSSimpleDB": "1b089d12c372e15c539a0d1710b93f9fd1a7ce603cd007d985eed54cd1853498",
    "AWSTextract": "a1e5f03d137c261d92d991315cc6e37538ae84eeaa965dfc575e2af1021f7b8a",
    "AWSTranscribe": "2132fa86f438acc778d84931d2430f2a7ecdf0be4da9a5420fcde9348949d771",
    "AWSTranscribeStreaming": "5fb4ef1430036f26ba4f60d98affee5c91ee6eeb9b611a2b5bced1348b17f05e",
    "AWSTranslate": "ad911f3c3eb3a265164527889b905e45e7145ba318cb3f0dc0d1d121c0515fba",
    "AWSUserPoolsSignIn": "bc26c914ca3c9a0f39277d6eb170fd562c9d49e1d508ddf9367b990b0c379211"
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
