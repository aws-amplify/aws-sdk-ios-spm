// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.36.5"

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
    "AWSAPIGateway": "8e2d46b2d197c1d46c2633f59f2a0ccc169753f2afbdf0f4da9423f3fa958b24",
    "AWSAppleSignIn": "85240176eee92767376d28693cada3a7af6a46750ec092598fc6e936e8a2dce6",
    "AWSAuthCore": "6a5f80f775f1ba8d9f86f92af26d1c090063970088b8fdf45cfbd0c55218d7d0",
    "AWSAuthUI": "f36f67928b857f143607a661f4f367260c00b779a56a60621a5910a4804f420d",
    "AWSAutoScaling": "e7f658f2f8a40c50a76474c38f314a0b64a6099bcb25938f7346bde6e91c82e2",
    "AWSChimeSDKIdentity": "81921858ec5cd69923d797a78286a83865b0e89bce44241f992cae4bf95e3eb9",
    "AWSChimeSDKMessaging": "344602666433147744fe416bad2e490fa22d041a9bafe6938ede421f96de8eaf",
    "AWSCloudWatch": "e78d84ea9cbdcd506559d15c9ec67330c17273b063020cac37dcbb6e0359c279",
    "AWSCognitoAuth": "691dd72c17ca15cb1734bee2c966ef88b067cb6f16633b408923713893af47b2",
    "AWSCognitoIdentityProvider": "9aa9ec109d0511da7e6682e6915341d8a10668cbb929411a0d1dabe5f3fd481b",
    "AWSCognitoIdentityProviderASF": "7410926d8f68a423aff8650015a51422635991a05bea10577f3ae947e89f7fa0",
    "AWSComprehend": "00272bc40165427d903ea396ed0c18119f2a8b3e065bfa07ec0306640ebe4f5e",
    "AWSConnect": "b900e69f2342fffe61830b53a2e8d0988db805473e1e8f9440335181522d2c9a",
    "AWSConnectParticipant": "a5bdcd26875a4e485218db3a11eaaf5b96609ff8eb380a914dce1bd0f0be5ea7",
    "AWSCore": "6267fb9365e9477ca6b281e1f7836a5e1d1b91e72eb69b90ceb73c30e1d515f6",
    "AWSDynamoDB": "e35b9a5f151bc87ea054f0598a193403cb086e1e039f25be5f3e5f922966da82",
    "AWSEC2": "a8dcc4eb9ac8a71a306e24876d4fa82947cb12f0a72530abddfece8354b9f89a",
    "AWSElasticLoadBalancing": "2f6c46e99c3d1db8dae5cf18b29b69d4bf85b38a0b6c06e6584fa6c4e65675a7",
    "AWSFacebookSignIn": "fdf572830d024ba3832250a4a62c765b7cab7883346f0dfb06903015cfdca545",
    "AWSGoogleSignIn": "a2a7570d965be345f0bd93549d1af799830fa0852e410b0993ae5aeb367f88e9",
    "AWSIoT": "496c26c5a51e38512420b38e9f33d49ee270f434ebee3e32a58baeb77d4c0ef9",
    "AWSKMS": "a27c1cf0445154edacf84c642bc9fe1a43a0242d177ce9e9dc041c51d1a35981",
    "AWSKinesis": "1c801009b174f4656cfebe560a148333ae4031c296f56a8370b8918dcb035502",
    "AWSKinesisVideo": "baabb4dd450f20db951e6b206470d205300c5b2fa147fcf4089079dededa3a78",
    "AWSKinesisVideoArchivedMedia": "96a7e9e730dda80427a9c3fda8a3b77d2c8bd2a57607361f593cc0527ac8ac75",
    "AWSKinesisVideoSignaling": "eb847dabd0ef54155e214c976bc451963278aaae99af24c030194a14767b99cd",
    "AWSKinesisVideoWebRTCStorage": "2afdc68fc886ed529f5ea5c4f0ee6156975d0c9b37f81976ec77aed1d778a599",
    "AWSLambda": "74ead6b6653b6aec1321b2bd88b9504b251c419fe8845309afc74061ad292dc3",
    "AWSLex": "56f6f48d717b93347013d0b104f98f14ecea1291326a0af66952d9609768c9dd",
    "AWSLocationXCF": "c164d33bab5d8dd2572852b295b7db2b6fae24b91a1004ff0ef933f700472708",
    "AWSLogs": "8eff133689e79268b77827f5dcc238a2b7f67fbea0d1f2d7fe29d79873512600",
    "AWSMachineLearning": "661b7ecffe07b0dbe4e3ea254d89c0381a2651698ed32170d10db473f7eaca30",
    "AWSMobileClientXCF": "eecb4a394b6a2e942c66c1aa8db17d1a50e89d943e024fe8a5e7f6a7dd27dd1f",
    "AWSPinpoint": "7341945a24ef010fe7ffbe5504dde267e09d4f6b681d3512dc168dd20d1484fd",
    "AWSPolly": "af6af31df37f7663fbec7248867decc85f55d4b35c7b857543754d75006bf8a2",
    "AWSRekognition": "b8d8b730a24dcbe35b109a5efe07ccf5c1d3098726f31b8a1a910671c17c3741",
    "AWSS3": "04ac725e72d195de52d5294f8d55bda4e1a420a942db428003006cedb34f2f9d",
    "AWSSES": "358fd41f0c042a2de3f67b5962cd2efde7a935eeaa23bd386d54379daf682864",
    "AWSSNS": "16b000e9d5d3c66e12f43e9a611382d4b8a317aeaeb2570209b7ae70d76ad036",
    "AWSSQS": "feea150e90e10d916d348ddbd8daedde42cfeb69405e6bbf207763b4b44a3ef1",
    "AWSSageMakerRuntime": "9ae0c00facd883974f3b85d42016bf237f7f9ea1429ec6eec54f840222f54292",
    "AWSSimpleDB": "8822d4f537020c36a40fc1d6829260a8fd4998b3bed399ac9c01848003efc950",
    "AWSTextract": "8b890537cd842173d36cad8468ebe810b0df2401ba534bacb9a190b2631fb719",
    "AWSTranscribe": "4023df8331724a8c34081c69d7ea8239472f0abc755c0e33bcf142340f56427f",
    "AWSTranscribeStreaming": "7eabae1b10a670dee80230b05d1708ae8268603281e6266c84a11e34a4faaf31",
    "AWSTranslate": "02ad500ed2d3eb8533dcf3c2cbfc59cc86f0d09574143487f1bf1ccfbd9c1e33",
    "AWSUserPoolsSignIn": "08ccbfae9110a7a130d9a15851e89fdcd9f106ad78058e3a89a680377a183632"
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
