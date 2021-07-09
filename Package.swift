// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.24.3"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "5ef29d0ba5fc3fd2972196d304a2dafa20fd374f0d08db30905d32891439cdc2",
    "AWSAppleSignIn": "3d0aa4eb9fb266df374d5c8bda6f1bdf68c37bf0d1bc58622014d0f3b55bd481",
    "AWSAuthCore": "4df85b856769b1fc302ad6c95a00ebefbdedda8914d8c0cef84c4182e87f445c",
    "AWSAuthUI": "aa9dea28db822456a74413c545532ed914e9e65610ae9dba459999a50360a4ed",
    "AWSAutoScaling": "30123ecbe381bd2a6c0c1617a19cc6d6e36ce56732d599750a44f06466619665",
    "AWSCloudWatch": "3248fa86f505b3575b2f775052b39a3e9c1e7d2529f680d66809f9595b67bf8c",
    "AWSCognitoAuth": "27cd6fb2750f900b4e8bbc0318f08118f1b184c12bd3619e67262240144b2625",
    "AWSCognitoIdentityProvider": "d867f1dffe73f23b28e8de298e8e93acf6d6f964246deda434960a657f5cc7d1",
    "AWSCognitoIdentityProviderASF": "59019ed94673ac68d3346ca9e1a471984884964f5d9d10866f3b7316630e9d37",
    "AWSComprehend": "c083f41770ad97879e1f136e9a403f59947eedc9d50d033a853fa31730fccd1d",
    "AWSConnect": "bccecc3e72c8e197cb6c479a3bae0c28088b3baad450f6039cf06c0028d68c6e",
    "AWSConnectParticipant": "eee303f72cc980b286983d610fb3d10f1e3884775db31b91b87f6c05ff683923",
    "AWSCore": "fc81c2ade43efbecd76f9b79cb1ff01a32b81f82accf5a8f67d7ac7ecac3c004",
    "AWSDynamoDB": "d2c3e298760a1361baf3f6aaf3df4fab1345a8c17d93ec081761d0b5afe33714",
    "AWSEC2": "bbe9c3d4695cece1c6ee1b19d7427116622be2ecaca152a2f899b9e38cd71859",
    "AWSElasticLoadBalancing": "1f33bae842886960e76f28056cf94e65b06054fd8e9696b33ac7d10ad18d182d",
    "AWSFacebookSignIn": "852e6dcad555992d37d47882e4454aae21b498332c4cc590ec4264078541a6c9",
    "AWSGoogleSignIn": "6f44e34ca04f3c6a8244a664ea158e7f9c3dc04deaaa059c3e24169188c8cbd4",
    "AWSIoT": "f53a86522b58b18751f4fc763c93fbd872bb444ad9797205b2c459d3b8c149b0",
    "AWSKMS": "8850d873cd0491d37fe2f540609cfae7ac34b6213af048a76e8d9c2aaefc0ef5",
    "AWSKinesis": "8baecd451122b9d28784fc2e8ecbe60a070d876008cf62e1286c66528b8d4164",
    "AWSKinesisVideo": "bdc95a310dc4fade307d2cf300117352701480acd9d20521ab1c3b81f5911093",
    "AWSKinesisVideoArchivedMedia": "b77c53610ec91ff7000791bad7ed2afef76493f8e5e659b4fd96cc8e2747867e",
    "AWSKinesisVideoSignaling": "4221c60882b16035fd16e0ebdbe8c78c394747f3ef70e1254eb4f9441fec74fe",
    "AWSLambda": "be07e645b0288d111ea9d05fe84e171ca7d19ef00e5a28bc9d41134a09a7ff3f",
    "AWSLex": "f9f485b387cf6866520861fa9b15aa4581aa8d91ff1cb3cd99d39df9d208e40d",
    "AWSLocationXCF": "43f7cc9eaba4f209e1844b36719743f0fb3da326ff175eef739b9a3e94c3261b",
    "AWSLogs": "4d2db11f1147763462d423140e18d00600599b04adcd81bb4220d550f25940b2",
    "AWSMachineLearning": "3de910682fb11f0df327c9aa5e9570516e5de46102da82eee8758673d662d167",
    "AWSMobileClientXCF": "eb0517fe5db05d42165a00b09815634dd6b1ebdac6f666eb9ca23161a87ece39",
    "AWSPinpoint": "d64df3a27826e8ef697097c89fa159e9d3cfd6a2335346992e0256544b1ea9ba",
    "AWSPolly": "c20d22748defc537e32b753f69c04f3bddf143294f93fcdbaeb77ed27f640c72",
    "AWSRekognition": "39a1ab568a9398cfca95f6351b38990c82320ac64801cf33388f21883192a573",
    "AWSS3": "08b0b859b50ac6064c317a025adae0cd5cbd1eec88157446e49f5bdec4e7c881",
    "AWSSES": "30d7fcaf66d907ab7beba696cf6e6dd1a360af41dbe7a6139a0e02cd5d72d7bc",
    "AWSSNS": "6bc752cfd961272ab8ee40e3e0133f98cb74f70a6110f85000128926a3b9a187",
    "AWSSQS": "38faf0def6b26fd86c9bdfa4287e1a80fba0bab4229de9f5ec3a2751ab878d46",
    "AWSSageMakerRuntime": "deecab98d4bfe2f7b2c197b9a11026aec5ab0e1a2625ea958533e13935ef0b1d",
    "AWSSimpleDB": "b93b08ca800a62001f6842ce180932b737bf2e541bf5b90c5b48f578d1201110",
    "AWSTextract": "599cdc50d3b15eb1b1fe65496be59dd38f307272247b7921967399393c8c83fb",
    "AWSTranscribe": "bd38b7eeb8bd3e9f4be20ef5d6b30fd2a3893c345ac50114f5d01709622f89f7",
    "AWSTranscribeStreaming": "da5022240c89b9430f59fcf0849f4972f733a54e45a7bc3391da2e6b47644b9d",
    "AWSTranslate": "a1749aab866f6ebe3648600fdd3120a99a0bdb7bbb121c464b9a5844bff94051",
    "AWSUserPoolsSignIn": "2f9e422162b327c0461e53ead685e7fa3cef10025c2763be9e20696accf25431"
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
