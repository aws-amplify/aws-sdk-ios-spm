// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.1"

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
    "AWSAPIGateway": "19af4746dc949351035224bf73a37834b4bd520671592d62fd06f84a0a5b227e",
    "AWSAppleSignIn": "fff64402a6a1ca5de118043c74b26a9312b347cb6ce05c0811ff46179a1eadd9",
    "AWSAuthCore": "fc1c408554e11da7df91aeded02377e91d6262b7f36223be497f494257cb98b3",
    "AWSAuthUI": "6a24229c89ce24597d68b87c666eba8235fc3abbbec02eb88f40236ece26be1c",
    "AWSAutoScaling": "d0ea5fae93a315845a52f909ec74bee51f4ac8f1534ac9fff94e23cd3f6f75b9",
    "AWSChimeSDKIdentity": "73e58b1c7469c3e3c037ac2f353b6b949941d5eb8d344457b09029e4bcc8f80b",
    "AWSChimeSDKMessaging": "22420eb4960a7579a365d71105d98e564a629693aa93f711d9550699cf0a1de2",
    "AWSCloudWatch": "4ac36567a7ef6fd532e2502e0ee387535a2f07efd605c2212b953781b354545d",
    "AWSCognitoAuth": "d1463a57aa06ee9cbf47347225f4852c7fd08cd448314a343f4a789f52a94bf4",
    "AWSCognitoIdentityProvider": "1194dcb5331b10f9709177bdefb386926aabd1fb78c58252245279483959f579",
    "AWSCognitoIdentityProviderASF": "deadef98379f3046e46e2b4ad1fbc974546ac8e848e101063170ffb177251f89",
    "AWSComprehend": "997679a3cbfacf3bd921b31ea4fabac1dee01a32fa86bb0c43798e3e7b232c91",
    "AWSConnect": "91f75c86ac7a2e3e8e38138741b2331c91de0055e4acaea8877294a549b6fb6a",
    "AWSConnectParticipant": "2d0be929b243d4bc794906d22db2b043b606a1a9c1cab46e70bc5cb795fed796",
    "AWSCore": "aa83a76959bdd8ac9f5efd906e91f80d9ade772cd2a9a8cd8877d85bd4cdae32",
    "AWSDynamoDB": "715f457307dc74362eb778554bb81e3a57ff80d50af7a68f2a59cde4b15aac85",
    "AWSEC2": "120fece696715c04bc9a2dab94cd9d9d0173cb5bc8a110f2374ad86dacde3c29",
    "AWSElasticLoadBalancing": "e952cc277fbf8522656bf3c7a5686cef72bd0a55cbf580ed5d6f302cf84d0f80",
    "AWSFacebookSignIn": "96e3f65a75562b65a4e6ed61668a5ddcf4bd6ce55796bf6c28033e8629617ba3",
    "AWSGoogleSignIn": "754feea3302a0edf05d447a0e49d6974ee493ad8209abd58b2a4d737f916e3df",
    "AWSIoT": "493c02f833fcc43abefaf1259c17661882d704005f01476ce8624e56179b0331",
    "AWSKMS": "80fd3c2658c7ef72855f1834f3cff0b319fa0b3d2605ca7a6826e6ac42d228af",
    "AWSKinesis": "81ad7201d70b5489483a23aba845f0527578ab40edd26dff9a42027c4d3999de",
    "AWSKinesisVideo": "d4b3d637c0bb4a9420bcd6e20c89ff31056ce4081fb59b886b8196a98fadc87b",
    "AWSKinesisVideoArchivedMedia": "01c8993f0af4b63e8d8a44e3a24a50a1d238f184a7c5b0c1257ed38ad29152d2",
    "AWSKinesisVideoSignaling": "7890ce953183d9e34ca8904de1c2c809b4dfee236f4bc03f9ff03d5b4ba53487",
    "AWSKinesisVideoWebRTCStorage": "b6fd60852863e6788b793758519b04a0f6c778b21529639cc785e6dad75fc8b8",
    "AWSLambda": "6b427c17720b1dc14ebe66cd9db85b21595be79b9240365dfcf54af5b3df9e71",
    "AWSLex": "7eed85245bfcc95bb6ff8a0f25fd1912ad08bbac769be5df7129debe320508ce",
    "AWSLocationXCF": "aab5f440429a3a46b518979eb042cada5bcbac152d0815cbfd0c56f185afec83",
    "AWSLogs": "04c2387307f65a435df3497b699d7ace89fc4098a953ba5d3a4b4a5938acbdc8",
    "AWSMachineLearning": "c3ba6789bb3361fe6c5fbd37593c98605aaf7a3a1fc439cea229f1fa1ec93898",
    "AWSMobileClientXCF": "aa82e866e06f459f1892bb844c4dde5765cc805ce18ac049d405f19aedc893a9",
    "AWSPinpoint": "72d33473518a283515f4feef5f4f8c1f416c57bc152360579797974d2750aca9",
    "AWSPolly": "701e179aaf84dab930a32a26443fe07132a1c3710ceea5408b30dcb3de63ef48",
    "AWSRekognition": "85febdc9f6dfc5f518271ccae77020635565f8a6ed2946d7c311173ac68bf795",
    "AWSS3": "0cd47881f71a5e549df69b2c30f69650cd0dfae5a9b174dec4141a7ffacf1d09",
    "AWSSES": "e81e512541714ee96020d92022beec69494dc76db7fadc6c76b3621189706648",
    "AWSSNS": "1e848678aec2ac40c0c4da2e08200b5702bdc5d58a84723445dfaec70a9ccd8a",
    "AWSSQS": "33f418d2e90105c61f81f74e88da4dcf8e6319029c14525ac85b33e3d9da526b",
    "AWSSageMakerRuntime": "748dbcded5a6e21c8c19cf4208007ace6ac2f63a70158f50b9717376c200567e",
    "AWSSimpleDB": "1597d8cb748223721e7ad4c9d69abdc2414fef176883c68a71fab81f8410f2e8",
    "AWSTextract": "698278e7429371739aa74e74d0b40414edf0ba4c4826b6a2e66c5b88be30156f",
    "AWSTranscribe": "c0537cf5ece54ed3771a332993305165487a10b728439e1821e045a9a7f4e573",
    "AWSTranscribeStreaming": "82c7dfaa8291f6c074648ec183a6815903ace877ff942cd466d2727034b1ef03",
    "AWSTranslate": "206e81f493291bde0d0e578b248d1b3e393f8069144dfbe72710cac5c4fdc60a",
    "AWSUserPoolsSignIn": "4a2a40aa2e9c7d5687d35d6f1ccef9434d4be72d790c4489e8ab4efb5b54bae3"
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
