// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.7"

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
    "AWSAPIGateway": "5de251c1be8d1374982a91d9cbc1ca5d7d9bf6ea42cc88c719ab98275d049b40",
    "AWSAppleSignIn": "67c33229b5343b92b212e13027a819308163565d452153ce1acbf76b61814f55",
    "AWSAuthCore": "6ab57d8831a504c69750a7a3d4af089ac6dfd9a8d1884f6eb8116eb697014c7e",
    "AWSAuthUI": "772da6dfaef51fbdf1adba212b85a25a29b9149aa5e729fc01fd0f5869b36658",
    "AWSAutoScaling": "f3e1f054c24bde7ed878b98047aecaed808014a4a0c456bd6ce27612a1171a5b",
    "AWSChimeSDKIdentity": "231e058f74f5b090054e79f1bfc2f209ee64d39f15d92ce611d9d62cc8e471a0",
    "AWSChimeSDKMessaging": "f5232dfb00f95d428475ef5bb72725a78830cc402407ee8ebd43516ec481889a",
    "AWSCloudWatch": "9ee64d56bc2512f50223a9bed03fee98975873b260d2854d2b8c6894f968a081",
    "AWSCognitoAuth": "cb7894398faa31713441a62aaab2643b40104406b1cf5a42e26f19c5c8fe1112",
    "AWSCognitoIdentityProvider": "a631c836e625f995b95b7ed5ca4c85687cdd17590f87bd58b4f94440202aba8f",
    "AWSCognitoIdentityProviderASF": "189047f399f6d00cc424b615ec0c227cd0296872035916350a10fc1b5fe2492b",
    "AWSComprehend": "48f948c4c564c2bc035c48fd61b04dbed41473faa7dfb08a9c3d6af427f6e8ad",
    "AWSConnect": "9e50ef5d56e0fb7e316a66df61d76e703ae649a7d954c88726c484ae0ab5e27d",
    "AWSConnectParticipant": "c407d7aff372be35736392d5b6f2989b0ad16ae4f2fbfab857420b3934999e9f",
    "AWSCore": "bdb66cb65a35da3eb77bb46b4e37a1b3974cef05ea53075659fed9a08cd29e7e",
    "AWSDynamoDB": "b0cd019890b60664db67b1e7763c4be8c8abd7321fbacd4f83f66bcfdd152717",
    "AWSEC2": "bd619424d01833725ee398996b6c3253070e00de4ec902222a376338f17927dc",
    "AWSElasticLoadBalancing": "e0dca7d777097b2466bc60f1ed70aa9c8ff4665fb3f731d686520f073e9ed9e1",
    "AWSFacebookSignIn": "06f948d9ef23b70166212f008e98927a183137788631a880ea158e5febdd919e",
    "AWSGoogleSignIn": "5672d1dac18b28beb0718cbfcc373bed3adc47eb48685459c37b2f83f825f6e5",
    "AWSIoT": "e01b644485568fc4cab2d006c9c7960160c951e9c01a2dfb999a5f6ad56a80b1",
    "AWSKMS": "4dec5015b692be2805e121bf7d8aeddeaea15c09bdb647e3b2d23753fe0be482",
    "AWSKinesis": "dfae3bf41485e960c7d51e0d79755ea11fa8629959bab5e453d07a848b19a95b",
    "AWSKinesisVideo": "c686f4e8ba4141466e589c395e5861c8b8bb4496086446693bee6e83f0b40e48",
    "AWSKinesisVideoArchivedMedia": "834ba1acd2a95adc5d3adf5ad7fcf344336c7e9cdf2cd9c1a597eecb4f4ce1ff",
    "AWSKinesisVideoSignaling": "382217ad6e8ad5209fce781423084c71cb1095a4322a729d8163917fbee2f76f",
    "AWSKinesisVideoWebRTCStorage": "76db86fa042061ac0af6f7eb385aa9d543820c823884167345dc9bc5b8ec776a",
    "AWSLambda": "733e2c6424d226b4665cd165509f461ac4b58691c4913d173253e9d1762b64b0",
    "AWSLex": "3c78e29fa426dfa7f5543310d62e192c75f718a4ae46204367539131eb3866d4",
    "AWSLocationXCF": "f9e46e19d49768f070673f1328c3161cbfbf2f40b086ff98acc454bc99e9e0bb",
    "AWSLogs": "4085a53fe5f174cd05f8334934f80ddece6bf817c8288d0a501f2bf5355e6a8b",
    "AWSMachineLearning": "25c774351c8bec7f58e9d2dc0b0a09e845f1e61e2030a93177e1c672893274d7",
    "AWSMobileClientXCF": "b939c04a19b79cc02aea2b656d9d45f33768e1bdb26e45f6dd092be356b86f82",
    "AWSPinpoint": "a5fc27fbaad9c62487b04dcff7c45fe7863779049a3f1199949b43864edf2b83",
    "AWSPolly": "eb9d06f23f61900715fa0d4255234e4012a90eb894a55a34d9bad4c8457f3dbd",
    "AWSRekognition": "679f577a606552415272b3bf7fd0676564b0863cba3efefac6dcb82058caaef0",
    "AWSS3": "22c2e22a7f8bafbf525e9914ac7673e9cff79b38cfaa1c7b4a9cbc67753ef3cb",
    "AWSSES": "142ab5d9b515926e7e8368cb4b13117ef2f4f615b072d07e0d0feb76e2fbeb63",
    "AWSSNS": "af8f8445a02c5bbf49d952b390d2e16bec97739a65a0311715765785a6b40803",
    "AWSSQS": "409c859aa916dc7f0e793ffcd2821ac1ccaa9094d4f650b9ead2721e5e4a022c",
    "AWSSageMakerRuntime": "28f28d3568e01fdab769457667d1e8e7f285e8c579c843975789d3937d2a3265",
    "AWSSimpleDB": "95ba2fc34ec9eace0cb28c059e858cc8e830221f033d747cb5497ffda10a9ca5",
    "AWSTextract": "524cafd0b958af31cf9fd2a6d607a6b29e3abbece49221d083347116884ebb51",
    "AWSTranscribe": "7325ea49b4b232509e67cd227d2c2f6e2db74179999fd9f664b579f3906632d4",
    "AWSTranscribeStreaming": "617cc1ad0980416b71f2bf43109408592f968aca833a62275582f5dbac71046a",
    "AWSTranslate": "ff6e8ada49562dd6b6e7c1c61476b1dd846c01161846daf775eb55e8eeab811b",
    "AWSUserPoolsSignIn": "c5a55e29dfcb620d888405fb261d19423d08bfae0fb9f4a9d6a2a27ad9a71134"
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
