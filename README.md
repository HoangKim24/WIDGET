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

Add this secret in GitHub repository settings:

- `APPLE_TEAM_ID` - your Apple Developer Team ID used for automatic signing

The workflow passes this value into XcodeGen and archive/export so the generated project uses the same signing team.
The archive step also passes the team ID directly to `xcodebuild` and allows provisioning device registration updates.
If this secret is missing, the archive job stops early with a clear error.

## Notes

- The widget and app share data through App Group `group.com.example.lichtuan`.
- Lock Screen widget families stay monochrome and use only a small accentable symbol.
- `systemLarge` and the main app use the full color palette.
