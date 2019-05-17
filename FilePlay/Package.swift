// swift-tools-version:4.2
// Generated automatically by Perfect Assistant
// Date: 2019-05-07 17:07:41 +0000
import PackageDescription

let package = Package(
	name: "FilePlay",
	products: [
		.executable(name: "FilePlay", targets: ["FilePlay"])
	],
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", "3.0.0"..<"4.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", "3.0.0"..<"4.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Repeater.git", "3.0.0"..<"4.0.0"), 
	],
	targets: [
		.target(name: "FilePlay", dependencies: ["PerfectHTTPServer", "PerfectMySQL", "PerfectLogger"])
	]
)
