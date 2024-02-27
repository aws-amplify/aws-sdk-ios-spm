// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.34.0"

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
    "AWSAPIGateway": "7e1fab0a1660a5f621d6ae02764a5bace6cb2dbcc720770469c89f85983d3587",
    "AWSAppleSignIn": "073bc2a37c4b1c59af1dfbf49632b9063c7df7c7e824ed9d71d329dc3aed4402",
    "AWSAuthCore": "fd9b7db2ecf8d36c6519889c5286fe3e4a769ac40874eb63d4539e60e0265a17",
    "AWSAuthUI": "a6d9103d1178ef1a840d93feb773bac83a8b8afd83957b7595a0eaadf064645b",
    "AWSAutoScaling": "766b93c59a7fb141e6818174420b6be4bec3d76942a39897d2863bda2f9b5baf",
    "AWSChimeSDKIdentity": "b048ea2bb9c55688862501153cf01401bc41f7aadf642c82741f175afecf0d14",
    "AWSChimeSDKMessaging": "2127f445d56840380b0544d08a1a609ed8faf5b21e35807ab5cb0f44a8dce7dc",
    "AWSCloudWatch": "6af3a26053fbdbd496ba14a0084dc05bcae891a554c653a724276e32837b00e5",
    "AWSCognitoAuth": "b8f345f2eb353e0c9c17c71fa0f133d21bcd1ea645d6bef2c27398e14d8805ec",
    "AWSCognitoIdentityProvider": "7d4f3117743e1f3181477ce3cbf3cb0d603e90b597863cca7c599ca956a42dff",
    "AWSCognitoIdentityProviderASF": "88a4752688fc9ac5258869c3efea7be5aff8b2d19c8c905f415643009811ae1e",
    "AWSComprehend": "de3252a03e84f58fedbc3579e47368c0cfac3417bfc8f21c571831de553ce30b",
    "AWSConnect": "181043e90d0b6fdd7efc5f1dc428ef8aa68bde69fcbefd7b96800c00f1a58b10",
    "AWSConnectParticipant": "6c4586503288295620e8415850559e10f67c36fe8c5146ce5815805a049992e1",
    "AWSCore": "c2472625a2abe47f2d7d0d5f2e48ea4720ba6b20eb49455fddbe32112e7f0ad8",
    "AWSDynamoDB": "0272eda5374b8180d40c768c4352db520907d54f42be3b2a3c1f1c258cad4ca8",
    "AWSEC2": "6f49a0303aa245ff7711b024a21e5efd46f4f67baa2b44ae98538cff059cc991",
    "AWSElasticLoadBalancing": "343ae43f8c91e8a3bcc908d61955b4c6af215e5671ef0af1dd924aa1d3d6852f",
    "AWSFacebookSignIn": "b5df033e7ad20db22806332b3f2334d1cf8ca5f678439fb872f3e142b1e45b2f",
    "AWSGoogleSignIn": "b55cfddc1174d879c57e557eb54eb3cfc48e15d00be7e2214dd3394f165bae34",
    "AWSIoT": "adc94e3118c25157820d8cc4a76d4937308f8a4196aa6aa17e9ffa2684aa8ade",
    "AWSKMS": "907eb64ae86f6755be7b7d3b8aa11d3d53991a1914c9afa48a17717fcdb6bb38",
    "AWSKinesis": "435463cb05a46cb86fccacff770782f0d868fb78727679cf909d22c77043d4d7",
    "AWSKinesisVideo": "031d5d66cbd2fbb13a4205446fa7839ca7bdab4244b45f40dba82fe76c12aec0",
    "AWSKinesisVideoArchivedMedia": "e2a39e207b18a96b533063cb05db236a665244d838cb3dcf0324e0de3c2331b4",
    "AWSKinesisVideoSignaling": "a65da36b495559627b3a8757a11bd8ccc40db71dc6b936a27ca76f87f64fd56d",
    "AWSKinesisVideoWebRTCStorage": "8a820bd90c78994b441fcc3cbd7029ae1761435d019f1d5057737817b051fe6b",
    "AWSLambda": "e3f5c50f21bf7dbfe3e375b9c050495c1c1e4f6687aa04df53b93c539370ae5c",
    "AWSLex": "c3e401a265dd5aeb095fc35911fdf6412c1fd2c7d61c354bd58da9036289d807",
    "AWSLocationXCF": "4c39bdbed7e24144b6af0ed5aa47ea684d1e2ec83537b7cec6a3336a9b8e6e38",
    "AWSLogs": "56faedf5a63b071a33e7bc4005ed21a72f261621169407083850646291a44e86",
    "AWSMachineLearning": "d8a9e706f69d6cf5aaf3b957c9e070ddea1c267802126f038e567a87e50d6974",
    "AWSMobileClientXCF": "29e96e1b3db3b1b781512acb3ac3b0a55bd88d05074929e011b7fa61318f013f",
    "AWSPinpoint": "e9ffd140faa23950eb400074600f24d5486e57955434dc897a0ee4123cd638a7",
    "AWSPolly": "833f213af8113bace0c4132215b4e1fd8e75a07eeab4f3f76a35b922c463c900",
    "AWSRekognition": "15d06baa24635fe7b8a547cb27d9913d6e1a6581043cb13c957c6cdc7c75e54e",
    "AWSS3": "a6663b289d54b59a914648b591f1c0d0b41e6b9431d8cb0d0815f16aabcdede7",
    "AWSSES": "815dcbd92415c9939b7d861cf30402d934cffc5bae2a11577fbf227f2e4f5024",
    "AWSSNS": "e251c48260dfe85dc709afe22bcf9392cfc65212a7ad2d195cc56d88a42827d9",
    "AWSSQS": "e1b452b692f4cdd588cc9ef43b8a3cc59f991e33d9803234f427c72c28da25c9",
    "AWSSageMakerRuntime": "a22d3c0f8763b2921d36c53372a67b9f1c0796282aa8a95064e409abca415b61",
    "AWSSimpleDB": "ca78da95c37f9606902eeff9088caf7ee44852d3634c75130151e46cb3b0794b",
    "AWSTextract": "f480fd210c514b4e7d1ce7690b0a5c7f2b209ad2f816ef7854ea206233850ad3",
    "AWSTranscribe": "55b101ebb0fd08c22928675adabdf21a81dd20aa5c7c2b1a7e6b1fd558990ec4",
    "AWSTranscribeStreaming": "89149f1ba304324acc466d5a857aca09075b88d955f76b0059f6828b51cc8987",
    "AWSTranslate": "26ed6b9ac40b1786d6bf68abbe410abac93d82c50eb8b6fe5a1fcc450274f316",
    "AWSUserPoolsSignIn": "e57f1e9d0a4ef42cc55e3c7a0464eca8daff4391e9588b5577e02bdd73a1ff4f"
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
