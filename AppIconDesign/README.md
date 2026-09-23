# App Icon - Lịch Tuần

Tài nguyên biểu tượng ứng dụng (App Icon) đã chọn:

- **Mẫu:** Mẫu 1 (3D Glassmorphism Dark Mode)
- **File gốc (JPG):** `AppIcon_Mau1.jpg`
- **File chuẩn iOS (PNG 1024x1024):** `AppIcon_Mau1.png`
- **Đã tích hợp sẵn trong Asset Catalog:** `Shared/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`

### Kích hoạt khi nâng cấp app:
Trong file `project.yml`, chỉ cần đổi:
```yaml
ASSETCATALOG_COMPILER_APPICON_NAME: "AppIcon"
```
Sau đó commit và push lên GitHub để GitHub Actions tự động build bản IPA có gắn icon mới.
