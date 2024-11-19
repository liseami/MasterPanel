/*
 See the License.txt file for this sample’s licensing information.
 */

import AVFoundation
import os.log
import SwiftUI

final class XMCameraManager: ObservableObject {
    let camera = Camera()
    let photoCollection = PhotoCollection(smartAlbum: .smartAlbumUserLibrary)
    
    @Published var viewfinderImage: Image?
    @Published var thumbnailImage: Image?
    @Published var showCamera: Bool = false
    @Published var loadingImage: Image?
    @Published var finalImageUrl: String?
    @Published var isLoading: Bool = false
    
    var isPhotosLoaded = false
    
    var onComplete: (Data) async -> Void
    
    init(onComplete: @escaping (Data) async -> Void) {
        self.onComplete = onComplete
        Task {
            await handleCameraPreviews()
        }
        Task {
            await handleCameraPhotos()
        }
    }

    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
            .map { $0.image }

        for await image in imageStream {
            DispatchQueue.main.async {
                self.viewfinderImage = image
            }
        }
    }
    
    /*
     处理相机拍摄的图片
     */
    func handleCameraPhotos() async {
        let unpackedPhotoStream = camera.photoStream
            .compactMap { self.unpackPhoto($0) }
        
        for await photoData in unpackedPhotoStream {
            let imageData = photoData.imageData
            // 拿到图片，直接关闭相机
            Task { @MainActor in
                Apphelper.shared.closeSheet()
                await waitme(sec: 0.2)
                self.isLoading = false
                await onComplete(imageData)
            }
        }
    }
    
    /*
     解包图片
     */
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        guard let imageData = photo.fileDataRepresentation() else { return nil }

        guard let previewCGImage = photo.previewCGImageRepresentation(),
              let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)
        
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        
        return PhotoData(thumbnailImage: thumbnailImage, thumbnailSize: thumbnailSize, imageData: imageData, imageSize: imageSize)
    }
    
//    func savePhoto(imageData: Data) {
//        Task {
//            do {
//                try await photoCollection.addImage(imageData)
////                logger.debug("Added image data to photo collection.")
//            } catch {
////                logger.error("Failed to add image to photo collection: \(error.localizedDescription)")
//            }
//        }
//    }
    
//    func loadPhotos() async {
//        guard !isPhotosLoaded else { return }
//
//        let authorized = await PhotoLibrary.checkAuthorization()
//        guard authorized else {
////            logger.error("Photo library access was not authorized.")
//            return
//        }
//
//        Task {
//            do {
//                try await self.photoCollection.load()
//                await self.loadThumbnail()
//            } catch {
////                logger.error("Failed to load photo collection: \(error.localizedDescription)")
//            }
//            self.isPhotosLoaded = true
//        }
//    }
    
//    func loadThumbnail() async {
//        guard let asset = photoCollection.photoAssets.first else { return }
//        await photoCollection.cache.requestImage(for: asset, targetSize: CGSize(width: 256, height: 256)) { result in
//            if let result = result {
//                Task { @MainActor in
//                    self.thumbnailImage = result.image
//                }
//            }
//        }
//    }
}

private struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

private extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

private extension Image.Orientation {
    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

//private let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "DataModel")

extension UIImage {
    func resize(_ width: CGFloat, _ height: CGFloat) -> UIImage? {
        let widthRatio = width / size.width
        let heightRatio = height / size.height
        let ratio = widthRatio > heightRatio ? heightRatio : widthRatio
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
