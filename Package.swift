// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.24.4"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "21c4b5470531fd48fdebb8053fd14e329ce8c2f5ec89b34521b908c3d3aa0456",
    "AWSAppleSignIn": "2e5d3f647d258ed8a43fb86026ffc44ba660042235556865d4267830237c4e45",
    "AWSAuthCore": "da49b1d4fe50e7c4da7521d51033ab1d5d120fc8ba1c0c8df6ad1ce0e6d47e89",
    "AWSAuthUI": "5969e95a6116f99cb6f61e4ec7b5f5082f12f85c1732d43bbb69eb681b82601a",
    "AWSAutoScaling": "eed8767e244d28f7221c318d29a67f0e55ef821a732f53f10d8976a6eaa13d68",
    "AWSCloudWatch": "866d28670e0bba0a3607a8bee66cffbc556e97f3d7938dd6c12e99db5f3677a6",
    "AWSCognitoAuth": "ba224d22a71668966391d322e7095677bd456a17e68e8de990500624fc1cd92d",
    "AWSCognitoIdentityProvider": "d1a74d776b5a20b6cdb7c37373b281c664fb7c1416456e09765263bb0522bb12",
    "AWSCognitoIdentityProviderASF": "b94b842bfa01d3fd9fcfca1bba5280e24f1c85793445567c50199e69bddbbaa2",
    "AWSComprehend": "d9b17f0f4fb282a4268dbeab017639872e625c293265e988d925d0529209773f",
    "AWSConnect": "715ea716ce66e7bc41d7f4c58fed11886d6f7106cf590a0420a825e158c4b495",
    "AWSConnectParticipant": "a7ea73828986d5177bac22040094b5e0112542f30972d6fcd465a2fedd6809b0",
    "AWSCore": "eb23658cbf66dfe090cc9a23e1595d7e0646cdc1d9925384bd49623020628a5a",
    "AWSDynamoDB": "8eea183180e3e9ceffe7b4df3744ab35f3f8e65b7bc628a1fe078abc08cce315",
    "AWSEC2": "0088f6ff0ff4071eb88071749036a1531d00f9a4d679c53bb19b2cacc122cb33",
    "AWSElasticLoadBalancing": "7fe924e6582849ff552f74cd143de287066a5fee7b9c772cec57c7ef063b3529",
    "AWSFacebookSignIn": "951e66b560031c003687e9932d0d1bb0e9a223ba8d10062e111bfd74e4f9a706",
    "AWSGoogleSignIn": "600a34f229625bd32a2419d5c8efb12261106921fe6ba1c0b4fa290e4f054b34",
    "AWSIoT": "94e0d0324cd02618db516732769866b57ad1ce5e6bc85895014b94381c9109bb",
    "AWSKMS": "053224a3771f5c9c279e1f8d7a756a973dcef97385f0499509042605a6fc926f",
    "AWSKinesis": "3af5a804e2cf9c5697e1c56e36f85a5edba2984447dfc6feb15f8b5345256705",
    "AWSKinesisVideo": "00c3e52985ce1c49f8b657d2fe6396c6c81a48c7142abc88c6f712401a8a5085",
    "AWSKinesisVideoArchivedMedia": "84c3886aa240b88c5971d49e4a642bb76fbbbf8d43dd5e85a9b282262616d6f9",
    "AWSKinesisVideoSignaling": "f302735b10eaeec9c90fe9a9390d5ac063784a49b1ebc00dac262ca828557771",
    "AWSLambda": "d7f4853af40ffbbb3555e44b01c5d9774aa4c3b8f39fd468d05302fffd4e32d8",
    "AWSLex": "b1aadd5e16bd1dd8c0485c391cc80805385fc5528864be445f2eafc210355acb",
    "AWSLocationXCF": "afe47f17d18af46cc49e122065139da8f8b3cc24137b9797b5037cfa65b673e6",
    "AWSLogs": "60c877bb27d5086294eab4eddf226e27a6a74eef5f3c9842848097dcef7c78b6",
    "AWSMachineLearning": "8588d12650b73949f3f69f59b971ad962d228c380f82314e6fb46fc30b076536",
    "AWSMobileClientXCF": "4a66b5217aae6f37a5fc39d9c3b6ffd1abcdcb2059d1be131d4eaf6c830f287d",
    "AWSPinpoint": "2b3083860733e65ca723a0473d1f9634fad6bdc58f95bde9ca66b5d5a90331b9",
    "AWSPolly": "d318797e8a233608a7df506887739f50f26bdadb7819e3e7a3b25780e3031755",
    "AWSRekognition": "1524e22403502dda40fea468fa2c42c2ee355c8cad6530d6a1f28064ad553c5d",
    "AWSS3": "f5a7b90e457d58bb0900c29451a14b47a8056f041b16bb0f3368d685f10bf5e0",
    "AWSSES": "fb63bf7be6d6a287d717262c3e687410ecbc7325c9653b4537c37f39b5dff780",
    "AWSSNS": "b5d8debcdde910cb011b9a51da166aa2f066717e3a93b5ab5254c304b98b9dc8",
    "AWSSQS": "8ac9ef530585fcdb7d7090580a6c4f9c4c02ff9e9f03a180a04cb4130ad82433",
    "AWSSageMakerRuntime": "c239070740f27dea92606a60216a74a670d89844c9492d9a5a47d799e98ea64a",
    "AWSSimpleDB": "ca418ca54d260f5f5053e48d1581822e443abe056aabf43cdec50b1dca059778",
    "AWSTextract": "180ad862f478bf3cf59b1c7a19494eb81c5cf4de75edb9305303ad10e41b3cce",
    "AWSTranscribe": "4f8b261d926dce1ce1c9f86ea45d8b37371dc62152e116aa076320183cceaaa5",
    "AWSTranscribeStreaming": "5cfffe155af1773c8e481ba0141b9c8c896f435ceb5ec8b71d111417b17bf908",
    "AWSTranslate": "09d4386b3173051444ecd2f1df2bbbef4e1a3e36da06ec71e6ccaafb12fae26a",
    "AWSUserPoolsSignIn": "897ec865dfce19ebd78e57fb08f786672a1a14ba699d3a4f6d3ad499a03cd6f4"
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
