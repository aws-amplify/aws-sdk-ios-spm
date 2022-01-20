// swift-tools-version:5.3
import PackageDescription
import class Foundation.FileManager
import struct Foundation.URL

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.27.0"

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
    "AWSAPIGateway": "73e1d1ecae762fad6e952b75fa83797c94b2509cd2cc93b4d05d532fbcd61baf",
    "AWSAppleSignIn": "a7be04341a13002fac33d3bc384376668a0fa2814e292c0d51e0cfb0ce16311c",
    "AWSAuthCore": "7ea68e15c46dbaf8680ac6d374ca1f19a393f6b1cb1100a5e03df6584c5bd5ff",
    "AWSAuthUI": "bdd5996df91032db48e345a62ed272ad30bbd8abf928223c8e2b7440ea303c44",
    "AWSAutoScaling": "5dd0d892009d6e45eada04d5d61db77f8ce192c0cf5919f9075beb2f3e36cbf9",
    "AWSChimeSDKIdentity": "880fc6d3c2300288e5547063c64d60b255046f04200b74cf16f6ffd5b663c71e",
    "AWSChimeSDKMessaging": "1b411d20c71578b6a973fcda37a7de0eb99c26fdf0b7ff98ebc80f751e919762",
    "AWSCloudWatch": "57e6ea983d29705cdb484d41e9f32a0f81bb6d421649f080fcabc8f5c024580a",
    "AWSCognitoAuth": "d0d837e51cf38d2003b2f6129a5ce1ef833b85dacf4b9591ed2e25a0f2aa382d",
    "AWSCognitoIdentityProvider": "4610917c490317f68044f2a316fd34c77d6a67bc7417fa4a505b2117d20b7e2a",
    "AWSCognitoIdentityProviderASF": "4d48265596f3844607353a5fd13478f99abdba287982b7cb6262f0d6fbb3d3db",
    "AWSComprehend": "a454efa4f2ae480ba6a8619e7ba904bc2967a108118caef03153413f71ab9159",
    "AWSConnect": "ea5e10ac57dd8d9725e0acd42e25c08d4fd8ca3541ca9e99b95ec57abfecd1c4",
    "AWSConnectParticipant": "77c0b47145afee805832aae7e82a6f1e0a6ab755966f6cba96d83ff351204dbc",
    "AWSCore": "73dc33ec8a11587d83379f4d544943c69cb3226d72bb46434c1a80679b543260",
    "AWSDynamoDB": "e28c6c87e219df0e0ade4db07c60b56127211ba0fa23e518d16c5041935c97a7",
    "AWSEC2": "0c42bfb504872af1db37d2d9892f6dae2d4252977682ed25e5d4480ed2c87cf7",
    "AWSElasticLoadBalancing": "63e143c62bd4d85afeb10b3e23e1ce7b8eacb60bf304d7363c4bf783a619c699",
    "AWSFacebookSignIn": "aa84fb93488980e7f5144f5d9e3f1219bea97bbad39ad23021c6ad77efaedb5b",
    "AWSGoogleSignIn": "bde08b33ecc38fcc3e119b739be46ff248a00b1df3ff21f25bfd5e3324ec3f09",
    "AWSIoT": "a0b959bceea9599f044f9b735672269f072da49c2e56950fb8463448102ae3b9",
    "AWSKMS": "8188aee0f4094eaa72d842d7d9b1bc176565324ccb14226af1c4740a2f61f885",
    "AWSKinesis": "b9ff7c7f70595adfc4f23a4cef2e5f701e02510f47f69570d87fe4e02ec29706",
    "AWSKinesisVideo": "3c99c6680c3bc22296ccfe5a531a310a6040bcdf88339bfe2e8986cd8b693a04",
    "AWSKinesisVideoArchivedMedia": "8851d48f4670f1c813ef1c5a8b784d59c2bd60e06c4b8a1d77f2d3bfe30afa5a",
    "AWSKinesisVideoSignaling": "7865afe04b0eeee81c5778a8e8e9705554e8dd7caf60164f0238dd405d2b4ac8",
    "AWSLambda": "bfcf9205787c0179d691fa3be2f121b3cfd302cb025263666d1dd6668f684932",
    "AWSLex": "cae642c7b633e1708094322b32349b2afd6c248f4a5b0c2f13eca60a746dbd88",
    "AWSLocationXCF": "e0ce75570ccbf7de03a732f2a51827f4dce7de1a75fcda51fc03f8482b62cf91",
    "AWSLogs": "32009d1b0cf687143dc4ae44314743f8082a45ac0de58b81f7396ce7604697ad",
    "AWSMachineLearning": "e4da951e6ff3ebc9dba880a9b4aaa88b6e71c57b484d24ed479f34cca51ddf30",
    "AWSMobileClientXCF": "d8e9b8c972bb02ce75738e42eab2ab1ca6281ad9da6d7f7f3e1844c92dc17577",
    "AWSPinpoint": "1ded2b056a00f15c57d6da93ecf5498d237664360887a30133ad38ad311afe4f",
    "AWSPolly": "cd00c38f183f821b56805f61201fed42d7452229865583b2fd331de84832d05f",
    "AWSRekognition": "d9f28d351c08fa5d6c67a66b1a13b111cca2578a4a27b56fc22840c3ab139487",
    "AWSS3": "413e685f23103713a1b6d7918350a73e44e6d41183fc03cd40b2ff6221d77fa8",
    "AWSSES": "22d4ce90c85d3d279b23a36834af591ab173410c6a914b4bd812c35f6d01241b",
    "AWSSNS": "3b07474151d8e4257c9f822a32045ff34b02130da42449cb2a1c6a4f4098e6ee",
    "AWSSQS": "df9acd3f0ce26216c0ba5a4a81c92ff6fd640e2bf0a56f3a1c92ac1596258750",
    "AWSSageMakerRuntime": "311e0923361d8a88fbcf668235db44505060d5df829f801846dd487de945aa71",
    "AWSSimpleDB": "a385bb68a2d1887c281f46bf612d8636afe9652916d3b777b5d77674fcd81c57",
    "AWSTextract": "2ea42114249a37a517b8237c27477dfa93ac940650f09afb77ed7031350b1375",
    "AWSTranscribe": "211326ca2623d614a5c22bd006ecd12cd470f7951f71af45eb8741ca47da6769",
    "AWSTranscribeStreaming": "d4eaa29002b0775a5aa50c796abb5a691f0c43150b49c8d18a74ca85f0cce3c6",
    "AWSTranslate": "7f02a02ec502c237ba282e604f54f0af06290624498fd38319496c6d3f8dae80",
    "AWSUserPoolsSignIn": "e3ec5ec0c7a506c7305541099b5417deeeab0d9d3d09da6abf4ce4bfab2b3c4f"
]

var frameworksOnFilesystem: [String] {
    let fileManager = FileManager.default
    let rootURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
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
        products = frameworksToChecksum.keys.map { Product.library(name: $0, targets: [$0]) }
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
        targets = frameworksToChecksum.map { framework, checksum in
            createTarget(framework: framework, checksum: checksum)
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
