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
  @objc  func Action_viewController(_ params:[AnyHashable:Any]?) -> UIViewController{
        let bundle1 = Bundle.init(for: ViewController.classForCoder())
        let path = bundle1.path(forResource: "SalesManLogin", ofType: "bundle")!
        
        let bundle:Bundle = Bundle.init(path:path)!
        let vc:ViewController = UIStoryboard.init(name: "Main", bundle: bundle).instantiateViewController(withIdentifier: "Login") as! ViewController
        return vc
    }
}
