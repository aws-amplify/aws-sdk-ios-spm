// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.26.0"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"
let localPath = "XCF/"
let localPathEnabled = false

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "45149b1a4289f4594b56e5798aa6506e1685bd7ab35b8b1ec2ccad1c1e083881",
    "AWSAppleSignIn": "2fde46b35e7fd22bb806f7769400f71f74d329656d6961dd5a06c6e259ffa4fc",
    "AWSAuthCore": "3d39823f111603ddf32e8c38786e613fc0e4cad5b49fb9dec094687ec4c2104f",
    "AWSAuthUI": "462957894ca05abffab362ad290e9bac3090c98b0dc2439a2caf5a5307cd83e8",
    "AWSAutoScaling": "77c3745561212168c057f94a353381aaa335d5316a77aa5ccb1380ca0124cffe",
    "AWSChimeSDKIdentity": "0c6b8608abe52405af8b1a125f30d4f164fd09e229c0bb58825cf96a5046277d",
    "AWSChimeSDKMessaging": "99643a3ca3347c5c5dce6b9d7419a441d5b5c052eac409a174e6ac3f67e24f56",
    "AWSCloudWatch": "d8c956551df9dc1c02a82b67a1baaeabce6c324eb56c18685458da734a12600d",
    "AWSCognitoAuth": "f79abbe17415bcc97211525bc08234a382d75c14fcbe683b2131f94833eabdce",
    "AWSCognitoIdentityProvider": "12a71ee090a3fe152963fa19abe363e75dc093a984283f0a238b9f9faaba5110",
    "AWSCognitoIdentityProviderASF": "83e44f5bc8a7430863643efa3e6ec95ec5d5b4c0050526ea21e12567b27c6ab9",
    "AWSComprehend": "23cd2b0f89d0253c3fa9593f7ad6357a257071699dfb880e74fdb983a346cf9b",
    "AWSConnect": "c682acdf6ff0064acd1a3d11103b47c76ad49a4c7926cc5c5708e619a4308893",
    "AWSConnectParticipant": "8de6808500e428c53845abdf91bf08cf02d3548d69a41c8af5e1a5dedcd84c96",
    "AWSCore": "9d66226ec5cdfe3e98c90d64a59549667e938078d16305e1543c78beb42a6acd",
    "AWSDynamoDB": "5210675fbdea9d7c43a4f1509a007a823e9f415f40def706ed7710037691ae08",
    "AWSEC2": "9fec334be1eb3641f27ab30041b60293cc61ed0be33801d3d0da339d724fe8e2",
    "AWSElasticLoadBalancing": "b007cfcffb16d8fa85b61d3b7f6c689737cff63a3382d013c1306707972adef3",
    "AWSFacebookSignIn": "f20fe0609fbb1546ff0213845aa42545b2799dc66467e470075bea2ede69fe11",
    "AWSGoogleSignIn": "4b376d781d62241634d27e71124b5f9b8c1ad1a17671bc16d81a73b15472036b",
    "AWSIoT": "d22f907b15666b8886a4797fe0eddb803d31c23aa699782161c6afa20362dfa3",
    "AWSKMS": "af6f217ee911b4b2bbd583fc1d66032d78cce7b4ec33310918499e691e2f1ef3",
    "AWSKinesis": "fad6f89dd95819905e4c4a076d875352a2be4ca71967c676b0d99e294134de7d",
    "AWSKinesisVideo": "933b391d97063a6dc2612997fccb07f964c59097dae8d5ac08d6c89fef6c3304",
    "AWSKinesisVideoArchivedMedia": "29b21315bd337a2cd28816e90082a27815e7e3ee050e0beb1e431d3d09cc82d6",
    "AWSKinesisVideoSignaling": "5cc0859fd9635784b13d076830ddd109a06c250af2c75963a7a97fc6f9949fdd",
    "AWSLambda": "8c02d0e00fbfb6f63da04a0a260df32bbaf15ae203e807b50eee8830165582d8",
    "AWSLex": "52a05c33c0d03417d07d6d0026ad555edd79ee489df273656b5c770d4f3f7fe2",
    "AWSLocationXCF": "a06c372ba8d822910d0e03783b472f3042d1e8066fc63b3ad6e398eaf9d06d7e",
    "AWSLogs": "b13bfe180be6f935cb0a06498657dd672cb9fb4a5ce8843f724b07b657828067",
    "AWSMachineLearning": "116becc679c77a519083ae1f104580bf906b5013a86fffadbfdbb6bc83574f58",
    "AWSMobileClientXCF": "a82beeff775a3ac3a31960ea717dbc7b2f5e2ba1c3d72fa6cc6c0258ade08ca7",
    "AWSPinpoint": "4204d85242604f53c767e5c774510ee75984e50336979a9f6d54f7aacc4948a6",
    "AWSPolly": "0bcc6f07b900da5f2e08cbbc595adb1ae66be2c57f32cf50727da5955a51e61e",
    "AWSRekognition": "e81a1c1a67767417a6d29b73821836d86001047a9c1dda0c9be82756d96ed1db",
    "AWSS3": "34455aebbc98b48af65517700cecc36dbd7321581868adb78102ff6a6a9ff18b",
    "AWSSES": "d7c9a4b419607c4cfd60e5a3485683fdbbac35e95876b6223d7813e8ff559d4e",
    "AWSSNS": "d6cd9bc0b8f2610dd29a4038b3fcb7dd0bdcdeb38f48cf00619a026c86b6c022",
    "AWSSQS": "29b5d994818f8785ffb0e71c4cc3a0e344f0e1e7407f37e28dc4fe9611c264ea",
    "AWSSageMakerRuntime": "f31a3e8ea5ed3160931545852950e1f6bfa2fef7fa0e5927228d6499b4de2239",
    "AWSSimpleDB": "1c514e09f23f3cba2b891e79bb0169d3a6d14a016744f851b0a33789df264250",
    "AWSTextract": "3caa5dce1e2fecf31bb65a152581cc80a08990a190c9cede843aee98c878c784",
    "AWSTranscribe": "7cbe1ad9b5526c71f124df894aa8e3cf8aae290cce8903eefd8e00523d599807",
    "AWSTranscribeStreaming": "d96a19dae2d28129da5e33227390f018bb583db2cc01785adcfb9744a57663fb",
    "AWSTranslate": "16efa6d712e2fe2967c7109109bb6222f8f84390ed08a59f378404b1782a2d73",
    "AWSUserPoolsSignIn": "bc20da40eb0943afd113d257077a034fcf6f8db2f9bb6fda35b62ab786c836c1"
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
