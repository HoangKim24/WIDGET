import UIKit
import Vision
import ImageIO

/// Bộ quét chữ OCR từ hình ảnh thời khóa biểu / bảng lịch sử dụng Apple Vision Framework
enum ScheduleOCRScanner {

    enum OCRError: LocalizedError {
        case invalidImage
        case noTextFound

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "Không thể đọc dữ liệu hình ảnh. Vui lòng thử lại với ảnh khác."
            case .noTextFound:
                return "Không nhận diện được dòng chữ nào trong ảnh. Hãy thử chụp góc thẳng và đủ sáng."
            }
        }
    }

    /// Nhận diện chữ từ UIImage (hỗ trợ tiếng Việt và tiếng Anh)
    static func recognizeText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                    continuation.resume(throwing: OCRError.noTextFound)
                    return
                }

                // Sắp xếp các đoạn chữ nhận diện được từ trên xuống dưới theo trục Y (trong Vision, Y = 1 là đỉnh ảnh)
                // và từ trái qua phải theo trục X
                let sortedObservations = observations.sorted { obs1, obs2 in
                    let y1 = obs1.boundingBox.origin.y
                    let y2 = obs2.boundingBox.origin.y
                    let diffY = abs(y1 - y2)

                    // Nếu cùng một dòng (chênh lệch Y nhỏ hơn 0.02) thì sắp xếp theo X từ trái qua phải
                    if diffY < 0.02 {
                        return obs1.boundingBox.origin.x < obs2.boundingBox.origin.x
                    }
                    // Y lớn hơn ở phía trên nên dòng trên xếp trước
                    return y1 > y2
                }

                var lines: [String] = []
                for observation in sortedObservations {
                    if let topCandidate = observation.topCandidates(1).first {
                        let text = topCandidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !text.isEmpty {
                            lines.append(text)
                        }
                    }
                }

                if lines.isEmpty {
                    continuation.resume(throwing: OCRError.noTextFound)
                } else {
                    continuation.resume(returning: lines.joined(separator: "\n"))
                }
            }

            // Cấu hình tối ưu nhận diện tiếng Việt
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["vi-VN", "en-US"]

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgImagePropertyOrientation(from: image.imageOrientation), options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private static func cgImagePropertyOrientation(from uiOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch uiOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
