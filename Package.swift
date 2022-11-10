// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.28.3"

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
    "AWSAPIGateway": "aefe1c8da25e7ca59743b0efd009c9be43b9f5424ecbc40be2bbb5fa58ae0eae",
    "AWSAppleSignIn": "75d7133a90815c3e51c96e8ee2ca74814ee21f691af8ac802c963f41d23282c5",
    "AWSAuthCore": "e332a236b16e028609f174f7e95c4c4886995f53eab75155be8ff73daaac0c7f",
    "AWSAuthUI": "0ff497331eec7676d39c68b1260d05f67360d27340d48a770e3e163a749eb527",
    "AWSAutoScaling": "7217984d9832f2d05440ca052f1f24229974dd757e77caafe2158b55f3d5052c",
    "AWSChimeSDKIdentity": "72457a2ae29711045d06b333c0dba1daff3ed456118e88d14ad0799bb84643ba",
    "AWSChimeSDKMessaging": "97381f42e7d21aa1c835a77232aa05a7f4a28031dd5ab89e285ed05f15dd9331",
    "AWSCloudWatch": "405bd65ba6a0cd472a4830002b97da8bdd6fe591bd721828598c618cbeaba1f7",
    "AWSCognitoAuth": "8676affb39e018d7d7a403fa967b21522669cff8a2c861f3278d61e68830ad0b",
    "AWSCognitoIdentityProvider": "2845ef937b0bab7badfab2d7d2d4379f9cc800d44357614590c718d391c81e6e",
    "AWSCognitoIdentityProviderASF": "00ccbab889ca395f8e8e21817937a200f9082846902590009a7f846f5928d78a",
    "AWSComprehend": "c606f2e405e79dedd0b9971093c61514a6b354946ced829cbbaf591b185cc021",
    "AWSConnect": "e8d2056287ebc21dd65c4bb8e378a353ca958c0fbd42b81b9d8c93513c0f16d8",
    "AWSConnectParticipant": "351c8aea1abd78b5393d6f626faea065a3ad14f4d2d244c68d18cf47a6f75b5e",
    "AWSCore": "113751110458ba6b2cfbaa4343cf66d6bc289086a3c24327e82011e45dd7c70d",
    "AWSDynamoDB": "96033663f70cbe119acd699b41fc92561a855f74394a1fa77d7ccd7fa85a0716",
    "AWSEC2": "4e79afee3f13118a6ea12fb2241a0ce2d04dee4dfa5721b4540d7215e4cc087b",
    "AWSElasticLoadBalancing": "9ca4554202f2b9c114879580444a908cf3cbbe583c6a28b9a516b38db04d52e7",
    "AWSFacebookSignIn": "1f811440564bd33c71f56adf8941cfd6591d43865b3b728a929b368171ac0cdb",
    "AWSGoogleSignIn": "d729d0040fa97858c368a68d79d7e61cada196b239f1bb9cd4767118e322f0f1",
    "AWSIoT": "e6a1c74a7fe03ec7d6b5429567156a47e4fb892e3adc21336aaffa0aad6a2afe",
    "AWSKMS": "d999c8368851443ec64377ff457cec20c4707243e81af87f626ce03156fce7f4",
    "AWSKinesis": "87252f32a35f6331ff48ee96ca9bf05ad7a08edb44294b8adec5c6589dd2d6d2",
    "AWSKinesisVideo": "c8d02dd8dea3b691d0a386144050c9a5267bdb8cb6c92eafd5dc8e21b2d46512",
    "AWSKinesisVideoArchivedMedia": "492b40279da025d69bb6c73f8a741c11c7b8984cb3124757510d041597ea4902",
    "AWSKinesisVideoSignaling": "142c2befcf3bd0f1612d50e56d1f2e57e1686a03139de7bd0221468041e20c7f",
    "AWSLambda": "3748b34cb7982df2cea2dfd7e6d145d32a710c46e8204f5ac4f35e9d5924d3fd",
    "AWSLex": "299abe28257ca8cff4adbdec1bc61446d2b19807afcdcca235fdb1fdb238a657",
    "AWSLocationXCF": "32e5efc14045e2f41c0d85e8db9fb7e645fb9357e3ad5637d86eb8d302d67be7",
    "AWSLogs": "d018852a642be2325c768c77a7d69ec6b5e2dfda784487f2a6aada6a774992be",
    "AWSMachineLearning": "330a4068d3fd945fb2302ba39ff98c3929d4721479b1ad1548d427803a9cdfdb",
    "AWSMobileClientXCF": "19f4419d9947fd029c68364053b4c271d78dfa218592565d18a941a16aefdb08",
    "AWSPinpoint": "306df240cce1c153f3b1ba0d11daaaa725e3f7f0acd69422ebbd6e49c3fe2618",
    "AWSPolly": "e58bc02b80fff1a5d7db8ce318a35c7ac2628e605d9a163963ed75aa55237948",
    "AWSRekognition": "5410b2fa8f29c36229f632777d85a6dd93339e857d03bececc90c7015dc248c9",
    "AWSS3": "f7091133608f4887e4a5c74b9b756f57bd905c2236ead488eff32de0c7ed055c",
    "AWSSES": "8e0902c478b67053ac2b0bf952ee21f91d121a17a8a7ca4573ba75f914ab5474",
    "AWSSNS": "6f69261f73fd37ecda49ea831e96c0e6a1a51a0271c9b11f39820f98ce687716",
    "AWSSQS": "7232716d88ddc3ad2ff061d19efdb10450c96df17ce18dd9ed658bc9fd16fc37",
    "AWSSageMakerRuntime": "082364cf93c479a6bb2c3d0e1fdb7ba4e157cf180929379b2a7f8cb97d5f36d9",
    "AWSSimpleDB": "e29a4ab53117b0fbaf04e5daa168c00d595e08f559ab2f199ab880b3f7fff3c8",
    "AWSTextract": "ee0b4e758db194028522ae4de78ffe2572bb9ba31c12e16d91ecdc1f8fb3e4fa",
    "AWSTranscribe": "0c5b553912b4aaea00434146bc70557f80a6de6c45b9702610112f889190c1dd",
    "AWSTranscribeStreaming": "8422568da73e37d798488270b0a80f91b71cda5d41ce41528bd4e5ae6f5bfb8c",
    "AWSTranslate": "81265146a7796235725125f0da58b76ec6bec7d89fb570c9e2bfb0b6156977de",
    "AWSUserPoolsSignIn": "abd9557f377aff6bc42e9a8f984baac356ce99768cb9dc714d947145161756ad"
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
