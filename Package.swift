// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.2"

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
    "AWSAPIGateway": "ad2eae6522da96d5f38e2d46d24dd3ce963c37b070963464ff48bad459b35a9e",
    "AWSAppleSignIn": "c4ddd15c9495ec930a0027defb21311a761ec150ab9bb2283a5c2ea5a8203aea",
    "AWSAuthCore": "ee71271e621b4e48854f72d6f7a48d6901f5d6a79e26e0380a764e2529a210dc",
    "AWSAuthUI": "7a6b5cb752a5a1a3bb9fb491f020b1bb1d328746c3519f0f1bf5dc610eed52df",
    "AWSAutoScaling": "c110f4e479d2c6e6486e2a39974f506802c7b9767ae3eb026a9178abf0877d72",
    "AWSChimeSDKIdentity": "3a8f904a882716ebd925243b5d3f7bb91e9e984c106c561e221aed523ee240be",
    "AWSChimeSDKMessaging": "91f8c3ced44d4a4ab156612eb54dfc11745e86cb26bcce440055302ae6f0f388",
    "AWSCloudWatch": "678299b5201c3a7a664e00ba14c69179818a71205ba4354a9d071e9aeac2fec9",
    "AWSCognitoAuth": "5ae39978aebda86cfd9eb7abff2314744f94ae1aa748aa6d052c801a640c9bf0",
    "AWSCognitoIdentityProvider": "ffbbf8b48e10fe4ecc09dfc64c3497f8a5dd768b8d5d3825338c2ccc87f73ba6",
    "AWSCognitoIdentityProviderASF": "0f4c1ce39c09c3d27fed664ebaefddd6b4c7eb2077129185ca93f6e7f201d194",
    "AWSComprehend": "39e11141cdda537ab0c54d4862fcbcdcbb0d73bfc4189f46683385fa2d24a85b",
    "AWSConnect": "3fd6a766bf5b2cecb691cd22fdbf6d21628c5f878708b3b73b4efff0a96eff55",
    "AWSConnectParticipant": "899a401088391d54a7cdd676adb551560314294e3c88d834468c630aab18e4bd",
    "AWSCore": "30525f659da50e7767fd6701ef2c35b6d2d20fd5aa616bf370ad840de0d03958",
    "AWSDynamoDB": "15129dfe078b73ea202c716402b6d82cb5142fd28f11f3e3c950a5cc256a587e",
    "AWSEC2": "282095dff6407fdd3435cc56e9be70142cf5e1669bb82a146d0d35cac708caf9",
    "AWSElasticLoadBalancing": "e4f84a3631b138dd8666dc9b0c193722c5851766333e14483d6a7b7df0743535",
    "AWSFacebookSignIn": "f3c5179232a1fee2606f0330de72037d8a300e5c50b5485fbad7bf82dee09f1c",
    "AWSGoogleSignIn": "56de34cb186e12b3dc69c9eeed72a344af5b211df96bd6c1a7977329cdb11e1d",
    "AWSIoT": "b5cfed8dd3024fe737ab7bd5a38374f7529a3c5d599b62c6a64d85d1f635e41d",
    "AWSKMS": "428a1f2525a69cf09ae934123f256da10657b490a5cd91c272b4329b10ecb990",
    "AWSKinesis": "e770f6ee4b7e9e368c11e0344a05df74ae4d8ca03b5cb44d690b69d571c7b911",
    "AWSKinesisVideo": "5080af880879ae784c7f3da0ad099910fed06d8c4e75494c27281de7d4c56f67",
    "AWSKinesisVideoArchivedMedia": "91030f9cd3adce098f2b18098d51a9222adc01ff8a6a53b222e6a91ca232c47b",
    "AWSKinesisVideoSignaling": "3353b7582a037ae50f3e757046f5606e877f29ce19f796bea881053ec2b24fd4",
    "AWSLambda": "3eb3a68b84e4922805523a40d4345301d965a41fad72dfbc20274a4192536680",
    "AWSLex": "5a7b79be930dcc7065014254d786046b8be714055cba329a727caa0ec269e4b7",
    "AWSLocationXCF": "0e14492bc02478720c2b29d2aa3292e73c41d0aaa16336b06d910f1a7a29b3fc",
    "AWSLogs": "b4d7e0dc09c643596c7329f95d81e96886918c67a47afbeb1e385f28059d86ac",
    "AWSMachineLearning": "d2c9fb79b94336049a0c9b64f8f47ae12ef705518cd3dbe9a56b14a33fff9f78",
    "AWSMobileClientXCF": "96f6778866221baf757f7471b9108befbb4b79f482786374e6f184048cd47604",
    "AWSPinpoint": "fb8e63ffe56f1d3ae129d3c158d33d75e160a40e9f99fa40fc9042cd1afed33b",
    "AWSPolly": "47e2d57a5c58c06739b3a3ed216b696570d17fad8111a711107bb6d95541fe84",
    "AWSRekognition": "0b013f57d5aa9e28fa09c54a1c226919af15f16f014ec54f628c2e960de21e82",
    "AWSS3": "e25f40a387616ccd8fc540b87c7fab9e551c70fef64d0137b429cf1662d6c55d",
    "AWSSES": "6d5141879a5db52e19129e0cf008ab8700fefa08a988c5057d01d67b0ca8359d",
    "AWSSNS": "2aafee2dd98ad538677e03a009ef5bb14292fa203abd6b3b602e82c85d6c0f07",
    "AWSSQS": "f8553c66325fa516d587dab121a834273bd85474f7f4a2568e4dddd1d0a7fafc",
    "AWSSageMakerRuntime": "3edfbcc64edb05c45a43e6118682aa4a1b2feb4524aef41378beb1e3ba0daaca",
    "AWSSimpleDB": "0c8ffc8d4b1bd888aec2e4df54d7eb4945a7b91c8d624d36046a86e22ede2c77",
    "AWSTextract": "a6d4896e77c15ed1a0799d036333fc6cb41d1ff6dbc339b9111c02adff0d9795",
    "AWSTranscribe": "f84161137dfcfb5363685a204180304a47f25e316fab254a4f50fd5e12faaf76",
    "AWSTranscribeStreaming": "190eeb007809d55ac7a5bb43bb34f7ea04ec56189f9eea891e747ed1355381e5",
    "AWSTranslate": "6a55d2590f1a84424147afcb54392fd461f1ff72501e4dd1d9159ccf909104ee",
    "AWSUserPoolsSignIn": "53a5f16cf17745568549f489ca5c0a1b4938106b57860ec73da35f42034df8c0"
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
