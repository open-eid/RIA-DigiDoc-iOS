import Foundation
import Testing
import Cuckoo

@testable import CommonsLib

final class BundleUtilTests {

    @Test
    func getBundleIdentifier_success() {
        let expectedBundleIdentifier = "com.apple.dt.xctest.tool"

        let bundleIdentifier = BundleUtil.getBundleIdentifier()

        #expect(expectedBundleIdentifier == bundleIdentifier)
    }
}
