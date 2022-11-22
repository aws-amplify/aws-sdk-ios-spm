// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.28.5"

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
    "AWSAPIGateway": "2474edb268a8e1e64d9b7405526ce3191d825520ac99112e9538666e77b1223b",
    "AWSAppleSignIn": "6b14f95645b2213606ac4b329e1296ba0f393b41f943e8b547ec935a80f487ef",
    "AWSAuthCore": "cf3380c3bfea6c3ea392deb1aa2a5de83103c64ac1fe224b8c010d943f87775a",
    "AWSAuthUI": "9b4e714843c7e182bd7ed197ebce141f856f27b1afe8feadae422cd01046db9e",
    "AWSAutoScaling": "669ea341dbeea586661d25e17517be1359946a15e8f0dff614b75262775f8493",
    "AWSChimeSDKIdentity": "c8f9cb1f002b97ed4d6b1864d4653dd0f6a96cbc0fd246229a686df5b6580a78",
    "AWSChimeSDKMessaging": "e3949a1113b50b8df2d68eadaa65f659552493f10e319e6df744ba3322b702ae",
    "AWSCloudWatch": "9b9da28c525adb46514e2a861b202dd15d41915af86ec0708aeefafae63fcc48",
    "AWSCognitoAuth": "f5ef31e6f74c8dbffa68018b97a9f8dd9c364fbc24635cdede97c9bdae7244b1",
    "AWSCognitoIdentityProvider": "5333d4d076c7c7d700077bcaad0985303855c03052a19b55aa7f9eb0302563db",
    "AWSCognitoIdentityProviderASF": "ad6bff706b167a778cffef990e94cbdddb3eb06ad884bf3403c0d931bbc4d754",
    "AWSComprehend": "ef04d7a65cbb2f9f94604fee4e8f63c7a5d1f4a47e961165231de3c11bec080f",
    "AWSConnect": "a6d575321fbe427dfdc55b74b0f2b3d7a3e28b4e335586666352ba31ec11fec0",
    "AWSConnectParticipant": "5ff387d24c33749e1a1d9dbcba2ef9eda957234a778c1bbc2592a0b1600a8931",
    "AWSCore": "3c9517a4443226bd4721f3f187cbc095caeb2d655f40fdc2681ffc4be02e5159",
    "AWSDynamoDB": "47f8328c948f0428853ed973a47447ad68ab8f9076c1b79196b2af81d5993710",
    "AWSEC2": "d7f058933fc582d45126d538166d3af007c3850288d35b1da9108f4815ff300d",
    "AWSElasticLoadBalancing": "51cfa2db4f2aa09d4d085469e19caa9d34694414a8ca779d0958dc56d4ad9b90",
    "AWSFacebookSignIn": "9fce3ca525e5aea8cd60f4087c214425f023eb11614c334af7589755678e11cb",
    "AWSGoogleSignIn": "d340e42601cb68bb7cb1cdd11f94af46064590a437b25529ad3944fa01c3db29",
    "AWSIoT": "533f9fa01af9daa16511064cb2a91ab0de37112e7dbbf2334543d6ac34c5bc3d",
    "AWSKMS": "ddf36e25e8be40dd92b521c7b321f49861f5aad530eba7408edc67937d12c314",
    "AWSKinesis": "8ffb60cd906cd3d63cce455f57f87d259c462b96eb1d7ea2f453a4b58c37e213",
    "AWSKinesisVideo": "b423754e4763b2c8df6b2e95a45982105c332dc1c1b7f4a8ccf78d5bb7ef2254",
    "AWSKinesisVideoArchivedMedia": "f81d739a5fabeccf4dd880207306803839920066b4a4b4b6d088b5c1870f84a5",
    "AWSKinesisVideoSignaling": "ec41b1b32a737ef721ea40265051c0e94f605845095b25ce3bf4737809129b3e",
    "AWSLambda": "2818840607f1af7b6bcda8a282811fb5a42a967548046cde5436a56a5702bdb3",
    "AWSLex": "3de8d8109cd57b77626319fa6f817278da8a5e279ae9c2fcebf13aea8360983a",
    "AWSLocationXCF": "0f09dd187c15863fb298e87a2d4298499b235ac32950ad26edcf9f3c1b152ece",
    "AWSLogs": "30604d1f79107f479d9d987b83909f062fa3eaedbeb93fdf24bfcf064b390dd0",
    "AWSMachineLearning": "9cae7befaec19ce2f739cc72820bc1a0b229f07658b3207edf627573e9df80a3",
    "AWSMobileClientXCF": "c94816423e242ba3cb2ad8f552b27fe4ffa9553a766b6fe384e56ba8d3841120",
    "AWSPinpoint": "282f99146c3075c5e891e2fe64877559c5a53e3f2423b16bdd5baaa3f8a7f6a8",
    "AWSPolly": "b4f4f57245be24c42ce02c4dfbae6dfc3590382c323bbdb3c708fb8d4cb9fb7f",
    "AWSRekognition": "4446c7a81a129b002baba7bfeba220bae971e33546a3d2fecaa58e3639615b34",
    "AWSS3": "49de8e4367872b7d0bc33c8cde7948caf80b8716472f72b0993cab99776c2ad1",
    "AWSSES": "d3e990cbd77663deb590a0a0fa9e759d454cfa46fd47bf0890776a51278a16b5",
    "AWSSNS": "a650cefe5d52e985f813fc8a9604d1a03dea21f84192e2c85fe7c6aad00a23d2",
    "AWSSQS": "f8c883854f1538fcf76d317067f6f13debd34723e0d507111b54e917169fe483",
    "AWSSageMakerRuntime": "b06508699cf17ba8e9a7ca2bf256595d5ff7f5bf9f76ee5b2c0296d437660a2d",
    "AWSSimpleDB": "8c47245bc615a953687ec251d1e79d7dcbddf6e869f55ca5ae9d363c8ddf0da1",
    "AWSTextract": "ab977ddafbca6805c90e7cec2fc1cb08df1519b117a2e0aba85394f22562fb25",
    "AWSTranscribe": "30a14cef46254b0d916d21a209922b6a8318353d076bfd4f53d596ddb060c228",
    "AWSTranscribeStreaming": "41e7e0334f7f07a36c392d50335238115e511e4adf1d5e15c220652a08129935",
    "AWSTranslate": "9ac7a501d6d31dd9247b730af16c65de695cccc3d50777dcf06d137c86117e6f",
    "AWSUserPoolsSignIn": "23822dda38d642f238aee37aa79351e5e0bd49b893969ae164dcdc50fc14f51a"
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
