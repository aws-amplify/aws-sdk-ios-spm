// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.24.5"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "223fffb42155c948f615e209f63b5d429b6e2857be2f687f716eddd5b797fd0e",
    "AWSAppleSignIn": "62f770e4bc9d710b2271fe56ac060d75b98d2eeb3ed5c70a1609bb26c69e2ace",
    "AWSAuthCore": "97dde7f2ceb27eb3c6d46b6e50c8f7abc9d454906634fc3bbb5c837657ef736d",
    "AWSAuthUI": "d687027242701af0ffb4e08d29fb947a1fe724955c2a27489225d7432485eb12",
    "AWSAutoScaling": "cfb914808fd012cac5ebce3301e55083db06cec2d1c11f91b9b4a2992e788c45",
    "AWSChimeSDKIdentity": "c504ca0ccd3012c486d164955330c132d101df24a5f09ab707b22fa6ecb15e7f",
    "AWSChimeSDKMessaging": "c455319e9ee2f6d8a45b740810d1e0890e47a05fa5a47ac1a1c727a1d57809bb",
    "AWSCloudWatch": "183de8cc336cacfa9ea8bd8ef155e8b412e038527dc8c8a8f1a921f34941671a",
    "AWSCognitoAuth": "612f0220bec2df4c83c329d57bf40d38bd36342209e232835f81ba53ee1e60bb",
    "AWSCognitoIdentityProvider": "243719e81798ba9aae0f26ba03e82df85106ff96ef60621a1634495f5c965e14",
    "AWSCognitoIdentityProviderASF": "406b04ec1da13822fb0be454fa3dc7aa3fe65ac9bbf814e4b07b3d63b51877cf",
    "AWSComprehend": "594464d52a5c12206766cc0542077499a49a24214c5f697325ea452cc32be35c",
    "AWSConnect": "340938ff31618f95062d6ca5f89e8a91a53406ce7559c9e4bef23157ab57921d",
    "AWSConnectParticipant": "d5c64eda44f7343204e8311508685a8e7c73954f4fe184e89a65f68ad506eb2c",
    "AWSCore": "6da1e292fff3b5cf85105b16482cec16de43174b42a5990e960f061d4c8a6bc3",
    "AWSDynamoDB": "5c2d60b81020d694163894900fffd224a398d6a0e47d6935ae95ccb04adbb7cc",
    "AWSEC2": "b0f920f0936758080c440dcb5a4a0657359a20db1bc3e2ec3c0b70ae06bbd8bd",
    "AWSElasticLoadBalancing": "41951c30f4932431cca8cf22fe230865645982adf7f43cbaedab3ae7a99a622a",
    "AWSFacebookSignIn": "3979b5acc9c80a663c25dfa1e37da4ffdd7b27cef191b9a82dd1a2f959e7a4ee",
    "AWSGoogleSignIn": "a4cf19e4863e36860f5407948196f7187388a0a547afa54576cb466d8db2936d",
    "AWSIoT": "34c6027e637129af036b9e6156ed6390b3b6109e232e813e0bca797dec320261",
    "AWSKMS": "867187f06eb7ebff070fcb0b0dd2b4883f59a0f686831b3bf391d1972986ee62",
    "AWSKinesis": "b665b3110eab037c25673c794632dcd60897ab23c979405f10c216582ef9497b",
    "AWSKinesisVideo": "e1fa91f542722b9bc5a05ed3a7b75b6156d0f9befd06679eddef021da348b8cf",
    "AWSKinesisVideoArchivedMedia": "e6fbb2c14f97ce60021ac53d15148422ab9573f3b8b01759f94dcdc041777ed7",
    "AWSKinesisVideoSignaling": "f2a2bb43fb41da4f6e82de45add0cd2142dc47bf53a58299a6702d84625e9985",
    "AWSLambda": "12e38601233b4d4ae8883663ff0503d03ea0012d2af790e682715fbb754121af",
    "AWSLex": "31194409e0c3f8aff96a44387115a4eaa58f35bc1ec947852eb2e85bf075ac7c",
    "AWSLocationXCF": "c64e7e25a13c82eca67ffa82c82cc728fa69108479c0523a4acd1b7c2998770e",
    "AWSLogs": "071ca03cfd71d8a82bf2a7adbbc19da5f497ffcd250010dc764a5b4cfb9d5128",
    "AWSMachineLearning": "7c7f08486d74c98816c6ccfe1cbbf260a06917106cb29d3f4681f6fdc2fcb53b",
    "AWSMobileClientXCF": "9f1674d7e965253bd1c7189dfa88edf28a34def6146e4a5cc6e80feb6c5dc0bf",
    "AWSPinpoint": "2a3147f050153a3f20dfa26ac08f0b41d6d1e14a8759359899eed58bd39fbb0a",
    "AWSPolly": "9e3b9aa3e1f6577aa7a200606097b951ef2b07a1a30fee32b90df6f0a867ee28",
    "AWSRekognition": "cf9386ef39735595f0d45af7fc7c0639bd3b6e675324e801369e8ddd90bdf41a",
    "AWSS3": "f293d016ddc665f3ae705b82e4b8e474b84f936de6f4ada8c47d4cdb480339de",
    "AWSSES": "39996e287046e18b8ee5215a2e714522938f4db8ba5f448133ef7de0b2affe5a",
    "AWSSNS": "4d2a0b8796a9a3245b5a0010557503c444542ca1f0ee8f90bd0acaf1ad506876",
    "AWSSQS": "81d68cb910caad6eb0adfffbb0bb473209d9f8c8c96f64631209b0f8f571f729",
    "AWSSageMakerRuntime": "0c7baeb2ae28ff2c2ec60b42b9ce8b7ecb26ea816e96d7001d505afb79871027",
    "AWSSimpleDB": "815b601f34a734f69076e6bc5e6581f7d11fa4741e1ff5edbaf6dd22b01ca21f",
    "AWSTextract": "9a0e7c6c5e7e2a2c0c8196112b40acd47141983b45367e82a14dd30abf2d9f2e",
    "AWSTranscribe": "76b3f17e56f731e9e7cab439b4c92ac36dedef3b9462db4c9b5199f996fba667",
    "AWSTranscribeStreaming": "616524f12117893bc9b2368f11c2ac9f3f75aa57c52923af1c3c99b09cd2c3c5",
    "AWSTranslate": "094064aee44e89e1459e17d42ca64c181490a128b15fcb8e618e289bc6bdda1d",
    "AWSUserPoolsSignIn": "2e40070696840976a9f817c9fbd03198fe08c908691d51c1a4138d54d80c0f63"
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
