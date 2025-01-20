import Foundation

extension Date {
    func daysBetween(_ otherDate: Date) -> Int {
        let calendar = Calendar.current
        let startOfSelf = calendar.startOfDay(for: self)
        let startOfOtherDate = calendar.startOfDay(for: otherDate)
        let components = calendar.dateComponents([.day], from: startOfSelf, to: startOfOtherDate)
        return components.day ?? 0
    }
}
