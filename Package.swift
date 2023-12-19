// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.6"

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
    "AWSAPIGateway": "23d688c35ab23291aafdc5d0b51099156ec898c17f250bbd71dca90518104d54",
    "AWSAppleSignIn": "f30ea4d95888d7c99202e1893628c70ba589faaa7dd9f81f831674e06534ecde",
    "AWSAuthCore": "66391a9d411208d50c9f041a0acb79ae12d524888dc9421b76b8eeb582f05135",
    "AWSAuthUI": "164f2d9ab03b0b2dd51cedc1447d65062544c387cbcfd2afa514bec8844c520b",
    "AWSAutoScaling": "17b4fb597f3d657ec0a55277e1b45cf0b4c81aeed0b204bd668fd0bb861f7084",
    "AWSChimeSDKIdentity": "0dc0f13500bc36dad0673c8f6f7eafd4a7174758723e42334b31ad443d35a8e7",
    "AWSChimeSDKMessaging": "56a3399458a410b4a18babe41b2bd04585559b59d8fb8f60ef67285d6e919529",
    "AWSCloudWatch": "7f44887aef229e5805889115c751be0f9b7fd9a49c8379ab0d8ea286ff1e163f",
    "AWSCognitoAuth": "e44de09204cf9aed642f06eb998dc576fb7f50ebe45917c25320b13ecd5417f6",
    "AWSCognitoIdentityProvider": "0addc800cace39dc9c69360ddef2cc37a4967036efde1ceb7e903dc4655ed4f4",
    "AWSCognitoIdentityProviderASF": "36890eb114369733ce65d2ac601492bc42f7066c491b58a9134339fa0da2224c",
    "AWSComprehend": "e94c2570771675db99d19d7639741058614e0ecd25cc9033dcb4cca45f1326d0",
    "AWSConnect": "4e9fa38275652ab83e2d94622884e19da900d14611eb8c83998cc7a153cde5d5",
    "AWSConnectParticipant": "c997608d5cf35104e5a39ec7a646f52a53f7ad3f7574172478847b066fb0a0b7",
    "AWSCore": "489744567f4e9897d73eaf9704382240445412bc808835550fc4f13b90f4e57c",
    "AWSDynamoDB": "dfa6bdd2c851914789c18715720315e09ba9a2c1704b96f237bf085979997253",
    "AWSEC2": "a6b5b7b7566823e7bb1359d76002c37e7e8841ac7b094e49bfd03447b4bf31f2",
    "AWSElasticLoadBalancing": "54c51be0fd1b0fbec247a26faf3aa0f5c25b9ea23cd2c98d61caa59bef26a221",
    "AWSFacebookSignIn": "67c007436bce407d7a046ae2370a14b73df8b25169735f57a15cbf8963eaa35b",
    "AWSGoogleSignIn": "dc883592c505023bd54812f739aa5fdfb2394b1130505af64a5d8a3510ea56b1",
    "AWSIoT": "32a85d685460c22a27d21080fd495f9b76078ab27e00ac42d41ebe6da2e74442",
    "AWSKMS": "d3430201881e183b5a91630fcb03762ad28f1a9be08e07f01fca3be9a429ac5f",
    "AWSKinesis": "2883b1459809c7b5b0b829b2b372fe23f7b62f0b6c4a43088c22158ed37b74a5",
    "AWSKinesisVideo": "4340af97a9d666dc072271acac5a57d89fa1748302e74c5fdc07b2cb116d0d77",
    "AWSKinesisVideoArchivedMedia": "303222a0a02d4cc0440b1350420348b6bbb9fe1844aac42fbedf25c8d05b2607",
    "AWSKinesisVideoSignaling": "eca52926d1c20fbb7bc05952e0d69b3dfd20e5fbc605170fc2e33c507ca00e4d",
    "AWSKinesisVideoWebRTCStorage": "901f10f8788cd3de1304751fc26d7acdd33f2f1880c8bdfcc428daf09669f024",
    "AWSLambda": "a82cd941a5359f3e9985603105dbe44e4d3310cb6fd0884c32647ee697d3a53e",
    "AWSLex": "23872005d5f431dc9fb47e83192e59ca03c42189e359314db93617afb9212a0e",
    "AWSLocationXCF": "f3802b0abb7846ad2564e80c6fd5ea2b40d963fec1bd5e4f8400d875f2269776",
    "AWSLogs": "2ea0ddb06d862fa1311457191539add8b4f7e90749b7c554e76e201960ff3280",
    "AWSMachineLearning": "f29a7d5f0b01e84f086727ec0494d1730fab04962499148b48e5b903d2b67c87",
    "AWSMobileClientXCF": "d6ac0e9b4feb21ec045783db281acea727cc96d15e131be38b240c83268aabd0",
    "AWSPinpoint": "b51ee75fa3a9b21e441d32a18a7b76547ea5c6fa48a7d0f48de513b1dc94868e",
    "AWSPolly": "155db13576d431c12e31b02d35bfbc2a88f4247352e80068938e208f00104839",
    "AWSRekognition": "fa12d3c0584169ddbac1b73dfbae84acd92762dfd1abb770b7b917bc626ac26f",
    "AWSS3": "80b6e60adedffadad3be2b4d17160279558e9205b575c46135549d91d60efc36",
    "AWSSES": "8e0f4d22f2e22c5bf571957eb399a118741b1cdd350174cc635a690be7e1dd01",
    "AWSSNS": "d19189e522be6e134704f334861720914b64651495657e659be5ff33e1f6e08d",
    "AWSSQS": "71fc1e85d2fcabb63150ab50e1b74a8abbc491024a0ad37e5e22db53ac62a831",
    "AWSSageMakerRuntime": "2c95d1ca1a037c7fd757ace20e2983d681318530969f7dad05a1fb899d665a3e",
    "AWSSimpleDB": "0e900213dd7dea897c3f485f227023273e50fd47c9036ad0b5b15c864a737c09",
    "AWSTextract": "ba3375da5936329ea73fddcb955527b80acc6d7135918b1a7d2f8bac3edbc231",
    "AWSTranscribe": "082e559fbcaafdb3e6575e8eaf2b8f5104354cbd7765aa367387a4bb9edff336",
    "AWSTranscribeStreaming": "85d6551ba337ce1f1113abeb7ffedc156ccf281f9448c0ffe415e721c3e49d4f",
    "AWSTranslate": "56d2e4fdd18bda73562c1ef12edf7e19fe005c49ca3592d04a636aee2b959f93",
    "AWSUserPoolsSignIn": "4e4d63f394dbae6f383627f7b2ffc8573684421614ea9917ddea8718d57d9fe8"
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
