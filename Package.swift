// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.1"

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
    "AWSAPIGateway": "12dcf67137c3d1a87b603c726e0db5eba15be3b3d766931fe581c3243a04fe3e",
    "AWSAppleSignIn": "ebc2fdb50f38673991735f0850fb5c2a48b5a9152edb056533a9bc5aa402bb82",
    "AWSAuthCore": "8d25ac22551b812b9e2692dc17e2ff967594c58c960270d12f0d73e50634bbb8",
    "AWSAuthUI": "3829d0b8630bcef3446dca86d819dc99a1fbd88331d721b816c12ba9c198b89f",
    "AWSAutoScaling": "acb3f6b16c4f733e393eb8533e8892500d1f9bfa913ea2e96150ecb5c7b0ca46",
    "AWSChimeSDKIdentity": "ec0141295c447d87a89276b3eb40e095c28c4d20ce79f02c6002de472c91794e",
    "AWSChimeSDKMessaging": "601bb1f3068817d68bb8b6e455385fde4637226155fdf019f897d1a4be821f7e",
    "AWSCloudWatch": "e88379b3c806502d0a57562499abbf54a67f906cc68b024533a839d1a880e1a4",
    "AWSCognitoAuth": "0978aad91736b5435af1900e40d472e828248852fee7b3d6217e2565b9c49ddc",
    "AWSCognitoIdentityProvider": "996f926b20132cf938fc541e42bb1b5bd44a5af6c2da966edca2fdb0782221eb",
    "AWSCognitoIdentityProviderASF": "e9f90dec90372cec8b3abae79d4fc5c956d2bd1572fb228bf9a47132ea98b531",
    "AWSComprehend": "4462c610defa98551a6a2f7f002b77f6b1eaaeda1f91a637e12a063d83d6693f",
    "AWSConnect": "736abe756b17a680b1c650d27bdd40193ea9de2ffece58a4df2cb64ed22c9197",
    "AWSConnectParticipant": "cb052ff22534e4a170aa5602271baf3abf4e738ffdfd944bfdb91b10e9a2495a",
    "AWSCore": "cf823e828af983e9a73fd959349d8f4eae522329cf5809817ae0ea23cfcae512",
    "AWSDynamoDB": "e54982e91e1720ac9a90395ac5874b4475c9456ddf4c324452ecfbb27a770b14",
    "AWSEC2": "4545e5f35bed883d8fda7d17374fe1361f6a2a746b1a2b283c2bdc4f2582e73c",
    "AWSElasticLoadBalancing": "e23e5b7dcbee30fcb5e87f5368787d1e25da22a40fb766978314725ed2ab2f39",
    "AWSFacebookSignIn": "771c944a948d3a56395a42ef6afc34196c2a9c03a0e755a6612ca92889094b48",
    "AWSGoogleSignIn": "c21916cb325efe4be484c97bf5eca9c77ed6bd9393f8834c1f36f55860605737",
    "AWSIoT": "405ab19d2695464466de1708a5c88ef7167c674fb5c687f6448c0820bab8e0ad",
    "AWSKMS": "223a358368eb74676c39fc3881db9bbc6eba8a7600896453b1bedae987259684",
    "AWSKinesis": "fb2dae9519c94dcefc28f113ae0b0f6d750c2f467458ffff84ccfcaf8d49cdd2",
    "AWSKinesisVideo": "c2fe7edf53d8be44e5a2a867dd79589ce9e14074049fb7ba68225e9c49d416f0",
    "AWSKinesisVideoArchivedMedia": "0d963ac818ad15bc10ab223d15d200b80dc7312b74384c7deaad32c27d80008e",
    "AWSKinesisVideoSignaling": "d90df469f10538b060683c101073d507b67a3992b442c267248852b921fe72fc",
    "AWSLambda": "be76f9e0ab0c0eaff6635a5d2bbeaaf79d44fcb15c2c8fa7bb8e9119d7f1444b",
    "AWSLex": "887375fce0e7731340a724fd0f714c9a0ba3bc9d070661d55f9a9ab99669fa6b",
    "AWSLocationXCF": "ade8d426d03c8d14406dda06237806e9262ada3d5beab8dfea58ea43bb5de870",
    "AWSLogs": "9e72bb9d52845e74897920837662a786bc7d52dd3bc8939bc6a0fbd014bc9041",
    "AWSMachineLearning": "c9981381e4209125f5cdb401c69109aeac1ee3a9da0b57c034a76db8521aeb71",
    "AWSMobileClientXCF": "37bce5d2ad5e8e4381a0efcb4343003cad2699aeb394421240a2270a4f4d9f52",
    "AWSPinpoint": "f75812db8f454f467cc46f1e99bb8118369d17b255cdeac41a26692c438f27c7",
    "AWSPolly": "87c54904f2f255d6eb8c4e566d8c2f4ca8ca921ea09ae06ed50c01b5028172cc",
    "AWSRekognition": "8ec2bfee25390af6c115a2e157a6dc91cd9724ba5a1d38027e577f37491368dc",
    "AWSS3": "9199bc82300eca118704d73fd4e235abaae73f704535d276b398c8af32a7cb0a",
    "AWSSES": "47e84cb2c8d4bf6886863077a14ae2e9037bc087f2bf2bce28590eadae874366",
    "AWSSNS": "f692ccb48036603996649c18cb24013789e1da9ae93b8355f0f6b051a7438814",
    "AWSSQS": "a573e2839e9f9c40a92d6818f3f1b675b6804f08acb744fade0e0e1f87c4bc07",
    "AWSSageMakerRuntime": "f2fa62e77e5c9d299b03dbda9cb344ca136e83e1de51ce2348649256c98c917b",
    "AWSSimpleDB": "f423bb45a03e515a963c75e734dc67808858f5c63e5f9794e0f5b63101c69517",
    "AWSTextract": "878ea6c361a1ddedfbe500b8255684248a4c44f52ea2738b40edefe4008afc18",
    "AWSTranscribe": "e903afcb2191228e7d76374e6af89ecbcce50326f2baccb273a81a33e2122052",
    "AWSTranscribeStreaming": "b4becb90971efedcf54221c8526dd560772661f361617bde1466cea14d28f9aa",
    "AWSTranslate": "fbcbee2956127aa56278a776df124b3bbb01e8f4aad908b005f9f2e757a2d797",
    "AWSUserPoolsSignIn": "d997eaa6dfe9368ed3e8ea3911ebd5ad2343db8dac811c6b0ea36c82c080af66"
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
