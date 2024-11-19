//
//  XMListDataViewModel.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/8.
//

import Foundation

// 页面请求指标
public enum XMRequestStatus: String {
    case isLoading
    case isNeedReTry
    case isOK
    case isOKButEmpty
}

protocol XMListDataViewModelProtocol: ObservableObject {
    associatedtype ListRowMod: Convertible
    associatedtype ListData: RandomAccessCollection where ListData.Element == ListRowMod

    var list: ListData { get set }
    var reqStatus: XMRequestStatus { get set }
    var loadingMoreStatus: XMRequestStatus { get set }
    var currentPage: Int { get set }

    func getListData() async
    func loadMore() async
}

// 定义泛型 ViewModel 类,用于list请求
class XMListViewModel<ListRowMod: Convertible>: XMListDataViewModelProtocol {
    @Published var list: [ListRowMod]
    @Published var reqStatus: XMRequestStatus = .isOK
    @Published var loadingMoreStatus: XMRequestStatus = .isOK
    var currentPage: Int = 1
    var target: XMTargetType
    var pagesize : Int = 20

    init(target: XMTargetType,pagesize : Int = 20) {
        self.target = target
        self.pagesize = pagesize
        self.list = []
    }

    deinit {}

    @MainActor
    func getListData() async {
        reqStatus = .isLoading
        await waitme(sec: 0.4)
        // 手动更新 parameters 字典
        currentPage = 1
        if target.parameters?.contains(where: { $0.key == "page" }) == true {
            target = target.updatingParameters(currentPage)
        }
        list = []
        let result = await Networking.request_async(target)
        if result.is200Ok, let items = result.mapArray(ListRowMod.self) {
            if items.isEmpty {
                reqStatus = .isOKButEmpty
            } else {
                list = items
                print(list)
                reqStatus = .isOK
                print(self.reqStatus)
            }
        } else {
            reqStatus = .isNeedReTry
        }
        loadingMoreStatus = .isOK
    }

    @MainActor
    func loadMore() async {
        loadingMoreStatus = .isLoading
        await waitme(sec: 0.2)
        // 手动更新 parameters 字典
        if target.parameters?.contains(where: { $0.key == "page" }) == true {
            target = target.updatingParameters(currentPage + 1)
        }
        let r = await Networking.request_async(target)
        if r.is200Ok, let items = r.mapArray(ListRowMod.self) {
            // 没有更多数据
            if items.isEmpty {
                await waitme(sec: 0.2)
                loadingMoreStatus = .isOKButEmpty
                // 数据小于10个
            } else if items.count < pagesize {
                await waitme(sec: 0.2)
                loadingMoreStatus = .isOKButEmpty
                list += items
            } else {
                // 下一页数据数据多于等于10
                list += items
                currentPage += 1
                await waitme(sec: 0.2)
                loadingMoreStatus = .isOK
            }
        } else {
            await waitme(sec: 0.2)
            loadingMoreStatus = .isNeedReTry
        }
    }
}
