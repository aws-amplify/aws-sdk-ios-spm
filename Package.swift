// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.38.1"

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
    "AWSAPIGateway": "45a05dc4f6feb98ce66c569479f89b7576bcd1fec186a1bf9ae869f32f04223b",
    "AWSAppleSignIn": "f8309c93ace63fd20151795a4f6f7082759c24a033b6985dfe1cd9da82d5ef33",
    "AWSAuthCore": "3b102078d81b6c9127175aa66a90cb4f72945411329dbe3505d5b5be5f36c765",
    "AWSAuthUI": "15615d785a3ec51fbe1b785f53344045c279d1c6b8c9656e082988bce419bd2a",
    "AWSAutoScaling": "f981b1da96d3fe343a31bfaf1bbd9d8f183ea8d1ec144550c1d28a34142a3ff0",
    "AWSChimeSDKIdentity": "6c976e23209a5d365c6292647877c6a3ad53964bb4298e152658d6eedf403076",
    "AWSChimeSDKMessaging": "15cd574621e771e3683a9b879d7000985411d59a21461fab499d2d89e5858f8d",
    "AWSCloudWatch": "5b705ede97e9fbf5efca7616c5df38ecdd4df7a0692c867ee81605aa66316f5c",
    "AWSCognitoAuth": "15b4a1a1236dfe16e3b64959f3c4c94477b76fb4327e5c7af6f57b1f84d7e136",
    "AWSCognitoIdentityProvider": "da509c129a008502f5331da2e2e928e22f069e45915a638788c1ae9fec1d6a56",
    "AWSCognitoIdentityProviderASF": "1651fac781fd89683c61fbecbb1e716091f92d14f21650a04c671b88ee7c3940",
    "AWSComprehend": "fbd926f8cc719e6d8ded4e2a2847acbb2507173ef74227eee674235e1e3795c6",
    "AWSConnect": "763d3ed1d176973f886c7f916a3ca73d9d2146c3596e66da9ed76c6c0ed455d6",
    "AWSConnectParticipant": "dd69dd62a65ffd2cb1965a3285d248522146916e6e62a41a0da9828480685c95",
    "AWSCore": "e603fda281de02dd394bc8d53878908a86c8f97e39f5195136d6536c69c1f576",
    "AWSDynamoDB": "594882e566677794eb4c19282506354e2d05d0f3272bed4db312dd17a736a976",
    "AWSEC2": "cbcd813ec07075af7264561819712954c3e3fd16a1f005fa36cd68234d2068c4",
    "AWSElasticLoadBalancing": "6579b4ea70d51f7b53ff05149018df3844d25e74a36b4aeda82d1cedbc76686b",
    "AWSFacebookSignIn": "c3cc27f93867fd579fcc1ca5199d6f965125ab3ec09716855072cc264790db34",
    "AWSGoogleSignIn": "47176d52e3f28f8ffd1464b43273533ed6581f66661f71fda2c3da28a7c1a46c",
    "AWSIoT": "1f81999d1cc4a23587399e2fa010b6f548a5c54932f42d9289936fd28ea7ed62",
    "AWSKMS": "b6b4f67db779434973419e2238eff4edd04c1a20f8df74dcdbf327d53f91ec6c",
    "AWSKinesis": "2e473dd5614ebdaddedd8cc69689ed80b921c6bbe5b542521595035d429b5745",
    "AWSKinesisVideo": "a3e2488e368c0761be9186fea39b37114541f168f74e7183e15c96b82dd236f9",
    "AWSKinesisVideoArchivedMedia": "c4fd5e9ebf171ab12b17d6a6d0ceccdd5c9d115dd7bd19b2207028479f07afbc",
    "AWSKinesisVideoSignaling": "df9c1153abe2e347e205f0563305c6f7cd9c41a835f1204448732a25efba0225",
    "AWSKinesisVideoWebRTCStorage": "e4c8e0bf973512c87d5c0f12b2619c6c0ca61d19781b6557656a7b66c0128525",
    "AWSLambda": "fce1f7d42fc566a7b9ff8ad9fd07f0a71cf7f8413c6430571a78561a506a2992",
    "AWSLex": "18abb3eb4725acded5bc6f233bf7de72bcf5aaa55d823134283da3cbbe0fa5bf",
    "AWSLocationXCF": "66d940473603f6df3bab77c9976ed139b596ff0f36be1bd3b6571ecb14dc5427",
    "AWSLogs": "acb206159036a83ef01a15bb4b4f41e839e3b4627229e6d09740dde91ab2d474",
    "AWSMachineLearning": "b5b27031a68364abff371283067ac26aabe23a10dba6af3974891255724e0e81",
    "AWSMobileClientXCF": "b0e58da9b6359295d4da14f6b00690fa69c2b3778e99ba14099cb3950005b154",
    "AWSPinpoint": "a1661e1164ffc4e8094f88594969d4af3064b9fa3e265493073b75432a60ff34",
    "AWSPolly": "4ee8b1f8904aa543bbb7b24952967d0114ff9237fdb14f52446a9f67dba4626b",
    "AWSRekognition": "444628d53e6bd26c525c3fa6156f1f3e0742fbb88e5be7b491474551328ebccb",
    "AWSS3": "57fd7560985385acbfd78a3e9a27e41b6b834ca4a0a894286b50199ec43846ff",
    "AWSSES": "9e865abd5d00d3e666831d6e4e334065078ad5b4e1a947f533bc96ab06a3caf3",
    "AWSSNS": "eea9f179dd89e88714127261c5d81d0d698e01e48bafde08a09066ece8842976",
    "AWSSQS": "0eec7af01cc843b45b7de77bc6c76e7da684cd6816457a96d3cccef9913e45b1",
    "AWSSageMakerRuntime": "6ddac7bcfbcaa29871b65f23a5a472720e41836eef74c2bdfb3936e86110c625",
    "AWSSimpleDB": "548e97e9ab3fd2290c8ced44c31436cb218481b685e4f8648bace679090470a1",
    "AWSTextract": "43e16361a80b85c024565c8642fa2a6bc67f825aae5782c5b773551ad033e60b",
    "AWSTranscribe": "fbca25c289f975abcd7cac630782c155868cb9d00fbd875dde31ab78745a48b7",
    "AWSTranscribeStreaming": "1138e02273d05bc7ad03d7c3c8c1689caa937b01c1e0c2c2a2053a1e6bce560b",
    "AWSTranslate": "b2948946e136865d408b8c7f237e580cf9af54ded51fe9d056987ddb92c2a10b",
    "AWSUserPoolsSignIn": "9ec5220224856bdb417e177a666501094d2c637b44ac459a5643d5759f543bef"
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
