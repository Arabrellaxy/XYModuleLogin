//
//  APIReformer.swift
//  SalesManLogin
//
//  Created by 谢艳 on 2018/10/31.
//

import Foundation
import SalesManNetwork
class APIReformer:NSObject {
    public func reformAPIResponse(responseObject:NSDictionary?) -> NSDictionary{
        let tempResultDic:NSMutableDictionary = NSMutableDictionary.init()
        tempResultDic.setValue(false, forKey: SWGlobal.status)
        let errorMsg:NSString = (responseObject?.object(forKey: SWGlobal.message) as? NSString) ?? "登录失败,请重试"
        let status:Bool = (responseObject?.object(forKey: SWGlobal.status) as? Bool)!
        guard let _:NSDictionary = responseObject else {
            tempResultDic.setValue(errorMsg, forKey: SWGlobal.message)
            return tempResultDic
        }
        if status {
            let dataDic:NSDictionary? = responseObject?.object(forKey: SWGlobal.data) as? NSDictionary
            guard let _ = dataDic else{
                tempResultDic.setValue(errorMsg, forKey: SWGlobal.message)
                return tempResultDic
            }
            let userID:String = (dataDic!.object(forKey: "me") as! NSDictionary).object(forKey: "userId") as! String
            tempResultDic.setValue(true, forKey: SWGlobal.status)
            tempResultDic.setValue(userID, forKey: "userId")
        } else{
            tempResultDic.setValue(errorMsg, forKey: SWGlobal.message)
        }
        return tempResultDic
    }
}
