//
//  UIViewController+Additions.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 4/2/16.
//  Copyright © 2016 Vashishtha Jogi. All rights reserved.
//

import Foundation
import UIKit

let noScheduleViewTag = 999

extension UIViewController {
    func addNoScheduleViewIfRequired() -> Bool {
        if Utilities.isScheduleEmpty() {
            if let noSchedulesView = NoScheduleView.loadFromNibNamed("NoScheduleView") {
                if let navController = self.navigationController {
                    var originalRect = navController.view.bounds
                    originalRect.size.height -= navController.bottomLayoutGuide.length
                    noSchedulesView.frame = originalRect
                    navController.view.addSubview(noSchedulesView)
                    navController.view.bringSubviewToFront(noSchedulesView)
                } else {
                    noSchedulesView.frame = self.view.bounds
                    self.view.addSubview(noSchedulesView)
                    self.view.bringSubviewToFront(noSchedulesView)
                }
                noSchedulesView.tag = noScheduleViewTag
            }
        }
        
        return Utilities.isScheduleEmpty()
    }
    
    
    func removeNoScheduleView() {
        var viewToRemove: UIView?
        if let navController = self.navigationController {
            viewToRemove = navController.view.viewWithTag(noScheduleViewTag)
        } else {
            viewToRemove = self.view.viewWithTag(noScheduleViewTag)
        }
        
        if let viewToRemove = viewToRemove {
            viewToRemove.removeFromSuperview()
        }
    }
}
