// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.28.0"

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
    "AWSAPIGateway": "bc70147ed613a2e2707eb32b7369431ef30e43c29dc19c754b74eae022685be8",
    "AWSAppleSignIn": "3f0d0b8d97ecd2da735d362d5cc81741d962d57f2c15f0d8970ab712763b88d0",
    "AWSAuthCore": "18e6688a4cca5d72e8e798a3a0747f3c92cf56db74b4039dd11b1a07e7fc1458",
    "AWSAuthUI": "12f9e658f00978e1f72bd5823d9bd900b1b2d22a1b61e9fa7c5fdaa86bf8c144",
    "AWSAutoScaling": "a4e0cf5a534e3edce19c24fc5866b37e793464a069eb6db7a456fcd7966b32da",
    "AWSChimeSDKIdentity": "63fc97215ebbd0726636267b22e1f499baf28198807f5a85c878a8ec2c177480",
    "AWSChimeSDKMessaging": "5b6f722c7753550ee726f8a07013566f00979a3c6cdd6f65ea625051d3bd3480",
    "AWSCloudWatch": "50d2852af9e57d70bd17adee5be74ad57c7e062cae30bd6688178701e7ddda19",
    "AWSCognitoAuth": "03b2ac2dcdc12d2bb6361b427bebbd1b15341798668999e81f8c4c06e576580c",
    "AWSCognitoIdentityProvider": "1b6268c00b24371566cc2965f26b2b95e74fcb0d98f8821b82bd3aeadad7aef2",
    "AWSCognitoIdentityProviderASF": "4ffde74d5deedd81ae82315f757a187a13c590f9ec968293badbe4c99f7b5788",
    "AWSComprehend": "e74d75d6263f726f5f2c281cf3efe9e1cdf932ee005dcf4347c1fb4d7b328063",
    "AWSConnect": "17062da23f6a1c5d2463ca604cc58257acdcb4f3fde3fbbc6db5e3a03e9a10bd",
    "AWSConnectParticipant": "6e222277502e595ca79809e7358dd4c9ff83b158452cb6849fa6c7c79be2b687",
    "AWSCore": "0b7c39b92d046517c35dd70c91284d7d4fc2adb1d367bed2551615878435ea3f",
    "AWSDynamoDB": "113f7ff8f99e438299373e7eb1a34a02f4461e65c61e839d60fc7d4f84a934a8",
    "AWSEC2": "99c614a046fb7ce63e8c4f6a92b2ae5806c4ef4b02d4651c990cc8b5110b0c22",
    "AWSElasticLoadBalancing": "6a35944ea27c989c22dab9c8c86b41eccf0367ae1d5bf0645a5a955edf7cdfa5",
    "AWSFacebookSignIn": "477a741eecd4a0536cb95ea59e61ec9cb420c0c3d640aae0197f557885785591",
    "AWSGoogleSignIn": "132777bbcc2185e526658fb47dc15b9b83d1b3d3b1d6b41aec0e7c3d979c3d3c",
    "AWSIoT": "67efee1fb28bedee7a75044ca05090891f352f82cfdb345147c24b0527c089fb",
    "AWSKMS": "dcd98655aafe79c7a82e3e19b3846e42383fbc23bf2d40b7a246c932c1a06a4c",
    "AWSKinesis": "2822c482f95a61b61394a6733924501ea19b4dfa8abc5bcaef3ecc6a9e1348bb",
    "AWSKinesisVideo": "9e5f465cace94afb5236e424834a8f9dacd752cee8361a58015d9c34a2e1cba2",
    "AWSKinesisVideoArchivedMedia": "46f234fb81c2ec49c3866ae7940010d195a175c2612d5e810d5f3a9807499396",
    "AWSKinesisVideoSignaling": "d8b7a94de14a1a21d1a31aa439a952ca3ac643dbf2625988c077a3f0d914336c",
    "AWSLambda": "3f4cefbd3d8c70fae36c134dd7e67fdd0f8e676f4c6c589a117a6c96764203bf",
    "AWSLex": "9fd4172e79040b6922378683c5d0967cfb9aac5bc24e83f31e5f85b1f40c7492",
    "AWSLocationXCF": "0c84889e05ab3d8455c8308b9e2c54c2dfc2e4153d06a4959f0e3d03881eb8fe",
    "AWSLogs": "e5a5b0d00328560e41d6ad40247055bcbc1d3bdecd31cbc008d995236543bf2a",
    "AWSMachineLearning": "731422c86477a191deb99b63cfd3423e44f73215be335480f4e546bb7bdad52d",
    "AWSMobileClientXCF": "b0301f46206d7ad1194ed6eb7ec4334485a22c3128265f5148bb9b42e6f9fa77",
    "AWSPinpoint": "2e22953500fda683e26f4a109b6ac4e5c761f3a3874852a8338e5937990bbf4d",
    "AWSPolly": "e7369beccd38d4512c52b5599b414135cc1e2a0c974fa2206e0571bc627372f7",
    "AWSRekognition": "aeed4a7a03daacbfee497d08f230c26c2c026a82f59e94733f757926b5993143",
    "AWSS3": "20960f003e3d4bd773fc66232144d5ee1cfe018dab4356ea71af999323efaeb1",
    "AWSSES": "cec35e72190907b8017f856450f0c6632eb99a568591e2231586df08924c6f8c",
    "AWSSNS": "68ed21388a2c32bd68ed0b2043de7c732ead348be3881baf57e0b9dba27e5a2b",
    "AWSSQS": "75f0073155465b57fba06ddce4858bc5684aba9573c7e1b7e4ee112f4f673fa6",
    "AWSSageMakerRuntime": "8d0eccf73fd7fb570305399349a9e584422a018586584cd151fb3ff4bdca0b43",
    "AWSSimpleDB": "973b0fec5aca4841ca2b4a0336ed0856aedf87112349f3f7f84371bc4bb63127",
    "AWSTextract": "85107a8a148ddc5d77500e0aa35f843d724530f04168327f700785c428f145c5",
    "AWSTranscribe": "b3a0951c35960a3314ab684569d9b533fa4e605e37699064555dc4c2665b3783",
    "AWSTranscribeStreaming": "bb11ff47e5f2df1163f449d442cebfc7ad341d38ab7a57b23c271d5db22ee4d8",
    "AWSTranslate": "26109084aec8238bf395384cb2aa1a581f03c762650f6b77f8fabedf349d58be",
    "AWSUserPoolsSignIn": "d24936d0b64233859e4f5f1261c1de4293db2f88b9cf10371e0c106e6329c68f"
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
