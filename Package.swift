// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.36.7"

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
    "AWSAPIGateway": "3daebf4bfb9deaca203008fe54d94cc1dbb71e9159ca0aad276f00c55b10b1bb",
    "AWSAppleSignIn": "3539686116ffcf9f4444bd497dd2e76a635870c95831b350fbfe81a8cd3aef1b",
    "AWSAuthCore": "83af0654badccd82101dcd0f205a98dea5c804932f2f57b682e2b7dc1fc9a0f0",
    "AWSAuthUI": "ce6a16161de3c5aab60d46f96b420467092a267e0738c27483d88229d90a0936",
    "AWSAutoScaling": "06517c95c5ada72a421fb06d2e5ac385ba0801912066bf6e605412f233411db6",
    "AWSChimeSDKIdentity": "5f2c93033159602a9e425ae0d715f9912a6238062dac524d77c8f9a2831922a1",
    "AWSChimeSDKMessaging": "da50df47665b6b3ebd019065e8f546b1ab3819deee281de240fac90dba61a689",
    "AWSCloudWatch": "eb9829d8b407f2ae4ee4c3f216ba49331e4c5d204838a191cfdb6d7fc3a41930",
    "AWSCognitoAuth": "57c425d3ae0d8c56c1c480d17dcfef1837278c4517c93c0d99576ff4d4f0a881",
    "AWSCognitoIdentityProvider": "55f4b778930869ab6842559c66f83d999ef6857bfbdd50588c6d605b639e54fe",
    "AWSCognitoIdentityProviderASF": "2bfb026a242d8c77dbd0e1c3fa4e0f444d60b11a506e2158d03bb25b7384fde5",
    "AWSComprehend": "1c8ffba8f9b6308282f40067274432b918084a641a60182064f590f34cc94c3f",
    "AWSConnect": "c2d6258dfc54eb9b62745c44d886aadb71a489bbe0f0d442ec5d65ef18ca974b",
    "AWSConnectParticipant": "2968a3e4ee433616340677c23429387076aef77bbae33c2daf46953c6707c98f",
    "AWSCore": "5c5301a09f810fd64d13c13501583d0588fd297c0dc0c4b19a71b9bed30005db",
    "AWSDynamoDB": "36d1f9c83a8d1017ffa57437875bedcee93f7f15d8c9ffc19de9667d6f9ec1ed",
    "AWSEC2": "c9086a18caebea614a1aae46ded1e0a3dd6d1f4c050714790759d04c69f08ca1",
    "AWSElasticLoadBalancing": "12265247a7b04949dbf19a3089fe335eea36db2f340d5201b1f31268279421d6",
    "AWSFacebookSignIn": "eddd19dc8c2a8857c20183b643dcf00141ffadc6e06dc1ce8b40e6c325dbf68e",
    "AWSGoogleSignIn": "8d010589da08700426b13cdec03d05227dcb5f4bd1c9b0bd956da336b05fd15a",
    "AWSIoT": "e9a4381b234282db5b339db386a0d11cbdfd30cf0f12f4009f5c7fb5309273e3",
    "AWSKMS": "c1168380cb86174de3202ccbaaea6436259302f08a8c3d31d6415e2a9a4784b5",
    "AWSKinesis": "1a19b46d03c23805197b6baaec3edd818ed6c028580d9ee6d37938bdead09559",
    "AWSKinesisVideo": "5cb7b28e65f086d0e4faabb00d16235f2547cb389097ee798a09120fa173db02",
    "AWSKinesisVideoArchivedMedia": "a79c69c05ac29a1e7b0503a4637c01bf43dc81d1cd6949b0c65827bdc3c6e7bf",
    "AWSKinesisVideoSignaling": "2f246c7fa28faf0578bce6c894faccdab316459cea4d2287ca45e59ce7635af2",
    "AWSKinesisVideoWebRTCStorage": "9f4a9d1ff02461866b960eb0f8edba2104bb883fb6678d8214ef6eb6a8f46bb8",
    "AWSLambda": "33bbfc78b7fe0a1918687c47d7f3e98ac383e7f9727a9d8ec1733cde31b228cd",
    "AWSLex": "68ef66242a76bbf263b5b2588baf666aba70618d17062b9d24ac94af65aff202",
    "AWSLocationXCF": "fb5115976a52670bfadcb42ebfd2aeb6e88331cc7a96599c019fe672af8f8d01",
    "AWSLogs": "c807ff02221ec2bc0395390a62d0c7a3d92303d373e10067d5a78b30e678c71d",
    "AWSMachineLearning": "72b04cb047585b4eddc130f2a2c617f93808a06a85737f3e8c06f93dd95c17c8",
    "AWSMobileClientXCF": "0fbd5af3fd4e4335e5063db7f90d3a49bbb887e95c35a2be6d3afa84b95ce80a",
    "AWSPinpoint": "2225a4cafc706757f44c10223fcf804784667c4d262f3a49e1088caf1ac4a20f",
    "AWSPolly": "6805e804abe70ee6f3ba0361588c89fbde8ec6500024f6537b6e58587791db3d",
    "AWSRekognition": "568aa77c5c8db250b4065b72b1242922fbe7e16c8e45a443953020104114e188",
    "AWSS3": "9af4a0f4eba812d2144bd6cce42bb345883ee7165ae0f0bda162215eab5cb402",
    "AWSSES": "c87578bdd3441242a87bbfca4ae9092fa4e6cc0043295b73a430d85feb7695a5",
    "AWSSNS": "db4c9117da463f1da56a1c98dfacac966bb920ddc9546d573f8520f858af5128",
    "AWSSQS": "46e588e48d725103bc3e9f5c5b6f668441200b1327328c766a9422f5c386daf5",
    "AWSSageMakerRuntime": "7d964fd5395c97903713e9d803f2dbb66697c112f88cb202523da53dfa2eb2e1",
    "AWSSimpleDB": "6adec4f0c3fd45ab39d7db334f8b7fdea893f74cb188081005208e051246e2cd",
    "AWSTextract": "52b9b36cffb7ed245c60e3946019e28ea72db9da1a88ea9d6555bbbd5b6021a5",
    "AWSTranscribe": "539b561e166609f99d16f4a00b72e3e1abd0a5a197e5bc1b69c357866d3884e4",
    "AWSTranscribeStreaming": "6dc20bcb07e12b84edd46cf7cf421af25f7f508f041ed53cdaf002f19c88c544",
    "AWSTranslate": "662adfc6fde53d5bbd2b4e3a5be1a94aa6ba21248e4dbe0511e33d059b09049e",
    "AWSUserPoolsSignIn": "cd1802a6ee7398ac092beb769694d15edb0ae896d7202e8dcbe6d31d1e70d012"
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
