// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.23.5"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "8577c7385e322654f823a7b53ddce0273697a8499aafd30749d6603e1bf59483",
    "AWSAppleSignIn": "c7a1879b83167412f526127639d23efbeb2d605236fe3367ea840e0d9aa0dd64",
    "AWSAuthCore": "796d4bea940e1b33900485f457736f50019945b726f526bfe2069110183a1003",
    "AWSAuthUI": "31d25082fae3fa726d9c9f830b1a574f3397e36e614b2be9a7ab408f6dbea7f9",
    "AWSAutoScaling": "71511c4927aef5208fbac86f4282038fa072eefb44be359b7f06c8756670bc4d",
    "AWSCloudWatch": "9d9d180d3626032d4b129b6515f104ef07f82cea3904039199539615d548ebaf",
    "AWSCognitoAuth": "d05f1b85e099f7d9965ddea644e0ac2aeab434464d0142bd3ce2864b79043430",
    "AWSCognitoIdentityProvider": "e7ddfbdfb928da5bb696430c22dababc9b28d81fe68a937c0a3028562189e5a6",
    "AWSCognitoIdentityProviderASF": "406d9d5668a07cfcabc09531772055e8b6c1267db4b967b1ff45fb7e80fb25dc",
    "AWSComprehend": "83a7c0f16d69119b61e5022ce242605f5291fd4898e293daf5bb66948721db93",
    "AWSConnect": "ca9fec5d84975f324b78e15c7b4815967d79e8323e7972ad798ec61cf0e3bb89",
    "AWSConnectParticipant": "5cfd30367c825f69ec142d3ab32bbe06b86ecd648921b078c98263988a5626a9",
    "AWSCore": "ab69acc97326ee5d4b10c24fde647078ba7f24ddfc1f3f664bf9072f9ab21a3e",
    "AWSDynamoDB": "a901bfdcc2d61efcb5fe732b47cb94bf737f3db6892b3acfc2739569bb26e16e",
    "AWSEC2": "4745d7f68225b8309891051111cf9d7519cabb330e49733a8ae2535f3cf0a09d",
    "AWSElasticLoadBalancing": "28e78d553242b8008f55301eb3d67c3b1ce15ba28014829157c9a6e0127a49fe",
    "AWSFacebookSignIn": "5ac7da8d7fa94e0d54414fdd934af82e53fc735e5312addd8738e394ad898c43",
    "AWSGoogleSignIn": "47fa593f191c8252f7ecfbb16243a05470559184dbfb9beb01f32d8bb07f0dd9",
    "AWSIoT": "c57b0faebaca40cdf975d810cc5b999875e4b6b719bb68c4a475972620298110",
    "AWSKMS": "7674bdefd636191b813f15f2d7bfeb5d1fb218877518f4be129fee78f05ab3d1",
    "AWSKinesis": "7ed8e595b5f23b32813c1c3d218e4c000e563e3a90d0fd38968c8505e332a47f",
    "AWSKinesisVideo": "6382b7b2676dd9243208f20113994809e954ca31912e9eb893fc14e2a9248767",
    "AWSKinesisVideoArchivedMedia": "b20fee01a3a0f867e3ae2787063d612dabfa63a02e21148e532566e4670fedd1",
    "AWSKinesisVideoSignaling": "074a45975359d67e1614bfcf26735d5ccb27f950160e302dd1de6924f7715a20",
    "AWSLambda": "affec44ec0cd6f9813a93683b8b9d3a57c327e95b67dfc9f90e4788c31424a1d",
    "AWSLex": "a38071dd18f239d60785d73b81ed0c4ad27fdd0bac0dacef12c2d12443defbab",
    "AWSLocationXCF": "c218f8fcba2a1cb43934bdd6975a02b07603aecbb6c22788817a39012e0c9238",
    "AWSLogs": "784cc61638c4734aef7da4c2e3cd79b461de0eac106b196992327f801c8b64e7",
    "AWSMachineLearning": "d83200c3e07cbfc48b3c5f6988ee4ce08dbef5ea7290adf0b8dbee243f8cf9de",
    "AWSMobileClientXCF": "b16b584ae437033dcbc4b785eb316eff648b78e0d17b3357df5b557a7ee50510",
    "AWSPinpoint": "7cd8b036e46461e06d522e78ab4a0232aabb0b67bbf8808fe8c8e4a84b6b611f",
    "AWSPolly": "a7b701818d45a915d1bc74337e3aa92f0e94a97b3317d20d3b40322d1bd0150c",
    "AWSRekognition": "ded333ea04fa3281a8ff762d574fc7683275f4f42292ed8fc8d2d49687de633f",
    "AWSS3": "429774e009aab4c41cff161fb9ac824afc1a7df5241be0e4de5f58df0e1800c7",
    "AWSSES": "cf7760e14d5b08d4ca340969f4bd5716bc24bed2457308dce22f8fb32509aeee",
    "AWSSNS": "58cf0ee9e8b5a8e7eb9b585a20c44c5535219b28dfd4bd022c2e72c79b14d558",
    "AWSSQS": "faf73fd84ae5dfe46d43ab4bd285b2905495dfdf1466bd2ad3ed22ea6bd4a38c",
    "AWSSageMakerRuntime": "169e0608b0bc0a6c0ef71fbe0bd50c6cd133b3ca991d950c0850ec0f6d8fba84",
    "AWSSimpleDB": "a9063cfa423dc73253ea7a201d1d15134bd925864d64425a7f116599cd74b99b",
    "AWSTextract": "1c730097192bb2ebde6e9f48ceaabd4c8229f4676621dd84c9455b888444ba11",
    "AWSTranscribe": "e6660241e9c31b83edd273f41e26f5639443f4adc89d4d211b3eb891fed7fad7",
    "AWSTranscribeStreaming": "96570cfd2daab8cd95b68b605e951ccead43b45adca28553f5b82bf0a24a63fc",
    "AWSTranslate": "c34c6cc6e9a91aa77c2b1145511f0da8a1fb1c4c54f2cceb39c0bdb22603ac22",
    "AWSUserPoolsSignIn": "9911bc57c4352ec932f39917d925d6defe3c7454bd89bc0f1759eea8afbea2a5"
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
