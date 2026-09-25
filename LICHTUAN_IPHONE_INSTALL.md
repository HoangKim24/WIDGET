# Hướng Dẫn Cài Đặt Lock Screen Calendar Maker Lên iPhone 15 (0 Đồng)

Hướng dẫn này giúp bạn đưa ứng dụng **Lock Screen Calendar Maker** lên chiếc iPhone 15 của bạn
mà **không cần App Store, không cần tài khoản Apple Developer trả phí ($99/năm), không cần máy Mac**.

---

## 0. Tổng Quan Quy Trình Siêu Đơn Giản

```
[Push code lên GitHub] 
          ↓
[GitHub Actions tự động build file .ipa] (khoảng 3 phút)
          ↓
[Tải file .ipa từ mục Actions về máy tính Windows]
          ↓
[Mở Sideloadly trên Windows + Cắm iPhone 15 qua cáp USB-C]
          ↓
[Bấm Start để cài đặt vào iPhone 15]
```

> **Điểm tuyệt vời của phiên bản mới**: 
> Ứng dụng hoạt động **100% offline**, không cần mạng, không cần tạo GitHub Gist, không cần token phức tạp. Mọi thứ lưu thẳng trên iPhone và xuất ảnh trực tiếp vào Thư viện ảnh!

---

## 1. Chuẩn Bị (Chỉ Cần Làm 1 Lần)

