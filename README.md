# Lock Screen Calendar Maker (Tạo Hình Nền Lịch Màn Hình Khóa)

Ứng dụng thiết kế và xuất hình nền lịch màn hình khóa dành riêng cho iPhone (tối ưu chuẩn tỉ lệ iPhone 15), hỗ trợ tạo hình nền siêu nét, tùy biến đa dạng và lưu thẳng vào Thư viện ảnh trong 1 chạm.

---

## 📱 Điểm Nổi Bật

- **Mô Phỏng Màn Hình Khóa Chân Thực**: Tích hợp mắt xem trước giả lập giao diện iOS (Dynamic Island, Đồng hồ to `09:41`, Ngày tháng, Nút Đèn pin & Camera) giúp căn chỉnh vị trí lịch không bị che khuất.
- **Kho Nền Thời Thượng**: Tích hợp các tông màu hot trend: *Hoàng Hôn Chill, Cực Quang, Đen Huyền Bí OLED (tiết kiệm pin), Matcha Dịu Êm, Kẹo Ngọt Pastel*.
- **Tùy Chỉnh Ảnh Cá Nhân**: Chọn ảnh bất kỳ từ máy, tích hợp thanh trượt làm mờ nghệ thuật (Frosted Blur) và lớp phủ tối (Dim Overlay) giúp chữ lịch luôn nổi bật.
- **3 Kiểu Lịch Tùy Biến**: Lịch tháng tối giản, Lịch tuần năng động và Khung kính mờ sang chảnh (Glassmorphism).
- **Tích Hợp Quản Lý Sự Kiện**: Dễ dàng thêm việc cần làm, ngày sinh nhật, deadline. Sự kiện tự động đánh dấu chấm màu xinh xắn trên hình nền.
- **100% Tiếng Việt & Thân Thiện Với Người Non-Tech**: Không thuật ngữ kỹ thuật, không cần tài khoản nhà phát triển trả phí, hoạt động 100% offline.
- **Xuất Ảnh Chuẩn Retina 3x**: Dùng `ImageRenderer` render hình nền sắc nét độ phân giải cao và lưu vào Photos.

---

## 📂 Cấu Trúc Thư Mục

- `LichTuanApp/`
  - `Studio/`:
    - `LockScreenStudioView.swift`: Màn hình Studio chính với thanh công cụ điều khiển nổi
    - `WallpaperCanvasView.swift`: Canvas render toàn bộ hình nền theo tỉ lệ iPhone 15
    - `CalendarOverlayViews.swift`: Lưới lịch tháng, lịch tuần và kính mờ
    - `LockScreenMockOverlay.swift`: Lớp phủ mô phỏng màn hình khóa iOS 17/18
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
