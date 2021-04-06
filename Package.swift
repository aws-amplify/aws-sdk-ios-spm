// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.23.3"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "2442f2a8de8162dee3ede5b1c6d95e38adfc067a482ac4c15bb353f64c06dbb1",
    "AWSAppleSignIn": "013151886d01d6d957833e231a6363662b53b7c026ab84796ce1af295b52a1dc",
    "AWSAuthCore": "f16dba0057e19164c3b2ba0c6861fc2087fa0526a3be152d1f83c151bb71941a",
    "AWSAuthUI": "9b074872777843442e8fe281bb5b54aea2089d7c2df12a622ffe00461de6d11f",
    "AWSAutoScaling": "b3155e2e3d0dc3ca051a32a4b9c0fb92848089f5e046f99b6d973fb014541995",
    "AWSCloudWatch": "57524a05eb642c9fa4931a7fc03df5da3dd5c5590eb350b6fffd52cbfc840fdf",
    "AWSCognitoAuth": "0dd0729d87953d279ab8010f906859bcdf6352ff14516e0bdbbff6134ce7a464",
    "AWSCognitoIdentityProvider": "16138933bb959fc4fb37ad001bce5c9b2f5c97236ba8cbdf361763e78ed42ae1",
    "AWSCognitoIdentityProviderASF": "c0016b7e1ff94c7aac468197f840226591a13155495b9d975f8e5b0206a47e1d",
    "AWSComprehend": "29da40e7a1504d520ac4e55a9980f9e134b6bf037c7fa7a6bc624f374e6fc77b",
    "AWSConnect": "eb852396c40f69e6a23a98d0ae05488269bd1bcbad24dd7349122f3f3860874b",
    "AWSConnectParticipant": "dd21a871debddebbd5012694321b0a4daead1933c99f26f5a670463694ccd174",
    "AWSCore": "2731c89c0a7f214a0bc522cd80ed9c3a27a265856a56a3f5795028d70486d4a8",
    "AWSDynamoDB": "01f97b33f512614da503424b3fb8b6bf8ea5ddaf2a4c825d2b2118bfb1de9abe",
    "AWSEC2": "6af71b570500de3372ecc76230d761daa8d7dadb45e832909f2c2fbba3e71fa2",
    "AWSElasticLoadBalancing": "8d299004956bfab46fdf61788c3d2e74f496c26edf3681c42df4e3926f563acc",
    "AWSFacebookSignIn": "4be39d288251b3f647240a60365b565b86cf3c680e819713ea533bffee7b1685",
    "AWSGoogleSignIn": "06404faef203a5e854b2b271dc42c8fe4487c5d1848b478682bb689bd194a7c8",
    "AWSIoT": "abcb6c7fff15dedf3047ceb7320c8c22531cdd550355101b96e4c96797ea796d",
    "AWSKMS": "e2eaf408bd339234aef88aaf3a870d292fe853194cbb81c7776a0d65160db746",
    "AWSKinesis": "15077ba0b824411688409124932d410a3e26dc83237d4743256109d310056f64",
    "AWSKinesisVideo": "18a3aefc864e4953517bbe744f617300b5c55a0377d43e6fc9c98a844cbda2e6",
    "AWSKinesisVideoArchivedMedia": "14afae0d07a3082ee436cd5a70f337fb2d829d74a2b10e4ac0cfa13fd6a22f1c",
    "AWSKinesisVideoSignaling": "723b791948eb75e807f054f97a4ce18da245c9a41d9d3824814ee1153e8dc545",
    "AWSLambda": "beb5e6b6668044eac1bb526dc955721e187fe48cd64f085ee74cbaf235446f4c",
    "AWSLex": "58e372151e4bbda630c3b88f29d7df5d04a50be09fad38dcd640a86e6b94fd4c",
    "AWSLocationXCF": "a91af270a12c9b93e292d46796f3b20b9ffe320c077105584067b2abeb8201e6",
    "AWSLogs": "a81bc02aa65f2d0e62b225c026700227c28cd72ddd49448abaa0203cc69be9d8",
    "AWSMachineLearning": "4144f0529e33baf463b45d2658dcf0519d9aab0b76bdd559ab1113ca5344402a",
    "AWSMobileClientXCF": "201f8ff08e462c08c2049300c6a41d9cf23814539e9df17ae0a2511a342e91ad",
    "AWSPinpoint": "cf4dbc7d522b26e38f12ed570c7d984f53178ada99566ac0a1873461e25abf18",
    "AWSPolly": "729d9b40f95146b7259f9163deb2ac19940a331eb4b59310c5d40ea71681dfb2",
    "AWSRekognition": "598aea53951354c6c14cefa866aede7a8d45564306c579984127d701f4b390b2",
    "AWSS3": "397afaba76a9e200358b4a1708e5ed7140c3b346e701b2df92939816594ee1ab",
    "AWSSES": "bd6bca28d7f4ed0042ee39deb781431da198b8872d92ee61787df075f06f4c81",
    "AWSSNS": "adc9e2670526d1a99118d42a19d2612d652174e45973097fe7857e2d4ea55725",
    "AWSSQS": "305249ddee1b7ab82ce9429fca1fbd5ff7f9db7ae0aacb0b43ce74a09d726a5f",
    "AWSSageMakerRuntime": "2dcc4d83261f9a986bdd49ca29bf7c9c0b5fbda6119e8b2bd8934f58d663c9a3",
    "AWSSimpleDB": "39c885e0d9d8ada75c5b06d97dd288b2c3bc4365f60933d6cd5d7db3cf55b7ba",
    "AWSTextract": "59007ded0d289dd9d83dca93131c22b7f0d7ae023bc86cc56c479fef6fae24cc",
    "AWSTranscribe": "72219546c20fb53a66973f8c5856a2bc093022af24a28ef6e639e5b77d69a009",
    "AWSTranscribeStreaming": "cb4347697caa197c610536009c58ead99ab1bdb89eeb277570fed9eb9f632683",
    "AWSTranslate": "5a756d8bcac71261fc8ce9f7b5115a5353500e4d7939f66d493f986a3d4ab928",
    "AWSUserPoolsSignIn": "95690d281c354f3ebecf8e2898b242775a996b0152620761432c9cd441b0a9ef"
]

var products = frameworksToChecksum.keys.map {Product.library(name: $0, targets: [$0])}

var targets = frameworksToChecksum.map { framework, checksum in
    Target.binaryTarget(name: framework,
                        url: "\(hostingUrl)\(framework)-\(latestVersion).zip",
                        checksum: checksum)
}

let package = Package(
    name: "AWSiOSSDKV2",
    platforms: [
        .iOS(.v9)
    ],
    products: products,
    targets: targets
)
