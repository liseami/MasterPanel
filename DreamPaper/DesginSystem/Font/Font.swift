//
// 字体.swift
// 守护进程
//
// 赵翔宇创建于2024年3月8日。
//

import SwiftUI


extension Font {
    enum XMFont {
        case big1, big2, big3, big1b, big2b, big3b, f1, f2, f3, f1b, f2b, f3b
        var v1: Font {
            switch self {
            case .big1b:
                return .system(size: 32, weight: .bold)
            case .big2b:
                return .system(size: 24, weight: .bold)
            case .big3b:
                return .system(size: 20, weight: .bold)
            case .big1:
                return .system(size: 32)
            case .big2:
                return .system(size: 24)
            case .big3:
                return .system(size: 20)
            case .f1:
                return .system(size: 17)
            case .f2:
                return .system(size: 15)
            case .f3:
                return .system(size: 13)
            case .f1b:
                return .system(size: 17, weight: .bold)
            case .f2b:
                return .system(size: 15, weight: .bold)
            case .f3b:
                return .system(size: 13, weight: .bold)
            }
        }

        var v2: Font {
            switch self {
            case .big1b:
                return .custom("NotoSansSC-Black", fixedSize: 32)
            case .big2b:
                return .custom("NotoSansSC-Black", fixedSize: 24)
            case .big3b:
                return .custom("NotoSansSC-Black", fixedSize: 20)
            case .big1:
                return .custom("GenRyuMinTW-EL", fixedSize: 32)
            case .big2:
                return .custom("GenRyuMinTW-EL", fixedSize: 24)
            case .big3:
                return .custom("GenRyuMinTW-EL", fixedSize: 20)
            case .f1:
                return .custom("GenRyuMinTW-EL", fixedSize: 17)
            case .f2:
                return .custom("GenRyuMinTW-EL", fixedSize: 15)
            case .f3:
                return .custom("GenRyuMinTW-EL", fixedSize: 13)
            case .f1b:
                return .custom("NotoSansSC-Black", fixedSize: 17)
            case .f2b:
                return .custom("NotoSansSC-Black", fixedSize: 15)
            case .f3b:
                return .custom("NotoSansSC-Black", fixedSize: 13)
            }
        }
        
        var number: Font {
            switch self {
            case .big1b:
                return .custom("Handjet-ExtraBold", fixedSize: 42)
            case .big2b:
                return .custom("Handjet-ExtraBold", fixedSize: 24)
            case .big3b:
                return .custom("Handjet-ExtraBold", fixedSize: 20)
            case .big1:
                return .custom("Handjet-ExtraBold", fixedSize: 32)
            case .big2:
                return .custom("Handjet-ExtraBold", fixedSize: 24)
            case .big3:
                return .custom("Handjet-ExtraBold", fixedSize: 20)
            case .f1:
                return .custom("Handjet-ExtraBold", fixedSize: 17)
            case .f2:
                return .custom("Handjet-ExtraBold", fixedSize: 15)
            case .f3:
                return .custom("Handjet-ExtraBold", fixedSize: 13)
            case .f1b:
                return .custom("Handjet-ExtraBold", fixedSize: 17)
            case .f2b:
                return .custom("Handjet-ExtraBold", fixedSize: 15)
            case .f3b:
                return .custom("Handjet-ExtraBold", fixedSize: 13)
            }
        }
        

    }
}

#Preview {
    VStack{
        VStack(spacing: 24) {
            let text = "设计系统3232"

            Text(text)
                .font(.XMFont.big1b.v2)
            Text(text)
                .font(.XMFont.big2.v2)
            Text(text)
                .font(.XMFont.big3.v2)
            Text(text)
                .font(.XMFont.f1.v2)
            Text(text)
                .font(.XMFont.f1b.v2)
            Text(text)
                .font(.XMFont.f2.v2)
            Text(text)
                .font(.XMFont.f2b.v2)
            Text(text)
                .font(.XMFont.f3.v2)
            Text(text)
                .font(.XMFont.f3b.v2)
        }
        
    }
}

