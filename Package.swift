// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.37.0"

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
    "AWSAPIGateway": "e4262ddee98857ccb64a28eb3068ce32f3747f7ca9b0c7e462fd43ab1fcf6598",
    "AWSAppleSignIn": "5bbb506e4685c0b623ef3166c2bfd7a20c5af185151d196c41da23347755a001",
    "AWSAuthCore": "b076186b454db70a46e64368b8d38a87d0b9717fbc7a05ef9a2f38a1aed06d8b",
    "AWSAuthUI": "f296de0c4be2a095d804f931fee058aa4e856c2773b6862461ee5d368b39dd09",
    "AWSAutoScaling": "43667f82cf928e78876cc9ab657f7d50556d55276c2cdc5d5f2ce73c241ac19c",
    "AWSChimeSDKIdentity": "ee83ecf75e36a8fe1880652deeabe3750b50fb374f55ea0a50074fe5dc666279",
    "AWSChimeSDKMessaging": "75e0cd5d4ae48b60729d77d9473a81190f3b066bfab426d50eb20560367862a1",
    "AWSCloudWatch": "c7be52bf5dd82bbb78e1dc528f1fc923d81f09decb2d375752bc26063d7c25f2",
    "AWSCognitoAuth": "35fff678994213a12298eda66f49e27b9dff1c20184313142029fb76880bc56a",
    "AWSCognitoIdentityProvider": "4e05bc411cd628f4101757cd15de3b932afc08326edf94a5718f95046198897a",
    "AWSCognitoIdentityProviderASF": "e454839db6a2743bf50b8c5e8c8bec2b19b9af7629d8e2f75c06e478fcd11ed4",
    "AWSComprehend": "99c355d3aa7c756ed295fe79d0c182c5f7ca81f8ac38340bbc4911d85c8ce363",
    "AWSConnect": "4968d92a7260c00e92fd39e0ba0079a37203609957d4600e110a90b54296fa15",
    "AWSConnectParticipant": "0b5a3fc0df95cb476dc5e22e0e31765ac4e4d923e695ad564911f7095713a187",
    "AWSCore": "9878a4733de31a4246e2ce66cd67e97495cc073c6023fd2473ca388793cdf0f2",
    "AWSDynamoDB": "ee512043fd4006acb0d97697f4f21999c5499676c5b9ea7b509e4d5c86535381",
    "AWSEC2": "a71d66e6e372c23f1f3459bcaa549ba0b05491a244b00e0f252f882177bde2fe",
    "AWSElasticLoadBalancing": "07ddcfee51385e20d41d5a9effa820c6804526686f62808b442fc271dc5cd616",
    "AWSFacebookSignIn": "278f32aafadbca6fd4b73bd2403201f2362f5a892be8ff74e0edbb3232e564a3",
    "AWSGoogleSignIn": "b1311fa84e8a47cde084f01338a523bdb8d673146a4d93c3d7fb7bc0d221ab16",
    "AWSIoT": "7b98d413bb1a0481b616bc289c72da3b508f0a5ae5a0b58a700a4bedacc467dd",
    "AWSKMS": "bf05afe6225c131ba560731c59d3ef3e80b76a8ceca764eebf57a063789d8aa6",
    "AWSKinesis": "946d7d0472b291691a9b40df70b73550ef75863151e567ee016b547ad53b8d09",
    "AWSKinesisVideo": "a3bb34969a2a8e71992abe067940073c45f7cebb4d2ad83685e5b5479222905c",
    "AWSKinesisVideoArchivedMedia": "fc7cc4a92bc3dd1800a12e0fdac88e61112e5055938616df4901b48242c8304f",
    "AWSKinesisVideoSignaling": "715a23ff3cfb0face7c87d8efe9e199c004f2f6278f11cd7167c332383b4ff3a",
    "AWSKinesisVideoWebRTCStorage": "ec689fc6de8b3041a2329add435210d155d580555b9aa5daae12d8ac2633ace0",
    "AWSLambda": "6cb1f5b7848af9af839802752f63c3aafe5c280a7d195d2d7d1a7b8d6aa69cc6",
    "AWSLex": "8f69efedf6732f353e2001635c7ba9769cca2750337a2618a6edbcf1f5e4e78a",
    "AWSLocationXCF": "4d0b7d1c2a29eef48618e1c0a644dbc3452948b65a40a9f377e361b3814322c7",
    "AWSLogs": "e90251768149e2eff4dac1a1fdb1823e4115ce12f58c0b6dcfcafa71739bd925",
    "AWSMachineLearning": "2d5d87f77610de0f03b5cf665a0ef44cacaee0fb9edd36caf1d5141c73f13dcb",
    "AWSMobileClientXCF": "725efb0a294e549794d2e874e02c5547952e5bfc155da60c478ee085b5311793",
    "AWSPinpoint": "424f4e58c256487767672bd1fe92dcc047732760c0cc08a8efc1fb44541fdcc2",
    "AWSPolly": "d93554b0c9c338e5b9c06cf4e29b9509c80d9010ccffd3538f8ff0764b4bd5db",
    "AWSRekognition": "0a3796b94feba7700b94de1eca874501acccf6826f7bcc2ea562b041866d0ec5",
    "AWSS3": "60427ee2f5773da40750fd5be399ab95c86061d2b2ea28818f81b41224f22709",
    "AWSSES": "96705f6f95629cb789d7d8c925dede070cec11425baa0f6d089747ccee882caf",
    "AWSSNS": "6256dbfac83032ea2f15ab70f071c17e367b30593694b95c1051ff8906f51984",
    "AWSSQS": "8342dd3991ff44241e735a5726391d2eb5533c8629dfedc589ca5301d62224eb",
    "AWSSageMakerRuntime": "e87688317aa2c92a197ff386b4c756cfa03a2b9e2b9637435e1d23cc8f0ff125",
    "AWSSimpleDB": "4474b4cde08b1f506b21e9a8efebc89ea7b1402f8db7d4f9a0bdf95a37a886ec",
    "AWSTextract": "5030b30395dfa439c162f53fb1a11fabf499d60d6e2f551a85f7960fe9e377ac",
    "AWSTranscribe": "8e79c6d2cbddd9ab219759a874ec11aaf506d3f202ebccee52f2e35d82a4d216",
    "AWSTranscribeStreaming": "41077e1687e3a8377b3ab0fd4ec5e2b043ce5b547cc47d5bdd0911e2360eb899",
    "AWSTranslate": "ab8d03733e0bca6528f38057017ca328489948f9738cff152bfaffdedfe4c426",
    "AWSUserPoolsSignIn": "1303aefb71e3c2e8eb6aa68ee14576e518a652cb86502a2bb394d7715cefc86a"
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
