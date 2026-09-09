# Lich Tuan App

WidgetKit app for iPhone weekly calendar, with shared data between the main app and widget extension.

## Project Layout

- `LichTuanApp/` - main app UI and CRUD screens
- `LichTuanWidget/` - widget extension for Lock Screen and Home Screen
- `Shared/` - shared models, palette, timeline, and widget views
- `.github/workflows/build.yml` - GitHub Actions build, UI test, screenshot, and IPA export pipeline

## Local Project Generation

This repo uses XcodeGen.

```bash
xcodegen generate
```

That generates `LichTuanApp.xcodeproj` from `project.yml`.

## CI Flow

The GitHub Actions workflow does the following:

1. Build the app in Debug mode.
2. Run UI tests on an iPhone simulator.
3. Extract screenshots from the `.xcresult` bundle with `xcparse`.
4. Upload screenshots as the `widget-screenshots` artifact.
5. On pushes to `main`, archive and export an `.ipa`.

## Required Secret for IPA Export

Không cần secret `APPLE_TEAM_ID` cho flow hiện tại, vì archive job được giữ ở chế độ unsigned và IPA được đóng gói thủ công từ archive.
Nếu sau này muốn quay lại flow signed/automatic signing, lúc đó mới cần thêm Team ID và cấu hình provisioning tương ứng.

## Widget Data Sync (no App Group)

Apple ID miễn phí không được cấp capability `App Groups`, nên app và widget không dùng chung container cục bộ được. Thay vào đó:

- App chính lưu sự kiện trong `UserDefaults.standard` của riêng nó (`Shared/SharedDataStore.swift`).
- Sau mỗi thay đổi, app đẩy JSON lên một GitHub Gist bằng token cá nhân (`Shared/GistSyncClient.swift`).
- Widget tải Gist đó về bằng lời gọi công khai, không cần token, và cache lại trong `Caches` của chính nó (`Shared/EventCache.swift`).

Cấu hình trước khi build:

1. Tạo một **secret Gist** với file tên `lichtuan-events.json`, nội dung khởi tạo là `[]`.
2. Chép Gist ID vào `RemoteSyncConfig.gistID` trong `Shared/RemoteSyncConfig.swift`.
3. Tạo GitHub token chỉ có scope `gist`, nhập trong app tại mục **Widget Sync → Cấu hình GitHub token**.

Token không nằm trong mã nguồn, chỉ lưu trên máy chạy app. Nếu `gistID` để rỗng, widget vẫn chạy nhưng hiển thị dữ liệu mẫu.

## Notes

- The widget and app share data through a GitHub Gist instead of an App Group.
- Lock Screen widget families stay monochrome and use only a small accentable symbol.
- `systemLarge` and the main app use the full color palette.

## Build And Archive Risks

- Unsigned IPA chỉ là đóng gói từ archive, không phải flow ký code đầy đủ.
- Không còn entitlement nào, nên ký bằng Apple ID miễn phí không vướng capability. Đổi lại, dữ liệu widget phụ thuộc vào mạng và Gist.
- `xcodegen generate` depends on the runner environment. If `project.yml` is invalid or the XcodeGen version changes, CI can fail even when the Swift code is fine.
- `WeekTimelineProvider` falls back to cache rồi tới dữ liệu mẫu khi không gọi được Gist. Widget vẫn hiển thị nhưng có thể không phải dữ liệu mới nhất.
- Widget chỉ làm mới theo lịch của WidgetKit, nên sự kiện vừa thêm có thể mất vài phút mới xuất hiện.
