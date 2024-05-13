// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.36.2"

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
    "AWSAPIGateway": "6602e5782b5587e04a8bc995b7636ac43ed0d492a0cfc3a207c1be8229afc842",
    "AWSAppleSignIn": "f5eb8ba3379b20c994f02005e3cf5d294faf61f03b8e8bd1fe051593340377ee",
    "AWSAuthCore": "deb4b25de04084089f348b5f6cc85937df5fdbb4ed15ef39c3316519472b4677",
    "AWSAuthUI": "7efb8020fe21d97407d8f22f872524b7aae01db28c7e9efc3d185f0099098143",
    "AWSAutoScaling": "c032a61670638df5c821bba02be6fe8359d0176a9b6f2a869e90231d76ef930f",
    "AWSChimeSDKIdentity": "283f439811d3000e623cb96d327d050618873e77c6933f7c492c534b237edd8c",
    "AWSChimeSDKMessaging": "5a75201470077ff74fcdca45322073d44aa8371d70d8af20f80c06ea7be6fb32",
    "AWSCloudWatch": "422c6aca6706424ef3940de8ef5acd4703b5be0dfb1a195aee7c62a698340f08",
    "AWSCognitoAuth": "a07d07fda82aef6f6770cc7616e86c0fd054391858fc56d15eaec3d9d6052dc0",
    "AWSCognitoIdentityProvider": "8c54529319686d0e8fe825377c08c6133bd0ab7c8fee652ae61cf163d4cebb1c",
    "AWSCognitoIdentityProviderASF": "575ef535b9bbaff39c65c0e843cc390bacd302b448e9dfa94c1182054f1621f1",
    "AWSComprehend": "85b0771aef3898bfdb5d1c592bdb111e20faad6c5b718d916e82803fd340bb1a",
    "AWSConnect": "189e503b18f44b3cc5fd3df003197a5b67c643df345af3f6ccc323c159580651",
    "AWSConnectParticipant": "8f791ec6656a47f9fde703573d8c1bbfdd98e580e6e0604204f52dfe7a68ee59",
    "AWSCore": "1a428788e78af41b6e2b9e00b29feb9b6c2c73d9f291bb924efa89ad3db40dbf",
    "AWSDynamoDB": "3589517bbd18fe36201f2a519167622ccf1d650bf36c2a7bea930556320f7997",
    "AWSEC2": "24347e8487af8557bc790ce54a7507354c1d89467121eb3dee50a986a998ae8f",
    "AWSElasticLoadBalancing": "60f85e76f8a3fb5256f3b65e3c912534cf49d9c94831a7fbdfc45a463f97aa94",
    "AWSFacebookSignIn": "13c4b845aa354295553fc11182d390fd43582570e6421a81d777aef29b818fd8",
    "AWSGoogleSignIn": "ba5e9e8dcf00e0ddb7d58f10a1b28a515e36c3eb58c70e4eb81c5468c84f3eef",
    "AWSIoT": "37f044f4b4fa3a6c4c4849f724303e6a1feb37728ad0d235dce5cc00656aeef2",
    "AWSKMS": "70ae4801dae93bf74464ce48b3ece36e6a0bad0425dc82c61c37fb93fdb09a03",
    "AWSKinesis": "be46eecf3bc5a8eca510497dfa75cec48d3a4e10601b35a44e9aad2c7bc01702",
    "AWSKinesisVideo": "304f8085e9a5e8fa77b34b09135b6b6dc997f56bfd2ca80c3d562f0c3947a5f5",
    "AWSKinesisVideoArchivedMedia": "f748867397ce128a700a95af033196c2f17cfccbdddb7cfd4f5730ca9f74434a",
    "AWSKinesisVideoSignaling": "3a0956ce03ec1c99757c43e6fa698ee0e43c22a429d2f1e14e0b51ea17cb2f90",
    "AWSKinesisVideoWebRTCStorage": "682301dd01abb1817555eedede77ebedd3b4271153002ae65bae36d985858ebc",
    "AWSLambda": "0109c13066976fd87b25530e69c4c1cc14750697836045719ed849eab10c02ff",
    "AWSLex": "2d21264fec8225d6235223a5c37434dd353d75039f0164aed81c7798b34bb5a0",
    "AWSLocationXCF": "c74882d254e65e0e3bb83097eb09f15aa52ec2ec47c6631a5bd61cf50d4ea332",
    "AWSLogs": "d67c145e8e2c7ce54fa0c391e9037ec640494b7b40b822cb81049252ba2b9bb2",
    "AWSMachineLearning": "177eace2f522bfab02e38ee9348c2142fbedc9dcb47b0a8ab3d6b778182ba67c",
    "AWSMobileClientXCF": "396ff79d947699f3d6d46fd609a8a5d7b5703a7c4a9d449a351ddd07c7f50456",
    "AWSPinpoint": "d97fe197a6ab6ddacd3c29efe32fbd3bb9399c84eaba88ca42b3cb164a91c422",
    "AWSPolly": "d9d9efe2a954cdae65a2aa2a1821e2435b965fc26c59ff2c02c453aa9dcca2f5",
    "AWSRekognition": "a429ec4e7ef028ebf9fd9437067927542a75f8f12a05de011f69632802577826",
    "AWSS3": "ae033b3121d1a8790db219a4385be08f69721bd37fd1948fafa842bd9d47b130",
    "AWSSES": "d63c21b62ff8afc7b77901d23c02143222826eded894007347d2430972b0844a",
    "AWSSNS": "f70c95d706aa94e78678149203889a6c98ab21ba6956c12bbc89f53f5acc9d03",
    "AWSSQS": "cc8531732c2aa6897186572f9932391d1b5ec64be14a6bd58e6c63fbcf9eae90",
    "AWSSageMakerRuntime": "649e007cbebabad05c54a8f7741eba07f30ea586060e7882cc376f7f43e0cbca",
    "AWSSimpleDB": "bbab3ad8aaf88f3b30e566f8ec3266bcc5fcb87d293cdc31b34fb506d253e4b6",
    "AWSTextract": "0c8c2422ca635d7b879f25082a2fb4244bb2830f90370213e18746af35368161",
    "AWSTranscribe": "33c612fa1e42752611254adbd2fa140513e2fa52422545e736ad8de8b4d4ceba",
    "AWSTranscribeStreaming": "954b2f8a8ac56a459c85f00e7af0e05546eadca6793f322d7110b1d4281c62bc",
    "AWSTranslate": "fd9fa171e89292a4453b4b6a38bec558c71f691b0f41c194da73233073f66790",
    "AWSUserPoolsSignIn": "ca37f86e5c0cd70cb8a044d721e3f8318d26837b03fa7cc3b3c4883bfd383edf"
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