| Công cụ | Mô tả | Chi phí |
|---|---|---|
| **iPhone 15** | Điện thoại bạn muốn cài | Có sẵn |
| **Máy tính Windows** | Máy bạn đang dùng | Có sẵn |
| **Cáp USB-C** | Cáp sạc đi kèm iPhone 15 | Có sẵn |
| **iTunes cho Windows** | Driver kết nối iPhone: [Tải tại đây](https://www.apple.com/itunes/) (bản Windows 64-bit) | 0đ |
| **Sideloadly** | Phần mềm cài file .ipa lên iPhone: [Tải tại sideloadly.io](https://sideloadly.io) | 0đ |
| **Apple ID cá nhân** | Chính là tài khoản iCloud đang đăng nhập trên iPhone của bạn | 0đ |

---

## 2. Bước 1 — Lấy File Cài Đặt (.ipa) Từ GitHub

1. Push mã nguồn này lên kho GitHub của bạn (nhánh `main`).
2. Vào trang GitHub của dự án > bấm vào tab **Actions**.
3. Bạn sẽ thấy tiến trình `Build and Package IPA` đang chạy (khoảng 3 phút).
4. Khi chạy xong (hiện dấu tích xanh ✅), bấm vào workflow đó > kéo xuống mục **Artifacts**.
5. Nhấn tải file **`lich-tuan-ipa`** về máy tính (giải nén ra sẽ có file `LichTuanApp.ipa`).

---

## 3. Bước 2 — Cài Đặt Vào iPhone 15 Bằng Sideloadly

1. Cắm iPhone 15 vào máy tính Windows bằng cáp USB-C.
2. Mở ứng dụng **Sideloadly** trên máy tính.
3. Ở mục **iDevice**, bạn sẽ thấy tên chiếc iPhone 15 của bạn xuất hiện.
4. Kéo file `LichTuanApp.ipa` thả vào ô biểu tượng IPA trong Sideloadly.
5. Nhập địa chỉ **Apple ID** (email iCloud) của bạn vào ô **Apple account**.
6. Bấm nút **Start**.
   - *Nếu Apple ID bật xác thực 2 lớp*: Một mã 6 số sẽ hiện trên màn hình iPhone, bạn nhập mã này vào Sideloadly để tiếp tục.
7. Đợi khoảng 1-2 phút, khi thanh tiến trình báo **Done** là app đã được cài xong trên iPhone 15!

---

## 4. Bước 3 — Mở App Lần Đầu Trên iPhone 15

Vì đây là app cá nhân bạn tự cài, iOS yêu cầu bạn xác nhận độ tin cậy lần đầu tiên:

1. **Bật Chế độ Nhà phát triển (Developer Mode)**:
   - Vào **Cài đặt** > **Quyền riêng tư & Bảo mật** > Kéo xuống dưới cùng chọn **Chế độ Nhà phát triển**.
   - Bật công tắc sang xanh > iPhone sẽ yêu cầu khởi động lại máy > Khởi động lại xong bấm **Bật** và nhập mật khẩu mở khóa màn hình.
2. **Tin cậy chứng chỉ ứng dụng**:
   - Vào **Cài đặt** > **Cài đặt chung** > **Quản lý VPN & Thiết bị**.
   - Ở mục *Ứng dụng của nhà phát triển*, nhấn vào email Apple ID của bạn > Bấm **Tin cậy (Trust)**.

**Xong!** Bạn đã có thể mở ứng dụng **Studio Lịch Khóa** trên màn hình chính iPhone 15, thỏa sức thiết kế hình nền và lưu vào Thư viện ảnh!

---

## 5. Hướng Dẫn Cài Hình Nền Thủ Công Làm Màn Hình Khóa iPhone

1. Mở ứng dụng **Studio Lịch Khóa**, chọn kiểu nền, kiểu lịch ưng ý rồi bấm nút **Lưu Hình Nền Màn Hình Khóa**.
2. Mở ứng dụng **Ảnh (Photos)** trên iPhone, mở bức ảnh hình nền vừa được lưu.
3. Bấm vào nút **Chia sẻ** (biểu tượng hình vuông có mũi tên chỉ lên ở góc trái dưới).
4. Chọn **Dùng làm hình nền (Use as Wallpaper)**.
5. Nhấn **Thêm** ở góc trên bên phải > Chọn **Đặt làm cặp hình nền**.

---

## 6. Thiết Lập Tự Động Hóa (Auto Wallpaper Giống LockScreen Calendar Maker)

Để mỗi sáng (hoặc mỗi khi đóng app), màn hình khóa **tự động đổi lịch mới mà không cần thao tác tay**:

1. Mở ứng dụng **Phím Tắt (Shortcuts)** có sẵn trên iPhone của bạn.
2. Nhấn vào tab **Tự động hóa (Automation)** ở hàng đáy màn hình.
3. Nhấn dấu **+** ở góc trên (hoặc *Tạo mục tự động hóa cá nhân*).
4. Chọn **Thời gian trong ngày** (ví dụ: `06:00` sáng) > Chọn **Hàng ngày**.
5. **Rất quan trọng**: Chọn **Chạy ngay lập tức (Run Immediately)** và tắt mục *Thông báo khi chạy*.
6. Nhấn **Tiếp** > Bấm **Tác vụ mới**:
   - Tìm kiếm tác vụ `Cập Nhật Hình Nền Lịch Tuần` của app **Lịch Tuần**.
   - Bấm tiếp dấu **+** tìm tác vụ hệ thống `Đặt hình nền` (Set Wallpaper) của iOS và chọn áp dụng cho Màn hình khóa.
7. Xong! Kể từ bây giờ, mỗi sáng thức dậy màn hình khóa iPhone 15 của bạn sẽ tự động nhảy lịch trình mới tinh!

---

## 7. Thêm Widget Tiện Ích Lên Màn Hình Khóa & Màn Hình Chính (WidgetKit)

Ngoài tính năng vẽ hình nền, app đã tích hợp đầy đủ hệ sinh thái **Widget thời gian thực**:

### A. Màn hình khóa (Lock Screen Widget):
1. Chạm và giữ vào Màn hình khóa > Bấm **Tùy chỉnh (Customize)** > Chọn **Màn hình khóa**.
2. **Dòng chữ trên đồng hồ (Inline Widget)**: Bấm vào dòng ngày tháng phía trên đồng hồ > Chọn **Lịch Tuần** để xem sự kiện tiếp theo ngay lập tức.
3. **Khung dưới đồng hồ (Rectangular & Circular Widget)**: Bấm vào khung tiện ích dưới đồng hồ > Chọn **Lịch Tuần** (hỗ trợ hiển thị 2 sự kiện kế tiếp hoặc hình tròn đếm việc còn lại).

### B. Màn hình chính (Home Screen Widget):
1. Chạm giữ vào một khoảng trống trên Màn hình chính cho đến khi các icon rung rinh.
2. Nhấn dấu **+** ở góc trên cùng bên trái màn hình.
3. Tìm ứng dụng **Lịch Tuần** trong danh sách:
   * **Ô Nhỏ (2x2)**: Ngày hôm nay, số lượng việc và sự kiện kế tiếp.
   * **Ô Chữ Nhật (2x4)**: Khối ngày to rõ bên trái và danh sách 3 việc hôm nay bên phải.
   * **Bảng Lịch Tuần 7 Cột (4x4)**: Thu nhỏ nguyên bảng lịch 7 ngày (Thứ 2 đến Chủ Nhật) ra ngoài màn hình chính để bao quát cả tuần!