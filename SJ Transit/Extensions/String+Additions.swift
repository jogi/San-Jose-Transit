//
//  String+Additions.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 12/7/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import Foundation

extension String {
    var sanitizedTimeString: String {
        get {
            var originalComponents = self.components(separatedBy: ":")
            var hour = Int(originalComponents[0])!
            if hour >= 24 {
                hour = hour - 24
            }
            
            return "\(hour):\(originalComponents[1]):\(originalComponents[2])"
        }
    }
}
