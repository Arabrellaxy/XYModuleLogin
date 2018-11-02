//
//  SWLeftViewTextFiled.swift
//  SalesManLogin_Example
//
//  Created by 谢艳 on 2018/10/23.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class SWLeftViewTextFiled: UITextField {
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var tempBounds:CGRect = super.leftViewRect(forBounds: bounds)
        tempBounds.origin.x += 19
        return tempBounds
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var tempBounds = super.textRect(forBounds: bounds)
        tempBounds.origin.x += 20
        tempBounds.origin.y += 1
        tempBounds.size.width -= 35
        return tempBounds
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var tempBounds = super.editingRect(forBounds: bounds)
        tempBounds.origin.x += 20
        tempBounds.origin.y += 1
        tempBounds.size.width -= 35
        return tempBounds
    }
}
