import Foundation

struct ToastMessage: Identifiable {
    let id = UUID()
    let key: String?
    let args: [CVarArg]

    init(key: String?, args: [CVarArg] = []) {
        self.key = key
        self.args = args
    }
}
