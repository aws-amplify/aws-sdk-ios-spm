// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.26.3"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"
let localPath = "XCF/"
let localPathEnabled = false

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "3e7a9fb29ae6879e9c4ff6d1e24cf47ddae43b977519fd7c55806f67f7bab601",
    "AWSAppleSignIn": "e48898d147174f568a4bf3e95a642836fb9bb8caf0efb86da4c2ac8a74fe7237",
    "AWSAuthCore": "09f6b13613eb0a25582709a739325dc1366af94dc4762c4f2922f0ecea6d58ab",
    "AWSAuthUI": "efe1e3b1a070e3f291e945200fe151bbda974c5958ff14a47cca02c21d4f731d",
    "AWSAutoScaling": "c4691d8550265c5611eff5e16025edbadba3270f28f69a85b80b6668f2a5acbe",
    "AWSChimeSDKIdentity": "719091476d377afd2ff7333fb5ec93ea79d2500f0465b0b8e96da85fac32547b",
    "AWSChimeSDKMessaging": "6bae011dd42cf48eb55d36c49d0bab96bf7c04e48ad11df799b6513cf21e7289",
    "AWSCloudWatch": "7c87ea42ecc77b41a93073c553a23bdb946d3ab0bd26c6dfd1de0950fc3e6d34",
    "AWSCognitoAuth": "294924ae81ba2928fdb2bb863f729c6bd04cdf64ceb897fae5ce00779c960f23",
    "AWSCognitoIdentityProvider": "fe8f6de1d4659c083552d7943345ae84135cdda40d5a390c816a0c2e79bf7d1f",
    "AWSCognitoIdentityProviderASF": "b8ba633e555de1e5e51cb84c73d97d7f0363a2cb8c2f7d2ae038dca1a146aaa8",
    "AWSComprehend": "d7636021a0342c97820d1d1e41082a4345f1e348c993091e1b24facc40c205a3",
    "AWSConnect": "e7f968ceb5d1779c46e2c1f90dadabc685bff3ee4e9b2380fb1c78b2dade5d7e",
    "AWSConnectParticipant": "4299bdd00db6bfde5c3c5927dd18fc7813e5678b807ac523c82a10db0c77270f",
    "AWSCore": "b6eca50141c22bc02382d4db4011d8351082a149c1eb5cd09554d13c58a3eb23",
    "AWSDynamoDB": "06c69f810a8f3ad5bc97987ff694cd2e3b94e94cf4b1e7e40e54611bb8793d8a",
    "AWSEC2": "a12982789873501a755e12583acb8f6579d7d2c0c918639dc5da308cdb8b9852",
    "AWSElasticLoadBalancing": "8d05936ae741795dd958d4d34c6a3eb95f112d3221b153e8f00b092766bc79b1",
    "AWSFacebookSignIn": "7c780e086cb642fe7499cdc545092568a1208f0771df9b7aa5b4b41cff3ac3b5",
    "AWSGoogleSignIn": "a0cfd2b2e7dfa1b268af37a5724b4ded790fe9f4a534e9739f944b699212f060",
    "AWSIoT": "be7cd444d1b297337185d479246d50af5b37588a65037936ed203659c9b0c24e",
    "AWSKMS": "c61161df43b25147d8e803546d598b85d1eb84202e91fede565a55c4f797cd4a",
    "AWSKinesis": "a9beb289121be9350fa01f5a1ae0606adf3757776012018a1ad9780437f74f86",
    "AWSKinesisVideo": "ef45ac634c2e3c4f3f853dc176dbb6a712c62bcaebc11974aad64e57bed192e7",
    "AWSKinesisVideoArchivedMedia": "12c06a4722817b5f5a18a07da6473e99aa21cf00dba9bfffe2bda0a8a5038bea",
    "AWSKinesisVideoSignaling": "bee82891a88ebf30d5d480dce4e8b896313be5d737498f24493453632d736196",
    "AWSLambda": "74b0945d9cffda748f55642c7041bb4cd28578370473bf572dd256086398387f",
    "AWSLex": "ca4a1011ed4100339fcdcc359de815091ed00c2775e8856fd8b6c5356eb1029c",
    "AWSLocationXCF": "f0b3a8d56ac6abd522e6d54721f477eeccee8cf010172a3810c5873bf04d0e1d",
    "AWSLogs": "de3c464260a15fdcbaf68ed69fe3919fa8759405e35c855d06a7cb0bc46d856a",
    "AWSMachineLearning": "6ac47e8b0c2f559e11392e672f112ce785620ef915c5214f7ac2cbe896dc0381",
    "AWSMobileClientXCF": "762860c880ceb9b931543054f5b4449241d7da287b0293c7acaf2aa464be9ba2",
    "AWSPinpoint": "4c629a9d8a8fc3a54690a755b31aa74f2a071324c93f387f76a8cdabdad823b4",
    "AWSPolly": "83d5bab71a7ed33baaba149477b7e7a1a0d63fe5ac9c8a1389007e6b2534529c",
    "AWSRekognition": "326b3b75ecbad42849dc01fbae49f9dc9fafb3cfdd902ab66da8a8abf4998393",
    "AWSS3": "4383d896aa5fc5be67eb056a6fe9b6326af467d7b104e66704fed3fcd0f8a279",
    "AWSSES": "26ae04b2aa3b2abe0d28c9efb72ec5b682ea18105489d6726167f596f49e08b9",
    "AWSSNS": "6d49c82dd8db8a29698f3189f639f50bf6d70e22864d76141c30e2b0a35ed538",
    "AWSSQS": "091e52e416ae055d6bf2d8b79065a61a3dd55e017566e9bc18f48b10dd1ab4aa",
    "AWSSageMakerRuntime": "bf82ab2a3c8ad18e71b79be5198f4f61385eac9379fed2db405cc2af66f41b91",
    "AWSSimpleDB": "fa327167bfa38564ba2b26993be2c3fae74922adc34ba2b721e189f82069f2ba",
    "AWSTextract": "b4c1d774a78f10f2981d5d31213183a855fda0b4eb754e24689577198b3388f1",
    "AWSTranscribe": "1c5474fa1178374a04fdca71132d09d60e35278202b9938aa4f8ad7285af0496",
    "AWSTranscribeStreaming": "55c92bf9f0de6d74914c0f67f453b72af392042013df93b794d5108bfe988716",
    "AWSTranslate": "1b9b24e3c62ad7465552ea0714b5cf1f29fb832240b50cb27035d3cabfa6a9e2",
    "AWSUserPoolsSignIn": "15885dcb5eda644c82080e98cc608f3b20cdaca9138aca0a19c59ecda791ef51"
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
