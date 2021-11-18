// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.26.5"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"
let localPath = "XCF/"
let localPathEnabled = false

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "48cbdd0b34423bca6841596ac962a6289dfa237a55eec3c1f29bac3f7ef8d6d8",
    "AWSAppleSignIn": "77188a5d5d0cd5aa47c0c9554bcb46f6d735b0c25bbab483f5b766b7e98b582a",
    "AWSAuthCore": "a115ff5aebe18f6328cc47c027df71d20568e797948305bf4289db1ef12e4d5d",
    "AWSAuthUI": "13ed48244b8e2af3bb3a45483e88cb7b957e5c3607a4d088a849794a700b06fd",
    "AWSAutoScaling": "47c2cbd5808fe35c017db38a0644a76d46cf5757ea26300a8a9bd4edf2deaba0",
    "AWSChimeSDKIdentity": "faea675dab0939cbda197a5baa5707a0676e41d92af27d3848f9d23ace011aa7",
    "AWSChimeSDKMessaging": "0a2f2322f61314bd9f4718e2c7d69a294b5e5c1b34dabad248dca90c8a7776ff",
    "AWSCloudWatch": "476b06f7387262d2ab690d8a58c174c3d6e973217132ae7ee6cbb163c37800a2",
    "AWSCognitoAuth": "1acfe93f79240ac2e9e34d604ca0ad107949d7b88c8a6a0036c113fe6d96efec",
    "AWSCognitoIdentityProvider": "f94b213fda0758abdf13b7f83fc6be982a56e26a48dfe951355dab43115b43f1",
    "AWSCognitoIdentityProviderASF": "11c7475a12ecc8e404ee9a7e65f25fa4d2c26c548ce963bd82a80537a2ace490",
    "AWSComprehend": "9112c29426286bc07beb55d2924c2b1bed4aa806cefe806fc3d2b4d6c4920da7",
    "AWSConnect": "6e3ca0c7598104379e210f5460d75bef9f55274c886bbc3742f6d87b10818baa",
    "AWSConnectParticipant": "2ea437886d122aa027f27faee0c1ef9e3c31545d040e58cdfd44d754acc0194b",
    "AWSCore": "086ee9c737c13935a447f7340cb30f24c4d027f2d033b41cd4e0174b04fb4883",
    "AWSDynamoDB": "bc1c039a890d4aa4debe9523201823c147380d4a0da53424053287ccd127fc55",
    "AWSEC2": "cea6c098c0fc0b198f7993af133c50a0ac5fe134aac9216fe729fa5f4d76bccc",
    "AWSElasticLoadBalancing": "bf6954cbecf1f09c6e532ac2706340902e88242ad70bf33f805e5aed9d87a2ac",
    "AWSFacebookSignIn": "692ddce88fba68ff09adcf68b5d3f9f1a77d9cbb347d89816ebb1b5abc0c2071",
    "AWSGoogleSignIn": "94f3b5fbb841028cefed39a8079c44bc5d703fecdecfc348d352f2a8a6fe5b7a",
    "AWSIoT": "c26d74bb698c18ce400e79ba90cc1f2d89b39369239405216a6362812e32d3d9",
    "AWSKMS": "144f193bdc38d449445c27c13854f0f1e36cd9f282e25482c569e710c28359c7",
    "AWSKinesis": "8c2702423a8a8b2daf8007cdc9db66a74686f7e82fda3d268b6428859804ab48",
    "AWSKinesisVideo": "e247f294598f8c7193a2bdb6e681696bf015fb1f699b3354bbcc8a1051be442d",
    "AWSKinesisVideoArchivedMedia": "b3d302fa79c75027f7794e09d2b95327d8d837dc7b638e8a02d567b0ed227d53",
    "AWSKinesisVideoSignaling": "f152714630f1fc15d0c5e0af396641a86c49a4e635c0c5dcd320c73544ba4cc6",
    "AWSLambda": "85eedcc884fb9c474c8967f8270fc3c33bd8341af6bde6bab863b51d369db50f",
    "AWSLex": "c078428770acbcb6fa0786b2ac2089a84415f1e2b503ccabaab3cef74ecbb533",
    "AWSLocationXCF": "0e060d4ea67b4de0f2e956b4f577c14491673e0db954a3a2edc85c711134e5c6",
    "AWSLogs": "5f7ecad9f4a212ab2d14f74116054f257bf70f98460009241370d6521e498885",
    "AWSMachineLearning": "746a9a8f9684ec6de523f40c66c23df612231c311b4ec0f9ba418d9326fc67d0",
    "AWSMobileClientXCF": "25a8d3323010a55f3caabf687184549f0054dc0a16ab20f9491ec497609565f8",
    "AWSPinpoint": "979f4fee20b77dd14376a28e225ae9f0445a2908c96586f3bf66af7222d0a6bc",
    "AWSPolly": "c65edc150a8326d2379f8b143e2573aa3496f95adf2e93a950415543a3f84d7a",
    "AWSRekognition": "0fe98801d86742ceff9eea8cd5d795c46172dd5450ac4169be9274c6ba79fe0e",
    "AWSS3": "1b588caddaed818d6f3ca14f3ad32828d49f41b6677e95c549e61be123ddc31d",
    "AWSSES": "fb1df699dca0d23b79b49922c2967b1de993f2d5c0103c01fe4d9ed930a22f75",
    "AWSSNS": "5ce565e3037f7b753a6f9ac6eba20fbbcaf4d050c479d2aa1b420f4d89d63a56",
    "AWSSQS": "2102f2df89ef3dc2dc2d228594f44e39756cd2d80df7eb69eade20f35c3f3abe",
    "AWSSageMakerRuntime": "bed6d2695829d9001314aff55f4682518a33b85461d0d3587cf812859bd789f3",
    "AWSSimpleDB": "2d8b4462ef7b6d865360de5f7501d6348e08c8c4e8e0510028d532f6af6c6dab",
    "AWSTextract": "9dfe454e5c0b0868f57f9f33916fef5cfe1bc760aed112581b8e66bb482a8ec2",
    "AWSTranscribe": "0943122ac2551f14822a1ba1c61cdba1fc35f84e009b7a6fc8dc368c8cdb9e0d",
    "AWSTranscribeStreaming": "72691cc2cdbac6d2ae0e2c0705697f80b2986b592ee3c772b5a26675e09df034",
    "AWSTranslate": "c300ba59aacd64cdeee53001c4e460393fb88a932c9ed085d5c2d8d82e476731",
    "AWSUserPoolsSignIn": "b9da72afb3f4e1180736d17da592cd2f9dc1ab5afe12f77b6647e8bca0ae2847"
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
