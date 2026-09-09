import Foundation

/// Client tối giản làm việc với GitHub Gist API.
///
/// - Đọc: gọi GET công khai, không cần token, nên widget extension dùng được.
/// - Ghi: gọi PATCH kèm token cá nhân, chỉ app chính mới thực hiện.
struct GistSyncClient {
    static let shared = GistSyncClient()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Tải danh sách sự kiện mới nhất từ Gist.
    func fetchEvents() async throws -> [CalendarEvent] {
        guard let endpoint = RemoteSyncConfig.gistEndpoint else {
            throw RemoteSyncError.notConfigured
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 20
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        try validate(response)

        let payload = try JSONDecoder().decode(GistPayload.self, from: data)
        guard let file = payload.files[RemoteSyncConfig.fileName] else {
            throw RemoteSyncError.fileNotFound(RemoteSyncConfig.fileName)
        }

        // Gist rút gọn nội dung khi file lớn, khi đó phải tải qua raw_url.
        let content: String
        if file.truncated == true, let rawPath = file.rawURL, let rawURL = URL(string: rawPath) {
            let (rawData, rawResponse) = try await session.data(from: rawURL)
            try validate(rawResponse)
            guard let text = String(data: rawData, encoding: .utf8) else {
                throw RemoteSyncError.invalidResponse
            }
            content = text
        } else {
            content = file.content ?? ""
        }

        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return []
        }

        return try EventCoding.events(fromJSON: trimmed)
    }

    /// Đẩy danh sách sự kiện hiện tại lên Gist, ghi đè nội dung cũ.
    func pushEvents(_ events: [CalendarEvent], token: String) async throws {
        guard let endpoint = RemoteSyncConfig.gistEndpoint else {
            throw RemoteSyncError.notConfigured
        }

        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedToken.isEmpty else {
            throw RemoteSyncError.missingToken
        }

        let body = GistUpdateBody(
            files: [RemoteSyncConfig.fileName: GistFileUpdate(content: try EventCoding.jsonString(from: events))]
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "PATCH"
        request.timeoutInterval = 20
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(trimmedToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await session.data(for: request)
        try validate(response)
    }

    private func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteSyncError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw RemoteSyncError.httpStatus(httpResponse.statusCode)
        }
    }
}

private struct GistPayload: Decodable {
    let files: [String: GistFile]
}

private struct GistFile: Decodable {
    let content: String?
    let truncated: Bool?
    let rawURL: String?

    private enum CodingKeys: String, CodingKey {
        case content
        case truncated
        case rawURL = "raw_url"
    }
}

private struct GistUpdateBody: Encodable {
    let files: [String: GistFileUpdate]
}

private struct GistFileUpdate: Encodable {
    let content: String
}
