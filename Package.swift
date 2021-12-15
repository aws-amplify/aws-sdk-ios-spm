// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.26.6"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"
let localPath = "XCF/"
let localPathEnabled = false

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "7236a6ea944dba80545e7eb8ff6edd0642c39ee7e14c39f53875864ce8c0930f",
    "AWSAppleSignIn": "8b11acd68648ff1dbfc22874b4fda974691052148fb72abb1a6d3892491f2220",
    "AWSAuthCore": "422a2ec8c2ab0c90825f46ca24afb9accfc2f0c833da3e99e2c75abdb7928243",
    "AWSAuthUI": "e8d462b127d4a9d56d590296a9dfec10e0addb77f5f945028387d072974eb426",
    "AWSAutoScaling": "df2b3b8c955b7669bd5041b32ebdc794eabb27c945e77b6f7093ee4563140aaa",
    "AWSChimeSDKIdentity": "34f70a4a50650114bc0642b991dd30b590bd43b091a4a6bd5c48702e2b4a8a59",
    "AWSChimeSDKMessaging": "e59166e1debb187cb5047cba1d336805fe8ee05f4270a10ad47ebc0ca1e6c68c",
    "AWSCloudWatch": "c5ab33530844203df6ac254e702c7797592abe5b7f9e3854ec7a4d508294c88e",
    "AWSCognitoAuth": "cdfea41a1acc15784cbc8e6c94254732c0d263b20b472ca643cca50fd8ea26b4",
    "AWSCognitoIdentityProvider": "20db9fc9391c3e09f702172d914f69720c547faa997397306db65eca2192f75c",
    "AWSCognitoIdentityProviderASF": "801ccc45f44fb127f0beb25084b7291b3ee4bdea23d1dcf047f3d467716bac49",
    "AWSComprehend": "6a38034869575a9a98affae8e50ffdad60a63c21e82703a901b6019ca4f67d28",
    "AWSConnect": "7dcbff5a9def5a2e8b28d86d93ceb447cfedaf21f44cce1a3623c93883009a20",
    "AWSConnectParticipant": "89a18c52613002df4f81962611da9e1427ad5efb770789c169e81fab781c311a",
    "AWSCore": "87ee470abd68c4313509e192301b94081d4bf4fe97d24db70040aa56b81c1f50",
    "AWSDynamoDB": "d0a1c38b9ed9a68e351c509c3eadd23a633be93ff7c1579a2c863bc7d38b3e91",
    "AWSEC2": "c2833fa3f8a73bcb92eecd2eaab8ec47eefe497515dd460cd34add833c059566",
    "AWSElasticLoadBalancing": "9d6f510cf55008b218961335c2ca0753761f957192c145bb815660a831ee2727",
    "AWSFacebookSignIn": "fecd0bf39dc32b0b15970a020b191b739b4e16503202fd5aefc0dbb9486869c7",
    "AWSGoogleSignIn": "6f1aeb9f590475e6b357cd013cebf2c1ac024216ec34b4ca7bd68fad7449cd77",
    "AWSIoT": "c0f4cea6aede98374dd30b4269fc23f35626cfe3376383435e818c6fef429f9a",
    "AWSKMS": "958003d8760c636e7206bd39712be536e47f13f6dcb3e888cfae2a919ef8d825",
    "AWSKinesis": "f1d6f91bd38504e9f465c46e36fc825ae187d2287d74df62baf09ab855902fc1",
    "AWSKinesisVideo": "73db9a7cf3fe7f1bb743b6da87092848a30f6be4deb1f36cd060cdf75235331c",
    "AWSKinesisVideoArchivedMedia": "7692c3bb77cddded045692465d9936851adb23a3415c0acb9bb7dbcb61741974",
    "AWSKinesisVideoSignaling": "92f29b12d4b2bb5e8909510bca88ac44996821cf55a4d86001f9d8ffd1c507b5",
    "AWSLambda": "b4bbee568109cf7740f185a70e2a5ac2bc014841d33a1b3cec0f08963794d5bb",
    "AWSLex": "67b150a64e4232c14e6b6fbb52e71354ddbcfcf85cdb629c4229f3e36fbd49ca",
    "AWSLocationXCF": "230ff13dda2dfc27fb57ee12d6b2c49ffa2d6fbf4246d93245e91a1359e7ff69",
    "AWSLogs": "f71416a585794de0456ee6f7e6abcf7f42ce4a1ebbbaa9a871085b1d465d4d07",
    "AWSMachineLearning": "15928447e1d53f04710c62b08518f762547946bbb09f88e4a372f701eda018d3",
    "AWSMobileClientXCF": "9fecacb04cf877fe48976692b24e72ea2459d65150ef502b05315fa165952490",
    "AWSPinpoint": "3fabefcf9d802c5cb475d2fae61fa5466f0bf8d5d3f9a8eee81bbd8cebbf90ac",
    "AWSPolly": "a0ea9b878c4d167820277b40abfa25d535c7a59806e7f008d1fd4886cc6b68f2",
    "AWSRekognition": "89ae43d266d3a89eca735e2ecb39f5753843c88070fa8fd8bcf6d49fdb0c33b0",
    "AWSS3": "0ebf9e3710da280be13ca3a4192a66e02a80b85618fca32a96f2288b552fc938",
    "AWSSES": "9c2d3c993b1bbf09f0ab377f1c1464896f94ddc2292b0532a694703e8b32bd55",
    "AWSSNS": "2001910dcc6727abe36e7b5c97f8e021c84bf0097568c6f73126394d32711a22",
    "AWSSQS": "950af199198d93fdbd33d22a6f618b6e1ec98ecdb78d996dbb1889e9a2f78a4a",
    "AWSSageMakerRuntime": "f03ae7c59531ead77e4a01a0ffbbffdf620032f1349fd78843a580ee4f74a2b3",
    "AWSSimpleDB": "b4f91644315910dd9a2fe5094c6cf9bd6034de3b816c5bd098f470e5f565f977",
    "AWSTextract": "47e538494371099c23fb8dec8dd5976787675cc85e19227fac591fa9d3c2b3fd",
    "AWSTranscribe": "c70a036547c840fbde737192b19d8db527a21b69793018a73844981daaa47f58",
    "AWSTranscribeStreaming": "946785035277f72866d39502e5e2d46a8a256365afcedccec7368efdcf8a3fe6",
    "AWSTranslate": "8dc6d5bec07fbfd3d249b2d0abc2cea88d7c85dc7326eecd4cde5c1145990bca",
    "AWSUserPoolsSignIn": "f79706bfe0182810d2415f12da6d269b3ac2b5275766525b9440ca3d1115dfa3"
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
