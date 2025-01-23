import UIKit

public struct JailbreakDetection {

    public static func isDeviceJailbroken() async -> Bool {
        return await canOpenCommonJailbreakURLSchemes() || canAccessRestrictedAreas() || commonJailbreakFilesExist()
    }

    // Common jailbreak files and directories
    private static let commonJailbreakPaths = [
        "/Applications/Cydia.app",
        "/Applications/Sileo.app",
        "/Applications/Zebra.app",
        "/Applications/Palera1nLoader.app",
        "/cores/binpack/Applications/palera1nLoader.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/usr/libexec/cydia/",
        "/private/var/tmp/cydia.log",
        "/private/var/lib/cydia",
        "/var/lib/cydia",
        "/var/lib/palera1n",
        "/usr/bin/serotonin",
        "/usr/bin/dopamine",
        "/usr/bin/def1nit3lyn0taja1lbr3aktool"
    ]

    private static func canAccessRestrictedAreas() -> Bool {
        let testPath = "/private/jailbreakTest"
        do {
            try "Jailbreak Test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }

    private static func commonJailbreakFilesExist() -> Bool {
        for path in commonJailbreakPaths where FileManager.default.fileExists(atPath: path) {
            return true
        }
        return false
    }

    private static func canOpenCommonJailbreakURLSchemes() async -> Bool {
        let urlSchemes = [
            "sileo://",
            "zbra://"
        ]

        for urlScheme in urlSchemes {
            if let url = URL(string: urlScheme) {
                return await canOpenURL(url: url)
            }
        }
        return false
    }

    private static func canOpenURL(url: URL) async -> Bool {
        return await UIApplication.shared.canOpenURL(url)
    }
}
