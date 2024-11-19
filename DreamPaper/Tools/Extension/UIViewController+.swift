//
//  UIViewController.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/2/29.
//

import Foundation
extension UIViewController {
    
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        
        return self.presentedViewController!.topMostViewController()
    }
    
}
