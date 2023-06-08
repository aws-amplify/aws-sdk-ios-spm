// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.0"

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
    "AWSAPIGateway": "3076a87d3512aa44d1f71e9e66e7d85ed15c0923793f31860408c9c34860e5fa",
    "AWSAppleSignIn": "b4702c8267b26a35333b1b9993ee945d4c725d0200c29aa2507af0482c0f5d56",
    "AWSAuthCore": "16bbc340ee44ccb1dbd110c6f0f1841cefc9aa67698c6af2279f41989c12f7e0",
    "AWSAuthUI": "0487b637c0ddc7df9defef162972c2590c98cc5108057073c41663b39dc07a0a",
    "AWSAutoScaling": "6f1809a2a443f5bed9d1d3815ab3a43fd234fcaff16c224f93d9f10578d77898",
    "AWSChimeSDKIdentity": "aab4489125eb5ffc54f9dadbdef031fe76969cc6b7d61f2333ea197aaff343d0",
    "AWSChimeSDKMessaging": "2d37436385adcff235f5a83480f7298aec8c840db680707dc4c767e37e74bb66",
    "AWSCloudWatch": "bedfe71ee3613f32bfd53b77582eebc08a15a5c78f029f11222958a0ba359f48",
    "AWSCognitoAuth": "a5358ec2c3a6f24fcdc09dc2de0b586e39d233e1f73d47932bba97175e9983a0",
    "AWSCognitoIdentityProvider": "7c47d404a972cb791500db568121f3977155f8e3042b243cf38911b491951369",
    "AWSCognitoIdentityProviderASF": "fceb955218c9ac24de48224a1d1e75d7b5f6e64da3f074e37b1777b5a084cd70",
    "AWSComprehend": "9d2e05486369993d794d8a08fe24461249cfb69f81a482b296d0dd45b2e0caec",
    "AWSConnect": "28a57af4b28eb4a9e8f54b024bb6327c0a41b50f370abb3bd1eddd42679d4b38",
    "AWSConnectParticipant": "5238da8dcfead32a597ecd855acda265e4e56e6f21cded2f4f7b7e5a59cffb2a",
    "AWSCore": "ecf431cadf44e68fe233de86500607045497a37b06c6a89f3f5855b09c3d7f40",
    "AWSDynamoDB": "296b61fe6a17060bcaab9d9789eb322b5b4494e82aaf0cba51e4e7ce69f8a124",
    "AWSEC2": "48b9005261e226b365d52dd86d504fb81ef6bbc0cb9eea5575d7753bd6e597e9",
    "AWSElasticLoadBalancing": "f031d0a9fa8d65e5201fdc38c993441eca698d4fbb633f0c44e94dd240867bbf",
    "AWSFacebookSignIn": "4d03a2bdb64a3c5ec1d7506a09515640a0978dade0694c8c7263713c02c24efb",
    "AWSGoogleSignIn": "354152ea5ae71f887a05dd4873fcae6bb26cd50e0ab167dd3a65af829307853e",
    "AWSIoT": "13514cbbd391e087f54941c0c2c764e7f476db39cd0c1ae619a57234e744077a",
    "AWSKMS": "4a560d95c1f250a1491980a264998e051f12de5394a356b61b26fb792ded7088",
    "AWSKinesis": "7e796c96ecb66488c5ef900abb99aa58f93c267b559ae26763d5b9cd96c1015c",
    "AWSKinesisVideo": "73e54236920e55fd3a02440a1cca9546282d77647539122c1ef209a8ab457d57",
    "AWSKinesisVideoArchivedMedia": "4339f0e2b667a3134b0262b85989b3973120eccfa198c6bdef08cf857d76ed6f",
    "AWSKinesisVideoSignaling": "ad04378c7ac685cbebc7fdf153d14957c3811e0c6dc2305d748e63a509671c40",
    "AWSKinesisVideoWebRTCStorage": "c4fa4f678dda8c890039861fdd607f05a5b5cda61829358b7d69d277b8d5d528",
    "AWSLambda": "6946008afcef9ec31dba1eae608abba996fdcf0f66e5e87d29380ad67e0e35b7",
    "AWSLex": "4fc1e4086173805dc8c0dd6e60ec812e3e4cfc8ae73de4cddc06f39502be7416",
    "AWSLocationXCF": "cc6caeacc338f1bdc7110d4610d7eb26770e119145dedb8369d0687cc92f1850",
    "AWSLogs": "8e6cce3341a634eaa1610941f191d515a40b3d964a07846acac349d44cab78a5",
    "AWSMachineLearning": "7a591874e5eb069b21441e3fa1e584e453df3b3fe375d23b3a4e79cf6da7f34b",
    "AWSMobileClientXCF": "ecfbcf14e7aff04968bacaaaedc96c57803613c5271d3e0c937755758068735b",
    "AWSPinpoint": "c85a0c1a3dac3d23cb94f275c50e99da491013e258ac64fbfde4a7b9c1169727",
    "AWSPolly": "88c746b223738537c633c72896f06317e662d2ebc4e42b76b083b768499fdb26",
    "AWSRekognition": "aa4e3d56ba4e293dcb363c276c0608ec751a36bf8611452fd8bea6302ec0f655",
    "AWSS3": "36d0d2380482253e55f30b3ffc18569bf48b78a63cd1b6007aad33eb0fcbb780",
    "AWSSES": "153a8805c06de6a59ea6ccbd24aa4e1aecde798e05bb3e920d02f03ab421b665",
    "AWSSNS": "d4b8c6def71e9af2be7c07248a767b26f9843d36ff97d056249805e2428e4fb9",
    "AWSSQS": "8ab6f4e58d4f13a6bafacf04ecf365b6505401b9c2843c57bcc369f0eca1430f",
    "AWSSageMakerRuntime": "68318e43e5ae1095055237b69a5668f9455c5dfd8f41ab3a860f4dfb0cf1fcbb",
    "AWSSimpleDB": "91297fc302858d146ae865b8f8f76a31b93e8cfdf5106f9cb44c24fcd45c1f7d",
    "AWSTextract": "c9836e9b374fced3bb7acf1c5646c53e50d569c5a7c0708a375727b257e3872c",
    "AWSTranscribe": "c4f81f55a7493d2781ec6060337b9821ee40134bd39c0625a47761f9bcf7cbc9",
    "AWSTranscribeStreaming": "598ad97616ca7e80f68c7af6fbf49054360bc89d8488e79f61eeffeb3273d070",
    "AWSTranslate": "2cfb73eb14e548e7e7ee37a4836767186c8cd687fb8ac00bfe23526185ad56c1",
    "AWSUserPoolsSignIn": "5732e99e27404f4d0014b65c4f199fac07abb19bdaf60666669e8d4c76cf2074"
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
