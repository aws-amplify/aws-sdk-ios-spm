// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.30.3"

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
    "AWSAPIGateway": "513e020aa3e09b69aa74d6d2be8957bf0ae03049c41b9355fd9a72f24907dae4",
    "AWSAppleSignIn": "d540243cf2458c0dfc04b6f7bbf41c9c6d63becbb050aff8417097bb42491cb3",
    "AWSAuthCore": "9f17848d372521dd446b8e810425adc6478cfeb582c8976a4a49970cc8790f7c",
    "AWSAuthUI": "eebfbb8fd98e8a11c0e1c7add5c7b487b49bd3019752c5d8899f58273baf90f9",
    "AWSAutoScaling": "ccf349fb43c0554ce8f0fdac11a7428d26b18b73a9fd70f47760c5a922da383e",
    "AWSChimeSDKIdentity": "039bdc80384f9def764cab0557d1ff8eef3446b97879f969c84164f01a8a09a5",
    "AWSChimeSDKMessaging": "309d734e0a9fff9b8bec608ecfc935c38fae30836c8c81b3f5118cad68d5b3be",
    "AWSCloudWatch": "05941fcf34683adf3e39415bb23ed02c40ffaa19b46d68128cdb0d5663ab044b",
    "AWSCognitoAuth": "d123fd6e36385539c57cac4c90c8f4b673c52d02575f7f344e0d2b9678937fba",
    "AWSCognitoIdentityProvider": "1ad8745bf835416679697c87b3b656a6d835b5e46a1da1b04ba35d164d50fd0a",
    "AWSCognitoIdentityProviderASF": "88510bb585be9203461e33e5e6257fbcaaddae080e24155c2474309ed4ead6e3",
    "AWSComprehend": "944b5b734c734245f7e1d51181d4b4ac2b13a2aef747d271cbce6978b7f1abb4",
    "AWSConnect": "80e7380a9db51121c4b1fa5abf4013139fe8536ecb64afde3f7c2a33149ba937",
    "AWSConnectParticipant": "1491000fcdde277a450058aa2071fa609a7a1356036c0e924510104c634729b8",
    "AWSCore": "f9ca37b4ac47324ab9bb1f2123ec2e783c3d680253ad05bb3d582c9bf9fa63ee",
    "AWSDynamoDB": "9e7b0997586b5babffd87ff8901e3d4854ca664462baee95f87eef5e72649a57",
    "AWSEC2": "0df8f7ce46be0319414d3e3e25cd5d0731108a3f63c73c1d3e6c999c9d0e2691",
    "AWSElasticLoadBalancing": "c45e960e6c979ddd430c0b72fe6875dcfaa4ad11b7e2072869120daed736c7b2",
    "AWSFacebookSignIn": "6c2ccd655ba6e1a68a4e107f9dc6a160abf0f5939a7f4691d3a2c64915fdbd55",
    "AWSGoogleSignIn": "e778868228d0a457164ab4703525fe4f306e68ae8e76760623a282c14ab4f227",
    "AWSIoT": "f9ebddbe670fed79438e3f48fff21738b3cee8c0f3134869ff01545a1bf202a2",
    "AWSKMS": "5adbd02582346298c11539306af9ee1df52f81df11b05feee4c1b06aff6a5ada",
    "AWSKinesis": "6bd01abf8ecc0c68620b494a0d0cfd479713ed34de35129f7a8701d788f2afbc",
    "AWSKinesisVideo": "99606c21bafaf69c99362071c4654aa2fdb0cce97a414a6a586842b61fe3ae4d",
    "AWSKinesisVideoArchivedMedia": "8b7f49ed0722eef8e9bf3739dac2a581b77eccea0b5a6b0770c485dee4512648",
    "AWSKinesisVideoSignaling": "43a0685739d79cf1b42175c699d14501ac620bf607c531b52ea6a00793ca03a6",
    "AWSLambda": "07b45516b9e56c24a5156750b7eead08241f9b2f7a587a9b05f475e48631ee09",
    "AWSLex": "f92507ddd95ef990196d8b08bdb48f7de4e01f452f715ab4d10ccd28bccf9ffd",
    "AWSLocationXCF": "bf3bc63038cc74583fac458fc4e083d482c9292b3e26f772484eca8d8dac49dd",
    "AWSLogs": "07eb5441cf6a881a8a0a93d0df1b06fe6cdcb6b56782144a6582c5e7e4bada33",
    "AWSMachineLearning": "a6900ec102d160bd3686a26d96fc94c1a65c6870434aa25ea8aa72a910024032",
    "AWSMobileClientXCF": "5ffa73677b3de9419d3a6809b4dd061cc8493afd30f33ffccfeb782c650df9c6",
    "AWSPinpoint": "2a8c4ad21835bbd90bafba754a28790b0ae21c3ea829af050e6fb5880a7900d5",
    "AWSPolly": "bd2b2caf9650a513173cb0206ee61eb4cf11225a44978c14d071242644e6eaa3",
    "AWSRekognition": "c6a8c8044ae5a44d684631be9d31cd3126ae75303e1c4b54b68c19d14ae99978",
    "AWSS3": "0211657c19e33986313d937f92af53ef663ed833bc9c0f30a8502788da739c13",
    "AWSSES": "8be1eeedddea2436fe894519213a12d44a270161766350445c8a35c65c3e2502",
    "AWSSNS": "b45a29b7056e394549d5bd27a5e5807a9414728bec2d4ac2c8a8bd6678fa4f59",
    "AWSSQS": "e10fc5ce5eebfcf039d69feed7c920d4fa8ee640c6b8969dbc95dd4adb311978",
    "AWSSageMakerRuntime": "f6e84448484679a1b9b04f3ba5c6c9e2af039bd3993551b3a298acac1b9f7ee5",
    "AWSSimpleDB": "4a2b9ff8d9326ef15ac28867a9b4ccee5833ae1ad1cc9826be8970eec56839e2",
    "AWSTextract": "e00bb11b0386425aca9f8e185c51b8ab9cfdcded67f6f03af29d08ffc6d58020",
    "AWSTranscribe": "8328188818fecf83b8b2d573c677645fe94d3892d03ba10cc0f154c6d3f85bea",
    "AWSTranscribeStreaming": "2574909f72f4ece12ae37e1a1726c0937d983ee4f77e2bdb4cd1ba590ef2370c",
    "AWSTranslate": "42ae4f7dfc0779db33939cf636d93341f0185b1f0145b5350e43dc962bd5dcf9",
    "AWSUserPoolsSignIn": "50226f11cac5859774228697281c77c5d96ef6069c190425a63748f07ba089cd"
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
