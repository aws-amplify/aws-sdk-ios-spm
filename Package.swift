// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.15"

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
    "AWSAPIGateway": "088e93b778d4cf1d3c4f82186e1f3dbb6aa64ba5d84f31db54e99dbdeb9fc857",
    "AWSAppleSignIn": "afdbf724c389469e5321807c7046d6c826410a22ded413d8bae422502635ed4a",
    "AWSAuthCore": "b51f20940d6d3dbd72c73855d6df8672a542ad4ad80ca1e0beab4f6e009dcf3a",
    "AWSAuthUI": "42c9b29e6bfc9ae2cb54b8fd4820cdf7d50e98995597d26c296f23927667da17",
    "AWSAutoScaling": "20ebd095deff05dbdbc71d77d2cc0283621dd37b3cb765cc55e286489c44773f",
    "AWSChimeSDKIdentity": "3306d163576e670625ceef43ec5d846b9d03cb42d6063627952169400c9ed527",
    "AWSChimeSDKMessaging": "369c9473697f413158be826f1e3a1e1c4fc662268ba6aeb5350a90702929cd1f",
    "AWSCloudWatch": "aebc47ea806b593ee7cb55ce6e0e22460c3d6b0344e607c8bbc7489360b8954a",
    "AWSCognitoAuth": "df20012ced10718ce9084519698bb423d422cc57fbfeb5e7cb7875de97d36230",
    "AWSCognitoIdentityProvider": "390fe79ac84111d218e11ac21d04f96ce8c46b80b04ba4233c8c605cd4ca36a3",
    "AWSCognitoIdentityProviderASF": "d10dc5fb0c18cce5c1328709c490de4a364a29d73d3215a8114c72888669f32c",
    "AWSComprehend": "7cffc77b52ee66021733b3cf024d4b15493563274c10bd56b00523c38445aeb6",
    "AWSConnect": "4a82d414048c6d119eab4a1f2926b5cfcf658f7c185a91a1394bb603a9a29333",
    "AWSConnectParticipant": "a4b1db7fefc3fc14a08c48973b3404203e52f0beb97d5c7b2d3148463a9f7b91",
    "AWSCore": "838f03a0e7995c33a5047499a038577a81710fd869653ef99bfcbfa5aac4b9c7",
    "AWSDynamoDB": "b40ce998c594258d7d8a289f7da10fbf731485a8cb5f0729819dacfc1a33b77b",
    "AWSEC2": "3151866882bb2440532acad77a3628dba69669ee7c30bff231e667c627aca250",
    "AWSElasticLoadBalancing": "ebe2c3dcb15ebe0449cada1be1a56288c334e98850e56398e74fa2817edd66f9",
    "AWSFacebookSignIn": "11342830c626faf2f0650bb0a0a513b3a079428d9d2d129de161356a8baeeb3d",
    "AWSGoogleSignIn": "824dc57eebd49d435dc09ce027d35b974e74413b9b5e62ecab3f658b5af22609",
    "AWSIoT": "0693c2fdf0aa452426cf8c50e9a86000e0c385b9abb38e539aad89ec192afc1f",
    "AWSKMS": "ace8bf3b852d8f5fef6a54209a36504ce303fed1ea267b01e86b32dfafe29fe8",
    "AWSKinesis": "0942432fe52b10a0583037efd9797e01bcd3e4f5ad594f4519a76f9070aa57f3",
    "AWSKinesisVideo": "a5e90ebef03c7015cf16c81b99bb372fcd5083cd432fb87fc8902dd5cea6c76a",
    "AWSKinesisVideoArchivedMedia": "77508ef97104236225231c55c1ee6e132ada58d1a93841483fe9a6618bfae4a6",
    "AWSKinesisVideoSignaling": "fc01640422953f92e074766e898731339f935f2704b782d898416528e18f6384",
    "AWSLambda": "8376e13130f764fda3853cc467b16cf71fa88ff90d05611c90fd989975fdd4d2",
    "AWSLex": "d334a080729aaa68295882249e1f7c6c1fda8ff13b88610fa3cd247f95e0bf69",
    "AWSLocationXCF": "fb07a496ca250472cc4cd5861af6afd40277054c3b714db2422e212e8d7cc4f1",
    "AWSLogs": "f9e02ce4a22aab4349ef8af38c37dd6d4eb882610f1b6e4fb5fcaf5f68473731",
    "AWSMachineLearning": "94ca75d4bc95a81c38c52a66dd98443dd03e4df7688da89b22e53d5d2d23f34a",
    "AWSMobileClientXCF": "327521823eb8ca0fd44ee67681811c8d1aecdcfd0d8c28cf85d8b72c556bd7dd",
    "AWSPinpoint": "397b9f6edf2f6f727c298a2c120b688d03b704bf24fa8d49bbadb48e6eecf0a3",
    "AWSPolly": "eb7597b2307a42cedf30e6b9ca8c5db72e663a23677639306f92113299c05156",
    "AWSRekognition": "19c3d77c7b92c2e8cb44bbf0dc93ee7d9516cb62a5f1f6641542ec1a1e699f0d",
    "AWSS3": "c4f3293d8a970f39efae88e36145fa4c0d359a348f09a6f7f0f639ca7e4b896c",
    "AWSSES": "eb33bd8a75e34f3a961d91081bff86dffb94244a4d0580dab14aed71bf5e7c3a",
    "AWSSNS": "4c348aaeb174509e2b42bf4abc5378f365a46671779317ee07c0c0d061dad1bb",
    "AWSSQS": "9a06fcd4a81d88bfbca3a2aa9273cb0af45c2f1e8d9b58d2e3cfd8b101962375",
    "AWSSageMakerRuntime": "11ed023fd798282da2300633de9331fe4e5a45d36c8a858992265a98de4170d6",
    "AWSSimpleDB": "937370d6cf89d4131f4aafec96c9251ae7833836e19caf8f3bc1eaa8a9b8240d",
    "AWSTextract": "1db864da3c243d9c2ee1c45bffc01dadc08f3173eac5341c4c15fcaf2b5ad6ba",
    "AWSTranscribe": "a6bc5fd92a4c41872926df2060f014a0f5fd6da55494d650ce1339e31790430a",
    "AWSTranscribeStreaming": "a2249aa40fcffc7626deb1977459014ff7912db29273b90fa3d95aa9c9abda87",
    "AWSTranslate": "e6aea691a324979cbafed95fd2798e8bca17769dd58c4898a25fbd621dffbe14",
    "AWSUserPoolsSignIn": "1841d13357eabfa6f31597569fd1006e01ee2966e838db922bab17e3322b01a2"
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
