import UIKit

// 定义 Point 结构体，表示颜色的三个分量
struct Point: Equatable {
    let x: CGFloat
    let y: CGFloat
    let z: CGFloat
    
    init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    // 将 UIColor 转换为 Point
    init(from color: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            x = r
            y = g
            z = b
        } else {
            x = 0
            y = 0
            z = 0
        }
    }
    
    // 将 Point 转换为 UIColor
    func toUIColor() -> UIColor {
        return UIColor(red: x, green: y, blue: z, alpha: 1)
    }
    
    // 重载 == 运算符用于判断两个 Point 是否相等
    static func ==(lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    func distanceSquared(to p : Point) -> CGFloat {
        return (self.x - p.x) * (self.x - p.x)
            + (self.y - p.y) * (self.y - p.y)
            + (self.z - p.z) * (self.z - p.z)
    }
}

// 扩展 UIColor，添加 HSL 颜色空间相关计算方法
extension UIColor {
    // 将 UIColor 转换为 HSLColor
    func toHSLColor() -> HSLColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return HSLColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    // 生成文本颜色，根据主色调整
    func makeTextColor() -> UIColor {
        let hslColor = self.toHSLColor()
        let shiftedHSLColor = HSLColor(hue: hslColor.hue + 0.5,
                                       saturation: max(0, hslColor.saturation - 0.5),
                                       brightness: min(1, hslColor.brightness + 0.5),
                                       alpha: hslColor.alpha)
        return shiftedHSLColor.uiColor
    }
}

// 定义 HSLColor 结构体，表示 HSL 颜色空间
struct HSLColor {
    let hue: CGFloat
    let saturation: CGFloat
    let brightness: CGFloat
    let alpha: CGFloat
    
    // 将 HSLColor 转换为 UIColor
    var uiColor: UIColor {
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

// 定义 UIImage 的扩展，用于获取图片的主题色和文本颜色
extension UIImage {
    
    // 获取主题色和文本颜色
    func getThemeAndTextColor() -> (UIColor, UIColor)? {
        // 获取图片像素点的颜色数据
        guard let pixels = self.getPixels() else {
            return nil
        }
        
        // 使用 kMeans 算法获取颜色聚类
        let clusters = cluster(points: pixels, into: 3).sorted(by: {$0.points.count > $1.points.count})
        guard let mainColor = clusters.first?.center.toUIColor() else {
            return nil
        }
        
        // 生成文本颜色
        let textColor = mainColor.makeTextColor()
        
        return (mainColor, textColor)
    }
    
    // 定义一个异步函数，用于在后台线程执行主题色和文本颜色的计算，并返回结果
    func getThemeAndTextColorAsync(completion: @escaping ((UIColor, UIColor)?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // 在后台线程执行图片处理操作
            if let (mainColor, textColor) = self.getThemeAndTextColor() {
                // 计算完成后在主线程返回结果
                DispatchQueue.main.async {
                    completion((mainColor, textColor))
                }
            } else {
                // 如果计算失败，在主线程返回 nil
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    
    // 将图片缩放到指定大小
    func resized(to size: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        // 禁用 HDR
        format.preferredRange = .standard
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let result = renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return result
    }
    
    // 获取图片像素点的颜色数据
    // 获取图片像素点的颜色数据，排除透明像素
    private func getPixels() -> [Point]? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        assert(cgImage.bitsPerPixel == 32, "only support 32 bit images")
        assert(cgImage.bitsPerComponent == 8, "only support 8 bit per channel")
        guard let imageData = cgImage.dataProvider?.data as Data? else {
            return nil
        }
        let size = cgImage.width * cgImage.height
        let buffer = UnsafeMutableBufferPointer<UInt32>.allocate(capacity: size)
        _ = imageData.copyBytes(to: buffer)
        var result = [Point]()
        result.reserveCapacity(size)
        for pixel in buffer {
            var r: UInt32 = 0
            var g: UInt32 = 0
            var b: UInt32 = 0
            var a: UInt32 = 0
            if cgImage.byteOrderInfo == .orderDefault || cgImage.byteOrderInfo == .order32Big {
                r = pixel & 255
                g = (pixel >> 8) & 255
                b = (pixel >> 16) & 255
                a = (pixel >> 24) & 255
            } else if cgImage.byteOrderInfo == .order32Little {
                r = (pixel >> 16) & 255
                g = (pixel >> 8) & 255
                b = pixel & 255
                a = (pixel >> 24) & 255
            }
            // 只收集非透明像素的颜色数据
            if a > 0 {
                let point = Point(CGFloat(r) / 255.0, CGFloat(g) / 255.0, CGFloat(b) / 255.0)
                result.append(point)
            }
        }
        return result
    }
    
    // 对图片进行颜色聚类
    private func cluster(points: [Point], into k: Int) -> [Cluster] {
        var clusters = [Cluster]()
        for _ in 0 ..< k {
            var p = points.randomElement()
            while p == nil || clusters.contains(where: {$0.center == p}) {
                p = points.randomElement()
            }
            clusters.append(Cluster(center: p!))
        }
        
        for p in points {
            let closest = findClosest(for: p, from: clusters)
            closest.points.append(p)
        }
        
        for _ in 0 ..< 10 {
            clusters.forEach {
                $0.points.removeAll()
            }
            for p in points {
                let closest = findClosest(for: p, from: clusters)
                closest.points.append(p)
            }
            var converged = true
            clusters.forEach {
                let oldCenter = $0.center
                $0.updateCenter()
                if oldCenter.distanceSquared(to: $0.center) > 0.001 {
                    converged = false
                }
            }
            if converged {
                break
            }
        }
        
        return clusters
    }
    
    // 找到离指定点最近的簇
    private func findClosest(for p: Point, from clusters: [Cluster]) -> Cluster {
        return clusters.min(by: {$0.center.distanceSquared(to: p) < $1.center.distanceSquared(to: p)})!
    }
}

// 定义 Cluster 类，表示一个颜色簇
class Cluster {
    var points = [Point]()
    var center: Point
    
    init(center: Point) {
        self.center = center
    }
    
    // 计算当前簇的中心点
    private func calculateCurrentCenter() -> Point {
        if points.isEmpty {
            return Point(0, 0, 0)
        }
        let totalX = points.reduce(0, {$0 + $1.x})
        let totalY = points.reduce(0, {$0 + $1.y})
        let totalZ = points.reduce(0, {$0 + $1.z})
        let averageX = totalX / CGFloat(points.count)
        let averageY = totalY / CGFloat(points.count)
        let averageZ = totalZ / CGFloat(points.count)
        return Point(averageX, averageY, averageZ)
    }
    
    // 更新簇的中心点
    func updateCenter() {
        if points.isEmpty {
            return
        }
        let currentCenter = calculateCurrentCenter()
        center = points.min(by: {$0.distanceSquared(to: currentCenter) < $1.distanceSquared(to: currentCenter)})!
    }
}



//// 测试
//if let image = UIImage(named: "your_image_name_here") {
//    if let (mainColor, textColor) = image.getThemeAndTextColor() {
//        print("Main Color: \(mainColor)")
//        print("Text Color: \(textColor)")
//    } else {
//        print("Failed to extract theme and text colors from the image.")
//    }
//} else {
//    print("Failed to load the image.")
//}
