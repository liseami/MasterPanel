//
//  BannerRow.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/9.
//

import SwiftUI

struct XMBanner: Identifiable {
    let id = UUID().uuidString
    let str: String = "networkerror_pagepic"
}

struct BannerRow<Content: View, T: Identifiable>: View {
    let screenW = UIScreen.main.bounds.width
    var imageW: CGFloat
    var spacing: CGFloat
    var list: [T]
    var content: (T) -> Content
    @Binding var index: Int
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int
    init(imageW: CGFloat = CGFloat(156.0), spacing: CGFloat = CGFloat(12), index: Binding<Int>, list: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.imageW = imageW
        self.spacing = spacing
        self.list = list
        self._index = index
        self.content = content
        self._currentIndex = State(initialValue: index.wrappedValue)
    }

    var body: some View {
        // HStack视图的总长度
        let HStackW = (CGFloat(list.count) * imageW + spacing * (CGFloat(list.count) - 1))
        // 先将视图调整到贴近页面的最左侧
        let HStackOffset = HStackW / 2 - screenW / 2
        // 让第0张处于屏幕的正中央
        let offsetFixToCenter = screenW / 2 - imageW / 2
        // 接下来， currentIndex 每加一，都向右移动
        let offsetStep = CGFloat(currentIndex) * (imageW + spacing)
        HStack(spacing: spacing) {
            ForEach(Array(list.enumerated()), id: \.offset) { index, item in
                // 真正的进度与手指滑动相绑定 -1 ... 1
                let dragProgress = self.offset / (screenW / 2)
                // 当前图片与最中央图片中间的图片张数
                let offsetToCurrentIndex = CGFloat(index - currentIndex)
                let realOffsetToCurrentIndex = offsetToCurrentIndex + dragProgress
                content(item)
                    .rotation3DEffect(.init(radians: 0.6 * -realOffsetToCurrentIndex), axis: (0, -12, 0), anchor: offsetToCurrentIndex > 0 ? .leading : .trailing, anchorZ: 0.1, perspective: 0.9)
                    .offset(y: abs(realOffsetToCurrentIndex) * -4)
                    .animation(.spring, value: currentIndex)
            }
        }
        .offset(x: HStackOffset + offsetFixToCenter - offsetStep + offset)
        .animation(.spring, value: offset)
        .padding(.vertical, 12)
        .gesture(
            DragGesture()
                .updating($offset, body: { value, out, _ in
                    out = value.translation.width
                })
                .onEnded { value in
                    let offsetX = value.translation.width
                    if offsetX < 0 {
                        moveToNextPic()
                    } else {
                        moveToLastPic()
                    }
                }
        )
    }

    func moveToNextPic() {
        guard currentIndex < list.count - 1 else {
            Apphelper.shared.nofimada(.error)
            return
        }
        currentIndex += 1
        index = currentIndex
        Apphelper.shared.mada(style: .rigid)
    }

    func moveToLastPic() {
        guard currentIndex > 0 else {
            Apphelper.shared.nofimada(.error)
            return
        }
        currentIndex -= 1
        index = currentIndex
        Apphelper.shared.mada(style: .rigid)
    }
}

#Preview {
//    let memberShipInfo: [XMMemberShipInfo] = [
//        .init(color: Color.red, name: "月度会员", price: 6, time: "30天", desc: "平均每天2毛钱，基础token限额翻倍。满足日常需要。"),
//        .init(color: Color.green, name: "年度会员", price: 50, time: "365天", desc: "省钱又实惠！一次性购买，让您全年尽情畅享会员特权。"),
//        .init(color: Color.blue, name: "美食家计划会员", price: 10, time: "30天", desc: "每月只需支付10元，即可享受全平台美食优惠，尽情探索美味世界。")
//    ]

    Color.clear
//        .frame(maxWidth: .infinity)
//        .frame(height: UIScreen.main.bounds.width * 0.618 / 3 * 4)
//        .overlay {
//            BannerRow(imageW: UIScreen.main.bounds.width * 0.618, spacing: 16, index: .constant(1), list: memberShipInfo) { membership in
//                MemberCard(membership: membership)
//            }
//        }
//        .padding(.top, 24)
//    Rota3dTest()
}

struct Rota3dTest: View {
    @State var degrees: CGFloat = 32
    @State var axisx: CGFloat = 0
    @State var axisy: CGFloat = 1
    @State var axisz: CGFloat = 0
    @State var anchorZ: CGFloat = 0
    @State var perspective: CGFloat = 0
    @State var anchor: UnitPoint = .leading
    var body: some View {
        VStack {
            headerImage
                .rotation3DEffect(.init(degrees: degrees), axis: (axisx, axisy, axisz), anchor: anchor, anchorZ: anchorZ, perspective: perspective)
            Picker(selection: $anchor) {
//                ForEach([UnitPoint.center, UnitPoint.leading, UnitPoint.trailing, UnitPoint.top, UnitPoint.bottom], id: \.self) { tag in
//
//                }
                Text("center").tag(UnitPoint.center)
                Text("leading").tag(UnitPoint.leading)
                Text("trailing").tag(UnitPoint.trailing)
                Text("top").tag(UnitPoint.top)
                Text("bottom").tag(UnitPoint.bottom)
            }
            .pickerStyle(.segmented)
            Text("degrees\(degrees)")
            Slider(value: $degrees, in: 0...360)
            Text("axisx\(axisx)")
            Slider(value: $axisx, in: 0...1)
            Text("axisy\(axisy)")
            Slider(value: $axisy, in: 0...1)
            Text("axisz\(axisz)")
            Slider(value: $axisz, in: -1...1)
            Text("anchorZ\(anchorZ)")
            Slider(value: $anchorZ, in: 0...1)
            Text("perspective\(perspective)")
            Slider(value: $perspective, in: 0...1)
//            Text("degrees\(degrees)")
//            Slider(value: $degrees, in: 0...360)
        }
    }

    var headerImage: some View {
        Image("networkerror_pagepic")
            .scaledToFill()
            .frame(width: 156, height: 156 / 16 * 9)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .center) {
                RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 3)
                    .fcolor(.xmb1)
            }
    }
}
