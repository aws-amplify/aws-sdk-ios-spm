// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.10"

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
    "AWSAPIGateway": "6d7c5b8f9d678ea926743f7e0887ac8e15153e16c9b8b0380651c8b7bb24f7d7",
    "AWSAppleSignIn": "6c612cf4c6f6dcb3358da5fba023d895d8d54ee023c27d911a63891475a24795",
    "AWSAuthCore": "a14b379dc3ccdd7b3b16f4823baa4fa100cec7c7576f66daaa800c37298514ee",
    "AWSAuthUI": "ad6b1b0eb848aa6edb7c6c014bc57c11ece31551e63a21394a91e1c71ddd744e",
    "AWSAutoScaling": "808614fd87e244bc35a0806806950881bd2eea1f2b9e976448aef231158b9b1f",
    "AWSChimeSDKIdentity": "411da5a35add2dc308b19ff6fa13889585e41b2385a39a8b345046bd43ea1c7e",
    "AWSChimeSDKMessaging": "2db962faeae11a1a14dce0b2dd26bdde019fdc062e64445254baef9df01f69c3",
    "AWSCloudWatch": "05bb6ae3c1246c84d62b0dd4a7970b9e58cc02a9fbea1072cdf8d7dabff5b1ea",
    "AWSCognitoAuth": "11a8b1f84d4706f904864b138fb96b8375925fb72c50e55f11280d393eb8dfa5",
    "AWSCognitoIdentityProvider": "d183b54485283e17ea55bbe2e9f6a2261068690dbf115dca3e0b0ec1ca364628",
    "AWSCognitoIdentityProviderASF": "7d0ef04744e861e077e7dca6e635dae99ba0bc26caa94517d3baf2d0b1680ea9",
    "AWSComprehend": "9bfff9521bc6d9c32446b9314fcf14968854352c1665095843d8b8016682acbf",
    "AWSConnect": "4068c70f66d82f75be8c92251eb2b1e965310a3359848ffeacec234b7bc1af02",
    "AWSConnectParticipant": "58d8661cff52848c4685988f2ed8ea3e4aa5bf29be71679be1bcfbf5fa94883a",
    "AWSCore": "5396f7fe3c4a5f61eafa62982ce25cf11db4c7735cfd934fa4d2f606fbefb42a",
    "AWSDynamoDB": "01401d5dad9179cf03b7aeb483d569b1d080e44a4aaa1829d1430c2a397c2e45",
    "AWSEC2": "5e6ae684ebb583c83233652a8712f5cb8254febf8c89e7a16324c1d30864beed",
    "AWSElasticLoadBalancing": "cc8e10c79002ba9dcf0859988ef8daa73a9666161bfce1b5947135bfc1743765",
    "AWSFacebookSignIn": "11b8cb4a1c8600151da28b88b46ea559375a80729896967c69edcacc0b032350",
    "AWSGoogleSignIn": "7abfb9b1015369c5e53e85bac48a80e161bcd768a4584c8d319aeb8ddaef3f64",
    "AWSIoT": "c77ba3d7cec9172fcbbf400e64c331ccb01aaa7c009ea872f01d16e9e67d36bd",
    "AWSKMS": "7ca39a2242d25515cdfa6ab0273a0c34d6a948431422390eaa87b663e287829c",
    "AWSKinesis": "5debbf00866e0ec65cc96d5c0773533a3f649e3fff74673c17efcb9d413b6348",
    "AWSKinesisVideo": "a54058514a46004e0acda8fa2d91a23e638ae45aa8400db16ec24b4f8f43efd0",
    "AWSKinesisVideoArchivedMedia": "bd2121f9e62931c77a7e4fce3cb21048e798f3f27a4c55aa0afbabcf3044a763",
    "AWSKinesisVideoSignaling": "d431be16029416a08bd56832317398d85716590d24160ebb20413e8efcce357e",
    "AWSLambda": "586996784af2c16e22018251db6c6aad3664ac28672b442acd58da983f7a0315",
    "AWSLex": "c0464f09cc59bc2acb6daf72857cc37fdfac4712ed1e3defdde87a31c954c686",
    "AWSLocationXCF": "b1ac64b54da1f921f6e5783d4f4086059da71c30380adbe02485cf299913f6cc",
    "AWSLogs": "c1df7a2d15bdccf6d6aa0de7dace9e18fa05050c23da667bdebb1c7478431ed0",
    "AWSMachineLearning": "6af6591900f41c74a5f11c604e54f385d66f7a572c60d4f7a36d480eb6b20649",
    "AWSMobileClientXCF": "ae5cf22629d913a29a5c6dc7565bdc2e067fbe3d024f93f1f005e7a3c5ab231e",
    "AWSPinpoint": "8360a308eb1f08facc2cf5126c4d9c6bdb1b1e0b76669139f7236346beac3aa1",
    "AWSPolly": "a9999301028991c3f9d52afbbed4dc6ee5e2f5eb82fe4af0cc935df8e954c0f1",
    "AWSRekognition": "f21d8eaaed61103880f4b3bba6ac5bb5868a23aa4af12c3dd8402d7c749f3a41",
    "AWSS3": "662b7c74fc498bda36a0d2771cdc6c85e6c819897d033606ac221f77a76ad291",
    "AWSSES": "91372f8c247ff9d67bb429a108aea7870d5a14f9a5d593bc0bc34016ade94d9b",
    "AWSSNS": "28c813ba83dd83914f94e9456f9658cf950e47fa6ae1dd893224fddd53d6327a",
    "AWSSQS": "a3cae1b9ea38f0afd2edca359d7aa172442ea4a0f84e8497d464fa4fb2fd7158",
    "AWSSageMakerRuntime": "3ef51a485a5c058fc3e92238573c9160fc2ceb12f229332b706f8758f62138ed",
    "AWSSimpleDB": "3d4754383a1c1d47fe23d8fe45b3919cad1f579a64b6c0a84b60988748805266",
    "AWSTextract": "390ffe983114e158455927a496f270f158899b22cb89ff1227bbe185adfd3530",
    "AWSTranscribe": "690131551f3980f4f52e8a1f1ebb1fff100ed3e15ea427ea7d240ebcdfcde2db",
    "AWSTranscribeStreaming": "cad98ab2c33a2fc64fa6a05cad82fdbce9eecd6a9ce39ca991d8ef0a03c86bb9",
    "AWSTranslate": "71f104821e3a38119e9f56ba4012c60df0ca285f8d207dfaf25445df23139442",
    "AWSUserPoolsSignIn": "938694b89d3ae5242c6cba7d25167ed20b6c5e5a32316fd832ad9dca48de9e4e"
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
