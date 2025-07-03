import UIKit
import FactoryKit
import CommonsLib

public struct JailbreakDetection {

    private static func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    public static func isDeviceJailbroken(
        fileManager: FileManagerProtocol
    ) async -> Bool {
        if isSimulator() { return false }

        let canOpenJailbreakURLs = await canOpenCommonJailbreakURLSchemes()
        return canOpenJailbreakURLs ||
            canAccessRestrictedAreas(fileManager: fileManager) ||
            commonJailbreakFilesExist(fileManager: fileManager)
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

    private static func canAccessRestrictedAreas(
        fileManager: FileManagerProtocol
    ) -> Bool {
        let testPath = "/private/jailbreakTest"
        do {
            try "Jailbreak Test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try fileManager.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }

    private static func commonJailbreakFilesExist(
        fileManager: FileManagerProtocol
    ) -> Bool {
        for path in commonJailbreakPaths where fileManager.fileExists(atPath: path) {
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
