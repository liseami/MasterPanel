/*
 See the License.txt file for this sample’s licensing information.
 */

import SwiftUI
import SwiftUIX

struct CameraView: View {
    @StateObject private var cameraManager: XMCameraManager

    init(onComplete: @escaping (Data) async -> Void) {
        self._cameraManager = .init(wrappedValue: .init(onComplete: onComplete))
    }

    private static let barHeightFactor = 0.2

    var body: some View {
        ZStack {
            Color.xmb1.opacity(0.5)
                .blur(radius: 5)
                .ignoresSafeArea()
            GeometryReader { geometry in
                Group {
                    if cameraManager.viewfinderImage != nil {
                        ViewfinderView(image: $cameraManager.viewfinderImage)
                    } else {
                        BlurEffectView(style: .dark)
                    }
                }
                .overlay(alignment: .bottom) {
                    VStack(alignment: .center, spacing: 12) {
                        buttonsView()
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                            .background(.xmf1.opacity(0.58))
                    }
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.72)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .padding(.all, 16)
            .shadow(color: .xmf1.opacity(0.3), radius: 24, x: 0, y: 0)
        }
        .task {
            // 相机预览启动
            await cameraManager.camera.start()
//            await cameraManager.loadPhotos()
//            await cameraManager.loadThumbnail()
        }
        .onDisappear(perform: {
            cameraManager.camera.stop()
        })
    }

    // 拍摄按钮
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            Spacer()

            Button {
                /*
                 拍摄 🎬
                 */

                Task { @MainActor in
                    await ConfigStore.shared.getAppConfig()
                    cameraManager.isLoading = true
                    cameraManager.camera.takePhoto()
                }

            } label: {
                Circle()
                    .fill(.white)
                    .frame(width: 74, height: 74)
                    .padding(.all, 8)
                    .overlay {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                    }
                    .overlay(alignment: .center) {
                        ProgressView()
                            .ifshow(show: cameraManager.isLoading)
                    }
            }

            Spacer()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .overlay(alignment: .leading) {
            XMDesgin.XMButton {
                Apphelper.shared.closeSheet()
            } label: {
                XMDesgin.XMIcon(iconName: "system_down_arrow", color: .xmb1, withBackCricle: false)
            }
            .padding(.leading, 12)
        }
        .overlay(alignment: .trailing) {
            XMDesgin.XMButton {
                Apphelper.shared.present(SinglePhotoSelector(allowsEditing: false, completionHandler: { UIImage in
                    LoadingTask(loadingMessage: "正在处理") {
                        Apphelper.shared.closeSheet()
                        await waitme(sec: 0.3)
                        Apphelper.shared.closeSheet()
                        await waitme(sec: 0.3)
                        await cameraManager.onComplete(UIImage.jpegData(compressionQuality: 1)!)
                    }
                }), named: "", presentationStyle: .fullScreen)
            } label: {
                XMDesgin.XMIcon(iconName: "meal_image", color: .xmb1, withBackCricle: false)
            }
            .padding(.trailing, 12)
        }
        .padding()
    }
}

#Preview {
    CameraView.init { _ in
    }
}
