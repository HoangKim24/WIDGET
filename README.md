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

## Notes

- The widget and app share data through App Group `group.com.example.lichtuan`.
- Lock Screen widget families stay monochrome and use only a small accentable symbol.
- `systemLarge` and the main app use the full color palette.

## Build And Archive Risks

- Unsigned IPA chỉ là đóng gói từ archive, không phải flow ký code đầy đủ.
- App Group `group.com.example.lichtuan` must exist for both the app ID and widget extension ID, and the provisioning profiles must include it. If not, signing or archive can fail.
- `xcodegen generate` depends on the runner environment. If `project.yml` is invalid or the XcodeGen version changes, CI can fail even when the Swift code is fine.
- `WeekTimelineProvider` falls back to sample data when App Group access is unavailable. That does not break the build, but it means the widget will not read live shared events.
