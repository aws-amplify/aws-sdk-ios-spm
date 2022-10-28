// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.28.1"

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
    "AWSAPIGateway": "89de550a9e85f8d3e777dd5dc391e633eb3da1b20f0155e718ecd76a71c407d6",
    "AWSAppleSignIn": "068adb23aae4981ae5835e0dbbf639baa90a8f62085865982cd602576108ac81",
    "AWSAuthCore": "de4e3f7c73b15bfaa5718cbfdf6d2798c80119c2bced85c7cced0df507a0335b",
    "AWSAuthUI": "6f0e5ca0f47c59011e473e7801a65f4b8cc723af72d32fc5069424b2adfada3b",
    "AWSAutoScaling": "ecb79108f76e352d41165f344233a57cd31cca328d6ea7cdfdf1692008d00212",
    "AWSChimeSDKIdentity": "d026649688e94be71307d7b67bb1b56df916254206c2887201eb79c407c7104e",
    "AWSChimeSDKMessaging": "0b4295e167bc8de7d15a5a758b4a0047402dad939fb2597a8582b015eb82d66c",
    "AWSCloudWatch": "c314920a6d61fa245d60a873ead5e6e37ce3a63c2b89a7e65015cff5b72f8dde",
    "AWSCognitoAuth": "fde5dc0804984a81a50530b5579b05160587798bb7d56e0faf0d5b1d72ea321c",
    "AWSCognitoIdentityProvider": "1296369be792dab8abe1416903928e6891bb4b1209c0d57a0dfe28ccf5347be5",
    "AWSCognitoIdentityProviderASF": "ca84b287a9f788f21643fcb6f25651b40eabf19030c6d140a9a5e4fe792505ad",
    "AWSComprehend": "d2275d177469c44620a5dfb5e33f53ab7603a51d085616821464e93f16c9804b",
    "AWSConnect": "3df77be7e840ef9ec18248c57b7bc90d6c54ed30936c31bf5c07598b9982a959",
    "AWSConnectParticipant": "59a6a8d12a281964370906b18f8c26db825095b7c84bd002fc16735d40adf67b",
    "AWSCore": "66564f5b0829656796cc32bd1ed819226e067581543ba452ebd558ab6683b699",
    "AWSDynamoDB": "437218ad2cae368d0338b7fb6e2c33675ac2debdd208c08c36ace3290c8c05e4",
    "AWSEC2": "3792a8a828d3d4da05890d05799837cbb12f3f3157687083b5b57c8bd38ac817",
    "AWSElasticLoadBalancing": "eade449d6b05ce0bd299985362f57e67836623d412a3c2baadefae682dd0d8bb",
    "AWSFacebookSignIn": "ad037d7a525467e4b3b9bbca067fb15fd5ec2bd01d10d12f7ee050ad4a3af289",
    "AWSGoogleSignIn": "d286c7531047cea60733e18b610f129f06ea0917b6cad2b2c8c4c1966e9ed079",
    "AWSIoT": "e8ead17fe5ef5a66d40f144b7173e1c18c574652ad35a2a3efe509b7e1adfac6",
    "AWSKMS": "15e3a6999dcaef74e1f3af6ceb220902c4e26029ddd5048ed443cf20aa32ea9d",
    "AWSKinesis": "14eac8f5ae9c199668885192f857689a5812efb812700f3a7a9a5a83514b3703",
    "AWSKinesisVideo": "cb2da66f995c2539efe75d98ae07690ab90a4421d79b184b14c1829b25fc5744",
    "AWSKinesisVideoArchivedMedia": "ed2b3246ee97d631801425e5acbadf1f7c7446469530e0bf8f71de3434da64af",
    "AWSKinesisVideoSignaling": "24477f3d327b6cdf80cb9ec132d278a5cfd75623caa9f32296955e84793a4959",
    "AWSLambda": "2b741e6498592877964397e52e9c146a346003c042da46358c07cd4fbc39cb7d",
    "AWSLex": "6123ce44c5e77386ebf4c340eaf508280a845f099c0875a260643a6165b9d70d",
    "AWSLocationXCF": "359cfeaf85f41fa817c9384b77f0f23f0a35f974a1c2bdcbee7cddb39293523f",
    "AWSLogs": "aab5bee6bc0eeefa8c383ace44b18afd4b6ef9383dd7db9fb65714915d3e55c9",
    "AWSMachineLearning": "888ffd27754034040b2926d81696d20b6a278345848c263772c2aab98f638a11",
    "AWSMobileClientXCF": "8ff85f90465bf802c117d49c665452c98bfb32d0dbd27f7fa85d774870f407e5",
    "AWSPinpoint": "a336a79d40c21964895e74879fc834a56b43860d4422ef6a69fe49ea363ae058",
    "AWSPolly": "682eb3a8c393bb7bcde0e5bfc375c18138224bcc2810120e122dc11079f19038",
    "AWSRekognition": "4870cc3e8ed22f65645fe2853b9552ee8f160f53e40af8714ea156ae5c077937",
    "AWSS3": "36072424609a3e4bfd951258c88c2ea4c70cefbece4c44bba1aac88c1918f489",
    "AWSSES": "57ebe484731beebf18c01ac6f7089fa5c93c7900e5309b8a3e31d406c97324af",
    "AWSSNS": "0473bf1bbd6116c7d48280e6d47c3ba210a5d370e3000317cfd87dbc9e18bb8e",
    "AWSSQS": "ea70d72ad7f0ad69eb9d1f73ce1a952f930aa686036df6deb4b382bdd200bdeb",
    "AWSSageMakerRuntime": "30c6d993e93a8601ca09ae4ec5fa66b8cdb30d14cad5d85837ad2359d660164f",
    "AWSSimpleDB": "e69739a3a802ca65f91b0abc6619a7f537ebdf371a3f7d17dfc9a19f05293c2a",
    "AWSTextract": "b7e31794da3e092377cdb6231f5d87a169c20e043a6ac78198b0860d7d02ef7b",
    "AWSTranscribe": "d7b6c93bba820f0c48ab04519f44f4ee15f5662696c6f92b893d1973f41ad7a8",
    "AWSTranscribeStreaming": "f818e1e2c1417f25b30b9d2f2bbb125ba85c2e05d5487c7c77b644cc9e57cc0b",
    "AWSTranslate": "9e83d08d44e406105f6db4ae46e8ed1d5db19721409e75edd40a84be4b55620f",
    "AWSUserPoolsSignIn": "0aea762c9afde4ce91717e8ac65bcbed8b56b618c83556869dc754143bc602a8"
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
