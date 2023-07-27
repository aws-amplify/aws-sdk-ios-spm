// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.2"

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
    "AWSAPIGateway": "72e7e34b3327d6df6632e3cb61ca32ebedde5eadc40cb52ee9d2eb4b3046b85d",
    "AWSAppleSignIn": "fc4acf9f8c1e1084112bac0b6f482d418b2c16aaf580e4bd9d72269aafb408d4",
    "AWSAuthCore": "83f3423e1532038c758e194132cd3067a2e543b1543760fda23dfacce75088c6",
    "AWSAuthUI": "a2d661f973ccfa29e838ab79e39f89135e5f4cdb9e67f02677f968e8496a76e7",
    "AWSAutoScaling": "cc933fd25514a2bac0ec0198865928c7542a50cfb6b32fec7fd12268ab515ad5",
    "AWSChimeSDKIdentity": "f575395b3d0014171014780c0235458880e488b08723b0fa9a05d2708f919976",
    "AWSChimeSDKMessaging": "9bcf4946ed5d8f52b5c0d9d146b42e1adcedddf4f94c90f4a43221de917457cd",
    "AWSCloudWatch": "e74a1e40d48a2ccbe9766ef197ffb0eb13b6007fc4e173f189d326b548b39ba8",
    "AWSCognitoAuth": "2f0b95ad44abb2dafe9d9f2af893d44a905421addf358f2daa903162fb4b1e14",
    "AWSCognitoIdentityProvider": "b1a90930aa0aef2dd79aacf1462df12feb7368750d81c56655ae7bb11a8c92a2",
    "AWSCognitoIdentityProviderASF": "c33cf3397e85d87cf18121f873b5858d7cf1179c102d166c3cab115533d20573",
    "AWSComprehend": "5d4537a89ac4aaca5f55c2cd156e96f7dbf0e5a5d35bccd046fbccfe2b82cd18",
    "AWSConnect": "188712964cbeb3956b0d379e9c89339d8aef94059fe8d2c03b65fef8aca268a0",
    "AWSConnectParticipant": "884b9802e633401e66fbca610174e39ea797f59e55b9d687f41d081726bd925e",
    "AWSCore": "fcfd928622e2cc5bf3e2e8613487af67f3f6875ffdb26de9b36c1796c9e16a26",
    "AWSDynamoDB": "9eb9b0ea15ee6481ebde3ac9a9a9591e9239096d052ec3fdfec407e26ff6558b",
    "AWSEC2": "24ce6f15123f3f49f8c8155efb74a684679ad2e67427930c1f07fd8b464d2779",
    "AWSElasticLoadBalancing": "5b3de3f4b7cd65f358fb27f14fb8e301732d1e0cb99e4447326106a88fbec135",
    "AWSFacebookSignIn": "b534daa9a755d498bf4c4aa626e685a278c1444a0a971a25fa9f653cdb09aabc",
    "AWSGoogleSignIn": "7a1211b4ab5551ab0dbcc1ce2e3908d2c738b857759b297861de5b5be4c6c857",
    "AWSIoT": "ac8ed3ce12c40fec6495a248a066c86c4111270ed48370ac26bf7b3c3d5f30b6",
    "AWSKMS": "daa0b1e9749f55bca17f9369b7a6106c0cd9afaf6487419c24c3f298d351e038",
    "AWSKinesis": "826106247daaf3c7c2b0972d91820e58bf7669b59f8ec939e89b1e6924b3c759",
    "AWSKinesisVideo": "c3f43d455772dea30a8bb87cd8ba5ca1ff83d9f2d0b5a4f81593b81bcd061e41",
    "AWSKinesisVideoArchivedMedia": "3a1e40458b756e40bc19198b6cf2f372362bf2a8804ca35150937f6b9ef507fd",
    "AWSKinesisVideoSignaling": "f72c20fe2f6e36f9e361d1a05cc8e90d1d93828113ac51cde3ee3a749c463d6a",
    "AWSKinesisVideoWebRTCStorage": "2f56566c6219d427793dbb10adb9725efaa8b73d4d14936a612609834769ba67",
    "AWSLambda": "cd48c55e0f60b3dbb08f8e27e092ffe68123d9bea94775bce82e73f540644f85",
    "AWSLex": "c5fd0dd0555b465a25016b20db52e82c07eeebcc852d06735031dafc4307ee39",
    "AWSLocationXCF": "12b9f7bf337687961b37c54374caf5b823c1944366be56e4fa6d64f8121b682c",
    "AWSLogs": "54fb1cddba2257d629d575dfb2252c5630e93c6fc0913de1d1f687bd91bdd8ec",
    "AWSMachineLearning": "5161cd8fe23cf63c674776f076878b93352dab8f404cfa967d871eceae4da33b",
    "AWSMobileClientXCF": "e81d9e7d5e1ba1596de36244490aac44d7f4919dafa18db682ba648d14c55294",
    "AWSPinpoint": "56b9bd345b24ef1f8d2149b9d7ab7ce706da582a755348cb773a77b6880b917e",
    "AWSPolly": "9d2fbcbaac98dbebeef5949ff8ad57cfcf0805fed7a8270b02344ea863559848",
    "AWSRekognition": "2efa4b01814252c362aae00da650e83c0f1bfde38d194e14bd721f4b025c1d8e",
    "AWSS3": "a14828749a149c95f006a0586685b2daf8eb370b9e92de8b12aa744654255b06",
    "AWSSES": "ca1977f02ff728434c91f5f688ed9b7a3527e51b5cdfd5bc9f8f7903b723c857",
    "AWSSNS": "dab69a10b73b4d55dc17064c15d38550ed6f861199f202847125e4d50a24cfb8",
    "AWSSQS": "622cfa03adb664e0f69dff670600e471b22c7135f2f39b26de8fa8ea81f365a7",
    "AWSSageMakerRuntime": "28ec1ecd0ed06f73f9b42b4a36843dfef40e95ce984e0bde97872edfec719789",
    "AWSSimpleDB": "3d99b5ad8e0429c3251f85204fe69d8fcd4ee54547ddf0a854d574386c25c55b",
    "AWSTextract": "39753cf8f44b2de02a7aedc3843ce5a792bd773c8bf358f855ef0dd748966b00",
    "AWSTranscribe": "e4faa5a3d7c58a399fd519f9ac4b604f693132707c51c3c167451320713c558a",
    "AWSTranscribeStreaming": "8f73d6aece8c8e9a4eecae98ed418c9708de46f7b57161b83176e6c6f81d8559",
    "AWSTranslate": "eec3835a07664727c89f3bbc645598081713add03522ae4a61651ea7fa276276",
    "AWSUserPoolsSignIn": "e12bacb8883f0b3e7a021e6c5def915239637d11bfec66001a6bc0ee33d546da"
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
