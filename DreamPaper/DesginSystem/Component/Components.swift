//
//  Components.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/2/25.
//

enum XMDesgin {
    struct XMSection<Content: View>: View {
        var title: String = ""
        var content: () -> Content
        init(title: String = "", content: @escaping () -> Content) {
            self.content = content
            self.title = title
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 24, content: {
                Text(self.title)
                    .font(.XMFont.f1b.v1)
                    .fcolor(.xmf2)
                content()
            })
        }
    }

    struct SBPicker<SelectionValue: Hashable>: View {
        let options: [SelectionValue]
        let selection: Binding<SelectionValue>
        let label: (SelectionValue) -> String
        @Namespace var animation
        init(options: [SelectionValue], selection: Binding<SelectionValue>, label: @escaping (SelectionValue) -> String) {
            self.options = options
            self.selection = selection
            self.label = label
        }

        var body: some View {
            HStack(spacing: 6) {
                ForEach(options, id: \.self) { option in
                    let selected = option == selection.wrappedValue
                    Button(action: {
                        Apphelper.shared.mada(style: .soft)
                        withAnimation(.bouncy) {
                            selection.wrappedValue = option
                        }
                    }) {
                        Text(label(option))
                            .font(.XMFont.f2.v1)
                            .fcolor(selected ? .xmf1 : .xmf1.opacity(0.9))
                            .maxWidth(.infinity)
                            .height(32)
                            .background(
                                Image("picker_option_back").resizable()
                                    .matchedGeometryEffect(id: "back", in: animation)
                                    .ifshow(show: selected)
                            )
                    }
                    Image("picker_divier")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                        .ifshow(show: options.last != option)
                }
            }
            .background(Image("picker_back").resizable())
            .height(32)
            .frame(maxWidth: .infinity)
        }
    }

    struct XMToggle: View {
        @Binding var bool: Bool
        init(bool: Binding<Bool>) {
            self._bool = bool
        }

        private let date = Date()
//        @State private var booltest : Bool = false
        var body: some View {
            XMDesgin.XMButton {
                self.bool.toggle()
            } label: {
                Image(bool ? "checkbox_selected" : "checkbox")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
        }
    }

    struct XMIcon: View, Equatable {
        static func == (lhs: XMIcon, rhs: XMIcon) -> Bool {
            lhs.iconName == rhs.iconName &&
                lhs.color == rhs.color
        }

        var size: CGFloat
        var color: Color
        var withBackCricle: Bool
        var backColor: Color
        var iconName: String?
        var systemName: String?
        var renderingMode : Image.TemplateRenderingMode?

        init(iconName: String, size: CGFloat = 26, color: Color = .xmf1, withBackCricle: Bool = false, backColor: Color = .xmb1, renderingMode : Image.TemplateRenderingMode = .original) {
            self.iconName = iconName
            self.size = size
            self.withBackCricle = withBackCricle
            self.color = color
            self.backColor = backColor
            self.renderingMode = renderingMode
        }

        init(systemName: String, size: CGFloat = 20, color: Color = .xmf1, withBackCricle: Bool = false, backColor: Color = .xmb1) {
            self.systemName = systemName
            self.size = size
            self.withBackCricle = withBackCricle
            self.color = color
            self.backColor = backColor
        }

        var body: some View {
            if withBackCricle {
                icon
                    .padding(.all, 6)
                    .background(backColor)
                    .clipShape(Circle())
                    .contentShape(Circle())
            } else {
                icon
                    .padding(.all, 6)
                    .contentShape(Rectangle())
            }
        }

        var icon: some View {
            Group {
                if let iconName {
                    Image(iconName)
                        .resizable()
                        .renderingMode(self.renderingMode ?? .original)
                        .scaledToFit()
                        .frame(width: size, height: size, alignment: .center)
                } else if let systemName {
                    Image(systemName: systemName)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: size, height: size, alignment: .center)
                }
            }
            .fcolor(color)
        }
    }

    struct XMTag: View {
        let text: String
        let backColor: Color
        init(text: String, backColor: Color = Color.xmb2) {
            self.text = text
            self.backColor = backColor
        }

        var body: some View {
            Text(text)
                .font(.XMFont.f3.v1)
                .fcolor(.xmf1)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(backColor)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    
    enum SBButtonStatus {
        case 凹
        case 凸
    }
    struct SmallBtn: View {
        var text: String
        var enable: Bool
        var status : SBButtonStatus
        var action: () async -> ()
        @State var onTap: Bool = false
        init(text: String = "text", enable: Bool = true,status : SBButtonStatus = .凸, action: @MainActor @escaping () async -> ()) {
            self.text = text
            self.action = action
            self.enable = enable
            self.status = status
        }

        var body: some View {
            XMDesgin.XMButton(enable: enable) {
                await action()
            } label: {
                Image(status == .凸 ? "tabbar_back" : "tabbar_back_selected")
                    .resizable()
                    .height(48)
                    .maxWidth(120)
                    .overlay(
                        Text(LocalizedStringKey(text))
                            .font(.XMFont.f1b.v1)
                            .fcolor(.xmf1)
                    )
            }
        }
    }

    struct CircleBtn: View {
        var backColor: Color
        var fColor: Color
        var iconName: String
        var enable: Bool
        var action: () async -> ()

        init(backColor: Color = .black, fColor: Color = .white, iconName: String = "system_share", enable: Bool = true, action: @MainActor @escaping () async -> ()) {
            self.backColor = backColor
            self.fColor = fColor
            self.enable = enable
            self.iconName = iconName
            self.action = action
        }

        var body: some View {
            XMDesgin.XMButton(enable: enable) {
                await action()
            } label: {
                Circle()
                    .fill(backColor)
                    .frame(width: 44, height: 44)
                    .overlay {
                        XMDesgin.XMIcon(iconName: iconName, color: fColor,renderingMode: .template)
                    }
            }
        }
    }

    struct XMButton<Content>: View where Content: View {
        var enable: Bool
        var action: () async -> ()
        var label: () -> Content
        @State var onTap: Bool = false
        @State var shake: Int = 0
        @State var isLoading: Bool = false
        init(enable: Bool = true, action: @MainActor @escaping () async -> (), @ViewBuilder label: @escaping () -> Content) {
            self.enable = enable
            self.action = action
            self.label = label
        }

        var body: some View {
            label()
                .opacity(isLoading ? 0.6 : 1)
                ._onButtonGesture {
                    guard isLoading == false else { return }
                    onTap = $0
                } perform: {
                    Task {
                        guard !isLoading else { return }
                        guard enable else {
                            shake += 1
                            Apphelper.shared.nofimada(.error)
                            return
                        }
                        Apphelper.shared.mada(style: .soft)
                        self.isLoading = true
                        await action()
                        self.isLoading = false
                    }
                }
                .conditionalEffect(.pushDown, condition: self.onTap)
                .changeEffect(.glow(color: .white), value: self.onTap)
                .changeEffect(.shake(rate: .fast), value: shake)
                .overlay {
                    AutoLottieView(lottieFliesName: "sb_loading_circle", loopMode: .loop, speed: 1)
                        .frame(width: 30)
                        .preferredColorScheme(.dark)
                        .transition(.opacity)
                        .ifshow(show: isLoading)
                }
        }
    }

    struct XMMainBtn: View {
        var fColor: Color
        var iconName: String
        var text: String
        var enable: Bool

        var action: () async -> ()
        @State var onTap: Bool = false
        init(fColor: Color = .xmf1, iconName: String = "", text: String = "text", enable: Bool = true, action: @MainActor @escaping () async -> ()) {
            self.fColor = fColor
            self.iconName = iconName
            self.text = text
            self.action = action
            self.enable = enable
        }

        init(text: String, enable: Bool = true, action: @MainActor @escaping () async -> ()) {
            self.fColor = .xmf1
            self.iconName = ""
            self.text = text
            self.action = action
            self.enable = enable
        }

        var body: some View {
            XMDesgin.XMButton(enable: enable) {
                await action()
            } label: {
                content
                    .background(
                        Image("toptab")
                            .resizable()
                            .height(44)
                            .width(UIScreen.main.bounds.width - 32)
                            .opacity(enable ? 1 : 0.5)
                    )
            }
        }

        var content: some View {
            HStack(spacing: 2) {
                if !iconName.isEmpty {
                    XMDesgin.XMIcon(iconName: iconName, color: fColor)
                        .frame(height: 0)
                }
                Text(LocalizedStringKey(text))
                    .font(.XMFont.f1b.v1)
                    .foregroundStyle(enable ? fColor : .xmf3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }

    struct SelectionTable: View {
        var text: String
        var selected: Bool
        var action: () -> ()

        init(text: String, selected: Bool = false, action: @escaping () -> ()) {
            self.text = text
            self.selected = selected
            self.action = action
        }

        var body: some View {
            XMDesgin.XMButton {
                action()
            } label: {
                HStack(spacing: 24) {
                    Text(LocalizedStringKey(text))
                        .font(.XMFont.f1.v1)
                        .multilineTextAlignment(.leading)
                        .fcolor(.xmf1)
                        .tint(Color.xm.main)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    XMDesgin.XMIcon(systemName: "circle", size: 18, color: Color.xmf1)
                        .overlay(alignment: .center) {
                            Circle()
                                .fill(Color.xmf1)
                                .frame(width: 10, height: 10)
                                .ifshow(show: selected)
                        }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background(Color.xmb1)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    struct XMListRow: View {
        var info: LabelInfo
        var showRightArrow: Bool
        var action: () -> ()
        init(_ info: LabelInfo, showRightArrow: Bool = true, action: @escaping () -> ()) {
            self.info = info
            self.showRightArrow = showRightArrow
            self.action = action
        }

        var body: some View {
            XMDesgin.XMButton {
                action()
            } label: {
                HStack(spacing: 14) {
                    XMDesgin.XMIcon(iconName: info.icon, size: 24)
                        .ifshow(show: !info.icon.isEmpty)
                    Text(info.name)
                        .font(.XMFont.f1.v1)
                        .fcolor(.xmf1)
                        .lineLimit(1)
                    Spacer()
                    Text(info.subline)
                        .fixedSize(horizontal: true, vertical: false)
                        .font(.XMFont.f2.v1)
                        .fcolor(.xmf2)
                    XMDesgin.XMIcon(iconName: "system_arrow_right", size: 16, color: Color.xmf2)
                        .ifshow(show: showRightArrow)
                }
                .contentShape(Rectangle())
            }
        }
    }

    struct XMListRowInlist: View {
        var info: LabelInfo
        var action: () -> ()
        init(_ info: LabelInfo, action: @escaping () -> ()) {
            self.info = info
            self.action = action
        }

        var body: some View {
            XMDesgin.XMButton {
                action()
            } label: {
                HStack(spacing: 14) {
                    XMDesgin.XMIcon(iconName: info.icon, size: 24)
                        .ifshow(show: !info.icon.isEmpty)
                    Text(info.name)
                        .font(.XMFont.f1b.v1)
                        .fcolor(.xmf1)
                    Spacer()
                    Text(info.subline)
                        .font(.XMFont.f2.v1)
                        .fcolor(.xmf2)
                    XMDesgin.XMIcon(iconName: "system_arrow_right", size: 16, color: Color.xmf2)
                }
                .contentShape(Rectangle())
            }
            .listRowBackground(Color.xmb1)
        }
    }
}

#Preview {
    ScrollView(.vertical) {
        VStack(spacing: 24) {
//            XMDesgin.SBPicker(
//                options: Gender.allCases,
//                selection: .constant(Gender.female)
//            ) { gender in
//                gender.localizedString._SwiftUIX_key
//            }
            HStack(alignment: .center, spacing: 12) {
                XMDesgin.XMToggle(bool: .constant(true))
                XMDesgin.XMToggle(bool: .constant(false))
            }
            XMDesgin.XMIcon(iconName: "system_xmark", withBackCricle: true)
            XMDesgin.XMIcon(systemName: "flag.badge.ellipsis")
            XMDesgin.SmallBtn {}
            XMDesgin.CircleBtn(backColor: .white, fColor: .black, iconName: "system_share", enable: true) {}
            XMDesgin.SelectionTable(text: "男", selected: false) {}
            XMDesgin.XMMainBtn {}
            XMDesgin.XMMainBtn(fColor: .xmf1, iconName: "system_share", text: "hello", enable: true) {}
            XMDesgin.XMMainBtn(fColor: .xmf1, iconName: "", text: "hello", enable: false) {}
            HStack {
                XMDesgin.SmallBtn( text: "hello", enable: true) {}
                XMDesgin.SmallBtn( text: "hello", enable: true) {}
            }
            XMDesgin.XMListRow(.init(name: "system_share", icon: "system_share", subline: "2323")) {}
            XMDesgin.XMListRowInlist(.init(name: "system_share", icon: "system_share", subline: "")) {}
            XMDesgin.CircleBtn {
                await waitme()
            }
            XMDesgin.XMTag(text: "标签")
        }
        .padding(.all)
    }
}
