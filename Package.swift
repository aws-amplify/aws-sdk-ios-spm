// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.36.1"

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
    "AWSAPIGateway": "215032a1ede1e15ba16f68a453a0e9968e3e60cf5ab6adeb0cdd02349c4acc6d",
    "AWSAppleSignIn": "498c6aa77a04704cd8d66c32adc7b8d106169d9e95ec07c79691aadbc783332b",
    "AWSAuthCore": "836c633a70e1525668a0d1391027d1b9e45f636ebf46d0b5f818c0b9b4572021",
    "AWSAuthUI": "2995bc62f0e067f3591a3fc70bfe036acf6f8bcc273b500b409f0eec022d8dfa",
    "AWSAutoScaling": "2c05f060c6d237c2c2fb3c0ca3fb47d539c832cd866bc4b421b63551526c7fd7",
    "AWSChimeSDKIdentity": "888b5b1c170d7ab95d62a829214367463dfb19f6e156495f0cc98958e93245e0",
    "AWSChimeSDKMessaging": "cd74babfe01612d3eb7191d69cb08cf55879e8ebe1ac9110cf20ab2b79f23d2b",
    "AWSCloudWatch": "265fdfc5ae52cc348fa345f2d348f2956613053a760b64597c93632b645c26d1",
    "AWSCognitoAuth": "5cc1f762fc5b6afe1503b3a313877a0bc21a291432d638c68b35f1e636ffd2c8",
    "AWSCognitoIdentityProvider": "f34e94f964799ccd12e3f3b6cc8f6ad00b761da27c82136abd38bd377c2063cc",
    "AWSCognitoIdentityProviderASF": "32089ee21e6a6300c6559a556808c583ef5e35201e6599ee4167fbab6f6fb88b",
    "AWSComprehend": "6104936a9a630214f0dbd35defa6186b05ab543bb41bf6e8d4e513b5f46ee472",
    "AWSConnect": "f1ad1790dba688498aefbb1bbc1c778115486df30d692aed3b75b856bddb236b",
    "AWSConnectParticipant": "16c2b69f78a76ad8be85ab89bab5fa5152e9ca49652846cc36b49cbd4c4d32d2",
    "AWSCore": "a6edcd6e240dce6f5dc552646889c4ae4e672b1bc574497b83b19ac3b2ed5e9c",
    "AWSDynamoDB": "a67330f17c2c62fe811032b53a7dafc1de85426937bb3aef11f30e8dbcb6359f",
    "AWSEC2": "8ef2bdce5ae4b0f6f02b7f721e592f6061b7a046627d2264af1813258564222c",
    "AWSElasticLoadBalancing": "a7f1e396f38b118bf7d24453de1e539e28d460c57d1c747c2d9e7592138df842",
    "AWSFacebookSignIn": "d509328c62a77b9d18a58ae4840c18ad4ccce481b8dab9450bab19f91fe13e67",
    "AWSGoogleSignIn": "783dd48a26240f9161e8c388b01e4cfcbf742933166472fd5547ec70af236168",
    "AWSIoT": "3f2f033f520808accface7bc15992b069e8523f6cef481c800fa81b7006d68f7",
    "AWSKMS": "bb09c2f1497339cbe98fdcda8e2977b2d6b57a57eb02bbf6159ce3374d21cc10",
    "AWSKinesis": "32542c5d416ce4fe02e880fdb7df903fa14990726339cf921d99caf359ba1e0b",
    "AWSKinesisVideo": "ed7f1737ff812bb03f5f38748c5f6b2b647ef4d6f95540a8bb26f9ab8bb297a4",
    "AWSKinesisVideoArchivedMedia": "f6960c48b4d81b6ad423454b262cfc08c6cc2386747626442b2ef9afdf1387a2",
    "AWSKinesisVideoSignaling": "76cb9a7a9b92b84e433cdb95bf4fb3474868172f549058d81e96c9e6d72ece93",
    "AWSKinesisVideoWebRTCStorage": "6c3467bb7cfb188e8bb156ab2cfe91239583fa7c7a3d7a324974fff45b0d10d9",
    "AWSLambda": "ce695045642687567010cd55d21fe68d5f37126652789a6fd9a1f1ae82bbeec1",
    "AWSLex": "217dbd0954d88b3ee492ab3a6bcd8b78113f65500b9f651d6af99e55127aceb1",
    "AWSLocationXCF": "b5a1e0583dc14d3a65a51da9e56493da180fa9a23fb9128d39cf9d08110f0639",
    "AWSLogs": "3aa41803f69fe8e923b35e244b2cd11661c090f56e69583b7bf73d9a4785e5f2",
    "AWSMachineLearning": "6277c1a8e20f5cb9a31ed664613e1b55d78b1a707f250baee8cc358aba2c96d7",
    "AWSMobileClientXCF": "a8fc9e673abc24bb27e006c4d5a394bcd3387e11165d7574d75a86437401ad53",
    "AWSPinpoint": "0c7b6e4bb1c858f8669dca5572144d3e1c92796eb2e07c34e7d7e7f6c841f639",
    "AWSPolly": "4f0b687d8b6dc3016860d13942fefea506eab8fd99582aea8ad95570273b6cf1",
    "AWSRekognition": "d9847da441904e2be031b51a5809e1b43b37c44b704595f026fb043275212f5d",
    "AWSS3": "411778e11fd9d3eef439dff3074102aec2e9f847ce0ae0c6254c20b7452c9bb9",
    "AWSSES": "2b051cd0e13c033a4363778cd2cb4ed68fb7132acf9edf9f39aa3cf5e6067029",
    "AWSSNS": "bb5052ae0406b522283ff067fae2b5f6d59bd5327506c4389bf8f76aed4a7159",
    "AWSSQS": "2876dffc71eff20f591e7dbeb9d25b5eaae191d51858da8801092b27a9d0d323",
    "AWSSageMakerRuntime": "f8768ceca9ff9d78e51e0373e22cc2cd69b1ce5cc60277ecb9f310f2a24c6722",
    "AWSSimpleDB": "4819651935b1ffa9f808e227d157287e667cfe0bb097efeb723a83e60f6de257",
    "AWSTextract": "8f45a224edcc723ae25d8a2b58cf00a408f733a44379e48a88555309a3e45275",
    "AWSTranscribe": "1de2d1a78b507af2eb23616ad6d8b1110ae58cc2afa9b28bc8df8da66cdbc28a",
    "AWSTranscribeStreaming": "f720847b813672804e164945f48e672489cccc3c2489c7735b684a49b6b2a342",
    "AWSTranslate": "191f3c314e1cbea1e98a7349d63a2a6c22b4b267b4d1ca1fd8f4e96a9b7640cc",
    "AWSUserPoolsSignIn": "f1ad53e2028da61b696112de6ca654b22df2bcd69a89fe556521c8ef3ce92002"
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
