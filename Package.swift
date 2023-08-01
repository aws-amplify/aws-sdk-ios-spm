// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.3"

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
    "AWSAPIGateway": "76edaaddd98fa552db87463477848fbcda558ec4869107a79edcc800b51976f7",
    "AWSAppleSignIn": "4759f1756c033269d28d9e5f1069685fff504b90fecfc32115b15d277172064f",
    "AWSAuthCore": "402b0f12d41355b2475f52bd4071c900e4ebdd73d6710fdf4c445645b07262a1",
    "AWSAuthUI": "432b14698d919efb9591387f18830ff26dc4da6901a3030e64028be14094c21c",
    "AWSAutoScaling": "5a027621374f5e74f11c99fc70d867c5e22a41eec40c7b64b21d2a589752f0d8",
    "AWSChimeSDKIdentity": "2ea472575e7964864f786463f581d7284c29b31744be3accd5cf8b0c28c4f9d6",
    "AWSChimeSDKMessaging": "e07bc272bd3c06ab0ccc696bb6025812b830edbea96c3b2058341a1f60c55f51",
    "AWSCloudWatch": "87d798067c26b23b27fe4035b765b55b6c0c4bc993c410b96ce8c272f3ac52ec",
    "AWSCognitoAuth": "b1b5cbcb0f9f1274bd867896b6a91a22bccf2828c23323ef75dd892ec7d37f7c",
    "AWSCognitoIdentityProvider": "41fa7b7959fce1301c508ea62be5f6408b15030dde733a6c3e87a055706a7d1a",
    "AWSCognitoIdentityProviderASF": "48dd9295d9aa65927632b9e0170447d481ff7bc9bcd25ed552462fb0954658b1",
    "AWSComprehend": "fc54bcec7ea28ebab3a3bf8b10a6b961fbd57df42b6e80ebe8c22cd2656ade5f",
    "AWSConnect": "e67b43abfac1973e87993a5940d389ab2909937ddd1d40bcdea602b1c68d7d89",
    "AWSConnectParticipant": "5802f23370ba43c61b719a71d637174c3d3095e21ad1376f8ea298dce75cf957",
    "AWSCore": "37dc079c85f8ff0fac76cb04d760e69faa77d931dffcfaeaace08063307a2d6d",
    "AWSDynamoDB": "1e876c80b5073816f8a374028ebc41478fa3e0a76675bd0c3b175123ac1497c3",
    "AWSEC2": "202bac0b6ce059e069563e83034a8acea083ddcfcb508b65b58643a5e6b66f5e",
    "AWSElasticLoadBalancing": "6710a60e9eb9e7b14db79474c238f327d561bfd946ca9b367b7122ad53431f21",
    "AWSFacebookSignIn": "ee7466841464e493f34531f279459cc672ad9ba048163b90edfa7082740b6c9e",
    "AWSGoogleSignIn": "7b5471adb4d666d98c4697fcd9594bd55407ac16caa3cb4fb446cfedfc6c4b5a",
    "AWSIoT": "811367b55836c60ace4c39053cd40ae34ce75115048f9ba5b67c4f06b40a64ed",
    "AWSKMS": "67571ad58dc77ffec4d277609bd4232f08c6f6d3e6ebdc7fe1db7bae69be0f4f",
    "AWSKinesis": "d87047a6a19e58f2c142b17aa2bd9dcd543a4e7af21931c284fb0881a17e792a",
    "AWSKinesisVideo": "6d00eb4472ba3c04fb65aac3b749b902f1ecce9227aad3dea881fae4ba346cc3",
    "AWSKinesisVideoArchivedMedia": "6e23839285b35d4b55eaccc4720e1f4bb8f9fa801c88e6d8c729e9dde19945fc",
    "AWSKinesisVideoSignaling": "b266fbb1930acef0c680e8c9190924a0c3491d153260aabce11a91322170dbf4",
    "AWSKinesisVideoWebRTCStorage": "12d04e53c3515b955ea7ea32ff40980cbabe7063f6e69318909b676023f50275",
    "AWSLambda": "93c3511172e782697b74045a238b82476ce2e84c157a993037b3751f13a68c5c",
    "AWSLex": "53b698e670e9b58d302486c2f563429db157289d3bec8530ac36faa03f201f2a",
    "AWSLocationXCF": "8f85a4aecfca53911b77526a6d521ac24d9f73ee0adcb60b0eb36dc3ad496d66",
    "AWSLogs": "1ad5d21a6d78545a85a9aeac725243e00fc72c6d4a70514c775cf9889ddd7d66",
    "AWSMachineLearning": "dfe77ff9d901e1d7e93d4469b6a4b4436c151fc4532cca50775a4fa1c90536f2",
    "AWSMobileClientXCF": "1874018230617f8c57ec161a03efdc181de32591be13517e625c5760871da6c5",
    "AWSPinpoint": "028f1c18b451865239230d6418d47a570afa1ee67df83efbd1ce9a5e1ab43bf0",
    "AWSPolly": "4c3035124e6f4be1db60bcce8522b91346484a6749b61fbd9cefb06a384272ed",
    "AWSRekognition": "0f11a5a224a3eedfa1992de77544e61218be14b8dd55568841aa2556897993a6",
    "AWSS3": "2c4e4b148faf8839a34133bcc387db0f29ab917ca3d759489a710c76da8175b9",
    "AWSSES": "d6b082fabea1d807378fe26c8da00a72e4a010128cf33ea591448877257c72bc",
    "AWSSNS": "3a757fbeb9d8d550b8f980f31bf83cf3f220f3ccc4fe7ef71b9ce1733a6805dc",
    "AWSSQS": "c2749b315847c39fa4192198141fd9d97a653dd7293ef25228ba30c876dde763",
    "AWSSageMakerRuntime": "8bb00c4e1294fc771a46cc07bb627ece2a0e68ba7fc970a99612368adc273a1b",
    "AWSSimpleDB": "4df06088664dabc0bea9f2aad2bcf7d61a1f2640df10638f887eaf97c63cea8c",
    "AWSTextract": "f23761fe6b9b8e6d9839ae95744ab1ad4b6e29b3adca059eb59da3c6e0906451",
    "AWSTranscribe": "1d8aa55e002cf93021e153ec93c768cd5e3e33ad05183cbcf25efca049500ded",
    "AWSTranscribeStreaming": "5f4a8f6ca249a71bff76acd893d0ee8fe1db262bc0565901bc5e167e9df76cd0",
    "AWSTranslate": "a5f109995833875a31432e0530075cd392c23d8e416c7d9e4e9f8307c98e4d66",
    "AWSUserPoolsSignIn": "949d665961c2e713c8bbb3833db20745b84f3a961cfec81a9136af75a92574fa"
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
