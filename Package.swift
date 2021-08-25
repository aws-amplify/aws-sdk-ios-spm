// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.25.0"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "b600b04c803c5f1c2d0e4cdac2b93364ea5142f21ab7528e9b453356ba44e18f",
    "AWSAppleSignIn": "44a616a7a35cb6ab07eb4404d6a58f720fdb9913ae397d034e94dae585627cdf",
    "AWSAuthCore": "616e0d05ad4e7c769bdbb8c21315e4855a4ac8b94297db37b0797665fbb7fc44",
    "AWSAuthUI": "f0627abd70b03cfbf7808c84fc44bbcd80ab5884b4cf2c43c490918e788c28c5",
    "AWSAutoScaling": "cf4e6128f6d36b6ada393a5a2e1058c8002f4ae8a00d083a77bf50a1d143e7f4",
    "AWSChimeSDKIdentity": "f2c70bb38fef36c5ade181990f33f4557d926ac66bfb9c4a0516abd62d174331",
    "AWSChimeSDKMessaging": "d564173095486c990db6cf342c3c780ea19bbf10f08fd15c8d889604effc05e3",
    "AWSCloudWatch": "d10d8eda0868088a373d6eac9ad30f660c809e30f005744c4a5532d43c5888cd",
    "AWSCognitoAuth": "26c5fd2e107c95b4fd883607c6825e76cd92cf643fbff73d4b7c4e539f1092ec",
    "AWSCognitoIdentityProvider": "12f203d773f2f96a4e97082efcc56f20326567043c6d9aa433c8a225b290160a",
    "AWSCognitoIdentityProviderASF": "1d86f1b0bd7c7990e34a755c4eed10d0c00b89669a032bed68fa90012844f297",
    "AWSComprehend": "efd83ba1896b5dba17ae5755584a726630bc15dfe831cd18054172d007c631b7",
    "AWSConnect": "c1f391c386a35dc1b8c10d3180de4a4867acbee2922aae4f5f82bbbfee1ab129",
    "AWSConnectParticipant": "12664c36ce55d19427185b4f5c71fb9cf6a64780ea98c445886f0357d417224b",
    "AWSCore": "8b5f5a2bd74669be823caf341e857820a087a3153082c77a04f0aece09a8ba2d",
    "AWSDynamoDB": "9ebfae57aa79c41a86fad46ca2238bc99d39a4caf0d422d225c83fd9d5995e71",
    "AWSEC2": "fe05660f74a55d5a57e1960ecb9c7e50b02e6e7b04306e715724eabb7c6649a0",
    "AWSElasticLoadBalancing": "a65ff9c54150b52b9bb758c81ce9e10d9bf4747f667f8da390f3c5f4e45804ed",
    "AWSFacebookSignIn": "6d0cc356d61edd94af567c82b013708913ed88ec7bf08a18a5174dc01ed9d036",
    "AWSGoogleSignIn": "bc41a5312fbc691ce8e2b431a6adc15d482c5c6b3727e74a910777d1c1042fa8",
    "AWSIoT": "4b2d19075225ad16a1d76d3e3266a735343a3c6ddfce5681f8bfa7e22dc0f247",
    "AWSKMS": "37263dd0dde811af97e8b3a4d3c00471630f7fc12dd0a95da6fbfbff445de570",
    "AWSKinesis": "b91710ff516c892493c306150cad31bb26ac2e94b56175dfb0534f141f460b36",
    "AWSKinesisVideo": "e69fdebaf45d79a862e85477ab50e0572aea40f6ff84984def37b16eb0457d05",
    "AWSKinesisVideoArchivedMedia": "a9e2cfe060f78731b804007b26c982a370b0cc2c714226610562080a760b3817",
    "AWSKinesisVideoSignaling": "e221da5426a1f6d2605767f88795f16147151fd1d214437c5865559887daacee",
    "AWSLambda": "5392764252fc3fea7b69f81c196b8d3a61300c4df75c99641087c87b75d3218d",
    "AWSLex": "34d0cfe8f69aef8c9cc0d17593e0b840c3f4be12fa78755eec81280a534297a1",
    "AWSLocationXCF": "a38fab8d82c913850414fe29c398a7b8cffb740b276cc96ff88246adb68ae32d",
    "AWSLogs": "fe11f4da0be3e53d87059698a827193ee3e1e15adeba041f056b191fda42cc18",
    "AWSMachineLearning": "c93a752c386c1ea7ad3cc9754761582f512c1fb9e40e1099bc6ce1753bdf2cb6",
    "AWSMobileClientXCF": "fadad7c9c2a963b6440c933b36f3c3a4ef22ca312266e5212b394a5ca58e9fd4",
    "AWSPinpoint": "30a49aeb80cb5bedaf5ec53b3cec5db8ee88643e5e17c69510ec31e532f2f4f7",
    "AWSPolly": "8a887259d83520e8c9ba8b1184e8fc9d932323c9bc195220d60d2528fefcd33b",
    "AWSRekognition": "db01d223a0b35be4f8f7fcba3d01104e5fa569726671ee9ccd37fd2f7a6806db",
    "AWSS3": "7f88753d84b6cd9fe4e3776774e102bfc09bb006296a3eadf58b0826278627c4",
    "AWSSES": "76e1ba16b839817f71b5a97f4fc2b424ba600c4dfaf828b2e1892aa87e8281c4",
    "AWSSNS": "6c464b67988b421a3a4c6fd1e85b95083d90c232d54131ba225439f625b6f46f",
    "AWSSQS": "2f7d6022583e35e05bb0845033454cd2df281d913d85076ac323caabdbe3633d",
    "AWSSageMakerRuntime": "bfa5542a3548c79b04af671ae3b5ef6e81f8b360ebf0a0918e87100a4765f7a8",
    "AWSSimpleDB": "31d2af1fd9d29fb463e5ab6071dd08c27d182ce6a0a93b30d07712b2c19eeda3",
    "AWSTextract": "9670182f982767b28ed76f188e71a96b457b6ddae1bd1be6bbb97d68bc606b68",
    "AWSTranscribe": "4f2508682dd3761e3c059f56ca8f959cead5095977d0f0e2775d5ae506b23d77",
    "AWSTranscribeStreaming": "2e459d2a1eb716ab2da62456c741332fcb7350a9e89c7351f7d2403a663b91bf",
    "AWSTranslate": "ab4af5a389c4e17d1f3b772723ab0513803def7dccf88a35f3daf9c66138c0fa",
    "AWSUserPoolsSignIn": "48c37fda7a6ede1aa79b5505a3b12f19c733b02ebffe49bd6d19a332cacc1afa"
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
