import Foundation
import UIKit
import Supabase

final class SupabaseStorageService {

    static let shared = SupabaseStorageService()

    private init() {}

    func uploadProductImage(
        image: UIImage,
        sku: String
    ) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Could not compress image."
            ])
        }

        let fileName = "\(sku).jpg"

        try await SupabaseManager.shared.client
            .storage
            .from("Product Images")
            .upload(
                path: fileName,
                file: imageData,
                options: FileOptions(contentType: "image/jpeg")
            )

        let publicURL = try SupabaseManager.shared.client
            .storage
            .from("Product Images")
            .getPublicURL(path: fileName)

        return publicURL.absoluteString
    }

    func uploadPlanogramDocument(
        data: Data,
        fileName: String
    ) async throws -> String {
        let filePath = "\(UUID().uuidString)-\(fileName)"

        try await SupabaseManager.shared.client
            .storage
            .from("Planograms")
            .upload(
                path: filePath,
                file: data,
                options: FileOptions(
                    cacheControl: "3600",
                    upsert: false
                )
            )

        let publicURL = try SupabaseManager.shared.client
            .storage
            .from("Planograms")
            .getPublicURL(path: filePath)

        return publicURL.absoluteString
    }
}
