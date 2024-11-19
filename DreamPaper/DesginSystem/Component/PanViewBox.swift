//
//  Cloud.swift
//  Naduo
//
//  Created by 赵翔宇 on 2023/3/8.
//

import Foundation
import PanModal
import SwiftUI

// PanModal推送的样式
public enum PanPresentStyle {
    case sheet, hard_sheet, editSheet, setting, hard_harf_sheet, harf_sheet, fullScreen, hard_fullScreen, shareSheet
}

class PanViewBox<Content: View>: UIHostingController<AnyView>, PanModalPresentable {
    let style: PanPresentStyle
    var isShortFormEnabled = false
    
    init(content: Content, style: PanPresentStyle) {
        self.style = style
        super.init(rootView: AnyView(content))
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PanModalPresentable
    
    var panScrollable: UIScrollView? { nil }
    
    var showDragIndicator: Bool {
        [.shareSheet, .editSheet, .sheet, .hard_harf_sheet, .harf_sheet].contains(style)
    }
    
    var allowsDragToDismiss: Bool {
        ![.hard_sheet, .hard_harf_sheet, .setting, .hard_fullScreen].contains(style)
    }
    
    var longFormHeight: PanModalHeight {
        switch style {
        case .hard_harf_sheet, .harf_sheet:
            return .contentHeightIgnoringSafeArea(UIScreen.main.bounds.height * 0.5)
        case .editSheet:
            return .contentHeightIgnoringSafeArea(UIScreen.main.bounds.height * 0.618)
        case .shareSheet:
            return .contentHeightIgnoringSafeArea(UIScreen.main.bounds.height * 0.24)
        default:
            return .maxHeight
        }
    }
    
    var shortFormHeight: PanModalHeight { longFormHeight }
    
    var topOffset: CGFloat {
        [.sheet, .hard_sheet].contains(style) ? UIScreen.main.bounds.height * 0.12 : 0
    }
    
    var panModalBackgroundColor: UIColor {
        [.shareSheet, .fullScreen].contains(style) ? .clear : UIColor(Color.xmf1.opacity(0.666))
    }
    
    var allowsTapToDismiss: Bool {
        ![.hard_sheet, .hard_harf_sheet].contains(style)
    }
    
    var cornerRadius: CGFloat { 4 }
    
    var springDamping: CGFloat { 0.8 }
    
    override var disablesAutomaticKeyboardDismissal: Bool { true }
    
    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state else { return }
        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .light
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
}
