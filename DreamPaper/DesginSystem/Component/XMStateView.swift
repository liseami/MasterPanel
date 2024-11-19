//
//  XMScrollView.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/4.
//

import SwiftUI
struct XMStateView<ListData: RandomAccessCollection, Item: Identifiable, Content: View, Loading: View, Empty: View>: View {
    var reqStatus: XMRequestStatus
    var loadmoreStatus: XMRequestStatus = .isLoading
    var getListData: () async -> ()
    var loadMore: () async -> ()
    let loading: Loading
    let pagesize: Int
    let empty: Empty
    let content: Content
    let list: ListData

    @MainActor public init<RowContent: View>(
        _ ListData: ListData,
        reqStatus: XMRequestStatus = .isLoading,
        loadmoreStatus: XMRequestStatus = .isLoading,
        pagesize: Int,
        @ViewBuilder rowContent: @escaping (ListData.Element) -> RowContent,
        @ViewBuilder loadingView: @escaping () -> Loading,
        @ViewBuilder emptyView: @escaping () -> Empty,
        loadMore: @escaping () async -> () = {},
        getListData: @escaping () async -> () = {}
    ) where Item == ListData.Element, Content == ForEach<ListData, ListData.Element.ID, RowContent> {
        self.empty = emptyView()
        self.list = ListData
        self.content = ForEach(ListData, content: rowContent)
        self.loading = loadingView()
        self.reqStatus = reqStatus
        self.loadMore = loadMore
        self.loadmoreStatus = loadmoreStatus
        self.getListData = getListData
        self.pagesize = pagesize
    }

    @MainActor public init(
        _ ListData: ListData,
        reqStatus: XMRequestStatus = .isLoading,
        loadmoreStatus: XMRequestStatus = .isLoading,
        pagesize: Int,
        @ViewBuilder customContent: @escaping () -> Content,
        @ViewBuilder loadingView: @escaping () -> Loading,
        @ViewBuilder emptyView: @escaping () -> Empty,
        loadMore: @escaping () async -> () = {},
        getListData: @escaping () async -> () = {}
    ) where Item == ListData.Element {
        self.empty = emptyView()
        self.list = ListData
        self.content = customContent()
        self.loading = loadingView()
        self.reqStatus = reqStatus
        self.loadMore = loadMore
        self.loadmoreStatus = loadmoreStatus
        self.getListData = getListData
        self.pagesize = pagesize
    }

    var body: some View {
        Group {
            switch reqStatus {
            case .isLoading:
                loading
                    .transition(.opacity.animation(.easeOut(duration: 0.2)))
                    .frame(maxWidth: .infinity)
            case .isNeedReTry:
                XMPleaceHolderView(imageName: "碎盘子", text: "网络错误，请刷新重试。", btnText: "重试") {
                    await getListData()
                }

            case .isOK:
                content
                    .transition(.opacity.animation(.easeOut(duration: 0.2)))
                Color.clear.frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .center) {
                        switch loadmoreStatus {
                        case .isLoading, .isOK:
                            AutoLottieView(lottieFliesName: "bellyloading", loopMode: .loop, speed: 1)
                                .task {
                                    await waitme(sec: 0.5)
                                    await loadMoreWithCooldown()
                                }
                        case .isNeedReTry:
                            
                            XMDesgin.XMMainBtn(text:String.init(localized: "加载失败，请重试")) {
                                await waitme(sec: 1)
                                await loadMoreWithCooldown()
                            }
                            .frame(width: 240)
                        case .isOKButEmpty:
                            Text("--- 没有更多了 ---")
                                .font(.XMFont.f2.v2)
                                .fcolor(.xmf2)
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden, edges: .all)
                    .listRowBackground(Color.clear)
                    .ifshow(show: self.list.count >= pagesize)

            case .isOKButEmpty:
                empty
                    .frame(maxWidth: .infinity)
            }
        }
        .transition(.opacity
            .combined(with: .offset(y: 20))
            .combined(with: .scale(scale: 0.96))
            .animation(.easeOut))
        .animation(.easeInOut, value: self.reqStatus)
    }

    private func loadMoreWithCooldown() async {
        await waitme(sec: 1) // 冷却时间
        await loadMore()
    }
}

#Preview {
    ScrollView {
        XMStateView(Array(repeating: XMUserInfo(), count: 20), reqStatus: .isOK, loadmoreStatus: .isOKButEmpty,pagesize: 10) { _ in

        } loadingView: {
            SBLoadingView()
        } emptyView: {
            Text("暂无内容")
        }
    }
}
