// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.26.6"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"
let localPath = "XCF/"
let localPathEnabled = false

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "02fd19bb91b4c15786b4ee7bc2433afd23abeb162ff8232b5a85af0d569b39d4",
    "AWSAppleSignIn": "2406db780ef215a68783f54fe6c9e28655bc73d9d5fc61e578f4e54d129eb305",
    "AWSAuthCore": "452a529000c05c6004fc62e2d8b6cf5a582b9a51eeed970df0ebda7e221d1a4b",
    "AWSAuthUI": "77efa60e461e8006a01df901e1172be0c44c2046825386506b498a54d77dd974",
    "AWSAutoScaling": "33f5f418f1fa08568a46cdba3af241263a4b4c08f13745e767da752de8539446",
    "AWSChimeSDKIdentity": "b63b05dadbdfe77288966f72ef56cda79335a70b1c4aa0af1893f3921a2025f1",
    "AWSChimeSDKMessaging": "e438283fe27abe7ee8bed7a4e442d4ad347eb539277a69256428da25e1be16d9",
    "AWSCloudWatch": "13ae97a4f24e180a1b9c32db98ac167ac024ff256d04f9eef5217cd055be6160",
    "AWSCognitoAuth": "4389e6941a65dcf4456cc44b8cf6dab5b3b61677d6a61e3f5f1f0d2c85222c0e",
    "AWSCognitoIdentityProvider": "69c2dbb313feeda1ddd419f551a5ca90b0370ab1e64036662e44ff39d8d4783a",
    "AWSCognitoIdentityProviderASF": "c4988327a87d6a50801d05b1a72b84a687a996cd35588e505a48bbbd51ba22ed",
    "AWSComprehend": "61d37c1355aaaf60a14481f3cec191ed690073889ecd9d30357492ec20260957",
    "AWSConnect": "8c7e190f56ba904291136cabea3ab9750d5fe34e7f636c4cd2f416090ec075cc",
    "AWSConnectParticipant": "2ce23e2470f7f5192042311fb9e943e450ed1fa747eaff8f74e166fb1ccc3435",
    "AWSCore": "78c75fa02f5978dd3b2cf7854551b5af7f67d9dacda5b196526b5a01d2ff1fc3",
    "AWSDynamoDB": "41069a02214a4c9fdfed21cd62cb461f7e3b40da6195bb289b5ce73293442908",
    "AWSEC2": "4d30d89e71d6782bdb7aebdb2b59f178155270af4956689ded24f2b2439d7f42",
    "AWSElasticLoadBalancing": "ae217c021be835f0b97dab023dc8130aea66b8ce598025f741d3e371c1146c13",
    "AWSFacebookSignIn": "c952ba67a8961df78a2d6044b3098519fb63b3fd5102d8195af187eb7aa04cf6",
    "AWSGoogleSignIn": "6e621c6c918eb992ff0be926073fcfa7af30ee5719bb65c972793056420a921e",
    "AWSIoT": "6fa0de87b615483555b50ecf00d6f2602a6e0044f4d04949bcf4e3333e19e9d2",
    "AWSKMS": "0280895617f0632529c2dcd218444625fe805c4ca897a12cab1f94422f1d6c2c",
    "AWSKinesis": "5feb95d65e3b91f3596fcdfdc35019039c6762b43622b8ff90d9a3af465544a8",
    "AWSKinesisVideo": "62d5bfcd4cfbc62b6679684a49a1c6bafa0fef5e2483ba601a9b2f620a4bc17a",
    "AWSKinesisVideoArchivedMedia": "1523e7b53793debd27e155ca2bcfe0bebf5dc43ed0740782df6e28e358353ef0",
    "AWSKinesisVideoSignaling": "1617e3e5cf347d18f4425e546b7ff9cd1841e5d8ac7ff50295fdbf7b79302456",
    "AWSLambda": "b5cb15d6401d88c0e8858679206cc8e3d7260653c05874e2d9414e36e8f48058",
    "AWSLex": "0ac7298441d456eacd0fde3a6e60cb0f1e8324600596c66ccebc2beb84593648",
    "AWSLocationXCF": "f5858df9d087a57deb2f3523509f5e10aa308f13dbfa769525396fd950cc2bb3",
    "AWSLogs": "45c637caf5fa96c5244fa96c57f552242807361cce603567a9ac1ba242b2af8c",
    "AWSMachineLearning": "3a5ae73f7c835979a4b95ed4674ac35eca2ae490caa60c7b50505fbeef37df1d",
    "AWSMobileClientXCF": "778bffd6dd7124ce8c93c7676cbf1e6f54bfc249643c03c316e096177ad7e3c6",
    "AWSPinpoint": "02e9528e1c5fd18b1d3008550fa16620f82e6497b985d6cf01e3338a9e57232f",
    "AWSPolly": "7384819fbbf42bca770d53863fc4049ba0064876d5a7d8f97a752b49d6075a51",
    "AWSRekognition": "c5ce8d8b5e7222ff6513164868178367c7f428f62a540d2dc58f59347cebb995",
    "AWSS3": "7fed7e09f389fd6eb69683cd106e1e7a2a2fe743f19ab3b5237263b6d539ac0b",
    "AWSSES": "7ec28b2aaa4825d472af8ddc59579d69036399483ff7fe58d9cdbe16069c970b",
    "AWSSNS": "519882366e74ae375bb21d392b73620f2954daa883f35bbeadb5494f9f0d5599",
    "AWSSQS": "4fc327d9b7a870a4ed6f53bdf47e1e10964d33a6c381a199e4056a34e397308f",
    "AWSSageMakerRuntime": "3fddc3da8076095819cd820db6e5389ee37b9a50c511e312493bd3487c439c3b",
    "AWSSimpleDB": "ef027f94755dbf9a09762f1d798797d66fa4bdc35491dc9dc7b459e6cb05d7b8",
    "AWSTextract": "8b6fa49311dd29fc2ed8c9e6f2f374aa80725e63930dff224398b77af1b8c1fb",
    "AWSTranscribe": "6e038353cf93e4663c8c9e0d87a11b50d4ef081f1c972a5e43f7cc80410f9de7",
    "AWSTranscribeStreaming": "7509983fd3ff2b6c10205010add0b95258fc2ad50fedc6bc4c75b7d3781a9434",
    "AWSTranslate": "536014d8a1f8b41515c56aad2d8647fc418a63ac7ab477be2d2b2f07dccb6466",
    "AWSUserPoolsSignIn": "c5ca98a0d79424fb04f22a40214cd86cceda9136f8e218ff4cfae058e4a15353"
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
