// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.36.3"

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
    "AWSAPIGateway": "a3af304441c00cc814953485785617bfe024893ef3b0caaa428d5c8ef679fbce",
    "AWSAppleSignIn": "69678fb26bfd1564e03d95d0d2f82e0c758fc1ef4c55b2d068d13704ba827fcd",
    "AWSAuthCore": "93c1ef4a95efb7379f312a525db3568877866c461122a1a00e6f806fb6e65a36",
    "AWSAuthUI": "f00eed9bfc7ca2af8ad9bacc07a7eb2c40a9ba0e8ecb7631d2f097af502e2860",
    "AWSAutoScaling": "ebb16b96db6aa96019fc6a24cc091de24e4cb591e2530f6196238da9f4e67294",
    "AWSChimeSDKIdentity": "362cd9d849daa943be85e734e54cf5577b428657c8e76469d746b9a96caa3290",
    "AWSChimeSDKMessaging": "ce67160c1168e99369240c98c6f13120e2720deeb2def2095dcfca41bf40ae6e",
    "AWSCloudWatch": "11082eeba3db95541098cb2c4f19b0e49255fe1c6a2321a6919dfa129d6f5753",
    "AWSCognitoAuth": "e1ad5ccfdd7c2c28acc0e2ce2bad366f6362314c3706a7517fb61a0c173d7397",
    "AWSCognitoIdentityProvider": "3cd5cc97832913329c0a732c86650c87f7e1aaf809f787a7cccf9f807b0072d5",
    "AWSCognitoIdentityProviderASF": "e9215de3388f89d9e76447d21f99e6bd490ad3e97990512c6865d8ad5c36bc58",
    "AWSComprehend": "84243d0e503041a99564e4f90774eb2c170416b1cee192faae13b354f158131a",
    "AWSConnect": "78f023f49a178055f05a452a249947a284a467c6430f28d4787c03fdb02c7fc1",
    "AWSConnectParticipant": "eee37ec30e80804a6b1af575bfd267fc2a7384c5a063b677ea4a3d359b0e8f69",
    "AWSCore": "3ee6b16031763f364ccc402ec4db795cfa534dab1e40dc70262aa3de3dceac8e",
    "AWSDynamoDB": "d3a5ae1581d4717cb22064642344d9e1d8f8f2049c703987619d62f04386a172",
    "AWSEC2": "5fe3f55bedc3351637ed940e3fa2ad0b858781ed791b96a18b9d5a16bccdfe7f",
    "AWSElasticLoadBalancing": "48a17b6138210a9cf076a447bc93fb81a6484222f1cff1ec42855fcc14986b29",
    "AWSFacebookSignIn": "f1d84861a2edb458a461cb4613c9026c52f0248fae976cc1195147d6da9c84a3",
    "AWSGoogleSignIn": "668bafd46eb40985f1f461497aa45f66f458835500db30500e7bd7e925e59a6f",
    "AWSIoT": "b9de3f20f691fd168783318e74cf61a2ccef25326205b2085f402f4e01374eac",
    "AWSKMS": "446ee1754223541c3db470a69cd30c63a6eceb9d1197fb0102eba7757f746e4f",
    "AWSKinesis": "d7b4bc5e971cc839240f416bc94463a89772a03b54c369ab26174bd1d2461801",
    "AWSKinesisVideo": "80ca84547742d1875ce144056a0113e1508c04cd93ff2eaf1759c8adf434486e",
    "AWSKinesisVideoArchivedMedia": "9ff17e12cf131498ecf800db0b2fc090c1b20e5f71d253707252261c6df7906a",
    "AWSKinesisVideoSignaling": "c8ef6f05f20d7cf4bd7b529b497731ee65f00a066d68e81022d17212f0c4d33e",
    "AWSKinesisVideoWebRTCStorage": "593ab20190fcc9d93376131b90845b88447f584f7d3dd9849e2b31663e190dca",
    "AWSLambda": "7af065c52d9f32d89b4b818f2617e760baf224941105e4b63154651b79da792e",
    "AWSLex": "b844061f659bfd3a39a5439db90fc4c4a9311482367a0651e9560dd7d22dad73",
    "AWSLocationXCF": "25c434cf09b19fe6d55835a584e5b1387183c9e749f174c0827be3a8aab61bd3",
    "AWSLogs": "580d3923a6381001c042634c92ecd6d101f67c938226ff7ab7a8860a062b5c40",
    "AWSMachineLearning": "8d899608879da7064c5643ac9eeef6a5c12fa06cced3142698115f0f5670e589",
    "AWSMobileClientXCF": "a25e04c3caad09bf6ad618f2929522b04a03c4ab6b9fcb24a7df4a9df90003a2",
    "AWSPinpoint": "8c2b0313fae12d4b3c0317fd6ccac1307e5edbdd3a9e14da3fc94fff29ddd831",
    "AWSPolly": "504accbbeb666359e9d3b8ecaede98391841e3bab02835198ec576379a950536",
    "AWSRekognition": "97a198c547c4e0f6d75d6fe68132623a383874bbeadb63a759ee45f86d05795b",
    "AWSS3": "ba28454642e1ed745524a6a88996e03380adb54d047a34f024ea067788e258ac",
    "AWSSES": "166ca79dc090420c09d73151715fa3534280362bc8c7124f68b3981d93148d12",
    "AWSSNS": "4a027f5932eca86597e0b3873feebbe2906bb5cd36f47b70f4fd35bb4c0de9ac",
    "AWSSQS": "a17f22903df615c74b3b9c6cff9cd853df2edde9842d03eb74dcea2f2baaaa6a",
    "AWSSageMakerRuntime": "e385e7cbb998b4548f89889c2b182cd3f900f2a2d5af099b0ee14d908f5c118d",
    "AWSSimpleDB": "09f1a7cd7052c7e8237c592e46c425bb49335d27d225d5d5b8c9bfacf610f5ce",
    "AWSTextract": "5b71de023bae1b510b6a3396b8fb187466a985d1e28db2ff22d2672e17078e32",
    "AWSTranscribe": "bb2b1f9db280fd2e82cb765c5d9b77c2fc50b439e1589778f02b01bdb9f2c7a1",
    "AWSTranscribeStreaming": "25ed8e48db24a77afd6cddcec40869535b91b70f4915a42ce832cdf0a39c04c5",
    "AWSTranslate": "41d5d781169ed4c716df878a96f3f19fc39a7be8a80285f521484f74911feba6",
    "AWSUserPoolsSignIn": "4ca85e106074a0c78c7d506ef78bc11109a188638f12753c00203c6385f013b0"
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
