//
//  Target_Login.swift
//  SalesManLogin_Example
//
//  Created by 谢艳 on 2018/10/24.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

<<<<<<< HEAD
 class Target_Login : NSObject {
  @objc  func Action_viewController(_ params:[AnyHashable:Any]?) -> UIViewController{
        let bundle1 = Bundle.init(for: ViewController.classForCoder())
        let path = bundle1.path(forResource: "SalesManLogin", ofType: "bundle")!
        
        let bundle:Bundle = Bundle.init(path:path)!
        let vc:ViewController = UIStoryboard.init(name: "Main", bundle: bundle).instantiateInitialViewController() as! ViewController
        return vc
=======
class Target_Login : NSObject {
    func Action_viewController(params:NSDictionary) -> UIViewController{
        
        let viewcontroller :UIViewController =   UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Login")
        return viewcontroller
>>>>>>> b96a8d7aaf7cc582e0d7052ccc35e93729792b0c
    }
}
