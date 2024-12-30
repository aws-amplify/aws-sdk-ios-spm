// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.38.2"

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
    "AWSAPIGateway": "68282f61671e5c893d0b736d71c4381674b9f211b14593d0985a5a2ec66822bb",
    "AWSAppleSignIn": "9ff93f84eef2c416322a948933deee970b954eb5562250d043ed19e72f520cf2",
    "AWSAuthCore": "934bbff288f8ac4889e6842c88bf3a8d62d20b3d7046a0ce77115617997b5325",
    "AWSAuthUI": "19aaa8e9514df605230921f73cd033e1b94ef6595986f10a8c0e711631728f56",
    "AWSAutoScaling": "30bb4dcdf80df41de06b13d618643f9d9e8a8401b8e56fd861a72dcd06ff3bad",
    "AWSChimeSDKIdentity": "f02d4ddf61fe7003884633f4674c8beb6bdd06eccba347837270d50add491cf1",
    "AWSChimeSDKMessaging": "1a81eb7459043b41d362e22897aed1b5a0404787e033a0c6a0e794f4cd730dbb",
    "AWSCloudWatch": "0b5d7f0b63ea3319c5322baa1a875ad73838b54b708f575a74eaae6dfa7a7c15",
    "AWSCognitoAuth": "1d8dcbfdd60e38af6bc4d3f8a7f7b4d02c79327a6cdf70499db88f967e3f1b68",
    "AWSCognitoIdentityProvider": "fe81cabfe671793eded48f0de9aaa5f188925512cefc6281d2766a7092acf2a6",
    "AWSCognitoIdentityProviderASF": "cf32e29ef3a1065b005b54e71280d58f50506423583dedc65b690808b2996d1d",
    "AWSComprehend": "bc93bedb6c8d114d6b0920141010dfe5f7d04819e1f9da931459ed82a64592f0",
    "AWSConnect": "83540c87f0ada9320c93e36483bcd505f994dd800ba1adff68459ffbbbae7cd8",
    "AWSConnectParticipant": "81805b7a5c070bef90307ff55c159bf849e16b3fa6f783f95e5213c64af4fde4",
    "AWSCore": "f7c43698d51d3dce41311b1f0116a2de897d88ac94a8a4d17dd5d7ce08a0d577",
    "AWSDynamoDB": "f194be4deb74a218f094810829c5a54907f4b486381ab9afd529d056dbb0b318",
    "AWSEC2": "bce25ef622b2bcec382b331545517af37c1f49fde4c4354681ffe93846d1fa27",
    "AWSElasticLoadBalancing": "2d6ea80b79add3d8b6ab005411e1c0f94d07c59cae2af6b7c6df81201a548760",
    "AWSFacebookSignIn": "80b5d801a8409f5760a80424572e54d915fb2184626f669349b8d7d7ca9acd72",
    "AWSGoogleSignIn": "9aab711a2db3a5ebc9b3782a5be02939010c39102d840cd20a7b6844e07a7ba9",
    "AWSIoT": "e90b054f351b5f83c4ec19f58868742f9c46684a757b41817f7ec01d3ad97db2",
    "AWSKMS": "c8dc1a84c1528c3e9b9035b04acf647b7d517634ada3650e3819d9757f65ddfa",
    "AWSKinesis": "4de97f90fc2797c5f7a7e4b9a932c01b3e9c83d377e2281cecbdda63f5c78404",
    "AWSKinesisVideo": "e230d727a9696293b8de23649fa0388a917910e1aa87332f3c7f501ee38c9a88",
    "AWSKinesisVideoArchivedMedia": "d2eaeacaaf62281db537eb2d6c850b032b5822f2f54d2e87392a096a7b95e7da",
    "AWSKinesisVideoSignaling": "916ef2b1a26676b0b68f7581c7b5b17222bf23d1b315ec7a614eb803c27655c4",
    "AWSKinesisVideoWebRTCStorage": "beedbe956b90c11c5c0bb67be05110eb269c910f39c4686744e7415ae00722e1",
    "AWSLambda": "ae1b7dba9e2e7e0e2e3523dcd9ea8d70bb6b0cb73ca4a599323b80bab2f3369e",
    "AWSLex": "b8c9cf5e257133cd36e93428d5cd2c037cc29534c5b4fe696ef05362101fa129",
    "AWSLocationXCF": "429184757e20535449d852e407c8ad60f6d72c9a1f87edb7c86d48c23d26a7ac",
    "AWSLogs": "561c017d03f0869fcf07686396643254d0af6f4a11bdbe08901b4fcd60abc908",
    "AWSMachineLearning": "4ff4aa4174577735de46b4d58eb3d57633a09e33a263995af87f9e443ef6425a",
    "AWSMobileClientXCF": "55af3b5acd5b139df78105f0003ea17fd60e3af6c4105bb0fbbdf7373deb657e",
    "AWSPinpoint": "a170af773302686c8e702c8914cbbd198113faead613bede27df02844fcda2e7",
    "AWSPolly": "d77f84343a621a0c8e2197a3caac87950096bc630801b279bb6d91c3c47fa885",
    "AWSRekognition": "d687f042b24f64ac7edc6f1720ef7e4bc436b468fcfd64a20b385be251663a1e",
    "AWSS3": "07328b1c3dba7b5ddb10c627e9b7ee1175d6583930bed249538d93ffb919d0a7",
    "AWSSES": "0268480aceff0bb7d277e98a79d4129efeba8dc3881c9a0c238c2a8a0197c4a3",
    "AWSSNS": "77a94b90f83445bcd69f3f2c7553911dc774037c52de28e7d6267003e634e746",
    "AWSSQS": "4ba6a9e23716c1735363f1fcd24b9ad120e21c9f2b4d53440f24986eb8d877aa",
    "AWSSageMakerRuntime": "283d15293b3f9f2de20ff2f350e14db7debb203f0095333a9f07b069f2ba8850",
    "AWSSimpleDB": "c6e3fb851f3c1789660429874ea21771730990c7419d4d47e44ad348a5df9c85",
    "AWSTextract": "5b1ef7c901494b30e060bab237d726d7f865c2a302f78653fc0372c2211cefab",
    "AWSTranscribe": "a113aad8838ac21fcc3defbe03bb83054d3c65b7f77125918e24c22eb97a2d94",
    "AWSTranscribeStreaming": "a279d46a6755025f32e78bbb66b51fef09b2d3e9ce1f0bf6381d5b3e276e2dc6",
    "AWSTranslate": "b743808685ddd2e312795ebf5ee67fa2c0dd6bbe7ddc34e70b8e4fceb51c8ff6",
    "AWSUserPoolsSignIn": "6183955572a36cb68ca981243750b1f9a04f7bccca0b7d6041750b8c1df4a897"
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
