// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.35.0"

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
    "AWSAPIGateway": "66ed4608c2cc3bad562fddd4d02f7527bbef48716999e01aa0184c420181cc97",
    "AWSAppleSignIn": "a53dc777f12af8026f058f26682b640be23ffa7c6da52133d4aefaebfa0631b8",
    "AWSAuthCore": "f4f8fce05b4fa0706e7d073f9f00359ef70f8fa3bf43c2436bae49e548398344",
    "AWSAuthUI": "abe1a6752464235fdf8e0d5297d32670553e786097403167a1d74ac8ba6cda9b",
    "AWSAutoScaling": "2c419ddb45b0b3dbdef4a661e4dc65dc71dc671b9a8c79c67fc26bbdc9def3c8",
    "AWSChimeSDKIdentity": "3dc0c920dfb1d1fa266f3c9eb64c1f275a607c09de0d0721acf57e7e2aec669e",
    "AWSChimeSDKMessaging": "85893b9c6b072b2711cc60c4fdd4b5f0818562811d25cc1f46c517448497bcaa",
    "AWSCloudWatch": "3570ca333188c36a9fd84f233c38f7864a6930496b89bff49148ab1f79d4e349",
    "AWSCognitoAuth": "ffac5d0301be795e5b8a022b4429e04dc41e160752f29f21c7fb4c3ba69b8e6f",
    "AWSCognitoIdentityProvider": "b20bdee6c39320cfdf61d2e6e71b7d7e09679b823f4db0b79afb6b18249b6777",
    "AWSCognitoIdentityProviderASF": "a00ad17fead8d7e1b98ad616c7c96d52d827dcaf0e799102e9b01091cdc94130",
    "AWSComprehend": "9e003959c6a9886466db78d90f425480688f408dfebe8306639b7ec4f4b1e04c",
    "AWSConnect": "4ade9438e8f4a4609bc220f9c2aeefe18a66206985137c4522af4f3b9fe80f38",
    "AWSConnectParticipant": "4b67baf52038070a9cbd64e0d34ff1fb4a04f40cb7193e2714f4911a2123a44e",
    "AWSCore": "e8ec532558377372fa20030e1543934c5889291b2c7be1f501cef47e53071643",
    "AWSDynamoDB": "582d8ffd2b780a30a9a59dafb877215a9c483f4829de6c407f37e1b1db556797",
    "AWSEC2": "5283366c596f8e000d1e7a19da387e859470d0dbaec9ae2456a1a9b7c4a94260",
    "AWSElasticLoadBalancing": "c38cc06cfb4301dbab8353d3528aafddbb3e067d4512313916f7dd83d7e2ea00",
    "AWSFacebookSignIn": "a134752d06d562c8ca61973b12c162aec748454a740c50a23e4b2c74b6fb37db",
    "AWSGoogleSignIn": "52146a47764592a842dcdcd9bae4055c4d7c42d6afca8a1903fe589bd37d4bd0",
    "AWSIoT": "b8c18bc8a37dd834dd5b5835c8d9c1d30ce50e520009efe86599608b1db61a98",
    "AWSKMS": "69407219710c1567c8b9fafcb8a6922fa9eacc6ce19224320f5127bd5582f8c2",
    "AWSKinesis": "634d83e064712617c1feb21d1250a7bf3b5b02dd5531842d265612919eff36de",
    "AWSKinesisVideo": "05b7d418b87a11f2a65d6ab38aa515d024ebadb0fee8cd65c62a0ebd671c6bfb",
    "AWSKinesisVideoArchivedMedia": "06b505bf7117783e0af6006e7a4ec89aca4316f9e6a1e4d9613d7fbaeaf0efa9",
    "AWSKinesisVideoSignaling": "c7b90a4a8de419247210b422e8fc077f1f99de6ffc52127fcab4318a0e197c11",
    "AWSKinesisVideoWebRTCStorage": "881699087f10763bf54b81923bc140d3ea1b64634d3a43d0cf8c91070efb661d",
    "AWSLambda": "a3b706de5b04abce1c8165f9ac15214db283305c3976d72a79623896f01d8a76",
    "AWSLex": "079224104d7261e6370fcd9197994695821a5f806f1a3d10f0ae0b67773040b1",
    "AWSLocationXCF": "6977399d53d5f94cc320b5cc83cdfd1d7b24ec6c5d5a411cf4a9e58f099a4992",
    "AWSLogs": "0090fe3b1039e792db6f22a83e42a1c77798015262515b2e83e798d7718f92dc",
    "AWSMachineLearning": "98721c23ad0925e4cb8f8cf2f1ad24b8d3cbb6d28e0d5f85fd91c87f8ab85f35",
    "AWSMobileClientXCF": "80fbb3a29dfd5e13b4e73e28ce506cfe8b471e7a508d24a329d720af41e3db3c",
    "AWSPinpoint": "acbde38cd4856f54b0c19b0cae878f69723fad52cfc602113f3de573f0547e3b",
    "AWSPolly": "f9ffffa82b282548202459bbdebec1a33b40369e80342361ba5ce1a4a0eb689b",
    "AWSRekognition": "4a481737d72eb9e30062c0591217616564f0073db3a60771a4577a2615c73338",
    "AWSS3": "febf5fcac479a27660249d3457310b0165003aa4615d43044ebc423fa9742463",
    "AWSSES": "34311b387a41b6a4733be6c2f56ab7dee724c4aea2f4328688fd6dd14e6ba144",
    "AWSSNS": "7f3cdcd018e8d5a7b6c6eeb9b19c3eabb1d5af8475eb227134fe6760545db520",
    "AWSSQS": "cb27fa7079c2cda08d78a6d268d97e21c8e095cb48fff6ef348361d796633523",
    "AWSSageMakerRuntime": "b46c19843ca6ade59738d7a15676400be26e18009a9fae96a369dc3a1f696c23",
    "AWSSimpleDB": "325615d439a939002c93b8f869c72240a2dc1f62aaa9d09fafe91924cc07a298",
    "AWSTextract": "8cd5f4ad47f17751720b401fffa3c7f6adfd258d220606fe2d0e51988af45e8d",
    "AWSTranscribe": "e0dd8991918605382b4c4f0d3f019c4e6fa234fe0b8a1d6301fbd2faccf6e815",
    "AWSTranscribeStreaming": "9d91beac6ce47b9c07d54e1a9aba7d17a716c4b71d23c9c936a2d799a5154529",
    "AWSTranslate": "4db4ec23596a6c5856498aa17979be98611335cadb7ede62645316e38a744054",
    "AWSUserPoolsSignIn": "01f45305c178ddae7d097a0c68ff3ffa3a5ee726598d90d2cb0436b93e254f40"
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
