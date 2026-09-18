import SwiftUI
import Photos

/// Bộ quản lý xuất ảnh và lưu vào Album ảnh của iPhone.
@MainActor
final class WallpaperSaveManager: NSObject, ObservableObject {
    @Published var isSaving: Bool = false
    @Published var saveSuccess: Bool = false
    @Published var errorMessage: String? = nil

    /// Render hình nền ở độ phân giải siêu nét chuẩn iPhone 15 (3x) và lưu vào Photos
    func saveWallpaper(
        config: WallpaperConfig,
        events: [CalendarEvent],
        customImage: UIImage?
    ) {
        isSaving = true
        saveSuccess = false
        errorMessage = nil

        // Kích thước chuẩn iPhone 15: 393 x 852 điểm
        let targetSize = CGSize(width: 393, height: 852)

        let renderView = WallpaperCanvasView(
            config: config,
            events: events,
            customImage: customImage
        )
        .frame(width: targetSize.width, height: targetSize.height)

        let renderer = ImageRenderer(content: renderView)
        renderer.scale = 3.0 // Xuất độ nét Retina 3x (1179 x 2556 px)

        guard let uiImage = renderer.uiImage else {
            isSaving = false
            errorMessage = "Không thể tạo ảnh hình nền. Vui lòng thử lại!"
            return
        }

        // Kiểm tra quyền và lưu vào Thư viện ảnh
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .authorized, .limited:
                    UIImageWriteToSavedPhotosAlbum(
                        uiImage,
                        self,
                        #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                        nil
                    )
                case .denied, .restricted:
                    self.isSaving = false
                    self.errorMessage = "Bạn chưa cấp quyền lưu ảnh. Hãy vào Cài đặt > Quyền riêng tư > Ảnh để cấp quyền nhé!"
                case .notDetermined:
                    self.isSaving = false
                    self.errorMessage = "Chưa nhận được quyền lưu ảnh."
                @unknown default:
                    self.isSaving = false
                    self.errorMessage = "Lỗi không xác định khi truy cập thư viện ảnh."
                }
            }
        }
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            self.isSaving = false
            if let error = error {
                self.errorMessage = "Lưu ảnh thất bại: \(error.localizedDescription)"
                self.saveSuccess = false
            } else {
                self.saveSuccess = true
            }
        }
    }
}
