// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.24.0"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "4028384dbe99aa9a80312fab87c995d2244267cb40038a61a1073ab7fef20d94",
    "AWSAppleSignIn": "8634dfc7d76f66b70247279297ed4e9f48f40347be5130137a3f0e41dc9517c0",
    "AWSAuthCore": "3c6fe0b7a7bdcf09f9d7749c4018b8af6bb1e4adb7a2165a74bff880e82938ee",
    "AWSAuthUI": "6d59a2f82bfc3bbe6a96fcf3a7e8e70c835f766fa7dd09a93858b86a8e0b62ad",
    "AWSAutoScaling": "4948cd421508f234779b588f4de7c365c949157172530d2ae699344b8601fc5a",
    "AWSCloudWatch": "d5ee948c1a3fb7aa1e794b98a1e2c6ad2d38caa62ac14625f4031059cd3bb1c1",
    "AWSCognitoAuth": "b3da0b0fe09fa9dd069929d004a34f52ed85011998d7731b893d4c88c3c1bb14",
    "AWSCognitoIdentityProvider": "9c38171e3f94140488dabae7efdeb4ac943f1e4b5ba9806b69a46b90fb6a9373",
    "AWSCognitoIdentityProviderASF": "7a439c47c0091b30add4516d8c976960590082ab4075366b977c24ba1783a992",
    "AWSComprehend": "8f485fc8627e7c270d3214a9d71280e5a021f73e7a73c99a1d4ef2bba8e6eb90",
    "AWSConnect": "bc2ea0a170bef954b0a540dddbacdf1532bdad145f4084d8ad4f7ec51275997e",
    "AWSConnectParticipant": "c29aca9d5d1ff7dd071f7b46d6e43649733d73762e91db6286f3196778cfb4b4",
    "AWSCore": "f5c420e5a357d0bb58e4ec05e5306cf28f7305ab31f1ac58caf0ec100c2a9584",
    "AWSDynamoDB": "2a0ce51b7c9e288476c0fbe0fbab60cbce7029edd5b537a8e2b47aeb5fdb69e8",
    "AWSEC2": "13d89be43ac9fb2e7a3a9550f9083d587c6ff30ceff95f7e8dd431212a8dc27b",
    "AWSElasticLoadBalancing": "782c6f10b0407ecacbfb1bb38d1507c95b26fccbf3ff9f5e6be1757fa8319dc6",
    "AWSFacebookSignIn": "296837d47c0756a7cbb22d70d6b402b8feefdc26c756a732ce3d6c94607b6a18",
    "AWSGoogleSignIn": "f560cace0ef283e7718916f952ab22ad7fa3532bc627c9efb0cd2d804f5621e4",
    "AWSIoT": "65672259b814ffe67bbe7c1f4fad1f358980d7102ed236570eb37baec8a06d70",
    "AWSKMS": "e87831fedaaf19405a809c562dfbbaad325398fc80c8c0d9ae1fdd7bc23f14a1",
    "AWSKinesis": "ea1dc889615ac4d81d797323632f9ad12ed03bf0b96e02fff18cb88529182c18",
    "AWSKinesisVideo": "a78b7baed25ca0551ad36d2c60c60e914d5d4402aaa426207e70a6ef708d4e2a",
    "AWSKinesisVideoArchivedMedia": "3b79f2e83a60589426455294de61ab738cb39d965f83140db338059223956c31",
    "AWSKinesisVideoSignaling": "6864c23c5b8b2391972dc496f80f79d642dcae0b60937512de9f086b45f19f8d",
    "AWSLambda": "cf2a9f689b65394088e2f8b3faef33d954aa5d25d2fab9491a5ed85f5d675d67",
    "AWSLex": "1262c6bcb403abeb0662363799c74f1b9cbed960e40f43738a49ee2d2fdf7867",
    "AWSLocationXCF": "77757574c282a063d25b38a4242fbbb98892e5925046afd0a71930e75c7c1506",
    "AWSLogs": "9da8019e646d6d9a0311dafe796f899acf6bf0194b58c9c2b7335ac36cba30b5",
    "AWSMachineLearning": "614e8f8e94bac521fec7304a73334290c24d03db1331afae2405b35a6d017aa4",
    "AWSMobileClientXCF": "85dc021f48858ae61b1e820609861876d0c6b8e2d3a9c770d92338c6d281edba",
    "AWSPinpoint": "b40337a2564b77009affe462f59a90d3c28c74c2984fbdb3e4531e96f18dd4e4",
    "AWSPolly": "149b1339476b4cd9fab0cdb43edd261687d53901442a6f96a3bd62cfc2c79832",
    "AWSRekognition": "4e5a1556df0b66eb8d7ddb8edaf9f5281d2025668ca04536512274022662dc9f",
    "AWSS3": "30f09f47aa0041ce18d825187745918a7bb890aa40afa884982c5597efd2cbf4",
    "AWSSES": "35730b7bca6b7312eaed36495e92f45138378b30d71d22073ffee6f0b2e66665",
    "AWSSNS": "29ac176187bfa6b861a88966583c0361951fd4e7d4740d11c602eedf9a11cac4",
    "AWSSQS": "854c3a7368ed5d56ba0bddadc1f0fa11f18362ded3ea73a5924a265ad903d1a2",
    "AWSSageMakerRuntime": "32e883d9ac4fcbe24317a4edf6f26adee8b4549c66699f05b8a5687cca996696",
    "AWSSimpleDB": "196efbf80300207dff829a71b8a875e192f9413150b671469593ccececa1194a",
    "AWSTextract": "e12f8ffa06b44c7519705379ec9bc84923820e2f99ab9fc387f0c78d9b658847",
    "AWSTranscribe": "3a8cfbc26485ed5caad8fca2cef09a6dc696386ec5d2e494f9b7c6c905941f44",
    "AWSTranscribeStreaming": "49bdf0d437fb5a5148a8d2c157fef2acd6b1386eeefcfe408ff7b2353afc8a27",
    "AWSTranslate": "5b9c1b2d07330c1adb36e0d43596b59ef4e198b191e800a82f4b6fc4b63f9762",
    "AWSUserPoolsSignIn": "000f17ce0b90604dc2d6a221fb5c04253b16c431b942ff0c8a84a51c66efa9fd"
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
