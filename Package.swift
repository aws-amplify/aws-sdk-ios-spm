// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.37.2"

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
    "AWSAPIGateway": "d4b9f470714b1350ab8ba2290e7cba9c35d2fa252d9737f17c3a8c248aea4400",
    "AWSAppleSignIn": "5e1f13a0c8b4f3a5486a7587a9f944b3a4b4fe6e74e6c104fda76efbb08756ea",
    "AWSAuthCore": "30581cd07e4db93584d89589540de6a7cc980d721df9c775e3744a7c0619bbda",
    "AWSAuthUI": "d9d9e1cbee7ae7668047ced4d19d90d2134438894226886f3fc3f49e3d83a28e",
    "AWSAutoScaling": "84a38c15fc9c3941771da28f6a6a5f1dd9b1de228d77f06c1d381573f8c55b3b",
    "AWSChimeSDKIdentity": "d40675f9ced52b3986085c9b9b67a2696f60ed8ff04fa2e1a0165707d7cca101",
    "AWSChimeSDKMessaging": "f942d992864d55145dd45f1874f3f91d7980db01366df006487bccadd8625d60",
    "AWSCloudWatch": "32b8660ded63ae1f4d26dacfc445926e4d8c7763ce894a1bdc26f1136b621c4a",
    "AWSCognitoAuth": "2cade3592676e81ffb70d979b6044b5fe282dbaeb01ade0d0982a4bc79d748b6",
    "AWSCognitoIdentityProvider": "48211b98649b0488115efcac9ebcd09efd7955ff3799fec5b0bbfa8c7865ac20",
    "AWSCognitoIdentityProviderASF": "fcbfecf8182bdcd13ba3662046aa6bda765f1481e38555b11dd00cc90673c043",
    "AWSComprehend": "424a7da7b11c8c7da44d76a8ab3d6173eba1d14e80e8b4464bc8c2c567be586a",
    "AWSConnect": "464ad6d9f315a527245a473f46b6a56c1f87893c4fc8704b6789eab4008eccb3",
    "AWSConnectParticipant": "d2ac5bc6b0fddba7b94cc8fcfc027720c237d514b0538a32fed8c333aa70e3ab",
    "AWSCore": "904c97734692910d31b38912ab8e15929884e3f6bbff90498a4692e46b0679c4",
    "AWSDynamoDB": "38d3ac365bee618bf0981a8087bc5ed8da4790a344f8b178493066683a6ac9df",
    "AWSEC2": "c8e50a736ec9f876ebb187a7d1ce7b96ae504d0d42d15043d05ced21b4b2505f",
    "AWSElasticLoadBalancing": "c62408d06950f9283c81ef81f57965e9822431c0e1d29b60d9acb38f891ed86c",
    "AWSFacebookSignIn": "535a6f93f306eca3c91c1b8f5a320468db9a80ac827f05a2ba0c3def0a8f5cbf",
    "AWSGoogleSignIn": "386ed2b70611db56c2624997a822c0324d15a64e5cf6052223bccbbf2650d93a",
    "AWSIoT": "ed720509a803adcd77511c9d6192413aa231ad9f7798e8aba5bc1d280c97d708",
    "AWSKMS": "adc546d652ce272a891323f0fac20366b243054ccab29e8374774c5711c53430",
    "AWSKinesis": "72a19bcc4a5e54e157320db775d3aacc8bf63daa5a0392223afc918fd3ae0f20",
    "AWSKinesisVideo": "323093271049b3383068cafc22f65c596f7f54fac977c62ef61a23e45a6f9741",
    "AWSKinesisVideoArchivedMedia": "50e0b575e47b589f2808cdb152914fd7bc03fa940d1ea38cc23729e16f19c552",
    "AWSKinesisVideoSignaling": "0f091ea7d31c6fadad8df82297d7fc94d9909d7af7d0fe3162932267eccee33b",
    "AWSKinesisVideoWebRTCStorage": "ef68fc1c4df0b02c0d39f989ee704138b68575b52e92b5bf9336c2cb6638bcde",
    "AWSLambda": "aab4674a0e2fc021fbaae488372045f3bcd40175b843fff19a5f62d7e0acf337",
    "AWSLex": "c58a242ad7cd11c60a3a98c10669ba9de7d3b20407fb291189ad8f4d9837ad93",
    "AWSLocationXCF": "082a16e09899d318d3ea6d9da728ed7bf48c368f5544d20e102d668481c4327f",
    "AWSLogs": "b0ef25794beca8b1c3d92ea10bfdbfc0260dc1989b0b1be8f6f9cabf0bf57fca",
    "AWSMachineLearning": "eb02334ce1ecdd5f1f415005f3f1081eaea11dd126d329121b4773df318e6c4b",
    "AWSMobileClientXCF": "1a6a7d0ed76427b020be49a7c77fee401a5d58697e0102134fecff19d6b14a5e",
    "AWSPinpoint": "0ac09fb44423453aa64939eebba1d61440a4d89c8b26e5ac00526477d64d77f3",
    "AWSPolly": "b8e474799729e7f77c124e8549e531336c900fed2fa3db28918e82e98eb13664",
    "AWSRekognition": "88cacee9c39235659dd176da626ce223c6a5b6441028a6f13db7e9f55b4f8867",
    "AWSS3": "4ba7c1dc0dd2888aa490319533869f5ee696abe13bfdeb65dd1172b204c7b907",
    "AWSSES": "e2be75bd53f4774b197ff1b41af70f8c2b89c6d1ee08e13be4e2d5288d6882ed",
    "AWSSNS": "45f3b4eb668613d947c077868239925a2be9db818b9c89e8488061834cca06c4",
    "AWSSQS": "b0f532892922c1603681c6b3b608a6d25e028b4ddfdfeacbed6d71080b3c8d2f",
    "AWSSageMakerRuntime": "ea390c8f3e6959cbd99d9ab4362a6ccbe36c0c121f2b26587a70ad3016645bc3",
    "AWSSimpleDB": "ade8f48438a22131f92e1e1983ae44a2e52ee1b13f388ec06a515690e4b7b254",
    "AWSTextract": "1dc0797df474e0f85df1e5fcfc9009c77f3fac47d23afe422dd15db1d390dfca",
    "AWSTranscribe": "1b1734ac473e335b2c1748eb4ac6f40d7416ebe42c1bb11f4cdf9337d2dafeae",
    "AWSTranscribeStreaming": "cb946b00086b5a4d4d4107d891a05151bec52048893f3660a114173fbf4597b9",
    "AWSTranslate": "05da1c52dbe7ab9fd99481f6c812417fbb2c4aecb28cc0d87d98081a12d61f3c",
    "AWSUserPoolsSignIn": "6f84da31c317af45c4e31e760c9fe820c0bde1929f06c7ed9c2000d47e1bb3f2"
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
