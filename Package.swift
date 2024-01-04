// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.8"

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
    "AWSAPIGateway": "d678e5952980ac2603e297017fb7f4a0ec3448de189e2ced1a68a6a7451f94ff",
    "AWSAppleSignIn": "1edbbbbf84f6b160df577866031015fb94dc396b97b5dfb99691e8181d7ae1e0",
    "AWSAuthCore": "05334072af2f647184bfcd990a85d7debebe2269a374a4826afe24694b00211f",
    "AWSAuthUI": "d3478bef9149b327ed180136390619c2c61e17e623ce25f06b2b9434ba1045c3",
    "AWSAutoScaling": "94cf4b4dd2ec3675b70714326371c20200fcc00e2a058ccbc671f71831777cc7",
    "AWSChimeSDKIdentity": "b4dd4f027a396d01a5946e08e8c424ec2b94e1b6a5771357062829e53ba788ac",
    "AWSChimeSDKMessaging": "8a9213647625be512d0cb5733aac44eda8f9f76aaec0f33a014c49465ebb0925",
    "AWSCloudWatch": "f19c9695dbcdd1f4da65da12c081170cbac812a4260284aed46e483a7d2b70df",
    "AWSCognitoAuth": "ebe8b475ab47b89295c5a80fc89634fab23ddf4e4c00b5ff6b22516476c3004d",
    "AWSCognitoIdentityProvider": "611d63020751b8518198f339f7529e2bc08b020114e10b0ec0cc403f9477cadb",
    "AWSCognitoIdentityProviderASF": "3f5890ec7ae7123c005d6f3c6fe00956200e9c8942eb9171e4ba7e1c9fbe7eca",
    "AWSComprehend": "129710d975f09f2802ca2baac24ce5ba8e08c4b8e456bff5982b819cc4583478",
    "AWSConnect": "7b0ea2516382c77184a237db5efaf7467bc0eaad17c97ecb6b9f81ffebf3b918",
    "AWSConnectParticipant": "389b83a99ba017181eb7c24753359b3e25e1f13ed6d31a4d184f9370dfb49a06",
    "AWSCore": "fb1f9daba6bf518b96ab327da2bcaa535161e969c93d4d7d02e4a1c04f61a6f1",
    "AWSDynamoDB": "7e839a77a51bae6428605a9f898cc14ca08b9d5385c4175378511ba3eb40dd39",
    "AWSEC2": "f9f58c440d5f0f89d36ac79d1bc873e6e101fdaaaa0568b00617fa1a6407c07d",
    "AWSElasticLoadBalancing": "608a44d8a6a6b24fd7d880e4ea160500cf465c9f581101638c51dfbdde52e2f5",
    "AWSFacebookSignIn": "712e9913b1030fce622c7566acd1800f3418ab462135fa025af07482d1941f54",
    "AWSGoogleSignIn": "3c9cbb83fd19958b5b6766b944734e3d4f988d7b5ec090af51d872766203cf6e",
    "AWSIoT": "d0d6f907f10d58275bc4c30f71b550149fdf25ad3eeaa9c637be06a7581eaf23",
    "AWSKMS": "e95af2dd3e1bafab09d9539b1cb18a92e7f8b73f4674cccea92b451e0cd3c6c3",
    "AWSKinesis": "d8f27a50aad004f6efb6ae51e2f1955bf574b2bdc596b88e44116450a80cfa5c",
    "AWSKinesisVideo": "e641f188e9b09f4d8f5089010cdfe5f5540319141f4efaad57782b39992d4c20",
    "AWSKinesisVideoArchivedMedia": "63cbcb19f1294a63d40847485fcc596a525993571073d3e3b89664b68b900e6f",
    "AWSKinesisVideoSignaling": "571a999a2deea8da5495fbd197bd197fdd7ee7d0ef6162fcaeaefeca0c014ad2",
    "AWSKinesisVideoWebRTCStorage": "d7e210a1fcba768efa60784d1c057556294e610f845349e797e5ea82c82a4ab4",
    "AWSLambda": "d26581b7ea7a3fdb040a83b8abb96474961670042de53fc22c902b84abbd8827",
    "AWSLex": "e3c598aa242163e2f397fb0bf09f532f9aa3ba283f180d520e422bc7135dd927",
    "AWSLocationXCF": "3dba13bde61d200dc4e9afb64b9fd880509bae8ec969f93093ecc456ea4ebf1c",
    "AWSLogs": "a24ea63edcc73f9cf17bc3413cadd762ad7de469fd61f67d4326e3ba2953a384",
    "AWSMachineLearning": "c976b9266e8be0d39b217b0e48b4af2399784c3570875bfff02b9a7e46ee5fc0",
    "AWSMobileClientXCF": "c5ee69e9ffba6c11d65b61ccb7d27b8a9295549b2093b57bc33453acd4f734b2",
    "AWSPinpoint": "06b41216f7e4961de62f3980e7881351c7b22a0d7573ba97c6f8a6204268e7cf",
    "AWSPolly": "db737cc202060664644b92ec5be3bc01e6e1892ef21fe7c34bc93ab72f965bd5",
    "AWSRekognition": "3d1464780de4ecc78299ad8ad4447bda7e788092ad1f2a2d6322b4803f3eb9a4",
    "AWSS3": "f61d496e74c561f67efcf1ba45bc5a6c7aa889186109b7e5cb1a43123c97bd66",
    "AWSSES": "0e5a76517184324111e8d35bfd37b1f350d125e999643a8aaa974a09e6e55fec",
    "AWSSNS": "5cbe7eda4321700c8c114153bc3a5d70644eaa4235a9885b8eeb9d0fe7d21a75",
    "AWSSQS": "1e54c3363e888126c34d12c2eeb57d82b8147249d848fa5a25ae61753cb62ac1",
    "AWSSageMakerRuntime": "13c8f789a43e53179d80cb4995b13554dcd0334c4725e9f6d5ba064b4a4a280b",
    "AWSSimpleDB": "539e38addd573b12645ca41edbce7d135dc620fe22ef41497409a7241e5478a5",
    "AWSTextract": "950c126a3ca5fc4e8b3c1664dffe56c3727bac2e9436157a477f6391a04e52bf",
    "AWSTranscribe": "67a1f57660387963e606d9b161bbb6d8644e28f54e4fd470b0211351d112f73a",
    "AWSTranscribeStreaming": "3312cf14dbef3e114fdc02a64843ec3bceb662c4b23acb6450a74fde7a43f4fe",
    "AWSTranslate": "f89c3742e7f2d70c23cf092ddcb6da5e152486bc4d6e6ff863cc4eb83736ed2e",
    "AWSUserPoolsSignIn": "9bd55d5065ba1daca109559a21d8dd92d2cc986c70f3365762c97d55d44acc39"
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
