// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.4"

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
    "AWSAPIGateway": "e70515161bff00f8cd25df562325145133a1e054da847eb940f9eb99a75c780e",
    "AWSAppleSignIn": "d16316f8a4bd3087e69eec28ef191dba763edcfbc79f95e9a06796eda3853576",
    "AWSAuthCore": "95ccf19dc9d14e8275c8b0de6b30fd91c6eb20ee40815bab0ca14c1587182d07",
    "AWSAuthUI": "5c66361e36a5d4b5a2402777a0ecf7cbe783e9f58765ee1e29486436648e6c9c",
    "AWSAutoScaling": "470a47aa93c4b39558451bb00d73cf3086ab68c2765cc91faca8f3e903a4f5bb",
    "AWSChimeSDKIdentity": "5ea4ec66a50c533c8b022b19f4814f03b8b8e831d0ef33d10ddb7c7d2da42116",
    "AWSChimeSDKMessaging": "2c25550019710b75160afc8663a2c45df377fbcfd3539b33a271f2907cc84836",
    "AWSCloudWatch": "ff85adb0d42cc56e542c71471072bdf480649531370e541acec7907d0be54236",
    "AWSCognitoAuth": "9f318825d68ab58199a0c4382d775be042aa42a48b7f8b1fd7aacee8cbae2bb8",
    "AWSCognitoIdentityProvider": "90bde0b5069fac8878727a9780ffb1005018cb5c1cc2477136e8d18df5dd989f",
    "AWSCognitoIdentityProviderASF": "8c83cc0279beaa26cd5f9f91c52de44ab74b3d5a7ad5463934b8728493aabc3a",
    "AWSComprehend": "dbcb03f7f5af1f920d01a4b8313a542fe2776f50abeb1b0908af47816a4e5e55",
    "AWSConnect": "1287c3f2e985bf2b9cbb35fe82e6b75b4e5cb7084806d593781076f2c296af65",
    "AWSConnectParticipant": "b8c6316ef06115fdbd9b8c383e760748e7af1b7e8572d48450cda4b9243d43f2",
    "AWSCore": "35393600401e29923a6905a80551dda985e12cbaf9898a9659b212c7fb984bc5",
    "AWSDynamoDB": "797b2ba967a16e7cb428fc9084bfb92fe7ce23bcfb9236559d222c2a31b2dcfe",
    "AWSEC2": "f91b9fb546f159e8091d6c05bf718be53eb93c2d6bbf5c179d38edc0457540cc",
    "AWSElasticLoadBalancing": "11a4c0e810892705a80b2e6211019538c6bd9db7060694754e8c7c6e91f66d99",
    "AWSFacebookSignIn": "3f6927a49f827c7adb623d1212b7563d98964a52ea51d0f16478897e508afde1",
    "AWSGoogleSignIn": "ceb2cf77651f5493862c752c897b420c29ceab2e8d4857b224961d19ea195975",
    "AWSIoT": "bdbc061704cc9e6ce0958ee67cd914f1398438ec9503d6c0c213ea879de2161c",
    "AWSKMS": "b8dbdab519ddc8b1e7c89bb56f5508fe9914ed5c8c60270d2a63b9fff69aa7a5",
    "AWSKinesis": "45d558ba2f464ea39ffe04aca72e43d448e72c634e474170b8f0346d7f20007c",
    "AWSKinesisVideo": "4aff3ad2a6f72be7e661ba877b349441d24fb6b5ae740e3e6b1f27798b21e368",
    "AWSKinesisVideoArchivedMedia": "04b769a54dc801a46065fa047df47e4066e1b7af97a40ce5755de9f1c7d6ca9b",
    "AWSKinesisVideoSignaling": "7d2cd21a4c5d3c8fa2c506c90feab93bde279d4f1f899f3972df469deabbcca0",
    "AWSKinesisVideoWebRTCStorage": "de297eda79d97899371199b40589a1e21b32cddea88010a88063804cbc504420",
    "AWSLambda": "94612b375dfafd769b62419355281f73196285dd7140c4adace613da8a0d92e5",
    "AWSLex": "f789729c38cf17f4d981a3d8cdfe03840664cc01564f27c383303e27c72f4e12",
    "AWSLocationXCF": "0541554f9acb1df3f0852e150295380db306978d99e68cacde7021b54d917c7f",
    "AWSLogs": "0774f7d37e18a7005903029dbf6f44b09082a2930aa5186729d7cacb47023357",
    "AWSMachineLearning": "6512c09fc7a58e1f6fe126823f81e86a1172bc2cff6901853dc666f4465bbd28",
    "AWSMobileClientXCF": "37704d359b1fdb2e6a7eda4837a658766c8bf8bbd3fe7cac088b6604e2f6c40b",
    "AWSPinpoint": "0cc7d551a11029231db9b221827575516f1d0cb23c381ddb99158bd7a9410b65",
    "AWSPolly": "ffcc9fe2e717c1aa4fcfa56ff00df21b2792e7d16ae12ebd7145a02abab53cb2",
    "AWSRekognition": "e71b2471e675df7add34b6a37969a7a175f7c265d3823f6d92ee8cdaebb3f1ac",
    "AWSS3": "c9ae23b296608013ec195052888e762a5b9ecbd46ae28fcfb48225990ddf1f29",
    "AWSSES": "e4e7170b400dc0ad08ba5aafe87afdb1bf11585c8d469dba77ed305eef25ccf7",
    "AWSSNS": "711ad6d9005f7d1121803aacaf8aca67c57924f3dfaac4d87414caebfee944fd",
    "AWSSQS": "25a2090f844f52422cd97b993ee11df24e8e1d59703afbdf9408b3331ac796d2",
    "AWSSageMakerRuntime": "2e11c0f7641330ba6e58271a2049c3337bab5558cb8bd42bd81f6fc13052de3b",
    "AWSSimpleDB": "4d245509a7b3147be538b94704e4029711243ddb63e5465906190bdb83e1bca6",
    "AWSTextract": "da91757c24b0984053901d9f62d8fbed5006874ecdd9de22ea388e5746682a17",
    "AWSTranscribe": "4fc1ec46874c0aa0c13992bd74de8abf8b05982d306f1d07f959b65f018d5cf6",
    "AWSTranscribeStreaming": "50edbd8ef4d6fe8bf411bd61dff178f998718fbb498ce3d4dddca6d47b6f0c93",
    "AWSTranslate": "d0ef1e21c5c396812e8466c44d870779521844d214f596d3d376064babadb560",
    "AWSUserPoolsSignIn": "0afcc4bb832c8260550f19000e376762153f3ab2a10057fe8a58f31f4f115fd0"
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
