// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.26.2"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"
let localPath = "XCF/"
let localPathEnabled = false

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "be2303171f680370eb8e0773d6b06a22c78fc73bdf392b9df1444459aee3f4fa",
    "AWSAppleSignIn": "d67e5db7d9267d9d390596bd6d9a5113b4e1ddc9694e1f71bc31e7e91e1ba4f5",
    "AWSAuthCore": "111311ed5e332b2aba793cf4abc12a1f88009902dcc8b452b4d31b5d961aaedd",
    "AWSAuthUI": "46e6d099a58115fd22dfce4f518151a14194f1dd9cd122eeab3eff8e2b8c51d8",
    "AWSAutoScaling": "ca50cb22b3d7f85de2d77ab096856c88b604a60a28420954e410cb672709f22e",
    "AWSChimeSDKIdentity": "82169d334b09d047a5c370c576353fafc390a69c2ab350128b0bb7ec08104601",
    "AWSChimeSDKMessaging": "8c6bb9e1664e4ac64e12e37d70686539c8c1287e4d156426dea2c2e08c515692",
    "AWSCloudWatch": "65707ed6be3722804aaa9f836c9d89ca585537f09f2843ca74e2ee6ae472c90e",
    "AWSCognitoAuth": "5ebbb017d408a758d165f58c02cbdeea50291fbe1f149fefe88f393fb2438df8",
    "AWSCognitoIdentityProvider": "be85b3620df5982fa709581122209fee6412c5dd6fdd5a4ba7e2026ff25ebd7e",
    "AWSCognitoIdentityProviderASF": "8a5ee1da68460e011eea163c28d0f3c211aae343783203522b85954a0819a753",
    "AWSComprehend": "c518dd89434161cf06fd5315835dabcdeafc7ac09a94cd703c8a4cb5d2cf25ce",
    "AWSConnect": "1e79e8cba8385225d7bafd3d3bf59a077450ceab573f344427a08cda09af61be",
    "AWSConnectParticipant": "1bfe547c955bfbeb45cec2ee22809b2dfd6d66bacfda1b84509e6dc2b59fc456",
    "AWSCore": "22a39a8c6ba6dad426706a6d2e70f337d846297ed023db3a2f592ea9768dbb1e",
    "AWSDynamoDB": "87925ae5c7b60932dbb433abd98b2cb411067c149435f117a6d87ca58b19f546",
    "AWSEC2": "18830d52b11f19dd2ffbd47963095a972b67955137247756ed35a5ae9c419b90",
    "AWSElasticLoadBalancing": "583069798640b3e317941cea20b57b636a1f3e19202ec0fe3755e188d9da0489",
    "AWSFacebookSignIn": "2781fe59670a95dae2bca914d2817c333f0aebf5533522b35796921cb319cdac",
    "AWSGoogleSignIn": "ae516417780073fdb78cc391902693822971f00ee96cd8fd869f7821a893b91f",
    "AWSIoT": "4384179995031567f76c32bb8d482aca88fdc76302c401c0d1f311ad8c68b72a",
    "AWSKMS": "58a84e32ee2af79d459ec6a31b392e0bca2f4039b73d79de78fcf63757617ca4",
    "AWSKinesis": "75e2747d181e06026ea6867ae1e2325cad76c377d7ba2104e43e42f1c20ac853",
    "AWSKinesisVideo": "b292f3b54f4728b852d83d81cf97bf6916191276e1a59f2b96e091a1514df64f",
    "AWSKinesisVideoArchivedMedia": "fc0f8023dd709a1ffbbbbae7d998506a55ac085b1f3b04146d454623942e08a3",
    "AWSKinesisVideoSignaling": "51b826e16db03554d5c17a8b8f9037ea6eafa4f1d3d7e07bf9b182157f88e93c",
    "AWSLambda": "6c0d070fe499875866856914aa59001922a4045cf6d9e9d6ba55b3c3c1bfd913",
    "AWSLex": "ef783a443a947da27cacbcf2e9d113dbb9eba40c34df4ed43f2e39ae07dab51d",
    "AWSLocationXCF": "fc12b68ccc5815d7f5e40f12d64a6a3af87e29300cce0f8cac0591fc0dc7d398",
    "AWSLogs": "f82302b58a7b6dfd6dfadee5498f03dbebb7e3a7513511dd4577764cea93f01b",
    "AWSMachineLearning": "28d3977beee9f4efe41bad3cb1ba52eedfb1ee95e4d6697b3d48ac8c6782bfca",
    "AWSMobileClientXCF": "9b87257b1c88b8c01bb1fa2e1ecabceef8a0cee6c3ee35f5d3d062712ae640c6",
    "AWSPinpoint": "1aa1993f56caae879fa441e4c01508fe49a9859c74af048e55a8b41710891b5d",
    "AWSPolly": "96e1ade1a91b57a34b5667453b84c7b5e69b40e6f241ea4e7cb2d4a0e625ed41",
    "AWSRekognition": "e2b93467f4f06e54cf60d4bbfbd47fcbc876792507e36efbd131120661a2aa94",
    "AWSS3": "523d4659cfcef6acb7afd9ef0ec8d9eda77dea2989bd579d31dccc2ce9d01925",
    "AWSSES": "f420f0d48f6102721139bae9050af20266c3d016fda8d0e692e16f03bf1c5d80",
    "AWSSNS": "1985598cec4546313ed0fb93baac35821059837b16b9aa32123a2fc7195b3654",
    "AWSSQS": "7b77b405398574f7d6d884ad50b00bf5caed8eca2e1071bdfa0f491bc7b34392",
    "AWSSageMakerRuntime": "93041b7191c850d32fa9dee590d10dab0a390c53d898d22eb871cc55c3224a68",
    "AWSSimpleDB": "98df20d7cecdafc98ac4a23e20b4e5b5cc76548226704e3ca3d1c9c63f2e0560",
    "AWSTextract": "9a9922e7403be0e57b2769b94d518fb8daf2a2b672a63b9b4706a321e5ab9296",
    "AWSTranscribe": "42572c49040a135f61f7c04870dd60703bbab3912cf669a72ab783e69a653140",
    "AWSTranscribeStreaming": "3ca74251cbefaca375025d5a4f5eb8c7f7b2556c2e0cd544e458dd04942f43f1",
    "AWSTranslate": "7a5409710391f01cea25393662c5110712bffba9d9a2fef8e5bafb5312201cea",
    "AWSUserPoolsSignIn": "23c7320fe40c3f6e40e7c45be19fec5048e52776ab9b482c5e3cf9835d258671"
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
