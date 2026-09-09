import SwiftUI

/// Màn hình nhập GitHub token dùng cho việc đồng bộ sự kiện qua Gist.
struct RemoteSyncSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var token: String = RemoteSyncSettingsStore.shared.token

    let onSaved: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Gist") {
                    LabeledContent("Gist ID") {
                        Text(RemoteSyncConfig.isConfigured ? RemoteSyncConfig.gistID : "Chưa cấu hình")
                            .foregroundStyle(RemoteSyncConfig.isConfigured ? .primary : .secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    LabeledContent("File") {
                        Text(RemoteSyncConfig.fileName)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("GitHub token") {
                    SecureField("ghp_...", text: $token)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("GistTokenField")
                }

                Section {
                    Text("""
                    Token chỉ cần quyền `gist`. Token được lưu trên máy này và không \
                    bao giờ được đưa vào mã nguồn. Widget đọc Gist bằng lời gọi công khai \
                    nên không cần token.
                    """)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Đồng bộ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        RemoteSyncSettingsStore.shared.token = token
                        onSaved()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RemoteSyncSettingsView(onSaved: {})
}
