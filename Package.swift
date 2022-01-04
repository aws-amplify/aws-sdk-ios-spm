// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.26.7"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"
let localPath = "XCF/"
let localPathEnabled = false

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "8f5d6880819bee8280a00170b1de3fa876d2b93f53bee03da625d93f4b4df8f3",
    "AWSAppleSignIn": "53b3a7bb330ddc3824cb5bcb2c25d68d8930844876a6a90d1ce8f5851e0ecf9d",
    "AWSAuthCore": "c2bd5267c7d25fa334a85491927c8be34eaa121fbb707a269357fdfb92d16279",
    "AWSAuthUI": "d1adfcfcd62ca3dcf476de0637a33aea3d053460a8899bab4a99adaee33f4df9",
    "AWSAutoScaling": "1bbf74baa410413046c34fbad98c998ab73e72571b402442207b2f525d447745",
    "AWSChimeSDKIdentity": "2ed9434fb68c8796e96bb47a12d7171a659dc254b50c8875cd24de3da72a3456",
    "AWSChimeSDKMessaging": "dfa19cf30155dab49aad6dbc8e628d1e7115211fe33b17aad93da57521d21f50",
    "AWSCloudWatch": "754f3be8f56ea907c941d3b2a2f63ff39cd55493ce1e1587120bccd5428ba366",
    "AWSCognitoAuth": "271296f1eea52075457972421a8260121ab0f64adf2627450ac85308570a667d",
    "AWSCognitoIdentityProvider": "b987280125e335573b62e48835a2df4cb982074bba2cea026a02bbe8b1a92a8a",
    "AWSCognitoIdentityProviderASF": "1626b96571051f9deec94345761c1549f37900d0a302f5a493e6f1b2047baf4b",
    "AWSComprehend": "7f56976cda8d0f0563c71aadf97bf5849a5d3dfb64dff83cdb00a193ba1a487d",
    "AWSConnect": "85847a061517842452c7422c50887b5150ec5229f65e17abf2d969eaba725dda",
    "AWSConnectParticipant": "0a4dbf8a9f4d11a528b2ab1a8ec21271f018e705c1ade96e69fecb6181733973",
    "AWSCore": "4359301ad22480836aa418eec2dedcd662727920137dbe18814021f1883c3832",
    "AWSDynamoDB": "b2049820b19795e2df9ab6ed02a0630e7410d1ed6a65c3ea9ee1038a51c2840f",
    "AWSEC2": "2c1d630d67102bc1f23dbde11ab6f41b3cb152e6969d60cab141e03d58995776",
    "AWSElasticLoadBalancing": "f59daa27966a89ba840c7217e0a735d9cb6897168c787efd927ce99fafea84b6",
    "AWSFacebookSignIn": "6d3ff551a3ce96b794f2bc8bc01be8d2d68b0953eaacd439f5a3f5cdba6b771a",
    "AWSGoogleSignIn": "6af4878ebe16c90f3eb509f968610486edbfd43a336bbf6014afb8b6d37cfa39",
    "AWSIoT": "3354a0d580b68663a9089e5cf48a7ed9c4358d34b95c6600e6d08790266c222d",
    "AWSKMS": "6a4e3fcafee45b97d087b4680d4a11d3a215627d33742511a036f1353d52f004",
    "AWSKinesis": "9e66e7dcc332234891e5113589cdc2f750a06bb0165163a6481f43875d072ce6",
    "AWSKinesisVideo": "d04a4a87d3bf3ad949563e59082930650c1e5e2f3c6f9732ab8de163f257233f",
    "AWSKinesisVideoArchivedMedia": "d33628dba7233228c94e003bfeea6abfffca05914205006085e263fc94abc340",
    "AWSKinesisVideoSignaling": "c4fd3f4febaac8efd004a6bee88d67dd9fe242fb113065e2890e5de0da33077e",
    "AWSLambda": "f231f80f0b0511102ebb919208002ef36cab16a2b4ab84d94d4ff32d87f4e99d",
    "AWSLex": "27305048a44d36c54b6923a9401d1e866317da685c4ea8c7e7b4013487cbae55",
    "AWSLocationXCF": "d56a3e4d981c8c27cc7afa8e9124ab1fe53b226338be71595f836e932a776c74",
    "AWSLogs": "85bac045f6f78a6a6ad1173a984a030c2135676fe3670ce039be72e7f81e47ec",
    "AWSMachineLearning": "49eea1770a7561b3b1a2709dc387513a792b2eaa84cb11c554a03129e7ff36b6",
    "AWSMobileClientXCF": "0ace24906d75431317a94ce2d63e7e42f819c13e64fea76c8ef5f3e0f87495a5",
    "AWSPinpoint": "2629b8898ab9a93af97f31bb2ffe419b9ff64a8e5d69c551e4d3cfe7f5e87aa6",
    "AWSPolly": "e1f8ab6df5f07d7779ec5ebb022aacfc61741de06ebfd8a61b4d36308ecd5d11",
    "AWSRekognition": "fe452e891bdf0fc453fbb3f4e8431b0d7b61c4157d43f6ed831442d6cc11b87d",
    "AWSS3": "36b5bed492c398f93496cbe0ec0d1a9830086a50ca2d568923b150d4ff95581a",
    "AWSSES": "03666651b9bcce63f224a2c5a129af55d0fc8d4ec15e654183ef50402edf380c",
    "AWSSNS": "ee5fa1b83432335c04bcd75bb2810c24e065a196a08ff0e62184d4dd45e74162",
    "AWSSQS": "907f748c8a66323696638444df0b80fa0ff05d95893e83dfc55cc3ea912aa93f",
    "AWSSageMakerRuntime": "2417b8aafc8228f7358e91055c558b9ba26ce7f1858547453c6bad1aeb505b4a",
    "AWSSimpleDB": "42b009291ce91fb6c275e3f0a19fce278816511009129ba96d27a782b3b4e90a",
    "AWSTextract": "62ad3ab1c8f763401ac8117cfcb35590edfc4029a67191913ce607809c843382",
    "AWSTranscribe": "3f91662f5ebf3d345177747b7a147b53b4e1385a67566a2cfc40a693d85d43c6",
    "AWSTranscribeStreaming": "bb221001f1876d25433fc4d036c5835e75767e766d98c33ef1770d418fdd22fb",
    "AWSTranslate": "45bfca9341ca62a81c9a0b88869c4cef756a6e03ce0f1f2f80eee7c8a41cb928",
    "AWSUserPoolsSignIn": "5827de241f847c8e0f2569fc1366fbb6d732d0382320ffcae115cbabe77eaadb"
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
