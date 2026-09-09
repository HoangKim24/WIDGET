import Foundation

/// Lưu GitHub token của người dùng ngay trên máy, không commit vào repo.
///
/// Token chỉ cần quyền `gist` và chỉ app chính dùng để đẩy dữ liệu lên Gist.
/// Widget không cần token vì Gist được đọc bằng lời gọi công khai.
final class RemoteSyncSettingsStore {
    static let shared = RemoteSyncSettingsStore()

    private let tokenKey = "gistSyncToken"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var token: String {
        get {
            userDefaults.string(forKey: tokenKey) ?? ""
        }
        set {
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                userDefaults.removeObject(forKey: tokenKey)
            } else {
                userDefaults.set(trimmed, forKey: tokenKey)
            }
        }
    }

    var hasToken: Bool {
        !token.isEmpty
    }
}
