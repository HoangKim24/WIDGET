# Hướng dẫn cài Lich Tuan App lên iPhone (0 đồng)

Hướng dẫn này giúp bạn đưa app **Lich Tuan** (SwiftUI + WidgetKit) lên iPhone cá nhân
mà **không cần App Store, không cần tài khoản Apple Developer trả phí, không cần Mac/Xcode**.

Cách tiếp cận: build IPA bằng GitHub Actions CI (đã có sẵn), sau đó ký lại bằng
**Apple ID miễn phí** và cài lên máy bằng **Sideloadly** trên Windows.

---

## 0. Tổng quan quy trình

```
[Tạo Gist + điền gistID vào code]
            ↓
[Push lên GitHub] → [CI tự build ra file .ipa]  (tự động, ~10-15 phút)
            ↓
[Tải file .ipa từ artifact]
            ↓
[Sideloadly trên Windows ký bằng Apple ID miễn phí]
            ↓
[Cài lên iPhone bằng cáp USB]
            ↓
[Mỗi 7 ngày gia hạn lại 1 lần]
```

---

## 1. Trước khi bắt đầu (chuẩn bị)

Bạn cần có:

| Thứ cần | Mô tả | Chi phí |
|---|---|---|
| iPhone (iOS 16+) | Là máy bạn muốn cài | Có sẵn |
| Windows PC | Đang dùng | Có sẵn |
| Apple ID miễn phí | Tạo tại https://appleid.apple.com | 0đ |
| iTunes (bản desktop) | Driver cho iPhone | 0đ |
| Sideloadly | Tải tại https://sideloadly.io | 0đ |
| Tài khoản GitHub | Để tạo Gist chứa dữ liệu sự kiện | 0đ |

> **Lưu ý về Apple ID:** Nếu Apple ID của bạn bật **2FA (xác thực 2 lớp)**, Sideloadly
> sẽ yêu cầu dùng **App-Specific Password** thay vì mật khẩu chính.
> Tạo tại https://appleid.apple.com → Sign-In and Security → App-Specific Passwords.

---

## 2. Bước A — Cấu hình đồng bộ dữ liệu qua Gist

**Lý do bỏ App Group:** Apple ID miễn phí (Personal Team) **không được cấp capability
`App Groups`** theo bảng [Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios/)
của Apple. Nếu vẫn giữ App Group, app cài được nhưng widget chỉ hiển thị dữ liệu mẫu.

Repo này đã chuyển sang chia sẻ dữ liệu qua một **GitHub Gist**:

```
[App chính] --PATCH kèm token--> [Gist: lichtuan-events.json] <--GET công khai-- [Widget]
```

Bundle ID đã được đổi sẵn sang `com.hoangkim24.*` và 2 file entitlements đã bị xoá,
nên không còn capability nào cần đăng ký.

### 2.1. Tạo Gist

1. Vào https://gist.github.com.
2. Đặt tên file: `lichtuan-events.json`.
3. Nội dung khởi tạo: `[]`.
4. Bấm **Create secret gist**.
5. Chép **Gist ID** trong URL, ví dụ với
   `https://gist.github.com/HoangKim24/3f9a1c2b4d5e6f7081920a1b2c3d4e5f`
   thì ID là `3f9a1c2b4d5e6f7081920a1b2c3d4e5f`.

### 2.2. Điền Gist ID vào code

Sửa `Shared/RemoteSyncConfig.swift`:

```swift
static let gistID = "3f9a1c2b4d5e6f7081920a1b2c3d4e5f"
```

> Đây là hằng số biên dịch vì widget extension không đọc được UserDefaults của app chính.
> Gist để chế độ secret nên ID này không tìm thấy qua tìm kiếm, nhưng ai biết ID vẫn đọc được.
> Đừng lưu dữ liệu nhạy cảm trong đó.

### 2.3. Tạo GitHub token

1. Vào https://github.com/settings/tokens → **Generate new token (classic)**.
2. Chỉ tick đúng scope **`gist`**.
3. Chép token, sẽ nhập trong app ở bước sau.

> **Tuyệt đối không** ghi token vào mã nguồn hay commit lên GitHub. App lưu token
> trong UserDefaults của máy bạn.

---

## 3. Bước B — Build file IPA bằng GitHub Actions

Repo này đã có sẵn workflow `.github/workflows/build.yml`, push lên `main` là CI tự build.

```bash
cd D:\Widget
git add .
git commit -m "Bo App Group, dong bo du lieu widget qua Gist"
git push origin main
```

Sau khi push, len GitHub: repo → tab **Actions** → cho workflow chay xong
(khoang **10-15 phut**, co 3 job: build → ui-tests → archive).

Workflow chi build IPA khi **push vao nhanh `main`** (job `archive` co dieu kien
`github.ref == 'refs/heads/main'`).

### Tai file IPA ve

1. Vao tab **Actions** → chon lan chay moi nhat (da xong).
2. O phan **Artifacts** → click **`lich-tuan-ipa`** de tai xuong.
3. Giai nen ra duoc file **`LichTuanApp.ipa`**.

> **Luu y:** File IPA nay la **unsigned** (chua ky) — Sideloadly se ky lai bang
> Apple ID mien phi cua ban o buoc tiep theo. Ban khong can sua gi them o CI.

---

## 4. Buoc C — Cai len iPhone bang Sideloadly (Windows)

### Chuan bi

1. Cai **iTunes** (neu chua co) → khoi dong lai may mot lan cho sach driver.
2. Tai va cai **Sideloadly** tu https://sideloadly.io.

### Cac buoc cai

