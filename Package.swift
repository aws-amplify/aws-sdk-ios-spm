// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.31.1"

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
    "AWSAPIGateway": "50439e2a280aaaee56f48e8e6601d204d306e55df089c4a316f8c29b4a17a534",
    "AWSAppleSignIn": "4b8adf924d1b62b6d3d5f3711927c08ec8b77208e8defb82b44dc28e3f4c99aa",
    "AWSAuthCore": "38ea9e9d0297727c8f2d1bcbbe9ec09e152214a3a2baba222616382e9394ec15",
    "AWSAuthUI": "8b4e4ea8ba45c595573a85ec8ee1aefbfe745461ec02995c5a7143c806f21b30",
    "AWSAutoScaling": "33e9ab587173e0f587ca05108d992eb2ddbe34279eb95c684f7da3a3c265f200",
    "AWSChimeSDKIdentity": "0ba73c222e7d965f04e0c01a28176202049b6b1fbfc4cc18b88edd6333871195",
    "AWSChimeSDKMessaging": "f707e1543a3a39da96b8abcef739e7ef1b3909fa3e2c685056f0e1f9856b6046",
    "AWSCloudWatch": "bd849fef7206e97c9d3d8eeae0c95dd4341ed8b5a39404f17d17fcbe69384ccd",
    "AWSCognitoAuth": "8a6c830c3329e45bd41614df7ed3f41f8c92a2aca5093d42487604128726ea6f",
    "AWSCognitoIdentityProvider": "7ccd72e8f628fd61ecc5154e8c26a75c7b69ef7d7c113790eec653ec5b5bdcc3",
    "AWSCognitoIdentityProviderASF": "b3a279d7a24b6c28c7d456ac1eb570070c160a9803260da2ab50920d56947b8d",
    "AWSComprehend": "dcb57142ce75914d11ec091fe49d448b624c050f3fa969170154c0f2a35d7833",
    "AWSConnect": "e8d1066be02ac9e70f9d69cb445e964112d8d68841fb9928370ae222536d4919",
    "AWSConnectParticipant": "12256a9e06ce0718c43e025c078c9c0ce0dfe869c9795dd8cc540251d18daa37",
    "AWSCore": "1b81e43afa7d105a0dbdb70756223fdc2999475ebadfedfcfbd0fffbc37008e1",
    "AWSDynamoDB": "1e4fb6e806b0977242d8d9c2c647ae10d1b5f515a4e8bc2e96d75b1ac1d2eadb",
    "AWSEC2": "2fdd0311d118e6d7d9fac9dc5b897b15fef9e2f21059f12d89d98260998b0c53",
    "AWSElasticLoadBalancing": "0443619675bdf892bb43058f02960f04f41a556218a5fb72bb68432397053891",
    "AWSFacebookSignIn": "9bf7dde0f452b5f59c41a4089f52e8534f849cdd221e683eb380bbb1a119f4aa",
    "AWSGoogleSignIn": "4318c221151cee810626730a6f14b92fd97475bfdf5531bd446984f964be6ad7",
    "AWSIoT": "043c534407c1547b2ae0d0ecee0917fac3b4b435336924c5f31ee3ce0b22c5b7",
    "AWSKMS": "cdd9790bc06b84e177ec273f10994bb95d008cd2686dc63ac7991cec9af3ed2a",
    "AWSKinesis": "6af5deacce96d904114e41c56e676ab7754fb33980d4d5b5e4dd6ac10a8f1de2",
    "AWSKinesisVideo": "645397f337f089e1dd58f4748249c37874573c14e44e4b265ded165a8d78e243",
    "AWSKinesisVideoArchivedMedia": "5686b2f115c360498d66f195adc57664589a9edfa48310753df32d4a9ae646bb",
    "AWSKinesisVideoSignaling": "dd3968475813da51d16742811e28ebd4138987a6a5db73d7e76122e0469dd65c",
    "AWSLambda": "61cfe81dba3ebf764c3417c543223166cd45315f1469e4e392d4e5ccc21702fa",
    "AWSLex": "264fac6676927b525b03d8444ba85d6ad26e8e7b6475ab61eb64ae848235c977",
    "AWSLocationXCF": "a130c602a7ccb62a55ccbc27eb3f151533e5b9d3a2e9dc037b2b986569311457",
    "AWSLogs": "a58ba4d779e8529241acb7ae34af93cb58853abd35f7133816d19a5e1d5f6ecd",
    "AWSMachineLearning": "973be69673160940ecbc72c0b6552f56129c6e5f8ae98b429c57b5a79222df0a",
    "AWSMobileClientXCF": "18fb7f0e4c6eec1e22c7ee6b885e363eda35d71546b2cb2e5e4174e67b4dfece",
    "AWSPinpoint": "b5954f2511d5a9468ab9b595ea6f74388e4b192f6163dc169e57c89c26478627",
    "AWSPolly": "90ef7bbca28b717a907b122f3df2c3df73f2720d7b5696767a54d9abfe53d2ce",
    "AWSRekognition": "3d901ac6872a457f145ae8029c0714c2e096af0581ed23557ab2a8494d40b061",
    "AWSS3": "a0fe24ce8ceaee71311eeb4b7f62a0351e52e4f0862c4492fc16a3d15f554fd8",
    "AWSSES": "d2dba902f00c79e5e949f8909499d7b1aebb049b6a5ce9915cf12694aa79f836",
    "AWSSNS": "bbfdeb19b69bf152ee39894316bc9c275c78284e621d282e407ad29d7094e3db",
    "AWSSQS": "3f8c1e36eb4787af3f82217e2bd251f6a1e3d0c096bfac9a034dfc844d80921d",
    "AWSSageMakerRuntime": "827596b633643b7fdf64967491b4db49ec222b2314ad1e0f5d493e3e60acd563",
    "AWSSimpleDB": "45e41a758f3c2e42f6651ce68609791fef433960543eb037448c4bec63cd8954",
    "AWSTextract": "a5d3655957d76866c33dfd7a17ab2885cb234d56f8cb5278be3011feb8199efb",
    "AWSTranscribe": "913ab684f2a55216abab766bb3ff91926e31b23a99a7084ec27ba11c6e43eb5c",
    "AWSTranscribeStreaming": "b9334728285b2d2f0658588cff5cd3a3a276f6c8bf28b19e63e4d4b1a41adc79",
    "AWSTranslate": "e029713463fb244a6b4c043649b5a642a96fd2885ae67c7bc34509a468b2334e",
    "AWSUserPoolsSignIn": "6bedd432d7ec824272f245756911ed0ea548a39075a95e1a0bf40eaaf9958da5"
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
