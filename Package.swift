// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.26.1"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"
let localPath = "XCF/"
let localPathEnabled = false

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "38b692bad01f6e2c6e5642dbeed29e29965bacd156b62dd23ebd9e163a212172",
    "AWSAppleSignIn": "13a7e764e4042be59f83450389b3463a41ba67214171b8dfeef103941461f53a",
    "AWSAuthCore": "d61d5b78dce8e5345584f98bc09e85b220a083ad655812cbe1eef3bb312b8b7c",
    "AWSAuthUI": "fed5def1cf7d9ed3b72a428b9ff15cb284554fb45b2ee6b3169fb4b5a10cb9e1",
    "AWSAutoScaling": "f1b0d8c80527b71427e876f7272d9d716966fc60935096306c47b7f99b809850",
    "AWSChimeSDKIdentity": "e466593e1a07762eb79bf8af1dda41bb9134f80b90f5a1c92d3acab70d54e0ac",
    "AWSChimeSDKMessaging": "9b78398bc0468a2c5a6874892f417b4524d0880795a2b05a5744e9d2755efcae",
    "AWSCloudWatch": "4c1b4823b9483340507e5596033d1612f4399f67f29a93f3a493c31077720232",
    "AWSCognitoAuth": "60a7f5e864570d48973dc922e03b8385cedab6bdfbedca5c5d1253884ad1a567",
    "AWSCognitoIdentityProvider": "b67d1b2034f43ede768ffc39ca4a211856bfd8f10356375df151b477ba0b7db9",
    "AWSCognitoIdentityProviderASF": "7b95f3f881232483893ff9b0f7c2f0ec013f91e4a879b9a05ddc493df22b9edd",
    "AWSComprehend": "52c4517d731954b0fe96a2bd3e1d838bbd175bc93670d591710dd04764275675",
    "AWSConnect": "e2b64e23b2ec801d8b134858a99d5fc6af7c7c7c0ff5b30400659bbe3f1d8620",
    "AWSConnectParticipant": "f7e3da36ebaa0857e3eb694ce6b86da3e2549219f79f4eb3ddcd3b768150fb4d",
    "AWSCore": "809c86a50dcfb6d11d5a36a113878e1e54c9bcbe820269774f09716c10652975",
    "AWSDynamoDB": "17ce222622d1bd814b405b314c8b49cc41c34341c3e0a85fc6d5d6902cca9f51",
    "AWSEC2": "ad49e05aacce97fa9c5b72d391a8e7402281bf59d437abdd3d9e5f2a47fe3a87",
    "AWSElasticLoadBalancing": "3d1630dcf245cf87e446a951b2439923a83cb39383d31d3a745a3986e6c25b69",
    "AWSFacebookSignIn": "5308dac3c7674b00d57f4b87518d48aaf9f8fbecf2063d74ba99768f5688af1b",
    "AWSGoogleSignIn": "f5260abab61a912bda80be7cfb0df2ff942eddd2434f3a7798706f5b5cab32e2",
    "AWSIoT": "f6a6bdd36cf72659f9e3688d5b799c338cabe4c0bfd0f9cf726bcc01eb2132f3",
    "AWSKMS": "11898498f47745dade2748fc7141c1008512b9c9d7e74e4cbbca5229042670d4",
    "AWSKinesis": "ed8f87fcd04923ab5f21d2e3f5b811662aa80b2d4423ca054bc9ae06a3f76c8b",
    "AWSKinesisVideo": "201cacce90ec8dd967527d61d54591caeab3e9b12b326a744cb85b16eb7a2a2b",
    "AWSKinesisVideoArchivedMedia": "3ebfbf140b9aac161b84b1bbc055a5c8adf395ea45472c052b321b1db71b8b85",
    "AWSKinesisVideoSignaling": "b6b5b3bb6d0f9b41803f70f477c1200ace642536ac2cde2afd8127e8caeb5960",
    "AWSLambda": "bfb232ecc0f6192894370d369d7e2c8eb16db534e32a6a9a219f8e3d239bae6e",
    "AWSLex": "6423c12e5244feba0a85b0cbab62abf1503d2ec5e7a3449e87b73d57ecd49751",
    "AWSLocationXCF": "659ff95fd5dbacb44668a904d592db04241169dd7805a677bdf331380f21516f",
    "AWSLogs": "989a168a76024ab7678c9b6172d10eba4146ef07ec379e58cbd7e8efd764cb4e",
    "AWSMachineLearning": "e7546faf4dc894c4214acada3a5cd8b76d9d4161c149ceca60d773756a5e8830",
    "AWSMobileClientXCF": "dd11a163c3455cdb8401cbc6890cfe4f4e06ed87583bb5a1688c37932efa10b2",
    "AWSPinpoint": "f32efdc1226bdde9a20d5f3c2c13fc81a9c0695c2283c973478e36a1b745ad9f",
    "AWSPolly": "7bfaa2c1659b161566c469d087a93638d4515562f6be16bc66f1ab87dde9595e",
    "AWSRekognition": "ae6b5b5575ffbdd44ca4aaab389fcebc27fb4e8a4415979f1d4a8ef5ddd0a0d1",
    "AWSS3": "32bd0f1d3e5b2def4a11336f02de11a980320545215997d0b02e5f1557080500",
    "AWSSES": "2b68a83edf26f6ff950319c31fbfb5b29b828d86c506914db5f02f9c3cda800f",
    "AWSSNS": "f8c510cb1ca3bcd186d8a61dc96a301abdd11d269a19c07d9c5f234fdac624b4",
    "AWSSQS": "6ccfa5c45f2307f4d7e054c8d0ff159067bc4227cf645265bafab96a18033558",
    "AWSSageMakerRuntime": "bc1fdc062da3836cc2f967ba279538c84eb30dec5b0129f2255830f14d19260b",
    "AWSSimpleDB": "78c9bd1b2b97c6f3022874cb1c76fbaca7a37d2c81acc266e5c1d1967991d2b2",
    "AWSTextract": "af5fe000d55edcf1c924835880903c1f4c9f709b5533d428031595075ee25b23",
    "AWSTranscribe": "7a2f2a8f432d20c37a93faab89a3ffcfbea861ccd9fb4d6b6148edbc42f209de",
    "AWSTranscribeStreaming": "b8e692367764fbbc42a91c5c6300c188c615520a3cb466f9b3da176cdad606c9",
    "AWSTranslate": "cf37424a51044d40e428b43ee5f2709032d58fa19beaacfcae5250be49e809c7",
    "AWSUserPoolsSignIn": "4b2a7ac133c87c15a4287a868f9c7010988d1496d192760f6ad2b16f81fa87b1"
]

var products = frameworksToChecksum.keys.map {Product.library(name: $0, targets: [$0])}

func createTarget(framework: String, checksum: String) -> Target {
    localPathEnabled ?
        Target.binaryTarget(name: framework, 
                            path: "\(localPath)/\(framework).xcframework") :
        Target.binaryTarget(name: framework, 
                            url: "\(hostingUrl)\(framework)-\(latestVersion).zip", 
                            checksum: checksum)
}

var targets = frameworksToChecksum.map { framework, checksum in
    createTarget(framework: framework, checksum: checksum)
}

let package = Package(
    name: "AWSiOSSDKV2",
    platforms: [
        .iOS(.v9)
    ],
    products: products,
    targets: targets
)
