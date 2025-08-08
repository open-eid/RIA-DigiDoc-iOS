import Foundation
import Testing

@testable import CommonsLib

final class BundleUtilTests {

    @Test
    func getBundleIdentifier_success() {
        let expectedBundleIdentifier = "com.apple.dt.xctest.tool"

        let bundleIdentifier = BundleUtil.getBundleIdentifier()

        #expect(expectedBundleIdentifier == bundleIdentifier)
    }
    
    @Test
    func getBundleShortVersionString() {
        if let appBundle = Bundle(identifier: "ee.ria.digidoc") {
            let bundleShortVersionString = BundleUtil.getBundleShortVersionString(bundle: appBundle)
            
            #expect(!bundleShortVersionString.isEmpty)
            
            // Accepts number.number.number i.e "1.0.0"
            if let regex = try? NSRegularExpression(pattern: #"^\d+\.\d+\.\d+$"#) {
                let range = NSRange(bundleShortVersionString.startIndex..<bundleShortVersionString.endIndex, in: bundleShortVersionString)
                let match = regex.firstMatch(in: bundleShortVersionString, options: [], range: range)
                
                #expect(match != nil)
            }
        }
    }

    @Test
    func getBundleVersion() {
        if let appBundle = Bundle(identifier: "ee.ria.digidoc") {
            let bundleVersion = BundleUtil.getBundleVersion(bundle: appBundle)
            
            #expect(!bundleVersion.isEmpty)
            
            // Accepts numbers i.e "1", "42", "20250811"
            if let regex = try? NSRegularExpression(pattern: #"^\d+$"#) {
                let range = NSRange(bundleVersion.startIndex..<bundleVersion.endIndex, in: bundleVersion)
                let match = regex.firstMatch(in: bundleVersion, options: [], range: range)
                
                #expect(match != nil)
            }
        }
    }
}