//
//public extension Theme {
//    /// A theme that mimics the Bellybook style.
//    ///
//    /// Style | Preview
//    /// --- | ---
//    /// Inline text | ![](GitHubInlines)
//    /// Headings | ![](GitHubHeading)
//    /// Blockquote | ![](GitHubBlockquote)
//    /// Code block | ![](GitHubCodeBlock)
//    /// Image | ![](GitHubImage)
//    /// Task list | ![](GitHubTaskList)
//    /// Bulleted list | ![](GitHubNestedBulletedList)
//    /// Numbered list | ![](GitHubNumberedList)
//    /// Table | ![](GitHubTable)
//    static let bellybook = Theme()
//        .text {
//            ForegroundColor(.xmf1)
//            FontSize(16)
//        }
//        .code {
//            FontFamilyVariant(.monospaced)
//            FontSize(.em(0.85))
//            BackgroundColor(.secondaryBackground)
//        }
//        .strong {
//            FontWeight(.semibold)
//        }
//        .link {
//            ForegroundColor(.link)
//        }
//        .heading1 { configuration in
//            VStack(alignment: .leading, spacing: 0) {
//                configuration.label
//                    .relativePadding(.bottom, length: .em(0.3))
//                    .relativeLineSpacing(.em(0.125))
//                    .markdownMargin(top: 24, bottom: 16)
//                    .markdownTextStyle {
//                        FontWeight(.semibold)
//                        FontSize(.em(2))
//                    }
//                Divider().overlay(Color.divider)
//            }
//        }
//        .heading2 { configuration in
//            VStack(alignment: .leading, spacing: 0) {
//                configuration.label
//                    .relativePadding(.bottom, length: .em(0.3))
//                    .relativeLineSpacing(.em(0.125))
//                    .markdownMargin(top: 24, bottom: 16)
//                    .markdownTextStyle {
//                        FontWeight(.semibold)
//                        FontSize(.em(1.5))
//                    }
//                Divider().overlay(Color.divider)
//            }
//        }
//        .heading3 { configuration in
//            configuration.label
//                .relativeLineSpacing(.em(0.125))
//                .markdownMargin(top: 24, bottom: 16)
//                .markdownTextStyle {
//                    FontWeight(.semibold)
//                    FontSize(.em(1.25))
//                }
//        }
//        .heading4 { configuration in
//            configuration.label
//                .relativeLineSpacing(.em(0.125))
//                .markdownMargin(top: 24, bottom: 16)
//                .markdownTextStyle {
//                    FontWeight(.semibold)
//                }
//        }
//        .heading5 { configuration in
//            configuration.label
//                .relativeLineSpacing(.em(0.125))
//                .markdownMargin(top: 24, bottom: 16)
//                .markdownTextStyle {
//                    FontWeight(.semibold)
//                    FontSize(.em(0.875))
//                }
//        }
//        .heading6 { configuration in
//            configuration.label
//                .relativeLineSpacing(.em(0.125))
//                .markdownMargin(top: 24, bottom: 16)
//                .markdownTextStyle {
//                    FontWeight(.semibold)
//                    FontSize(.em(0.85))
//                    ForegroundColor(.tertiaryText)
//                }
//        }
//        .paragraph { configuration in
//            configuration.label
//                .fixedSize(horizontal: false, vertical: true)
//                .relativeLineSpacing(.em(0.25))
//                .markdownMargin(top: 0, bottom: 16)
//        }
//        .blockquote { configuration in
//            HStack(spacing: 0) {
//                RoundedRectangle(cornerRadius: 6)
//                    .fill(Color.border)
//                    .relativeFrame(width: .em(0.2))
//                configuration.label
//                    .markdownTextStyle { ForegroundColor(.secondaryText) }
//                    .relativePadding(.horizontal, length: .em(1))
//            }
//            .fixedSize(horizontal: false, vertical: true)
//        }
//        .codeBlock { configuration in
//            ScrollView(.horizontal) {
//                configuration.label
//                    .fixedSize(horizontal: false, vertical: true)
//                    .relativeLineSpacing(.em(0.225))
//                    .markdownTextStyle {
//                        FontFamilyVariant(.monospaced)
//                        FontSize(.em(0.85))
//                    }
//                    .padding(16)
//            }
//            .background(Color.secondaryBackground)
//            .clipShape(RoundedRectangle(cornerRadius: 6))
//            .markdownMargin(top: 0, bottom: 16)
//        }
//        .listItem { configuration in
//            configuration.label
//                .markdownMargin(top: .em(0.25))
//        }
//        .taskListMarker { configuration in
//            Image(systemName: configuration.isCompleted ? "checkmark.square.fill" : "square")
//                .symbolRenderingMode(.hierarchical)
//                .foregroundStyle(Color.checkbox, Color.checkboxBackground)
//                .imageScale(.small)
//                .relativeFrame(minWidth: .em(1.5), alignment: .trailing)
//        }
//        .table { configuration in
//            configuration.label
//                .fixedSize(horizontal: false, vertical: true)
//                .markdownTableBorderStyle(.init(color: .border))
//                .markdownTableBackgroundStyle(
//                    .alternatingRows(Color.background, Color.secondaryBackground)
//                )
//                .markdownMargin(top: 0, bottom: 16)
//        }
//        .tableCell { configuration in
//            configuration.label
//                .markdownTextStyle {
//                    if configuration.row == 0 {
//                        FontWeight(.semibold)
//                    }
//                    BackgroundColor(nil)
//                }
//                .fixedSize(horizontal: false, vertical: true)
//                .padding(.vertical, 6)
//                .padding(.horizontal, 13)
//                .relativeLineSpacing(.em(0.25))
//        }
//        .thematicBreak {
//            Divider()
//                .relativeFrame(height: .em(0.25))
//                .overlay(Color.border)
//                .markdownMargin(top: 24, bottom: 24)
//        }
//}
//
//private extension Color {
//    static let text = Color(
//        light: Color(rgba: 0x0606_06ff), dark: Color(rgba: 0xfbfb_fcff)
//    )
//    static let secondaryText = Color(
//        light: Color(rgba: 0x6b6e_7bff), dark: Color(rgba: 0x9294_a0ff)
//    )
//    static let tertiaryText = Color(
//        light: Color(rgba: 0x6b6e_7bff), dark: Color(rgba: 0x6d70_7dff)
//    )
//    static let background = Color(
//        light: .white, dark: Color(rgba: 0x1819_1dff)
//    )
//    static let secondaryBackground = Color(
//        light: Color(rgba: 0xf7f7_f9ff), dark: Color(rgba: 0x2526_2aff)
//    )
//    static let link = Color(
//        light: Color(rgba: 0x2c65_cfff), dark: Color(rgba: 0x4c8e_f8ff)
//    )
//    static let border = Color(
//        light: Color(rgba: 0xe4e4_e8ff), dark: Color(rgba: 0x4244_4eff)
//    )
//    static let divider = Color(
//        light: Color(rgba: 0xd0d0_d3ff), dark: Color(rgba: 0x3334_38ff)
//    )
//    static let checkbox = Color(rgba: 0xb9b9_bbff)
//    static let checkboxBackground = Color(rgba: 0xeeee_efff)
//}
