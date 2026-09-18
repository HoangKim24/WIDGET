# Lock Screen Calendar Maker (Tạo Hình Nền Lịch Màn Hình Khóa)

Ứng dụng thiết kế và xuất hình nền lịch màn hình khóa dành riêng cho iPhone (tối ưu chuẩn tỉ lệ iPhone 15), hỗ trợ tạo hình nền siêu nét, tùy biến đa dạng và lưu thẳng vào Thư viện ảnh trong 1 chạm.

---

## 📱 Điểm Nổi Bật

- **Tự Động Hóa Màn Hình Khóa (Auto Wallpaper)**: Tích hợp sâu với iOS Shortcuts (Phím Tắt) & AppIntents, giúp iPhone tự động đổi hình nền lịch mỗi ngày (hoặc mỗi khi đóng app) mà không cần thao tác thủ công.
- **Tối Ưu Chuẩn Toàn Màn Hình iPhone**: Khung an toàn cách xa đồng hồ và Dynamic Island, căn lề chuẩn 100% không bị zoom cắt mép.
- **Giả Lập Màn Hình Khóa Trực Tiếp (Mock Clock Preview)**: Xem trước giao diện màn hình khóa chuẩn iOS (Đồng hồ, Ngày tháng, Dynamic Island) ngay trong Studio trước khi bấm lưu.
- **Bảng Màu Thịnh Hành Color Hunt & Tùy Biến HEX**: Hỗ trợ dán mã màu HEX tùy ý và các bộ màu thịnh hành.
- **Dán Lịch Thông Minh Từ Zalo / Ghi Chú**: Tự động nhận diện T2-CN, mốc giờ và công việc để nạp nhanh cả tuần.
- **Nhắc Nhở Công Việc Thông Minh (Local Notifications)**: Hẹn giờ nhắc nhở trước sự kiện.
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
