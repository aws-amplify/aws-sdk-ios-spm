// swift-tools-version:5.3
import PackageDescription

// Current stable version of the AWS iOS SDK
// 
// This value will be updated by the CI/CD pipeline and should not be
// updated manually
let latestVersion = "2.24.1"

// Hosting url where the release artifacts are hosted.
let hostingUrl = "https://releases.amplify.aws/aws-sdk-ios/"

// Map between the available frameworks and the checksum
//
// The checksum value will be updated by the CI/CD pipeline and should 
// not be updated manually
let frameworksToChecksum = [
    "AWSAPIGateway": "cd33dc57baee393a4ec052ac92ee1fe33ea6689429d3e968a4fbf98090f9c7aa",
    "AWSAppleSignIn": "d6c08b97360502fb6c0891f15355937781c5acfe6cf0d6d55d44eb55bfe623d9",
    "AWSAuthCore": "5604f34d77b2559a3e0156c8003bd1d6ad24228677a9a76cf6e835ea1f903c11",
    "AWSAuthUI": "3ffaa2d14aaaff9cc4f523cc5c2c518b4ed8a78a5beb3c296274591a4de61ab4",
    "AWSAutoScaling": "b3a2b03381734b321a27412a1ece4c58688a5ce473e4e08e607d09d411d887d2",
    "AWSCloudWatch": "527c7d5450e60defd81107f98d2f414ecacb602bd52ce8636603944564186df6",
    "AWSCognitoAuth": "66e3c865b0283a612178178ed688e870af50c1f8109cbb163a3270a8c45e84b1",
    "AWSCognitoIdentityProvider": "bac7cc32d8da95ed1c68c2e0df71139a1ce1dd06d1a51fba4674870ccc17d225",
    "AWSCognitoIdentityProviderASF": "94d8b8c4b2861fb44db6c730aff8b2d9759b9c7c7368fa1227ee3e5292efaf55",
    "AWSComprehend": "71d2da519fa245983284ccce9951681221744233e8a0e123e1b343a485f6aae5",
    "AWSConnect": "f1827b11733df92fc78cf2d8f93f1ed46cc6e4c66b3d20499fdb7643bdc6e8ee",
    "AWSConnectParticipant": "13f46ef0267672d4f32f40fa395669509acabb5131732298d90acb84a2a3d9e4",
    "AWSCore": "c4de9eb201f357c85687373161283b24d41e7146ae5449e3f3de7c1e8ea78673",
    "AWSDynamoDB": "edb60183b96f49bdcfdfea32e8993a9064b65829d5f938eba2ce1cbbaf779617",
    "AWSEC2": "0f2596071d5386071d806976f37bcac83d98b2f8e27f9ee9299c481fc98435b7",
    "AWSElasticLoadBalancing": "490eca33befbd63016e0ab5b05784de9b131e9ea3b5c8b5f9c8edc6fadbb76f6",
    "AWSFacebookSignIn": "33803cdc0c18cdebc9c297e31ddddc31ea8117723dc7ae3d14f22164bb0ce363",
    "AWSGoogleSignIn": "6d98825e255c8906ea174ee73231cf0f0791eeff01c63444bbd28a8900165828",
    "AWSIoT": "fdde8372f6e91aa0ebce85e26b7135aec4e3c8ed71510e75d6c0c940c710a222",
    "AWSKMS": "b408b2745e8c87c47f22b55deb277f3f877cc33303d7da3cf365d7e6bedb8f50",
    "AWSKinesis": "8b86a1955b05f5d2e6c69059473089ee6308a647a13f9af5df9fac3c1ed80820",
    "AWSKinesisVideo": "6ace825dfeb48dadfb38a7d3e193ee6c0bd636fd46a4fdd64fb3c9a88e2fa520",
    "AWSKinesisVideoArchivedMedia": "b75a19ae68fdae27dc66be36948fd2be1d69762895755eb702b6a80606a963e1",
    "AWSKinesisVideoSignaling": "3b319886fc41d6856346d4c873d997707af992b154561cac2ed4e1938ffa9438",
    "AWSLambda": "da8e3006874ebb95757630c60e312c004893b2542fdf6049d6b779c9a6e9a37b",
    "AWSLex": "f22755e67f51dce6504a4378ac01b352eda602eb6a5eb2280ea2b0f79c4d64f6",
    "AWSLocationXCF": "7ed3a513af273d0a54ae8cdd9c0ab2f9f17f091353c65212d05372378be8b86b",
    "AWSLogs": "fb72f592b2bd9674b9839048753dab60bea62f50a7a9da91943218a79247b1bc",
    "AWSMachineLearning": "866f8fcfa1834406df5a9b5e749f1dd7f7bb100a7326ef0c910e729d309a890f",
    "AWSMobileClientXCF": "8a7178e78e02276f3e473253e725fae6e1ab221a66517117e0f9aea86df523b7",
    "AWSPinpoint": "3cb96af9125a764328fa4fea2b9556cbdb7dc15dd709562935565218654a21fc",
    "AWSPolly": "0b2005c56f468eddb70abc8e1a5907ea23c6e3d5f7ae8dec24a20883979d04a9",
    "AWSRekognition": "4de8c1ff7b3e690e5d9e561449a24c65177f0569b0c644eb7abdc2185ae35ea0",
    "AWSS3": "80c8d937e899a47ec735081ab116314242037793ce838c90009adc58e1f10c74",
    "AWSSES": "85da5ef27f3f92ad28e80702832cd3a2775fa699d3d4a7335f27793e2365a4f9",
    "AWSSNS": "3ebd94c2231d0fad215e3bd753155f6fd4a4d414638c55df784038ad2f90a149",
    "AWSSQS": "795974a26c5efadffb140c226ce56888eb14e59d3a21dad52c86aaded3df9344",
    "AWSSageMakerRuntime": "c9e46d7b0e5dbe4a101de3d4f03b94c08301fb93e6220094c22ff9c6d879cda4",
    "AWSSimpleDB": "6c34b784a25eb32966abcd9eb37ac671da6c272e18b24d50620ffef1c0843ac5",
    "AWSTextract": "212d4fc2e88c3e959fd7f30c57191ec63944febe70ff6f096131375a05520f48",
    "AWSTranscribe": "ddc3c564ea6be779e6d78daa8f8cf6fc45bb1e629c5cf2491a3f1b1bdc980a91",
    "AWSTranscribeStreaming": "2bb97a2bf7f7aa8bd77fc35eaae87a5d82882b568e783929afc9ce2f65a1d191",
    "AWSTranslate": "da39aba0fa3bf87672641c28c16e155a7e212ad4f2a84d045bd8454c18d9ecc5",
    "AWSUserPoolsSignIn": "bb591a2398318b0383106ecb5b3eb1da7d023cd6a9392a8bf6866f41b98ba14c"
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
