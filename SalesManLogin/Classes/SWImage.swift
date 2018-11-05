//
//  SWImage.swift
//  SalesManLogin
//
//  Created by 谢艳 on 2018/10/29.
//

import Foundation
extension UIImage   {
  class  func imageNamed(name:String) ->UIImage {
    let bundle = Bundle.init(for: ViewController.classForCoder())
    let path = bundle.path(forResource: "XYModuleLogin", ofType: "bundle")!
        
    let resoureBundle:Bundle = Bundle.init(path:path)!
    let image:UIImage = UIImage.init(named: name, in: resoureBundle, compatibleWith: nil)!
      return image
    }
}
