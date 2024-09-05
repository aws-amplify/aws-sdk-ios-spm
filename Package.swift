// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.37.1"

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
    "AWSAPIGateway": "0534976faa5e521f2695b85f6c65cf59aef3c52296ef37c893eaae5059a74a44",
    "AWSAppleSignIn": "3e9195689b13ed16ea61d38b508c25c4206303078219c792e590b22ef8db8539",
    "AWSAuthCore": "5eb260f92919aebf0e0d5962e903a1d4712efd78cb500df6f2d54e11cbeea291",
    "AWSAuthUI": "565cc3452f3997fead292fdb92e30b6dadd527a5eae7511564bf9a840da59e3e",
    "AWSAutoScaling": "16574b30b8cdcb6fdadbcd4301a2598fe341a7da7097b097dbe9083b91db4f48",
    "AWSChimeSDKIdentity": "d703417fd5d62f090d9ba54a2fad09701d95d95c5ebe4d2facf625ac291ef14b",
    "AWSChimeSDKMessaging": "477b7173eaf98d6c81ce0570d0723fd6835ca8f00effd5ce3fc2946d5c09b8cd",
    "AWSCloudWatch": "5661df36652b69cc823a464279654c0375f335b5ef364f18db4c7d0535c1a359",
    "AWSCognitoAuth": "a0a5d37958922e8877fd564ac8562f5b737ca646a035044deb04a25ce7e76f88",
    "AWSCognitoIdentityProvider": "2459c0a44e0e7ee706493478a967d481af334be10dbb73c7e9148dbf7b73ce2c",
    "AWSCognitoIdentityProviderASF": "27156eb3c09ab6bf0a082316c2194f83e7c0c890f9c1ba93341813e1115b60d3",
    "AWSComprehend": "a4b4c73dd1fa21d9bdf8e1efc43a7c271e838d715f840382ba167808a18a2e7d",
    "AWSConnect": "00feaa248d2088a85b5b836c8923a7bf47bafc640c2c7563007f148bafeb9f4f",
    "AWSConnectParticipant": "f8e59a9289700a09202f13a1db6007490f18c3e9bbc1b540565fef2820a9a697",
    "AWSCore": "d5447fa9aa26d62a468dcdc24678654b92b6b21a702c195b81188c3fb32ed332",
    "AWSDynamoDB": "5d2c87f8730060f5a2cf28341505159baf51685003780076261b892bd44388ae",
    "AWSEC2": "dca53989b4b9cdfa304076e0007a68f6817a71164955790502d469ac588700bf",
    "AWSElasticLoadBalancing": "a608c6475147b7713411cb9adae0977f19883aa702e1dd931e1d7b280fe920b9",
    "AWSFacebookSignIn": "198442871dfca1c8929df1437839d55ea8edcb73f8c8e85cbcc9bf9d85efe2a0",
    "AWSGoogleSignIn": "11c83c98445537d45d30058c0b341a05452b8e81dddfc7b99cd6e35848b791fe",
    "AWSIoT": "d43faf445d3c1a33671151c712496976484d3f051d1f47b1ddb7bd4d1e1ce665",
    "AWSKMS": "68f3cf9d0d339f0b6f8c23bdf17f9a73822f76a4cebcbe0a1dbf7124a2af004d",
    "AWSKinesis": "4e97521bffa3b6c4a40e8568fad0b55cdf0b32b12c63cdfb936f1416083ac233",
    "AWSKinesisVideo": "32eda4f027b0075298cb32d4f2d75655b8c7a5b703cd312f70dc42e55fec1b48",
    "AWSKinesisVideoArchivedMedia": "fb7f0a1e0fe2b1b15d4827e48c34a68ec1c8771e01d80e518efb38a1d30182e2",
    "AWSKinesisVideoSignaling": "bd30046b2296ace3f1542e85e3c37e854826add7d54a553a7e22468c7acfebb8",
    "AWSKinesisVideoWebRTCStorage": "3ee7bd8fd26525e02056d4356241a82ed1b0da891a9c9c318f59b15184521711",
    "AWSLambda": "5a5d793c9b9f135d4996cff8be517ef7aa0a998aabab1565f502522e58b3abd0",
    "AWSLex": "07cfc5f7adc6d95eeee622cc5b8f3cfca39cb424dbbe279a55bc2b759537a913",
    "AWSLocationXCF": "7cc5c9417af175f853870484154a9057fe35250f2d261c663e6ac43e5f06e603",
    "AWSLogs": "0f2ea89935f273af9874bac56f510096b3971db372c13ac318e609b650cda4ad",
    "AWSMachineLearning": "7ea46c650d720f24f96d8b2a08aab57731b4e3a93286d3a8943edd414f9e785c",
    "AWSMobileClientXCF": "18a5c87c85708ff0ae4f7c50a697920b5b2b51ddb7069a551e9077c73d01da97",
    "AWSPinpoint": "07defcf123509406a0a6847b9919cd2430b71ac326cd1a35db4ba8ccd8393de3",
    "AWSPolly": "662793f6f0265114c52dc1c7fa891eedefb9b8f859bad9db796e2482ab414324",
    "AWSRekognition": "0e69f591a9e9cded5984d91d7fff05c965f37f38c7d2e3c07450288b61aab91c",
    "AWSS3": "e03b56fd65e4adafc50113ab8e1b18666edbff5c17acbbed11e3bd6dafa1cfc9",
    "AWSSES": "5b603cef1b05c2fa399ce051f14f7bfa533ab0a7c41be193f1b36aa67bf7aa40",
    "AWSSNS": "da941172c94615d3605aac056ab419c22141f42e13c5c8d16bba264e23267adb",
    "AWSSQS": "06b9260eed374288a2160fba904054377b2adafd8f3312fa805c8cfe3d04e1e2",
    "AWSSageMakerRuntime": "c6b50a3fbe751719d09c5aef256c9cc47e75eda2b9ad5bcf2a71c5aa0a2d90b4",
    "AWSSimpleDB": "4f7c76dcd1a133789991413fb53cec284389fdf781a3c1efacd448e9be3b77cc",
    "AWSTextract": "24e11650d014ff3f8dd78abaeb13d20da03140749e91df8d73db8c5de0f16e0b",
    "AWSTranscribe": "f7f14f11bad933d5dc1a79b768f5fce212b3bc1b8c486e0122028984408ef2e8",
    "AWSTranscribeStreaming": "2e8ff9f429b4e2e144c0d5a4ea6900e16adc55f8980ce558cc70ff295ef943fb",
    "AWSTranslate": "fa80590d598915f241156832bfdab6a6b3a832557cd95e2208d415b485f08236",
    "AWSUserPoolsSignIn": "801750f0d6478369df52ed31d573860f7f2629913d3cdb00b2bbc6aa19bf8635"
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
