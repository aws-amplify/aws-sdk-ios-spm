// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.24.2"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "32f2406801efca20ab92f3d8158152c39c90f4b4a9e9385b6addbbce64bd9629",
    "AWSAppleSignIn": "7f8d3fcf3e1aea13dc3f1ea939ef563aa18393cb4834e9f5ed3563fccaf0d696",
    "AWSAuthCore": "c653dfc524dc3ab5fa26d4be06258ba2a250125f349401df390e169334cf6438",
    "AWSAuthUI": "2bc64b533128bfc95ac93816d4cf77249fcc2a70f0bc50b634322cea3db1e45f",
    "AWSAutoScaling": "f4f5289b8b43dc53e505eff54ca3da2fed7531fa8be0892cc69c2e56a465a2c4",
    "AWSCloudWatch": "c586fcb4dbf2174762ba939d87166a3c4f84f44415a578d97c0524a89206b996",
    "AWSCognitoAuth": "94a72d06386ad0d5bad6a156cdc4a242bfc88b802837a843260da43aa3fa0b80",
    "AWSCognitoIdentityProvider": "7afefccdef3ee2b166f2d128f59b05ca9c07a1638eede527b7a9f63e5155beac",
    "AWSCognitoIdentityProviderASF": "9feff971990b541b6edd9be9f992db8ee65763ae3a741516ae084eb8edfdc742",
    "AWSComprehend": "b3c67048f81b48a0483e9ed51b1b1598814c926b81dec754a65dd3011e8381e9",
    "AWSConnect": "d4be9eae7a0205318eaa0da636b5cd4e1407d223a74b2b1c787171b8eb56d37b",
    "AWSConnectParticipant": "de1926bbc8ce7a7cf2435c1bc30137750765848cc7f5e9fef7fa88da9363ffe3",
    "AWSCore": "d620b8d8a701d195ecdaf83b421bcfd62524a97af9ad250a04288042a342be86",
    "AWSDynamoDB": "b011ee6527a702f0ea174fe50226019fcbed3af7299fcf6d6f654547aac18ef7",
    "AWSEC2": "89977c396713cb8660dedef979bbb04ec6be0df59967bf06c1e55c5df6d9b951",
    "AWSElasticLoadBalancing": "765925516c506d4078b1f7a2306f02b1a7f71c8667add0c4e53305a6e98c07c6",
    "AWSFacebookSignIn": "b6dd8723cdd64a6d6eb0de414f3803e502d088bb1dfc4381088ada9edc95838f",
    "AWSGoogleSignIn": "2a9ff35e95ee3225bd302c919772b0ee272a144e05d6359f1ce949b47275be8e",
    "AWSIoT": "e6803351007dbd6482c5b0faa44c1373f2ee68a85b72040771e16cd04b5bbc16",
    "AWSKMS": "74fd7a57068e3ba54722d33195b5da6d7b7ac77e7038d018546d107e70dd832f",
    "AWSKinesis": "80e8569742af7becf212ca1eceddd35a8081e5ec344fe8237443c0774ca141b1",
    "AWSKinesisVideo": "1b2adc5d1dccb62da6f52fc2b65643055e09fd9fbe82d9387fad6e1c74bc7364",
    "AWSKinesisVideoArchivedMedia": "5a50efecdbd6dff2b841bd338d285962c5634c0d37d62ed46fdee39f5b5cac38",
    "AWSKinesisVideoSignaling": "3e94deee53321f137760eb973cf5969d5ade3fb37e5849f79d5851fdf518a0ed",
    "AWSLambda": "b349df899809e62e5b01be08ddd767c3e03e50dd3628215761311db38290cf55",
    "AWSLex": "07c8c18403c4f885900d2a7bec814d505fa164a268dd2715e7d022ea04059f8f",
    "AWSLocationXCF": "e73f03f0f2ef7d77320dc2cb70342869def29dbb39aff5dfde3abcfe9be56085",
    "AWSLogs": "f0cefb74d42684e186f8e1882df9e0722979c830b6490ba85856e279df502d11",
    "AWSMachineLearning": "5e2c8de6cfdc65268b239bf6bbe1d8c18e80e791ff27c0f2300e69eac627f288",
    "AWSMobileClientXCF": "e5cc0f1d286c41179020ba52b6efc59eddc109919ce1a43da423d9c05c60f657",
    "AWSPinpoint": "6797e49d93b486d00264a36e05e9e809e492d7474955314299575d6d94d82e91",
    "AWSPolly": "0a242c8bfd72045d0d89efe63aa88b57c27409c7cc7eeaf4e95dcd06b004de64",
    "AWSRekognition": "d531936b2767f3783c7c9f1236c8944c0e6ec91e244f1eaee48cc778a7fa0f4c",
    "AWSS3": "5edb4218120c1c99285331aeeb0b4daae5476c9177a21341f5189ec3f0b8e79c",
    "AWSSES": "1cbd178e3a2727cc53dd78bb54e7b27141928860d91ad11547bea246e701d1b1",
    "AWSSNS": "04fefbf33359bae8e514a75f8a49a046b5215e8bb007a24e211c981e845848e8",
    "AWSSQS": "f1969b959eea17f0823bbc329ad26de62eee5552daa84c7ccf0d074cfe201449",
    "AWSSageMakerRuntime": "59a038b3f0f40fc60821cb96d25a1c3370cedfc39c028b73861465ddb16988a2",
    "AWSSimpleDB": "b8c5b1d11dcc75d05884f8b24947152e29dba8b5b3d6b1027510408e9d368d5b",
    "AWSTextract": "683b76c56ea144f36a70844b90392b7ac3ec9f2e36282ad7d1af312b9d2aefd7",
    "AWSTranscribe": "bbbe3c6df488f192cae26e7f30a6bccaa2016c1da05170b768673fd638b21bee",
    "AWSTranscribeStreaming": "225fffce057ab9ddaadd3ce3960660e2fcfb23bc7f6c813710dc7e0c585e47f1",
    "AWSTranslate": "105538ad77ee9f758f76c46b4e235fd5173f0f61c30f556dcf1007e780c47f9d",
    "AWSUserPoolsSignIn": "af75c848c061c897a3f871b55d3abcdd5df9d21951f01b211a45f1ba06cac13d"
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
