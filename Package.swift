// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.33.4"

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
    "AWSAPIGateway": "bee1ed9cf0baa4b08776d864aea0b7e7f9ca782c23fe188d722d39258daeb610",
    "AWSAppleSignIn": "b26061af3f4c645178995cadd11abf90807d05ccaf6af2fb5707108ec5aa4d36",
    "AWSAuthCore": "2ceaaa9846e43369b206dcde2fe561024e4d8c619a131ed2847b880f087244dc",
    "AWSAuthUI": "85e1bb2be41ebc2a2bf5196534582f3e13e7d835add751d1cdfdaf0ad6b21a56",
    "AWSAutoScaling": "73c55332e621c68fd4fa26e8b1b5a449c5e40d06e7924142243cad9ecc7eea74",
    "AWSChimeSDKIdentity": "40d0da5a7deac456afec7a4bb61b2c7cafda5433fe4453020104c289a63059d5",
    "AWSChimeSDKMessaging": "33c2dc28ae499166d69df84e7a3543d37a53125e0875595211416b25b8a9c2d1",
    "AWSCloudWatch": "397d40c396cced44b83753fc265c562729f55cfbc377074ceb65bd1261bae6b6",
    "AWSCognitoAuth": "78fac96588ce85ceee5a8d01155650b1d7c5ba22bb17810273282dd94fc922d6",
    "AWSCognitoIdentityProvider": "f609fc45fc91c4133afcdc178907e97bee46dcc8cd109b219a1a282e0517a83d",
    "AWSCognitoIdentityProviderASF": "c8a5282de8691c1c0f909d58f5c5609bb3db9cbcbd74d01b9ce68bb0f7049cbf",
    "AWSComprehend": "2129aa544fef8ecf83ccd21b92888a3337a4a9220bf04971c8f945ed8be598b3",
    "AWSConnect": "c285c456bbcfd950be7ac79ec988e1242e963fb0a8c15f98a6eba75c2d00e5f4",
    "AWSConnectParticipant": "264c0c9d07f72a59a293bd3802e0397957e7a56223a8715db5f54dd44a80239f",
    "AWSCore": "b89a6fb2b51c4ba3112a1d3f17e5de7104c7c11dcd5fb275f6378a80d74a62f5",
    "AWSDynamoDB": "7b512081aea0529157c78d1692a0d51b1d96f1379ac9af1ad0d24e4e1630f6cc",
    "AWSEC2": "bbdbdfa7105c2c6c985e75b06f6baaecd5d0b624224870695048fbd54ce92ebc",
    "AWSElasticLoadBalancing": "0776cb57bbe14c6794033f5b60f2ae3e016ff4b14b49ea14e703883b14c594d7",
    "AWSFacebookSignIn": "d03e4262e31b99a6b12bf211b242c827b598975fa3c93080f840e3e599a65d9f",
    "AWSGoogleSignIn": "8072ca0beef0dba64f45c13b55e992e0aa9d58fc5de2a5b1d226a08a469465b4",
    "AWSIoT": "073e290802b8fc3136fd8edece269164dc6c2a358b5f860df6f7839a1441ee50",
    "AWSKMS": "0a107d094eb241afd6cf3a8561f61e8b39b40a60fe3d2644d56ae32c8fb7b9ff",
    "AWSKinesis": "04bd00d7c11394696c42b3cec72cf4603575363eebee6ebbbf5302c0ef9ad2d9",
    "AWSKinesisVideo": "9fb1dedcf5ec572147c0c253e2d76b0a4c61038b50bf73436d8de26b18fdd110",
    "AWSKinesisVideoArchivedMedia": "3e9321e43241425e99118c513f0cc9b405dc7c90ce13af6f290596c4b0880021",
    "AWSKinesisVideoSignaling": "fdc782860023c7c311255d1eeee47ab6746ac06972f69d33ff2fb4200ae50122",
    "AWSKinesisVideoWebRTCStorage": "4d7da4d73e82d4aabb1a79756f32c55511620e20c46e5b81664c8ae80f3194e3",
    "AWSLambda": "a4d28847fb7efad1499b29890dbab38deea5fe45861e321f190f1c48e615daf0",
    "AWSLex": "880d9e8d448becd3a4b8ad12eff616fe9291b715693462d92d11ee54d75f0dff",
    "AWSLocationXCF": "7bea7c53fdc3171e7688e54342b89e5fefaf25c009699d8cd75bd86912b15609",
    "AWSLogs": "cf5ccf1618aad0d23ca4bba77a34fa96d4ab16c4e12162ff4111ca8816fd2f98",
    "AWSMachineLearning": "f5239a8e81c63923f45612ac47270d41192c707a602b24d9e223109d4ed3fcc5",
    "AWSMobileClientXCF": "b23e091e97689a7240672c4ddbc57b7aef9e9049a2f2900b1c97ae4a379aa4d4",
    "AWSPinpoint": "5d0b9b9cb63be97c1c1be68b50b35f68cf846ea62e60a724959535e8194e80e3",
    "AWSPolly": "93f1d79959e8f56c40cc84a63b38b8a393a89077dfcdf91b19799efc3be0817a",
    "AWSRekognition": "d76a3057945f135591ac81de41b94e3c08122ac2a89760d1c200ad2ef9ca159d",
    "AWSS3": "4ca52cf8d710866eadc637d2ce983f2977363d17fc09d598c7d7db3ef820c9c8",
    "AWSSES": "1261468e0a4988d8dd2842df9001f0d2ea1a30d8990f0c78a28d0cbdc34bb7bc",
    "AWSSNS": "b54a99d4ab227c8fc13223741e3aea374cfc31cba2d6fa079e7a980036633771",
    "AWSSQS": "c64de01c1b1b5104d45194cb6492caece05bbb21207c21347bdcd17501902f0f",
    "AWSSageMakerRuntime": "799d59147ec71b4600a0448e8fb41954efc40efb52277c6f9965a2f1968c66e4",
    "AWSSimpleDB": "e0ec97dda27106cde9f615d60c516b331a31f3739402666093784ac63c7317b7",
    "AWSTextract": "5b6cc0187e06cd2720d05eed3bd359a65a7fa5d6cdd9bdce58d17a31b20b32b0",
    "AWSTranscribe": "415af94fb5b0c509d434acae7fe9ed8e848465a7e5e615d0368fcfff468da72f",
    "AWSTranscribeStreaming": "0a62c9a94b3f652e98d9780f8f6b2c363603f5e5d7fff9985f6747b0696b0a3e",
    "AWSTranslate": "b47f552ddfd4a69b01478b97fd3ac1ab57330b2a84d7147389019f29d0a13a76",
    "AWSUserPoolsSignIn": "bcde3455275f5dbcde8d210fc7f9a18e1c8fbd5b45f3b063c6b1c1d2b9480e1a"
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
