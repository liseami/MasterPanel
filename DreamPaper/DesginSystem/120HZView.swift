import SwiftUI
import MetalKit

// 创建一个自定义的MetalView
struct MetalView: UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.preferredFramesPerSecond = 120
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.delegate = context.coordinator
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalView
        
        init(_ parent: MetalView) {
            self.parent = parent
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let commandBuffer = view.device?.makeCommandQueue()?.makeCommandBuffer() else {
                return
            }
            
            // 这里可以添加自定义的绘制逻辑
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

// 创建一个包装整个应用内容的视图
struct High120HzView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            MetalView()
                .edgesIgnoringSafeArea(.all)
            content
        }
    }
}
