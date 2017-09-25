//
//  Date+Extension.swift
//  CZUtils
//
//  Created by Cheng Zhang on 9/24/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit

public extension Date {
    var simpleString: String {
        return string(withFormatterStr: "yyyy-MM-dd hh:mm")
    }
    
    var complexString: String {
        return string(withFormatterStr: "EEE, dd MMM yyyy hh:mm:ss +zzzz")
    }
}

fileprivate extension Date {
    func string(withFormatterStr formatterStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatterStr
        return dateFormatter.string(from: self)
    }
}
