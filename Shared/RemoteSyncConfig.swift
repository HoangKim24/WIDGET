import Foundation

/// Cấu hình đồng bộ dữ liệu giữa app chính và widget thông qua một GitHub Gist.
///
/// Vì Apple ID miễn phí không được cấp capability `App Groups`, app và widget
/// không thể dùng chung container cục bộ. Thay vào đó app đẩy dữ liệu lên Gist
/// còn widget tải dữ liệu đó về, nên cả hai vẫn thấy cùng một danh sách sự kiện.
///
/// `gistID` phải là hằng số biên dịch vì widget extension không đọc được
/// UserDefaults của app chính. Token ghi dữ liệu thì nhập trong app lúc chạy
/// và không bao giờ được commit vào repo.
enum RemoteSyncConfig {
    /// Điền ID của Gist bạn tạo, ví dụ "3f9a1c2b4d5e6f7081920a1b2c3d4e5f".
    /// Để rỗng nếu chưa cấu hình, khi đó widget sẽ hiển thị dữ liệu mẫu.
    static let gistID = ""

    /// Tên file bên trong Gist chứa danh sách sự kiện.
    static let fileName = "lichtuan-events.json"

    /// Bao lâu thì widget mới gọi mạng lại, tính bằng giây.
    static let minimumFetchInterval: TimeInterval = 15 * 60

    static var isConfigured: Bool {
        !gistID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static var gistEndpoint: URL? {
        guard isConfigured else {
            return nil
        }

        return URL(string: "https://api.github.com/gists/\(gistID)")
    }
}

/// Các lỗi có thể xảy ra khi đồng bộ với Gist.
enum RemoteSyncError: LocalizedError, Equatable {
    case notConfigured
    case missingToken
    case encodingFailed
    case fileNotFound(String)
    case httpStatus(Int)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Chưa cấu hình Gist ID trong RemoteSyncConfig.swift."
        case .missingToken:
            return "Chưa nhập GitHub token nên không thể đẩy dữ liệu lên Gist."
        case .encodingFailed:
            return "Không chuyển đổi được dữ liệu sự kiện sang JSON."
        case .fileNotFound(let name):
            return "Gist không chứa file \(name)."
        case .httpStatus(let code):
            return "GitHub trả về mã lỗi \(code)."
        case .invalidResponse:
            return "Phản hồi từ GitHub không hợp lệ."
        }
    }
}
