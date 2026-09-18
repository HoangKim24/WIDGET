# Lock Screen Calendar Maker (Tạo Hình Nền Lịch Màn Hình Khóa)

Ứng dụng thiết kế và xuất hình nền lịch màn hình khóa dành riêng cho iPhone (tối ưu chuẩn tỉ lệ iPhone 15), hỗ trợ tạo hình nền siêu nét, tùy biến đa dạng và lưu thẳng vào Thư viện ảnh trong 1 chạm.

---

## 📱 Điểm Nổi Bật

- **Tự Động Hóa Màn Hình Khóa (Auto Wallpaper)**: Tích hợp sâu với iOS Shortcuts (Phím Tắt) & AppIntents, giúp iPhone tự động đổi hình nền lịch mỗi ngày (hoặc mỗi khi đóng app) mà không cần thao tác thủ công.
- **Tối Ưu Chuẩn Toàn Màn Hình iPhone 15**: Hỗ trợ native full-screen 19.5:9 (393 × 852 pt), ôm trọn viền Dynamic Island và đáy máy, không còn dải đen letterbox.
- **Bảng Tuần 7 Cột & Khung Giờ Chi Tiết**: Xếp lịch trực quan từ Thứ 2 đến Chủ Nhật với màu sắc riêng cho từng công việc.
- **Dữ Liệu Thật 100%**: Hoạt động hoàn toàn trên sự kiện của người dùng, không chèn dữ liệu mẫu giả.
- **Kho Nền Thời Thượng**: Tích hợp các tông màu hot trend: *Hoàng Hôn Chill, Cực Quang, Đen Huyền Bí OLED (tiết kiệm pin), Matcha Dịu Êm, Kẹo Ngọt Pastel*.
- **Xuất Ảnh Chuẩn Retina 3x**: Dùng `ImageRenderer` render hình nền sắc nét độ phân giải cao (1179 × 2556 px) và lưu vào Photos.

---

## 📂 Cấu Trúc Thư Mục

- `LichTuanApp/`
  - `Studio/`:
    - `LockScreenStudioView.swift`: Màn hình Studio chính với thanh công cụ điều khiển nổi
    - `WallpaperCanvasView.swift`: Canvas render toàn bộ hình nền theo tỉ lệ iPhone 15
    - `CalendarOverlayViews.swift`: Bảng tuần 7 cột và danh sách lịch trình hôm nay
    - `AutoWallpaperIntent.swift`: AppIntent cho phép iOS Shortcuts tự động tạo và thay hình nền ngầm
    - `AutoWallpaperSetupGuideView.swift`: Giao diện hướng dẫn cài đặt Tự Động Hóa qua Shortcuts
    - `WallpaperModels.swift`: Các cấu hình hình nền, preset và bảng màu
    - `WallpaperSaveManager.swift`: Xử lý kết xuất ảnh siêu nét và lưu vào Album ảnh
  - `RootView.swift`: Điều hướng 2 Tab chính (Thiết Kế & Sự Kiện)
  - `EventEditorView.swift`: Màn hình tạo và chỉnh sửa sự kiện
  - `EventListViewModel.swift`: Quản lý dữ liệu sự kiện cục bộ trên máy
  - `Info.plist`: Đã cấu hình quyền truy cập và lưu ảnh vào Photo Library
- `Shared/`: Model sự kiện (`CalendarEvent`), danh mục (`EventCategory`), bộ lưu trữ (`SharedDataStore`)
- `.github/workflows/build.yml`: CI tự động biên dịch và đóng gói file `.ipa`

---

## 🚀 Hướng Dẫn Cài Lên iPhone 15

Xem hướng dẫn chi tiết từng bước (kèm hình minh họa và cách dùng Sideloadly trên Windows) tại:
👉 [LICHTUAN_IPHONE_INSTALL.md](file:///d:/Widget/LICHTUAN_IPHONE_INSTALL.md)
