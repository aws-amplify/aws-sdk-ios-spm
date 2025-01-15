// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.40.0"

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
    "AWSAPIGateway": "e70afc2be48e03c4b1f4da23c3107e0bdd80237cf0dc7488827f3a7a34bf4d4c",
    "AWSAppleSignIn": "2b35aa4b23a3022968ad4c3424ae4a097a16926ac4cff685f429e6b6bffd1eed",
    "AWSAuthCore": "ea404465dca2743eb4a66f2de923539e8548cf79ad70b93e34ee8574b0b3cde6",
    "AWSAuthUI": "07dbf7b4ef649df59946683db4002246fd4f880fc059c5a45b28a9d6bad6d9d0",
    "AWSAutoScaling": "f6ec60fbb23ee1c7e797a61fd65869e4939e30d5f354140873224ea5cc0c1df7",
    "AWSChimeSDKIdentity": "f570459b0f9e7c71af20bf6f99357f34c99e3178d8309eee8dcb09d5d1c78f5c",
    "AWSChimeSDKMessaging": "5ee6e963d19bbf1be1bcc362e2e62b88cbe16ff959e64696c4b365758b945077",
    "AWSCloudWatch": "1ea39775b8d72e15c001565f2d41fe606ec23abedc115e6023fdc3b0d8cca9ad",
    "AWSCognitoAuth": "2d35d4c11c0e30c8a7e1a9f841a339f8cc761b2ae22a4ad79154dcffc9ced021",
    "AWSCognitoIdentityProvider": "811ae2ef8d0954b2c4ccb4272fa79469d6b8d5bdd200c08661084ae729b70c1f",
    "AWSCognitoIdentityProviderASF": "a239a3a184da3dc5aee03c906721f472aae16d06f95518f5d41fef12132af55f",
    "AWSComprehend": "340d0e1373c1173a679ac98343ec1b82d34de62ac1b7065c710f59c7729e4eb1",
    "AWSConnect": "f75165652d6b8a2ff944128cc49aaa1996e1fbafdfe5f6154e8771da08ef9b33",
    "AWSConnectParticipant": "b3a14204359ebaaaf98f8c9ae8760c34ccf0ddb0aa4b0a7f13a46e94fedf7411",
    "AWSCore": "0508498ba4e40d6e665bc3e14193a79494946f4044c4550bfa0f055274ba3d2c",
    "AWSDynamoDB": "2a6b7e3fa090b3e88440d546987738a7f869be0ccae135d04349283fdbbfefe2",
    "AWSEC2": "fcdee2d63ad1d5989bdbce131e593997030a8090e2108e844ffecb93d2fb5a10",
    "AWSElasticLoadBalancing": "39e15014d95ce5ded0dcea3a4e84ecbe5f30288b2761d16757dd9b7ebc3039c9",
    "AWSFacebookSignIn": "553a09bcba70c32c73b38a5b2615b10e2b50801ae20f9bc157b546b980e8bb01",
    "AWSGoogleSignIn": "c84df6788662e2b2c3822dc5eb31c3f2796b03f72c3ab646eeb11eb024686029",
    "AWSIoT": "67ca9336b667bf82b5c1fd2a7968bd4b4875d6fd40176d7d5d1f42f573d99467",
    "AWSKMS": "c2f0b714f88e6b5a6b48b0fc250240df9b84ee61b49f0c98db2ec5575bccfc6a",
    "AWSKinesis": "679c1636e587ca67c7bf65ea6116b5bfef5979e520651876d0e89bee5700fa4e",
    "AWSKinesisVideo": "29812c853ab3acdb8427c31cbc5b6468200fc07f59a0ba9dca110b4d4e4838f3",
    "AWSKinesisVideoArchivedMedia": "1ab836f404c0a710a0e1dffc84227505cd74ad79fb593ccaac1ccb7b5637fe13",
    "AWSKinesisVideoSignaling": "e0e4d6b872c6672a0144b34e5c6d1c5e90712ff123c6941e2146f89bd5f52de2",
    "AWSKinesisVideoWebRTCStorage": "5f9a3e3d6028760655445d87c0abcc73590cd9883d226769a26ab620870dd672",
    "AWSLambda": "fc491b4fc8e36d5a2242da79b2dbf41fb74280cdf91e535d4744550cd11833e7",
    "AWSLex": "4739ea9ee00400b177e4b129bb775b05578c4b77ef8e8237bb18907bd0d051a2",
    "AWSLocationXCF": "87de02dc69c132b7c98f0273c141ba71f8818b8e4509d4ac41bb72be1cc336a6",
    "AWSLogs": "4c4aff962b2fd6026f377d12bd7316f9db8594948c6711e01a5d60a0bbf65cc4",
    "AWSMachineLearning": "09f64cd86579d77be3ad89624302d223c6221a59c86a76ccd16021471fab64c6",
    "AWSMobileClientXCF": "9be02234352a004d3a6cac4bfc912e500169f4692e78d9357a6aa4cb5a927eab",
    "AWSPinpoint": "4b57f534692a9dc88f97bcf951dafaad918d80ff393c3f37228ff0f3f1e6975a",
    "AWSPolly": "c756c01efcc5ba0a5b90b2cbb18175c4c755362813792c11ef5660654c8bcf5d",
    "AWSRekognition": "9263458a6b9d6a57ed217a02963e408849846c0610af8f6c2f4d3b607e64d4c0",
    "AWSS3": "3c158c24abbb945c87fcb3373fd09fb983db68d8c27788e61489615589ea06bd",
    "AWSSES": "47e4ac5878d5f5f32ef8926061a3695d5009dcfa91f02ff98d4a9b55daf69149",
    "AWSSNS": "4c6af493bf85709bc425a3d5ccc19a94a1b7f04e53669996796ed54ab5dbd23a",
    "AWSSQS": "530ac6eb603d0461feaac09cc09e589a04eb70b57f97a0f77f992cbf4572fb5c",
    "AWSSageMakerRuntime": "f5d620fe2e9ac3ce386feadda738e7f4e01947eaaf21cc167117581606708b30",
    "AWSSimpleDB": "1ce9d9378cd9e674bed70e6f4078663909143157cb4224b0474a7afc056796b1",
    "AWSTextract": "4bb8a12e51d6d97a064cb02f8af5e7d9a8bf69ccba8526d44a8cea8433539b68",
    "AWSTranscribe": "6a0419aea5d3bcbfb331e5bcad82502891dda8eb0cfa77fad512d865fd028db5",
    "AWSTranscribeStreaming": "5908d78b2769ed3beb73ddf9f10ada077748372c675d798ab7bbc38284c9765c",
    "AWSTranslate": "87d394ee3068fb4dee5e91ba3fc3f95dee2f950a087d6e5ddfe49c801334adb6",
    "AWSUserPoolsSignIn": "a2b66a3ce319edfa6836b3d2c1f2d13eeb24c76bf13dc074e16cb779e0e1c11b"
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
