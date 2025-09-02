import Foundation
import Testing

@testable import CommonsLib

final class SystemUtilTests {
    @Test
    func getOSVersion_success() {
        let osVersion = SystemUtil.getOSVersion()

        #expect(!osVersion.isEmpty)

        // Accepts number.number.number i.e "18.6.0"
        if let regex = try? NSRegularExpression(pattern: #"^\d+\.\d+\.\d+$"#) {
            let range = NSRange(
                osVersion.startIndex..<osVersion.endIndex,
                in: osVersion
            )
            let match = regex.firstMatch(in: osVersion, options: [], range: range)

            #expect(match != nil)
        }
    }
}
