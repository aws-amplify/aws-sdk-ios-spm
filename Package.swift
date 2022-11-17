// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.28.4"

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
    "AWSAPIGateway": "a76a759a33df51deac64a18390edadbba6462ff22a2026a82ccba8df06380365",
    "AWSAppleSignIn": "bebc65f9953663117d7ff15b980dcd82ebdcb74cf1f7680d433d6fd72ef760c1",
    "AWSAuthCore": "4d138b008eb545a524e92dbc06234f33d7751a769d74b4f00d089360fa87c45e",
    "AWSAuthUI": "61e9878d2ccc9e466938094f95cd317b8f3136cfc92760c227db99ccd6595430",
    "AWSAutoScaling": "8ac5146770cb8687651c78b257517f26cd50ba0b8ec776fea0771f502af35285",
    "AWSChimeSDKIdentity": "fd0b115c5ed1b1bec1331c85db9078753ac79b82dee581ab6f7f42c3860b64c2",
    "AWSChimeSDKMessaging": "e16acc69dedb0ecad3be20b3cded614ee2e514a4e86a1d128a7cf74edaf3c84e",
    "AWSCloudWatch": "f7a20fdb9f23d9ba6fb6e15c0e9083baa6d9ba29557dd99832a955849272f79e",
    "AWSCognitoAuth": "4af85d301a87bab7444dd70a0e34726fbb1db38fa0da38b42544ddfc17b1d57b",
    "AWSCognitoIdentityProvider": "646163cef96b3417414af03492c78f3a894c26c625e7a97506b013aba868da89",
    "AWSCognitoIdentityProviderASF": "2893af75e32023e87ddf226039f1d1940cd590154367a81702a1816c324dfb2e",
    "AWSComprehend": "38971a4f91b8e10023eefdaf0c3499b62d65143b2caa6896423a8d62f7ec40b6",
    "AWSConnect": "d4ddb7930e3a85280f706c74ab8dd5be88769463595867ecf349b66b8164cfbf",
    "AWSConnectParticipant": "e6a0e53094b0f2df7dab7a4f654da9f5830f6c46bd12a862829879220acdfe49",
    "AWSCore": "69806738f6bf0008a5af3d7f72a8ad93831873fc0fa17d1b90484b69b85971f7",
    "AWSDynamoDB": "5b15a5203fe51e3b9bde8411b4194d3bb5d3fd48731669be2399f03d6fd0e6ad",
    "AWSEC2": "e78f3675912277d88ddef76a4a449ee5ae0204cb76f6335a5ebd11dc3736071a",
    "AWSElasticLoadBalancing": "6d21398e8d735edca3a57cecc1f4c021294cd8e5b9982361377494aa655d9a16",
    "AWSFacebookSignIn": "166feb5e91b62c351f8158e00ba7ffc942d3b6e607193412a53f18c2a86a74cf",
    "AWSGoogleSignIn": "fe4f3ee3fccfa430c27f3de81f95094fd2504f257d9460ce43b7a07cf50028f7",
    "AWSIoT": "9d1ce30c024e3caef50bf4a924865dcffb7d8c19d698dcb93b759924adc8264f",
    "AWSKMS": "f5f6f48ecb85903388adc7fb91bbc9b993dc0dae3d340a7ffd00867f4729be36",
    "AWSKinesis": "64da08e80ccd56704f9fc27a9f30c05cc589311426fab24eeaad7d7408a22e84",
    "AWSKinesisVideo": "96322d6772442860953e19b234138289313306f6fd8dd0b7ae532f285f826413",
    "AWSKinesisVideoArchivedMedia": "9f40d7557c3f20db425b296e90710c8255b47c3e4ec22c488b99fd307c527c9d",
    "AWSKinesisVideoSignaling": "7d41bbd437cbb5a6cabda8a05f2a2d240aba0224e7316c01f33cd0fdb3faf0e3",
    "AWSLambda": "764237dd35aa9f5954cfe31227c2554884278b6123a1319b2bbf0d96fb67560c",
    "AWSLex": "b52528033a97ab0275b5f7d4f15e0d983edd5dd43554a3c5138981ff0579ae50",
    "AWSLocationXCF": "11a24292a34db602dd04682bcd3ac8082133e018d4489cd52caf75d5e7bfde3f",
    "AWSLogs": "eef4648412a06d4d39e014024424e5922e16ea202630e2eacdae9c95fb18d312",
    "AWSMachineLearning": "c7012e0cd8c54855b9df045f11a7ba4c1c9e26e95dd1bfe8c476593de100bcf1",
    "AWSMobileClientXCF": "26e7f694f1230a96eaaa7e60fcf436914e820e7d8a068a955c45ba88743dd979",
    "AWSPinpoint": "39ca8e2099f3488f89dd31026d94b459285964d15eec7bb1733ea87dfe5540fb",
    "AWSPolly": "8bd9f8fe97b0a9a9e064ae64b7fea21579a1291f03ad4e983e273416a36a0242",
    "AWSRekognition": "aae3563c2187184c321db1221e2fce1bf597e5247ed17c2d8a88915337212b2a",
    "AWSS3": "0299dd35776288e5008fcfdf8a37943f4d19acd98b9a37c483046536878fd0fe",
    "AWSSES": "95f89a2ca84c242a77cd8184b1fa433d3241bedad57f16fde762f34c79f5f849",
    "AWSSNS": "1f8c5f8cfd9b721a64f88dc3bb429385bb56981b73570deff890257c3f9cfb23",
    "AWSSQS": "0d90754bff87f8cf50af7066491de49fa488d0aa5d93225b0d2f9067e70b79e7",
    "AWSSageMakerRuntime": "5af854229785883ab1fad6d6a9270e5814ff57d60ef76721bf2ef33af51e56e9",
    "AWSSimpleDB": "517ef7883ddeff67f81b5130fd2c5f68325f023f67ae40fb19f78e751eff6d31",
    "AWSTextract": "ab7ccfb7324450c8c23b432c9140f2ea5e3c6bc74bd719d527617728e06f54f4",
    "AWSTranscribe": "acd0f1ec3f46af1f0d7cbd65a6765003ccd88c0d468e64c265dbc9219cba498a",
    "AWSTranscribeStreaming": "d1465dfd97bf7d9473486cb5d44d605434cdacbc18f40abfd13d3e515360db42",
    "AWSTranslate": "a2c1813d1a424da4563d30e4b055b47bf0b4d1aee90729c552baa1ab709d8065",
    "AWSUserPoolsSignIn": "945b77eab52bd8961cdf0f3b9155adb9f76cb7ad5ecfae8383eba4b211ead957"
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
