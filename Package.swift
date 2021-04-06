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
    "AWSAPIGateway": "cc9ace0fcc7dfa3d0277fedf89deff21e7a4b8ee2e7255d6a91f83c70c700989",
    "AWSAppleSignIn": "151b87b0edfe00cd2ad71d1b63c1f065a00d7c2e202e40950aa238a3f098bec8",
    "AWSAuthCore": "852035521c0076cd3499b19597870c9d1042d6879f5bada452b07970149f0b28",
    "AWSAuthUI": "2fd23ede9d1b8fc83a1f7bfda9fce4e2961823623d395457bdec5aedfb7d4a68",
    "AWSAutoScaling": "bcb301dbdc5028e28c6406954673b132f20d23c31b3468b624a2f2d7e27435e4",
    "AWSCloudWatch": "d6bcc0515b607cdaeee8e0596fde3043a3d52073b1e15a4c3f0e1f81b8f9b939",
    "AWSCognitoAuth": "c1399cae7898b522164f7d229a69fef6306daf133dd8326ec2b955c82ca7bfe5",
    "AWSCognitoIdentityProvider": "b6c3cf318d122aeaf6fc91a798a171e45648b030b25e1274332eb6368f5ce4fa",
    "AWSCognitoIdentityProviderASF": "8839fe1308adcf98b93c8ad8733a022b4bb37005ea8490b38a9c4b8028df8b88",
    "AWSComprehend": "a61da3690e227d8acf20682b4310f4d08e29a7ff56e718c47a7e88dde081ffca",
    "AWSConnect": "6ff94b1819a0c751ccbc69d1ee14a915e84e3775d39d52ed792d81a11a5418ba",
    "AWSConnectParticipant": "0f1ac19abcc77e9d071ed6d4d5c661ad978edf2b915f85fd7fa1262eafe4f9bc",
    "AWSCore": "98624dca3a51f7afd102ec9cc16f35200ffcacca2be0c53915ad0b10ad0108ec",
    "AWSDynamoDB": "f330b0bc7dd3ca28e742c78f1f3c4402e2886e4bc7624b3d80049d1b84cc7885",
    "AWSEC2": "71f10d3e614e697b18a5f6d89e73afcf506dd9745d26dc9d994899621f266075",
    "AWSElasticLoadBalancing": "716bd7ceab02666a20f2117356a48c621aba3e70d6f105089e1ba646deda53e1",
    "AWSFacebookSignIn": "21545c342a5a0e538e1b3a0858fd4f3e5b79f1ccb0fcf059dd88a426f9b71460",
    "AWSGoogleSignIn": "d62cec7f4888d896c1c0221eef708c1246b61300f2891bd8d96f8f27cacbf0cd",
    "AWSIoT": "6a2a01c36ab7d46004a36b0e45c6d8d0911b21ba0dc56d7d42c2c598673e50e0",
    "AWSKMS": "2afb3f897aae70df03259c559f6aaccfcbbf09a76f27a150f6821b11449b4b10",
    "AWSKinesis": "ba3df7ab51e2156190e5bacfd8d80f325afcb6a9258fd1acb0d0b1c71e12f21e",
    "AWSKinesisVideo": "03758f6c26ca9d31018e25438d5ffc443e4d4710dcce226d305aa0d7a5c78ada",
    "AWSKinesisVideoArchivedMedia": "e87fcc8fbb032d2b3b36850b2d1e50783a6a2ff2b3f08d2fa8c893f293e0334d",
    "AWSKinesisVideoSignaling": "6fa9a45635c7b6518919aef6ace12f27e4ffbf24ed8c0ce0810c48de66b4977b",
    "AWSLambda": "5a08a461190ff8aeb681328acea1aef4b0a0238f6d177ca633f14b17ec692d94",
    "AWSLex": "5c16087f66951f3182a09e1b24f99689578bebf5098b35222938f1f1a2928950",
    "AWSLocationXCF": "2c937eec6f881bf2f2e839bdd4e89ae64313ef98e12bd3927069b87f2bd8732b",
    "AWSLogs": "7d1992d5d5211cadf0b451b29313e9eb1c807e5de9b628b6f33137ce8c74644a",
    "AWSMachineLearning": "53600725cf8ea55bc1e1051d884a41ce8f26adcae07199d783b88368b29d5e40",
    "AWSMobileClientXCF": "6331873b0baf42c265b97186f839ad8cbd6d2742ed0928009405ddf69cfed7c1",
    "AWSPinpoint": "326956bbefa615d695e83f879aa07323e22f3eb0e506468ce4e8ee0541e80e76",
    "AWSPolly": "d90b9caef057c1c7305ac32aaebc735b796067f958ef286485f1bed3a9bad95d",
    "AWSRekognition": "d085776d05bea01fa7e2f5d2f970e43a2e00374bf6141147b8afdc6d3167523c",
    "AWSS3": "4e4f42ea549d50f5113dd66f6d934bb7c23ab53a1c163b1a9e441c1b315a6bbc",
    "AWSSES": "58796041256348d9935c9f8710b149202605a4cf1121b456633374afc37a140c",
    "AWSSNS": "17a3d29d691505891f1c1b81d3a260d5dc8c4ae17ad40125ca4d2729e30dbf41",
    "AWSSQS": "9ff9e57de65971a39a04499e37e62ddf4e6fb1472784e4bc445b915ecf27438b",
    "AWSSageMakerRuntime": "9444d57f5bee4f2dfb869886c21aaf5efc1fa54470b81b68370fece6ee973d92",
    "AWSSimpleDB": "51ebfba68f995c7bffaea0ac9350288f1de299b4f6a22b3287384593ea39cd04",
    "AWSTextract": "b6fb859c738bb7ce184373385282ecb08fb52f8c67660681e492e00d3ff5c1be",
    "AWSTranscribe": "9940528f2a67d5cce418b0ef1cb40f9b9c4edbe4c1be2cf1c4241ec6758bc565",
    "AWSTranscribeStreaming": "35b6954dfd097843b74838208e4b1c654fc557b590a84b14edfa30ee30090df8",
    "AWSTranslate": "6e20d482add2f31c7b6fb44277cb91eb17c36447321a3e46339720763444f2dc",
    "AWSUserPoolsSignIn": "8134b2c01a82506bf9b17500abaab7ad8d0b1a888e848e954fc32173a1a109a2"
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
