// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.36.4"

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
    "AWSAPIGateway": "a1b5a7bc14aa4b033b304f161c4fa373dfdbdc1941724ca7335629d04fb19c0b",
    "AWSAppleSignIn": "e2c3eedee44dea31e3c478f1af735037a0d7bdbfb1b397030b9f70ffb90483d9",
    "AWSAuthCore": "905ac59dce480a252a1e46cc1dfda98b528f55a4763b8eed4874b31c40ac4b22",
    "AWSAuthUI": "8dc14423effab8353e36b746910e9bedda1cae100193423994744477c2908812",
    "AWSAutoScaling": "4f174d402edfba1b1e159b49dbdae7dbe84a34f33b88647bcd741af7aae4cead",
    "AWSChimeSDKIdentity": "6d4c843bdf04562078be18b58a257624d639a458ae262895d5941d5f075f9e4f",
    "AWSChimeSDKMessaging": "92989a42127cae4f16c5308257e14ed0ff1860cbf0acbf94285d9fcafa61f770",
    "AWSCloudWatch": "8418fef3475685063fba78368adcda3df7b733b2b307d4f4bbef2e8366f68782",
    "AWSCognitoAuth": "52e305e520891f4fa1023fd2cbf2b7c1917bbeac67eddd0a4351c8cf87a3fec6",
    "AWSCognitoIdentityProvider": "740e51cfdc2654a69599b24d9bb466412140802ae3694de530bb6cd09a1b9756",
    "AWSCognitoIdentityProviderASF": "04e642a5bc943191a86aed9361ec9b7e7690f4259600471fe5568349ef97ddc0",
    "AWSComprehend": "8291d878c4366847579fd1041669f497bdea6da9e208f33e5da3f3beb35b81e3",
    "AWSConnect": "4de682e4b11cd3b21825b093826adab0984f2f319513a97f5bb249c18a5e8657",
    "AWSConnectParticipant": "258934aca8861fda220ddf80245029bbb6e5c2a449f2a734bbe9582d6b797f9b",
    "AWSCore": "2e0f21791710605e0a398ebd7f5215c41417042f9a5f05c7640b50a3532a10bd",
    "AWSDynamoDB": "f527bb77a80665e7d91c7ddb6b6ec89c9a10042b5c963efd9d1550760d9d0075",
    "AWSEC2": "69d4e7be6ea5a9c151b3fb2817ecb39706a474b38c7ecab6cbc640b1082854a9",
    "AWSElasticLoadBalancing": "0a80cd0c1da5679e2733c3fd53ecf0a1946bfe95114b9edbb5695140d2849916",
    "AWSFacebookSignIn": "06c094790f35f9bef67c8c63be9bc403b6daf70590be595bdb2b466cba352f56",
    "AWSGoogleSignIn": "326af1cee413bf29c56d7aff3282e14abb3f390b201908c7c42e6cc43bf5f6eb",
    "AWSIoT": "9d5d71eac519b749dcc4ef34876d1d28e4eba9e38cbe259fdb438e76fa0bdc62",
    "AWSKMS": "2777e4eac48aac372afaea1bd398c4d840b925396fe6c2600bf7955905e06828",
    "AWSKinesis": "4c6ead1f0b8ffd31e556badd60604dad94a5236cbdd710185a9305dde306d13e",
    "AWSKinesisVideo": "a167ff4de56da2b3c8c8998d264edbd3bb7a1a174f4cc95bfc03319cddbc618a",
    "AWSKinesisVideoArchivedMedia": "6d9fb361d866203f098d97459c7ec1b13543e90d4e9a3f6af59ae35d21e024bc",
    "AWSKinesisVideoSignaling": "94fb3039cc7ebb7c3d0ac4139a51bae9406273e91dcf23afb55d2776730eafac",
    "AWSKinesisVideoWebRTCStorage": "78ff96864f668a4f72dea39154650e716e9c1c850172fd1c76da1fce735d7109",
    "AWSLambda": "1d879882b8beea8f3713bd105a010a6465a1f74a19414f747af659b8ad4797c1",
    "AWSLex": "f5d227338afe04eda867b0fbab6d49b6b962aaf5b8387ba53293cba343720226",
    "AWSLocationXCF": "7111a8f393ddb6409c2aaff76c8bb1d7b030b4ac79177d9d5cadba56c257710a",
    "AWSLogs": "db6944ed8d7b612ce7cd9030f62d030885f908c1cafd188ab9bfc02a2d61c705",
    "AWSMachineLearning": "9966ce35082b20ec341671bd3f90cd7b010106aa541e3605e98e9f9948c91266",
    "AWSMobileClientXCF": "5273c1f18020d3efc19341ea1ec2a4ae4ce35cbfd2dad8b58e0037de7bc9725a",
    "AWSPinpoint": "04220ee9a92c7d1a1c5f9d76dc195d628d986172bb04a54d6c8dafe2e2c62f9e",
    "AWSPolly": "6da15ca1a4c5243339dda36f8495482414cc72347a019ac55635722d44b67449",
    "AWSRekognition": "5fc383cddaa36dce980b40881818ac3932c3f3a5c383646a63d363e8dc23aa8c",
    "AWSS3": "282731977b721863b2bed25df283d66613adb520b631072816d8d10caf659c6e",
    "AWSSES": "28744a9edfef1a3dab9cb88660d22fe5132b888eea5cbf6b6a1c91cd3ee80b5e",
    "AWSSNS": "9129f8fa55c0f5fb3b435746c716f65f4e97cbe929221d4e75325e30cc486304",
    "AWSSQS": "e911dfb105df0af4bce0a197488c40d8102b35437f55c608df44188c33afcd0e",
    "AWSSageMakerRuntime": "8aaa2f2fa6b3322acdcbed87a9b8b656701e6f62662671a019abf24aa564d325",
    "AWSSimpleDB": "53052909cf6cbc60a0185b4f76591c0c7920512432fe5a30f2a378525bd50b9b",
    "AWSTextract": "aae8e7424adc4c85be2eb02c6ecc8119fd388bea15b5b2647d131615b2c7ffa5",
    "AWSTranscribe": "4e190b50dcf80c33fd5a0496d078763c8b220ddd791916935af85e0bbf6b6cbe",
    "AWSTranscribeStreaming": "fd193f67a6f370af8ad46d0fb77c7920cb22e6c75cd5b0993352b7ba2f20ca3d",
    "AWSTranslate": "753fc4f5848c9af8d53b730a8536b923b8ded8cc5dc78fcc91c735070ef906d7",
    "AWSUserPoolsSignIn": "50fbcd0173e1ac96fd1c951f2b5cb1cd63cbd727fe9d7500058148c3f7cf6d49"
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
