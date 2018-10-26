//
//  Target_Login.swift
//  SalesManLogin_Example
//
//  Created by 谢艳 on 2018/10/24.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
class Target_Login : NSObject {
    func Action_viewController(params:NSDictionary) -> UIViewController{
        
        let viewcontroller:ViewController =   UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Login") as! ViewController
        return viewcontroller
    }
}
