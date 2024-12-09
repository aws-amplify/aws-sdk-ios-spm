// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.38.0"

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
    "AWSAPIGateway": "ae1f5720848fb454c2146275c45ca008f37dea0851d1ddbaf6e7c38c10d4bd4b",
    "AWSAppleSignIn": "574691d55e886ee192be41fa5350109deeb75e0645c247d42bc5e2d70f8f4824",
    "AWSAuthCore": "95d07d47ec1d85da85a8056344e513f9751af0dbdb7dd592f7dbc0cb6e5ac759",
    "AWSAuthUI": "72b7ce98363cceb616f5fb58cb15e5565f08e78256928320471748ce321e9455",
    "AWSAutoScaling": "099da0668ea600f89b06fe3f54ad33693f302b0ea9af1fe99fd78b19badb0cf8",
    "AWSChimeSDKIdentity": "34f93816c20a72665484108a6dba4f9ccaf7625b4faa5fe5688c0b6f20661bd1",
    "AWSChimeSDKMessaging": "a1cbc60a1884e16019ef0ca5b348c7145ae217e9141bf8d431af58181ec09c3b",
    "AWSCloudWatch": "940a5522b446916728df4d4da09c7dbd4fb95472a42b314dc84f6f0620e66af9",
    "AWSCognitoAuth": "463a6e18ae095b2dc3cf3b0f0502d0fbb28e0c216e827d4efc9ebcc617fa4b71",
    "AWSCognitoIdentityProvider": "2c2a505be389e31a87847a7fc7052f1e7f4ea1d8cf67834656efe67e640e1dc8",
    "AWSCognitoIdentityProviderASF": "745d8a1d0cefad7cdf4659c9c51108767acbbf2e60350c9857dac9f433247c77",
    "AWSComprehend": "a5c6496c6ef9dfb242d00c5a00b67baeb8a23d46f9235f549359a2558f72c250",
    "AWSConnect": "a1a17e2ae03c6aa4045ee3376dc0d155075dbb98b86f49a5773de30e30e36f42",
    "AWSConnectParticipant": "e0452dfd3772713b8a51780670ad3fc548187869306a856cd404bf08a490c2c9",
    "AWSCore": "70a12b33cebff5a48c7d646d0cf12976ae32dba09406107378ebd6cb8eae7722",
    "AWSDynamoDB": "66df6548dd8b22f90be9420aa03bbf9c6f901be2e38db81918ba01a0d5b5aa03",
    "AWSEC2": "fd06bc0aca98070067f52eb17a9c82e935dc15bbf6cc9e5c9ddc01aa6eb22b8c",
    "AWSElasticLoadBalancing": "fb93c612f934504d610303e80ed38c5e6d4cfe898249d4757e3f05287ef5b6f2",
    "AWSFacebookSignIn": "a5a344430b0421e619431bfd71c9b2c4877ad340034c866e351afabde7448aca",
    "AWSGoogleSignIn": "35a1e2e538b6da5602a350635ae83d3df40870e1e8422fea8ef4b8566bce6d12",
    "AWSIoT": "da5b47b051b2d617613a92cba0a94a13670a5242aca7c5df54b7ebc3e3221cd8",
    "AWSKMS": "9619e1ea892de2e53745a6f69a6961dcc1311798e015b7e9238d7dba607304ac",
    "AWSKinesis": "8cbb37bebaa9ff896ad4d981d5bfde014591ad00f61c66cac5b975d6958586ce",
    "AWSKinesisVideo": "3ba663b47ccbbaefd185b3d0a18db8124ef31af8dea21e71530ecb696ac38178",
    "AWSKinesisVideoArchivedMedia": "c024290373d2584079b61911439a7d8a22dded18641a0f7319b09920a4947202",
    "AWSKinesisVideoSignaling": "20284b77b08a7f97e1c6d4e75289025cbd73d279b449caad012019ab93592103",
    "AWSKinesisVideoWebRTCStorage": "1baed881553148d731ca1ce92b545103d90ec59c2694900e422f1118601d6076",
    "AWSLambda": "3bd1e51bf23d86fd465e61c25f2414689c2d2f4f5b3798391d56a09bc3cc3a4c",
    "AWSLex": "4215ed45f164ca91950481a81f1735984dd0e4a619e999848c731e2c3a740392",
    "AWSLocationXCF": "59606efe2530237172621cfae1ec0fb1f8e406c8791bc6c6ca350dd3f39c2f75",
    "AWSLogs": "2f7aeebbcb6825fee9b3f461e6366a2c3ae76139963b0444f81a4ba53b849c56",
    "AWSMachineLearning": "55a034234443fbdf58952c4de80529c960bd7d78653bab7e33c5642212a6e3bb",
    "AWSMobileClientXCF": "55bf45568ec31f5cf42447b540528b0f2fc19a2195a1b933ad28d249f4b54762",
    "AWSPinpoint": "48ae868823223a302e75362c25140d49e6bc65af9af316744e00d5c49d9c7a6d",
    "AWSPolly": "c5f39ffb775f52b263a2720ac133d895313da19e588ab52b2a2baaea922975b2",
    "AWSRekognition": "a36f26933dd452fb9c2c116edb9f15fbf4e517c8a3b48b1bcf2b1a1f654d5e8e",
    "AWSS3": "d0aa346e98a0fb63749f6bfe36035993a75d7338b6a3f3ad89cdbb9397bd3f41",
    "AWSSES": "20143cb14fa578a93e05537563a1c166ce42172295a195f15b0957f548cfbb3a",
    "AWSSNS": "4d2fe89abbd833484510c662eeaa08e87dd6735dcd788cdbd34f319752ba3739",
    "AWSSQS": "64654b94b4a36144bc3a364e53da5f008eb4cee0a352f5c90d6a5eaa11848dae",
    "AWSSageMakerRuntime": "339a11dc2f05d952a1407c256627aa6b718c74b24621a6b68f65567691ba7779",
    "AWSSimpleDB": "4786939660643a9a8336fc44816a710b283deee823d4b5c5a8747962967f239c",
    "AWSTextract": "0dd1e12576a1b10b4ec156770f4d525f32bc38cde09a27834fe4d60d1bba85ae",
    "AWSTranscribe": "95ad1720d4491c2cba9b88e666660d9a063952cbd8671e5b8dd146f8f868244e",
    "AWSTranscribeStreaming": "31f049e5cd341dc7b3fdd04a03ef3cb2aa6f6c0ee98b9596a8dd63bf42d90636",
    "AWSTranslate": "6251f4c44023663372ab6372b34af170edc4cc891ef5bc0912332c2b38101f64",
    "AWSUserPoolsSignIn": "8cfe88ed25a8c507b362177b224a0468e05999fcc8cd0c1dc1780643a2b89963"
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
