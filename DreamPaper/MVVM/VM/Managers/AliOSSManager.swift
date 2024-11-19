////
////  AliOSSManager.swift
////  SMON
////
////  Created by 赵翔宇 on 2024/2/28.
////
//
//import AliyunOSSiOS
//import Foundation
//import JDStatusBarNotification
//
//@MainActor
//class AliyunOSSManager {
//    init() {
//        self.OSSClient = getOSSClient()
//    }
//
//    static let shared: AliyunOSSManager = .init()
//
//    var ossInfo: XMAPPConfig {
//        ConfigStore.shared.appConfig
//    }
//
//    var OSSClient: OSSClient?
//
//    // 获取OSSClient
//    func getOSSClient() -> OSSClient? {
//        let OSSCredentialProvider = OSSStsTokenCredentialProvider(
//            accessKeyId: ossInfo.oss_accessKeyId,
//            secretKeyId: ossInfo.oss_accessKeySecret,
//            securityToken: ossInfo.oss_securityToken)
//        return AliyunOSSiOS.OSSClient.init(endpoint: ossInfo.oss_endpoint, credentialProvider: OSSCredentialProvider)
//    }
//
//    enum XMOSSKeyPath: String {
//        case avatar
//        case uservoice
//        case red_book_post
//    }
//
//    /*
//     上传图片到OSS
//     */
//    func uploadImagesToOSS(images: [UIImage], type: XMOSSKeyPath = .avatar, progressCallback: @escaping (Int, Float) -> Void, completion: @escaping ([String]?) -> Void) {
//        let bucketName = "strangerbell-oss"
//        var currentIndex = 0
//        var uploadedImageURLs: [String] = []
//        func uploadNextImage() {
//            guard currentIndex < images.count else {
//                // All images uploaded successfully
//                completion(uploadedImageURLs)
//                return
//            }
//
//            let image = images[currentIndex]
//            let put = OSSPutObjectRequest()
//            // 业务类型，头像，食物图片，等
//            let type = type.rawValue
//            // 图片名称
//            let imageName = "GirlsMoeny_iOS_UserPic_\(Date.now.string(withFormat: "yyyyMMddHHmm"))_\(String.random(ofLength: 12))" + ".JPG"
//            // 环境
//            let env = AppConfig.env == .dev ? "test" : "prod"
//            // 最终路径：test(or prod)/业务类型柜子名/图片名称.jpg
//            let objectKey = "\(env)/\(type)/\(imageName)"
//            put.bucketName = bucketName
//            put.objectKey = objectKey
//            // guard let data = compressImage(image) else { completion(nil); return }
//            put.uploadingData = image.jpegData(compressionQuality: 0.5)!
//            // 当前上传长度、当前已上传总长度、待上传的总长度。
//            put.uploadProgress = { _, totalByteSent, totalBytesExpectedToSend in
//                let progress = Float(totalByteSent) / Float(totalBytesExpectedToSend)
//                progressCallback(currentIndex + 1, progress)
//            }
//
//            let putTask = OSSClient?.putObject(put)
//
//            putTask?.continue(with: .default(), with: { task in
//                if let error = task.error {
//                    print(error.localizedDescription)
//                    print(error)
//                    // Error occurred, stop the process and report the error
//                    completion(nil)
//                } else {
//                    // Current image uploaded successfully, add the URL to the array
//                    let imageURL = "\(objectKey)"
//                    uploadedImageURLs.append(imageURL)
//                    currentIndex += 1
//                    uploadNextImage()
//                }
//                return
//            })
//        }
//        // 循环调用
//        uploadNextImage()
//    }
//
//    func upLoadImages(images: [UIImage], type: XMOSSKeyPath = .avatar, completion: @escaping ([String]?) -> Void) {
//        uploadImagesToOSS(images: images, type: type) { currentImage, totalProgress in
//            // 处理当前图片上传进度和整体进度
//            print("上传第 \(currentImage) 张图片，总体进度: \(totalProgress * 100)%")
//            DispatchQueue.main.async {
//                Apphelper.shared.pushProgressNotification(text: "(\(currentImage)/\(images.count))正在上传...") { presenter in
//                    presenter.displayProgressBar(at: Double(totalProgress))
//                }
//            }
//        } completion: { urls in
//            if let urls {
//                print("所有图片上传成功，URLs: \(urls)")
//                completion(urls)
//                DispatchQueue.main.async {
//                    NotificationPresenter.shared.dismiss()
//                    Apphelper.shared.pushNotification(type: .success(message: "上传完成。"))
//                }
//            } else {
//                completion(nil)
//                DispatchQueue.main.async {
//                    NotificationPresenter.shared.dismiss()
//                    Apphelper.shared.pushNotification(type: .error(message: "请再试一下。"))
//                    Task { await ConfigStore.shared.getAppConfig()
//                        self.OSSClient = self.getOSSClient()
//                        Apphelper.shared.closeSheet()
//                    }
//                }
//            }
//        }
//    }
//
//    func upLoadImages_async(images: [UIImage], type: XMOSSKeyPath = .avatar) async -> [String]? {
//        return await withCheckedContinuation { continuation in
//            upLoadImages(images: images, type: type) { urls in
//                if let urls {
//                    continuation.resume(returning: urls)
//                } else {
//                    continuation.resume(returning: nil)
//                }
//            }
//        }
//    }
//
//    func uploadAudio_async(audioData: Data, type: XMOSSKeyPath = .uservoice) async -> String? {
//        return await withCheckedContinuation { continuation in
//            uploadAudioToOSS(audioData: audioData, type: type) { url in
//                continuation.resume(returning: url)
//            }
//        }
//    }
//
//    private func uploadAudioToOSS(audioData: Data, type: XMOSSKeyPath, completion: @escaping (String?) -> Void) {
//        let bucketName = "strangerbell-oss"
//        let put = OSSPutObjectRequest()
//
//        // 音频文件名称
//        let audioName = "StrangerBell_iOS_Audio_\(Date.now.string(withFormat: "yyyyMMddHHmmss"))_\(String.random(ofLength: 12)).wav"
//        // 环境
//        let env = AppConfig.env == .dev ? "test" : "prod"
//        // 最终路径：test(or prod)/业务类型/音频名称.mp3
//        let objectKey = "\(env)/\(type.rawValue)/\(audioName)"
//
//        put.bucketName = bucketName
//        put.objectKey = objectKey
//        put.uploadingData = audioData
//        put.contentType = "audio/wav" // PCM 格式对应的 MIME 类型为 audio/wav
//
//        // 添加音频属性元数据
//        put.callbackParam = [
//            "x-oss-meta-sample-rate": "16000", // 采样率 16kHz
//            "x-oss-meta-bit-depth": "16", // 位深 16 bit
//            "x-oss-meta-channels": "1", // 单声道
//            "x-oss-meta-max-duration": "60" // 最大时长 60 秒（你可以根据实际需要修改）
//        ]
//
//        put.uploadProgress = { _, totalByteSent, totalBytesExpectedToSend in
//            let progress = Float(totalByteSent) / Float(totalBytesExpectedToSend)
////            print("音频上传进度: \(progress * 100)%")
////            DispatchQueue.main.async {
////                Apphelper.shared.pushProgressNotification(text: "正在上传音频...") { presenter in
////                    presenter.displayProgressBar(at: Double(progress))
////                }
////            }
//        }
//
//        let putTask = OSSClient?.putObject(put)
//
//        putTask?.continue(with: .default(), with: { task in
//            if let error = task.error {
//                print("音频上传失败: \(error.localizedDescription)")
//                completion(nil)
//                DispatchQueue.main.async {
////                    NotificationPresenter.shared.dismiss()
//                    Task {
//                        await ConfigStore.shared.getAppConfig()
//                    }
//                    Apphelper.shared.pushNotification(type: .error(message: "音频上传失败，请重试。"))
//                }
//            } else {
//                let audioURL = "\(objectKey)"
//                print("音频上传成功，URL: \(audioURL)")
//                completion(audioURL)
////                DispatchQueue.main.async {
////                    NotificationPresenter.shared.dismiss()
////                }
//            }
//            return
//        })
//    }
//}
//
//func compressImage(_ image: UIImage) -> Data? {
//    var imageData = image.jpegData(compressionQuality: 0.9)
//
//    while let data = imageData, data.count > 250000 {
//        imageData = UIImage(data: data)?.jpegData(compressionQuality: 0.9)
//    }
//
//    if let data = imageData {
//        return data
//    } else {
//        return nil
//    }
//}
