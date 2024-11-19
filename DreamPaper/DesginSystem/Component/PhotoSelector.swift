//
//  ImagePicker.swift
//  LifeLoop
//
//  Created by 赵翔宇 on 2022/12/8.
//

import PhotosUI
import SwiftUI
struct PhotoSelector : View {
    var maxSelection: Int
    var completionHandler: (([UIImage]) -> Void)?
    init(maxSelection: Int, completionHandler: (([UIImage]) -> Void)?) {
        self.maxSelection = maxSelection
        self.completionHandler = completionHandler
    }

    var body: some View {
        PhotoSelectorRepresentable(maxSelection: maxSelection, completionHandler: completionHandler)
            .tint(Color.xmf1)
            .ignoresSafeArea()
            
    }
}

struct PhotoSelectorRepresentable: UIViewControllerRepresentable {
    var maxSelection: Int
    var completionHandler: (([UIImage]) -> Void)?

    init(maxSelection: Int, completionHandler: (([UIImage]) -> Void)?) {
        self.maxSelection = maxSelection
        self.completionHandler = completionHandler
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selectionLimit = maxSelection // 0 表示不限制选择数量
        config.filter = .images // 只允许选择照片
        let imagePicker = PHPickerViewController(configuration: config)
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        var parent: PhotoSelectorRepresentable

        init(_ parent: PhotoSelectorRepresentable) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if results.isEmpty {
                picker.dismiss(animated: true)
                return
            }
            // 创建一个空的UIImage数组来存储图片
            var images = [UIImage]()

            // 创建一个 dispatchGroup 来处理异步加载图片
            let dispatchGroup = DispatchGroup()

            // 在视图顶层添加一个全屏的 view
            let loadingView = UIView(frame: UIScreen.main.bounds)
            loadingView.backgroundColor = UIColor(Color.black.opacity(0.1))

            // 创建一个 UIActivityIndicatorView，并将其加入到 loadingView 中心位置
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .white
            spinner.center = loadingView.center

            loadingView.addSubview(spinner)
            spinner.startAnimating()

            // 添加到顶层 window 上
            Apphelper.shared.getWindow()?.addSubview(loadingView)

            // 遍历选中的结果
            for result in results {
                dispatchGroup.enter() // 进入 dispatchGroup

                // 异步加载选中的图片
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let error = error {
                        print("Error loading image: \(error.localizedDescription)") // 如果加载失败，则输出错误信息
                    } else if let image = image as? UIImage {
                        images.append(image) // 加载成功，将图片加入数组
                    }
                    dispatchGroup.leave() // 离开 dispatchGroup
                }
            }

            // 当所有图片都加载完成后，执行以下代码
            dispatchGroup.notify(queue: .main) {
                // 隐藏指示器
                loadingView.removeFromSuperview()

                // 调用父视图的 completionHandler 方法，并传入已选图片数组
                self.parent.completionHandler?(images)

                // 隐藏图片选择器
                picker.dismiss(animated: true)
            }
        }
    }
}

struct SinglePhotoSelector : View {
    var allowsEditing : Bool
    var completionHandler: (UIImage) -> Void
    init(allowsEditing:Bool = true ,completionHandler: @escaping ((UIImage) -> Void)) {
        self.completionHandler = completionHandler
        self.allowsEditing = allowsEditing
    }
    var body: some View {
        SinglePhotoSelectorRepresentable(allowsEditing: allowsEditing , completionHandler: completionHandler)
            .tint(Color.xmf1)
            .ignoresSafeArea()
        
    }
}


struct SinglePhotoSelectorRepresentable: UIViewControllerRepresentable {
    var completionHandler: (UIImage) -> Void
    var allowsEditing : Bool
    init(allowsEditing:Bool = true ,completionHandler: @escaping ((UIImage) -> Void)) {
        self.completionHandler = completionHandler
        self.allowsEditing = allowsEditing
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.allowsEditing = allowsEditing
        imagePicker.sourceType = .photoLibrary
        
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: SinglePhotoSelectorRepresentable

        init(_ parent: SinglePhotoSelectorRepresentable) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = parent.allowsEditing ? info[.editedImage] as? UIImage  : info[.originalImage] as? UIImage {
                picker.dismiss(animated: true)
                // Call the completionHandler and pass the selected image
                parent.completionHandler(selectedImage)
            }
        }
    }
}
