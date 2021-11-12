// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.26.4"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"
let localPath = "XCF/"
let localPathEnabled = false

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "174cd9381fb7d71abf05f7fafb2578600af8b9a19f74e52eef6b6dc4b3fa7d07",
    "AWSAppleSignIn": "b8c662a095b09aec9103a28d6077e080dae97795e9b6e397798163b9dbe99f96",
    "AWSAuthCore": "88e7215dfd35b3df2169a4a0221b577e49f7c0c912cdb22b11c8ea4f9958ca0e",
    "AWSAuthUI": "263a286c45d87da1290b97bb125daf73d4368e119d350298ec98b3d590159a10",
    "AWSAutoScaling": "cca72071a047b3c1afca65f23d44eda2ce0b75c5d853a1a9a3c8d6b51c3ea6cd",
    "AWSChimeSDKIdentity": "1052e1c168a7e8aec505f952be6cc0b22b70e125802bb714c73e15db924ebda6",
    "AWSChimeSDKMessaging": "147fc1c4fcd53ea950fc68abb7d5486267477c8a3c533a1bb9cea2b62f7e47fa",
    "AWSCloudWatch": "76bc2c330e14362026e380008855d68e97b90821ed983ffa1cb82f19c4fcd192",
    "AWSCognitoAuth": "81ce847393f904350cc9fb88c06594d9fe4e54d8a12fc5a9b43fbd54210e0c82",
    "AWSCognitoIdentityProvider": "2045be297c54da33559810c3200f33cdf00fe64814767bb8d3017ff9281508b7",
    "AWSCognitoIdentityProviderASF": "9c8bed2f624201c262fb81e09f0aa8c70761c00ff1b89759bac1d3f52c5c5a3a",
    "AWSComprehend": "037426d415db3280484da8de8224f0a4e41f98d5f0074ebe29a722ba88aa4e26",
    "AWSConnect": "1c0e3ae114bc7e59c0bb930f8dde9dbb57b56c40c22b95b6777d090d6e086e65",
    "AWSConnectParticipant": "0224caf5df3d8a5ed7935f989ecc668ea39554da57a601baf2585b86d3db0cf7",
    "AWSCore": "2605c5a69a0c272673e034d23f22ecd878ec6c0acc73bf59a693df6a4481c5b9",
    "AWSDynamoDB": "21e4e1d7534bfd88ac775a5fe6b2b668ea244478d4d28a899672db5419fa74aa",
    "AWSEC2": "fddc3d7d299de497a8f8e8cf91b51a911d56fc1f5c2ae5466368746f88a3b32b",
    "AWSElasticLoadBalancing": "f04b5cfaa506fb6a35940a82a8750317cfe43d0bd75c27264173152c74103266",
    "AWSFacebookSignIn": "aff1e37aca671eac67c5f216bd632bb5919de1a7f685b4c9dad16269f5a5fe84",
    "AWSGoogleSignIn": "8225f21bb263e5bba91fe3e694edd4978bd425b524af089487047b5dc3f731b5",
    "AWSIoT": "2587847df9890b9e5dbcb87cf81b166714724cd765027d36068648bca660b329",
    "AWSKMS": "ace80c79250077ea54192239256bd37723152a9ae2e5f3f257f7565ee79307f0",
    "AWSKinesis": "2fcf8b8581f7ce1a2810022fb9caef31b474028d43f296bef082aedda8ae5d07",
    "AWSKinesisVideo": "6d790b187cfee58947d3246ba74dd17d6528f2677d1bbd6833bb622067eceb98",
    "AWSKinesisVideoArchivedMedia": "5c9d065e048dcb8a6dd6287da72d28eb701b4cf7f986dc6c61c6b232a035623e",
    "AWSKinesisVideoSignaling": "0d21950134fabd0e82f1ef30ab861b1db51ee4f7efbf0aac8484a38bf7228d6a",
    "AWSLambda": "86e0952114ea442d8094026e1770360fe36c779bbe4eaa395900d4d991f20b62",
    "AWSLex": "86d66c2f515a37f36845803458216f456ada0831fc0259a4ba1a45757fc74b5c",
    "AWSLocationXCF": "822ed295aee4b3220ca625503bc344c3ceae553aa2a613472c114188aa66bcc4",
    "AWSLogs": "5b0bbaad7feb89e28683848af4c56fa90c4e259a993817449abe2eaa833a5f4c",
    "AWSMachineLearning": "ed691ac5cd34682bad0bf7e06313bd503a61e5a37ea3256fc5530ac121d52df4",
    "AWSMobileClientXCF": "ca730e0dda2ac37a6e76cbe10c29bb36ca44903fc29655ce02475a8086873810",
    "AWSPinpoint": "c9ce14e428a9a357d9d37995d0050bb0f410899315bbdfa68087054b63385374",
    "AWSPolly": "a63ee02a2d0fe6fac3077a6c1878529171bf2a3f536391e0136cd4c95cea710f",
    "AWSRekognition": "7cb93096ce1030cbd87014dd379e9b08d4f28369f8f7d2e89ed3c3018f828878",
    "AWSS3": "f037fe245b4d29920f798d02d1801710f228c86a934c184fc16b4f6e9b13513a",
    "AWSSES": "1e39094d24db0d81d85acbb8d16a4fd3a1c02da53c2dec4ed81c801024ffae19",
    "AWSSNS": "740734f19746a094cb6594ff81402aa9e86cbcb7d67ca28861418957adf85a4a",
    "AWSSQS": "93faa2e8a118d4f940d269f8363da562d3a7c9cc107e17606b2429e5ef8fe214",
    "AWSSageMakerRuntime": "6109c0df1218747eecb9abd830af16cec57a56a7688b9bb23bff4ef059d83ed2",
    "AWSSimpleDB": "857616568339aa98a39c5b5343283b2d84c7e7cdaee990d915627207d3e04508",
    "AWSTextract": "1df07e0070f76cc7299199a93c5088bd37d97a4bdc892001f58665f20ff52cfe",
    "AWSTranscribe": "33bbeba795a4f9366a896a9392189e5993cd4e7ab6be91570b4be5aa9fdf755e",
    "AWSTranscribeStreaming": "f225948cb20641d80068719c53841c16bd9af0d4c19b02bd5f22da9abb528736",
    "AWSTranslate": "4ef6fee059e3c1bae8e999c419e619cfeae085ae79322af30cb3d65152c8c41e",
    "AWSUserPoolsSignIn": "b637466545b41a810c75b2a8ba85ecf868469a33cd13d6c995c6a2dc8df30fa1"
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
