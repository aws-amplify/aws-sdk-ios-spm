// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.34.1"

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
    "AWSAPIGateway": "70021f88a8e04abc7de5c82d27b98d80e9faac4c4dddf93ad1d89e9701c1fad4",
    "AWSAppleSignIn": "e887d34012c1ea7fb43a9add28c494d00f02f7f81a04b407bc083402232e3222",
    "AWSAuthCore": "e2b742ec5bccacde808db16e54ec07d3b92fa76d33a79cf746b4eccc1c3ee508",
    "AWSAuthUI": "3a1d3a8e27fd6ddb8f204c9d2b11d8a642d20634b0d593ba9267dbc9187f3205",
    "AWSAutoScaling": "aa8c5fe5322e4a0e03e998bcd2386526175d6cf60987e2adc41cc747486421e9",
    "AWSChimeSDKIdentity": "c1fefcb3a4bba0b1d948a9bdbe6951e34555c27c68d2c063c12f2402a3af36a2",
    "AWSChimeSDKMessaging": "4ea559b2cc050d5e7445af7b87419e155660b985e6afd54db5fac0991c9c2a2a",
    "AWSCloudWatch": "4ff206d6fdf365022b376eecc12c133c118eb3fb6e6a7170aa31ed92e1f41d6c",
    "AWSCognitoAuth": "2500e5570b8c395b5faba0f0d5fffb57adda9adf428a75f063851a2631bf7817",
    "AWSCognitoIdentityProvider": "1b4a7a2cb4dde6930263875cb3762e06c0886d89d6c0237f41ea89cf05567c32",
    "AWSCognitoIdentityProviderASF": "80c12002de42f62f622822711b7324d970fc76cc975c94aae7656965b664fcea",
    "AWSComprehend": "89e6dde98d82036ab186bdc69bfca0ca86e593a96cc30a1cd1b7b895372fc608",
    "AWSConnect": "1cc07f7631236155ec65107e48f501dc92d5be2694c1bcc484285c4a21efc096",
    "AWSConnectParticipant": "609c01e556fdc09a25923ba8d0e60b2aebb160d843faacbd5c5637a66fb718ce",
    "AWSCore": "942f428eca83eaa1e6ef4a8d549e3ea02daf0554046747a74fd8cc42feb8c30d",
    "AWSDynamoDB": "00731b3aa42d77ccdaf6aa8a3fec9c7df6d4a08784974a6c0d79a5784b7e30a7",
    "AWSEC2": "586e8f35492d7054925e8e4d4deccf72bd13ec6be721094655e2712d58f1ed1f",
    "AWSElasticLoadBalancing": "539c1b2841f3e404219bc4287dbefe7870109236ca999f5f3c16da248aa7b7d2",
    "AWSFacebookSignIn": "44cc6d2c9a331317bd4652112e60f2bc14591467c13a50cb4931134a1a0e9164",
    "AWSGoogleSignIn": "af04ed08c4d3061d8d91f062afbae6edb42b49dd14abf9263db793806321d7e1",
    "AWSIoT": "c388fa32668a696b0b442af63829bd086f92b86af1db444d51839a2b3e3a6a31",
    "AWSKMS": "be6fff6f474b94620c8a8f8ec235da9f0093513e0a885769ddf56ee65d84a73e",
    "AWSKinesis": "1cf1acf163cadfc60fe112756b7ae9f3c9d10946bb396039a9fabd55feecdfe8",
    "AWSKinesisVideo": "d74489ec620f35a00c93f1c68217be02da2126facf341ec8b643ec2b580a3d9e",
    "AWSKinesisVideoArchivedMedia": "88d1e7e410674b1444583cf313b110b4a0c0db66c5d3b73eb1a2ee1ea2cd10c1",
    "AWSKinesisVideoSignaling": "854cfcce1a760b74063de00b5c36180737d3b6f04dd3da5d9f7ffc60b022117a",
    "AWSKinesisVideoWebRTCStorage": "2b362f323013fa77c2915fc7a0070af338523fe15d2f970c3bd01e51a32d9222",
    "AWSLambda": "9a2fa84c86128273218458a328827b464779d75a61a7226d0857f385641ef778",
    "AWSLex": "1b341ed6439652c03ba376e8449f96ac23de028be1cad5bd18406718186d6a9f",
    "AWSLocationXCF": "11379b17e636eb30aede9ef5bef3885aa659e182ad02446b3a7766f22db8c154",
    "AWSLogs": "5d1b589b6f167163a561b732753edb4842258bd34a36ed858f63ec301d9e86a5",
    "AWSMachineLearning": "1614841f0be91322d33331cab244e19cf72cb89746dd43206cb1db2b187dfdd0",
    "AWSMobileClientXCF": "339ebaabc4cad8fe27dbe6cc0c7aafe137328ef87f147d9d0511612c2dafda8c",
    "AWSPinpoint": "f98df22dfa950a1e521f3376083fefdabfbcfde7f547edc80b926df9e92907b1",
    "AWSPolly": "5dc5402c4ec6b9c3429c48d8b225a646d2c5a7500eff1f8b11f4a3855e1a8701",
    "AWSRekognition": "0b9a3e648bdf6121f4226afc5d468c3e423949d84b10aa610afc5e03e805ede9",
    "AWSS3": "1bf511fd95919dd1ea7601943689e7947b1e6d9a4ceae86e4404e6b9637fc996",
    "AWSSES": "552ae76e1932058ebb6b8649a0e12d588adf1b1faf85b0706294f5e85769c1b8",
    "AWSSNS": "9f085c668457259ef8ba65710207a18e9e91b6986e0a060eef7037e45a8fb1d3",
    "AWSSQS": "923b47d3d3241aa997f0e77dd81969f8cb902119639fac33fbacafe13d3f5fb2",
    "AWSSageMakerRuntime": "3394899a66d441cc86207729bebc8235819f254ab1267c5961e6b9f110f663ec",
    "AWSSimpleDB": "74425e7315d02b8cce47b1548873e7fc62bc3a634a4e1f5ff78a308945e1a1c5",
    "AWSTextract": "73339322d84c0d60a074e1bde7cc06b752f3b950e5743d4e3d262a20fda4b994",
    "AWSTranscribe": "24eeb45aa9ed83aa6d082c235dbd97426d39cbf471d7f92dfe15cb64e088115d",
    "AWSTranscribeStreaming": "b73368c69a3b8fe101a656103af8681858cef80e229afd61c4d32e7d64dde326",
    "AWSTranslate": "c202d509bdb0b67228ad804aa4892a8650d55458f2013327c24ca82ee286a640",
    "AWSUserPoolsSignIn": "998ca145420ed692455a68ce4d2c8bfb70090723a55c2e056860879ebc33f54f"
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
