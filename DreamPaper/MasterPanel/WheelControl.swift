/**
MIT License

Copyright (c) 2022 Alexandre R. J. Francois

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import SwiftUI

public enum Orientation {
    case vertical, horizontal, auto
    
    func resolved(size: CGSize) -> Orientation {
        if self == .auto {
            return (size.height > size.width) ? .vertical : .horizontal
        }
        return self
    }
}

fileprivate let halfPi = CGFloat.pi / 2.0

public struct WheelControl: View {
    @Binding var value: Float
    private var range: ClosedRange<Float>
    private var orientation: Orientation = .auto
    private var onChange: ((_ value: Float) -> ())? = nil
    private var onCommit: ((_ value: Float) -> ())? = nil

    @State private var scaleIdx = 0
    @State private var lastDrag: CGFloat = 0
    
    static private let scales: [CGFloat] = [1.0, 0.3, 0.05]
    static private let linesDensity: [CGFloat] = [20.0, 8.0, 4.0]
    static private let lineWidths: [CGFloat] = [1, 2, 3]

    var lineWidth : CGFloat {
        WheelControl.lineWidths[scaleIdx]
    }

    public init(value: Binding<Float>, range: ClosedRange<Float>, orientation: Orientation = .auto, onChange: ((Float) -> ())? = nil, onCommit: ((Float) -> ())? = nil) {
        self._value = value
        self.range = range
        self.orientation = orientation
        self.onChange = onChange
        self.onCommit = onCommit
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if orientation.resolved(size: geometry.size) == .horizontal {
                    linesH(value, size: geometry.size)
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    
                    frame(size: geometry.size)
                        .stroke(Color.secondary.opacity(0.1), style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))

                    levelsH(value, size: geometry.size)
                        .stroke(Color.clear, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                } else {
                    linesV(value, size: geometry.size)
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    
                    frame(size: geometry.size)
                        .stroke(Color.secondary.opacity(0.1), style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    
                    levelsV(value, size: geometry.size)
                        .stroke(Color.clear, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                }
            }
//            .background(Color(UIColor.systemBackground))
            .gesture(
                TapGesture(count: 2)
                    .onEnded { _ in
                        nextScale()
                    }
                    .exclusively(before:
                                    DragGesture(minimumDistance: 0.0)
                        .onChanged { drag in
                            onDragChanged(translation: drag.translation, size: geometry.size)
                            if let onChange = self.onChange {
                                onChange(self.value)
                            }
                        }
                        .onEnded { drag in
                            onDragEnded()
                            if let onCommit = self.onCommit {
                                onCommit(self.value)
                            }
                        })
            )
        }
    }
    
    // MARK: - Wheel Lines
    
    /// Lines for horizontal orientation
    /// map the 2pi range of the wheel to the range of values,
    /// apply an offset based on the value
    /// the scale of interaction affects the line density
    /// - parameter value: the current value in the range
    /// - parameter size: the size of the rectangle area for the wheel
    /// - returns: the Path that draws the lines
    private func linesH(_ value: Float, size: CGSize) -> Path {
        let offset = (CGFloat.pi * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))) / WheelControl.scales[scaleIdx]        
        let delta = CGFloat.pi / WheelControl.linesDensity[scaleIdx]
        let halfW = size.width / 2

        let k: CGFloat = ceil((offset - halfPi) / delta)
        var alpha = k * delta - offset
        
        return Path { path in
            while alpha < halfPi {
                let lengthPosition = halfW * (1 - sin(alpha))
                path.move(to: CGPoint(x: lengthPosition, y: 0))
                path.addLine(to: CGPoint(x: lengthPosition, y: size.height))
                alpha += delta
            }
        }
    }

    /// Lines for vertical orientation
    /// map the 2pi range of the wheel to the range of values,
    /// apply an offset based on the value
    /// the scale of interaction affects the line density
    /// - parameter value: the current value in the range
    /// - parameter size: the size of the rectangle area for the wheel
    /// - returns: the Path that draws the lines
    private func linesV(_ value: Float, size: CGSize) -> Path {
        let offset = (CGFloat.pi * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))) / WheelControl.scales[scaleIdx]
        let delta = CGFloat.pi / WheelControl.linesDensity[scaleIdx]
        let halfH = size.height / 2

        let k: CGFloat = ceil((offset - halfPi) / delta)
        var alpha = k * delta - offset

        return Path { path in
            while alpha < halfPi {
                let lengthPosition = halfH * (1 + sin(alpha))
                path.move(to: CGPoint(x: 0, y: lengthPosition))
                path.addLine(to: CGPoint(x: size.width, y: lengthPosition))
                alpha += delta
            }
        }
    }

    // MARK: - Frame
    
    /// Frame for all orientations
    /// - parameter size: the size of the rectangle area for the wheel
    /// - returns: the Path that draws the frame
    private func frame(size: CGSize) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.closeSubpath()
        }
    }
    
    // MARK: - Levels
    
    /// Levels for horizontal orientation
    /// map the length of the control area to the range
    /// - parameter value: the current value
    /// - parameter size: the size of the rectangle area for the wheel
    /// - returns: the Path that draws the levels
    private func levelsH(_ value: Float, size: CGSize) -> Path {
        let levelPosition = size.width * CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound)
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: levelPosition, y: 0))
            path.move(to: CGPoint(x: 0, y: size.height))
            path.addLine(to: CGPoint(x: levelPosition, y: size.height))
        }
    }
    
    /// Levels
    /// map the length of the control area to the range
    /// - parameter value: the current value
    private func levelsV(_ value: Float, size: CGSize) -> Path {
        let levelPosition = size.height * CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound)
        return Path { path in
            path.move(to: CGPoint(x: 0, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height - levelPosition))
            path.move(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: size.width, y: size.height - levelPosition))
        }
    }

    // MARK: - Scale
    
    /// Get to the next scale index (cycle through available scales)
    private func nextScale() {
        scaleIdx = (scaleIdx + 1) % WheelControl.scales.count
    }
    
    // MARK: - Dragging
    
    /// Compute the new value based on a drag gesture translation:
    /// map the length of the control area to the range and apply current scale
    private func onDragChanged(translation: CGSize, size: CGSize) {
        let relativeDrag = orientation.resolved(size: size) == .horizontal
        ? -translation.width / size.width
        : translation.height / size.height
        
        // map the length of the control to the range and apply a scale of interaction
        let dragMag = (relativeDrag - lastDrag) * CGFloat(range.upperBound - range.lowerBound) * WheelControl.scales[scaleIdx]
        
        lastDrag = relativeDrag
        value = range.clamp(value - Float(dragMag))
    }
    
    private func onDragEnded() {
        lastDrag = 0
    }
    
}

// MARK: - Preview

struct WheelControlPreviewContainer : View {
    @State private var value: Float = 20.0
    var range: ClosedRange<Float> = -11.0...133.0
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    Slider(value: $value, in: range)
                    Text("\(value)")
                }.padding()

                VStack(spacing: 20) {
                    WheelControl(value: $value, range: range, orientation: .auto)
                        .frame(width: 100, height: 40)
                    WheelControl(value: $value, range: range, orientation: .horizontal)
                        .frame(width: 200, height: 40)
                    WheelControl(value: $value, range: range, orientation: .auto)
                        .frame(width: 300, height: 60)
                }
            }
            .padding(.bottom)

            HStack(spacing: 20) {
                WheelControl(value: $value, range: range, orientation: .auto)
                    .frame(width: 60, height: 300)
                WheelControl(value: $value, range: range, orientation: .vertical)
                    .frame(width: 60, height: 200)
                WheelControl(value: $value, range: range, orientation: .auto)
                    .frame(width: 40, height: 200)
                WheelControl(value: $value, range: range, orientation: .vertical)
                    .frame(width: 40, height: 100)
            }
        }
    }
}

struct WheelControl_Previews: PreviewProvider {
    static var previews: some View {
//        WheelControlPreviewContainer()
        FilmView()
    }
}

// MARK: - Extensions

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }
}
