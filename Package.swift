// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.23.4"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "a251bd470d033914d847a95f5fd1595a3bc6f45a55c016685bc5e8faf8f86d2a",
    "AWSAppleSignIn": "bf6d142a540944cd5291f40f3dd03b58f30ef4005179c667be8de26a23462ae7",
    "AWSAuthCore": "d87db8ebbcc11cc8fd489b4fbc542629eb816fefcbdbb9dcc7103581fca475d6",
    "AWSAuthUI": "999d2c49c3c4f66476eeae89b9892c23dbdf3929bd9b99e8b591cdccbd82b625",
    "AWSAutoScaling": "b49788def66e6489412a1d569a57a0b8d4a9075d85ef8ab7fca3f5ccc70c24eb",
    "AWSCloudWatch": "1e2d5792515f61adf9acc4b7a423e48769a627a52831a836d649e0ac62f2cd2c",
    "AWSCognitoAuth": "1ccfedefc70507d8d697b1cfef66d7a817e9b5f5b02606e604eb009241bccdbb",
    "AWSCognitoIdentityProvider": "6baba157ddd619bba5e84147a37a4074d3badfabbc808305950115f35e3d11df",
    "AWSCognitoIdentityProviderASF": "3013efc9cc79fae9c4c523def8c782f0562b984456cbe8be3d60bc13c4226317",
    "AWSComprehend": "297489d7a74de18d68b6844de03631d58cad0a0277c61aa646d7f053dc9756e7",
    "AWSConnect": "e53642da6bc3b8380b5393f2d3b89cc82c1d729f72969317689e00b5110cc35d",
    "AWSConnectParticipant": "d90ad5cf76609fe9eb512269232724dd6dacbfff783cee8dd48c36cbe79abb16",
    "AWSCore": "d4df2314268f7e3f0bba4358b6ea29153a164f7551ebe1061880b8033e749c18",
    "AWSDynamoDB": "c6d21b31e026d38b4ddcffdb1903862306a2d78bbb0059be7cfff774bb251d8c",
    "AWSEC2": "ac44683181e3753895bdd084c0cb06e2be2840969a1388cd1605f7a721a07697",
    "AWSElasticLoadBalancing": "46e354b7c47948d1c7adc9b3ffa0c89bc59a08b73a74a62a8d0e203f339396f5",
    "AWSFacebookSignIn": "0e099f020bb5fcad653f034c6d0ea5438fb0a9ce6aff385f565159b09d7965c7",
    "AWSGoogleSignIn": "8242c65c5b564b0b40cdcb30ae6b1eeca81f08aade03b492fce4fa0e2bd12c69",
    "AWSIoT": "314afb167e1923de74d394ffb95815da0adffbd1b5697658b25ae4cb7d8c855c",
    "AWSKMS": "7ffb86fcf1d6dd7c9b3ee3c5689f6e2d5713c9ba8e45b274972554e0b493611a",
    "AWSKinesis": "1d011f21100e2d3e181710eb87b5cc882e43cbc70ed09e49fc28b8841bfaf1f2",
    "AWSKinesisVideo": "fed6c1ca26ce53c3c89a25f25b03b19a1e142746afcbcf6a7d764dc6db861f25",
    "AWSKinesisVideoArchivedMedia": "fbdaad66d9dc1b2cb8b317e53c010fcfd53f727dc40afc64e5ffd27e63f58c8e",
    "AWSKinesisVideoSignaling": "70c1cdaa083c73d6de833725fa6ef0f943ba3750b446ff844073ba39f3a6dbe4",
    "AWSLambda": "1aea959fa2599b7b05b836a4e455e8fb6524cbe0782fc192458e50efd92878d3",
    "AWSLex": "256e7d7a2203d9b5366ea63c4947d8043cf94fa2fa9fad2845dacc6ca26b0432",
    "AWSLocationXCF": "1b4f719855023412f0bdecbc9658bdcfa35c7c0d99403a040e0317cae4091530",
    "AWSLogs": "6d5239b47b9712f06b548c1c59e31b01a7d4619fc16c9968929a8fa263b08ab8",
    "AWSMachineLearning": "f682cb19b28eaee73bf57fe6d20dd6667a6c383f09aa1f8178ac3d7d0eecde64",
    "AWSMobileClientXCF": "b39f05d3d3de7ee8cdb9b1fa9ed02a6550c80a27c0aaab71baa13768cc066596",
    "AWSPinpoint": "e071394fcffeebb498988272a28090a5e336b303ccf8198ded58a320438001e0",
    "AWSPolly": "0c9534fdc9f4b8ecdb70e730f495c6a993889c2d87b4b66419e57f9b64187815",
    "AWSRekognition": "e05a31fb36aa50190ff0240d1c1cfb569fafba92f7a099b04eb133ed567b4f42",
    "AWSS3": "35be41b54f5cbf1370182d8fa7f05d77f07f29d33c655b23349b4297d8bcd76c",
    "AWSSES": "d080bf128f03c58f7854d6bf8d861a9b8881ba01fbab523e796c9dcff7d2f790",
    "AWSSNS": "2e22179c98ea33d21124db178472e45da1757ba68f5a9542fb5da8338eadacbd",
    "AWSSQS": "f1b9118da4d8978bf6d98960e15888b208c18eac00ec1edec34456d85bd94478",
    "AWSSageMakerRuntime": "684ecf293a2b7cf6ba8669757efe8db80976b5c0647c96edaef9b5117d01dfac",
    "AWSSimpleDB": "6cf0bcdd6457153699a8a3efd95941dab1ff0d5a55c1382f069bcdc4d4284292",
    "AWSTextract": "a8ae74d6be24f7c6894afa25148ace57b4e3af7ed9adbfb104b7c0428cfafa22",
    "AWSTranscribe": "cfa5f4565058a9061c514f5ab753e269b1c54859d47a0e8ec914079c5af7017e",
    "AWSTranscribeStreaming": "954d389866ae8aa5bae9a78347c8af0ecf483e52fdd6fb4e84c5fb8fde79fbd3",
    "AWSTranslate": "5a35b88c170c8a01df77d99f8e689ccb180b28e7f74c4ca392be8e6e8a036890",
    "AWSUserPoolsSignIn": "f390249ba5287f2c13d8e7108fcb8e9cba39bf056a94d5c5cc3996af697bd5c3"
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
