// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
//
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.40.2"

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
    "AWSAPIGateway": "6c5a3d9de02869fdc606e129ea16a59565b25225520b86fb5bb02f6c4618328e",
    "AWSAppleSignIn": "80ce138442a3e7805d8e98453938219a97999db10a204a2a47d1cd29a2a2426f",
    "AWSAuthCore": "984c65f204d8f700b7ae62b7aa936d853b146d3d037fa56ea01e3f00cdc60cfb",
    "AWSAuthUI": "51acae8443735f545e8e36ac35ca735ee921bc7984948f0026e8eacfa9f12199",
    "AWSAutoScaling": "834dd9acf585077fa205debf0cdda7785bf7c565cae01240d6fa9d9587293dff",
    "AWSChimeSDKIdentity": "233e101dfce28710f5eafb15be64cb5202804b7a9fe4523c99dc2daaa86ba0c6",
    "AWSChimeSDKMessaging": "b6a9d0f3ff32c9f08e296cb4207732b792abf16cc8d3e50ce2eb49d3696df5d6",
    "AWSCloudWatch": "4c8158abdc75e4cf42bc8a05d6b9e903491e08f9983d941b47a3c24c0c9ef19e",
    "AWSCognitoAuth": "a482897a26bdb14c1b992bd4f7ae2cfc5c2817fed6c236c9a27a28a1490baeb7",
    "AWSCognitoIdentityProvider": "a589f27404ea54062b4c9f75d5c9b02e303b733d53f2809cbd20cecb8e1190ab",
    "AWSCognitoIdentityProviderASF": "524619c668be9bc0be5fcb199e63b0dd579e530c44ea69643d30944c2d249f1e",
    "AWSComprehend": "a3106ee5989287804a556fa04abd7033f66d23d84c217762352977e0fece55e0",
    "AWSConnect": "7b49940e8c950f8b79edee9161865d102f0b50600536ca64699ecbe1ceb6f1a5",
    "AWSConnectParticipant": "a7a117fb08b12718abcf8bf43fd1b5ac6695089c1d40e52d0ac97fe968084e3c",
    "AWSCore": "6784a3770f4a562c5238273a992b1404a332dc385390d1431f4af14685a963bc",
    "AWSDynamoDB": "bd0b6b734f2d95708057fd5da301df953963fb54f6efe9d8558684c9f520a08c",
    "AWSEC2": "bc582ad0b08c54cb1766a982d99dacfe8f6272a931d7bd6a922ad12529dc996e",
    "AWSElasticLoadBalancing": "81c93db216f6865ea5f8dc1bea2509712754144a3e4e9bdcb1879645a95b4b45",
    "AWSFacebookSignIn": "2c982e947228f031cb501f83a445c3d229eb577b38602e59286dea1ebc6b7491",
    "AWSGoogleSignIn": "94f693ddbd69549816659ea22de3ae281d0df8a98e72e84800d7a6d8d41cc3c8",
    "AWSIoT": "e1cfde62d214f96352d07e5ee5a3e0a3a0981e0dc54de2fdecdc52fba071e806",
    "AWSKMS": "2f84bc79ecd01fbd688728732740b342311031908048ac81ac51ad6e1bb792ef",
    "AWSKinesis": "ab54f8154344de404bdaae42a34f8b2c47e85a04f6fd7fb7a67b22537180ebaf",
    "AWSKinesisVideo": "a59d2d230689b03f7abe07836125e489eaf287853bdfa7491c99083bc9404899",
    "AWSKinesisVideoArchivedMedia": "65f8f156aa74fc08ea01ab294602bcd9b312650bc38b14d2f871df10f0b5970f",
    "AWSKinesisVideoSignaling": "fe88ba5282978dbaca164cb0f06ca7fce1ac4c3aac21a73bc81a3f1da3b3719a",
    "AWSKinesisVideoWebRTCStorage": "4ff42bb536bb239c4fa299206456d6bf9ce497fd7826840e93e7325ad8aae84b",
    "AWSLambda": "9040529297fd38d3e05d09fa5aba19103d41f7c47ae797544c383a8594aeac35",
    "AWSLex": "4b1d8f525fb5c8a3ba9940e62661aa03ee9ef3975563a81181e19c6768786d5d",
    "AWSLocationXCF": "ee079d799beabbc3d8369278b9107c6c7b617ee351b6079a0cb1494cf08a11c5",
    "AWSLogs": "70b091092681ee36e1885a2cf2529436af5cf2bf771afa2ff16639d8b7d3c66b",
    "AWSMachineLearning": "ef25d3591f25409fc9abb9a7f07c55aca8a3a2bd2818a7a7b0dccd9c3a4390ad",
    "AWSMobileClientXCF": "e0f10e0a168c9af2df5df16784165cb2d7ecd68eb0c91cdfb6cfacdd14cb0c83",
    "AWSPinpoint": "982502cb3f09ac223d0204927b1ecc120126c21f73d48b5966e9944bc7bea741",
    "AWSPolly": "edadb709211040e78b711013e7aaef33e23f411d94f081d4d707b19608fc9222",
    "AWSRekognition": "881ac8ece0cf2b9935a088a0df0f8b585e462e4ad945e3add5042b595381e1cb",
    "AWSS3": "c07e12433a8f4be2884fb5745be35207e03b52babdf34a38c28bca59560a538d",
    "AWSSES": "06d0767639ffc5a375ce93be1590a3b4207426dd0737874392e7935445fe76a9",
    "AWSSNS": "fc6466d6cc700fbbf281af817b69ecef6ad144f5c41fb132f11f603eaf407b17",
    "AWSSQS": "5d7a0b6c154f3b0a1442ec68589ad6a9d170139e65623f03370afa7ba7eab7ed",
    "AWSSageMakerRuntime": "c19186642612d986f026e1bfe5ce4194b94c2e5a5be31d3a579afc0fc13850e0",
    "AWSSimpleDB": "95b67e351320de21ab1af06935b1628bc374c91bb14ce3d119bff1f24407c113",
    "AWSTextract": "d3f4fca654ffb9e98b12d859b5e34ef67cac643689daa939009b176897b4299e",
    "AWSTranscribe": "487d2d105ace7809152d339e4cfe7c57fee97888b3de470e7f804d0eaaf9a193",
    "AWSTranscribeStreaming": "860d67f415dd009ff5cb719f1be9c8c6f5b0235e9fd03ac08abc9c1f55e5325c",
    "AWSTranslate": "13e5f05ae2e2efc1e77fa4ddc382ae2c1a3ba612bc551a10400f21c1187b6194",
    "AWSUserPoolsSignIn": "5cb6789af98dde44be4acd47ab17ad80b65ee7754958752ac5a4e4b9f06ae44b"
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