```
1. Mo Sideloadly tren Windows
2. Truong "IPA" → bam chon file LichTuanApp.ipa da tai
3. Truong "Apple ID" → nhap email Apple ID mien phi
   (neu bat 2FA thi dung App-Specific Password)
4. Cam iPhone vao may tinh bang cap USB, chon "Trust" tren iPhone
5. Bam nut "Start" va cho qua trinh ky + cai hoan tat
6. Tren iPhone:
   Settings → General → VPN & Device Management
   → chon ho so Apple ID cua ban → bam "Trust"
```

App **Lich Tuan** se xuat hien tren Home Screen.

### Nhap token trong app

Mo app **Lich Tuan** → keo xuong muc **Widget Sync**:

1. Bam **Cau hinh GitHub token** → dan token co scope `gist` → bam **Luu**.
2. Dong sheet lai, dong **SyncStatusRow** phai bao "Dong bo thanh cong luc ...".
3. Neu bao loi, doi chieu bang **Xu ly su co** ben duoi.

### Kiem tra widget

1. Nhan giu nen Home Screen → bam nut **+**.
2. Tim **Lich Tuan** trong danh sach widget.
3. Them widget (Lock Screen hoac Home Screen).
4. Vao app → them 1 su kien → cho widget refresh (co the mat vai phut) hoac
   bam **Day du lieu len widget** de goi `WidgetCenter.reloadAllTimelines()`.

> Widget doc Gist qua mang, nen iPhone phai co ket noi internet o lan tai dau tien.
> Sau do du lieu duoc cache lai va van hien thi khi offline.

---

## 5. Buoc D — Gia han (bat buoc moi 7 ngay)

Apple ID mien phi chi cap chung chi **7 ngay**. Het han la app khong mo duoc,
phai ky lai. Co 2 cach:

### Cach 1: Sideloadly (don gian, cam day)

```
Moi khi gan het han:
1. Cam iPhone vao PC
2. Mo Sideloadly → chon lai file IPA (hoac dung Refresh)
3. Bam Start de ky + cai lai
```

### Cach 2: SideStore (tu dong, khong can PC sau lan dau)

SideStore la phien ban AltStore chay **ngay tren iPhone**, dung VPN loopback de
tu ky lai app qua WiFi, khong can cam day.

```
Lan dau:
1. Cai SideStore len iPhone thong qua Sideloadly/AltServer
2. Dang nhap Apple ID tren SideStore
3. Cai file LichTuanApp.ipa tu SideStore

Sau do:
- SideStore tu gia han app moi ngay khi iPhone mo WiFi
- Ban chi can dam bao iPhone thinh thoang ket noi WiFi
```

---

## 6. Xu ly su co

| Van de | Nguyen nhan co the | Cach xu ly |
|---|---|---|
| Sideloadly bao loi Apple ID | Bat 2FA | Dung App-Specific Password thay cho mat khau chinh |
| iPhone khong nhan dien | Chua cai iTunes / chua Trust | Cai iTunes, khoi dong lai, bam "Trust This Computer" |
| App khong mo duoc sau vai ngay | Chung chi het han 7 ngay | Ky lai bang Sideloadly hoac dung SideStore |
| Widget chi hien du lieu mau | `gistID` con de rong, hoac Gist chua co du lieu | Dien `gistID` trong `Shared/RemoteSyncConfig.swift` roi build lai; bam "Day du lieu len widget" trong app |
| App bao "Chua nhap GitHub token" | Chua luu token | Widget Sync → Cau hinh GitHub token |
| App bao "GitHub tra ve ma loi 401" | Token sai hoac het han | Tao token moi voi scope `gist` |
| App bao "GitHub tra ve ma loi 404" | Sai Gist ID, hoac token khong so huu Gist do | Kiem tra lai ID; Gist phai thuoc chinh tai khoan tao token |
| App bao "Gist khong chua file ..." | Ten file trong Gist khac `lichtuan-events.json` | Doi ten file trong Gist cho khop `RemoteSyncConfig.fileName` |
| Widget khong cap nhat ngay | WidgetKit tu quyet dinh lich refresh | Cho vai phut, hoac go widget ra roi them lai |
| CI build fail | project.yml sai cu phap | Xem log job "build" trong Actions, sua roi push lai |
| Khong tim thay artifact IPA | Chua push vao nhanh `main` / CI chua chay xong job `archive` | Kiem tra nhanh hien tai va cho tat ca job hoan tat |

---

## 7. Tong ket chi phi va han che

| Hang muc | Chi phi |
|---|---|
| Apple ID mien phi | 0d |
| Sideloadly / SideStore | 0d |
| GitHub Actions CI | 0d (repo public) |
| Gia han 7 ngay | 0d (ton ~2 phut neu dung Sideloadly) |
| **Tong** | **0d** |

**Han che can nho:**

- Phai **gia han moi 7 ngay** (tru khi dung SideStore thi tu dong).
- Chung chi free chi chay tren **dung 1 thiet bi** da cai.
- Day la cai **ca nhan**, khong public len App Store duoc.
- Moi lan ky lai chiem **2 App ID** (app + widget extension). Apple ID mien phi
  chi giu toi da **10 App ID** cung luc, moi cai het han sau 1 tuan.
- Du lieu app ↔ widget di qua **GitHub Gist**, khong dung App Group nua, vi
  Apple ID mien phi khong duoc cap capability do.
- Widget can mang o lan tai dau tien, sau do dung cache khi offline.
- Gist o che do secret nhung **khong duoc ma hoa**. Ai co Gist ID deu doc duoc,
  nen dung luu thong tin nhay cam trong lich.