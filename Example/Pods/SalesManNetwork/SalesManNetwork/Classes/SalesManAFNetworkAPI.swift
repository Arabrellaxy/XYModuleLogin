//
//  SalesManAFNetworkAPI.swift
//  SalesManNetwork
//
//  Created by 谢艳 on 2018/10/30.
//

import Foundation
import AFNetworking
let BASE_API_DEV = true

public class SalesManAFNetworkAPI{
    public  static let shareInstance = SalesManAFNetworkAPI()
    private func baseURL() -> String {
        if BASE_API_DEV {
           return "http://sscy-dev.sailwish.com/sw-sscy-salesman"
        }
        return "http://39.104.21.25:8090/sw-sscy-salesman"
    }
   public func loginWithParam(_ param:NSDictionary) ->Void  {
        let tempDic = NSMutableDictionary.init(dictionary: param)
        let callBack:(NSDictionary) -> () = tempDic.object(forKey:SWGlobal.callBack) as! (NSDictionary) -> ()
        tempDic.removeObject(forKey: "callBack")
        var password :String = tempDic.object(forKey: SWLogin.password)! as! String
        let passwordData = password.data(using: String.Encoding.utf8)!
        password = passwordData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        tempDic.setObject(password, forKey: SWLogin.password as NSCopying)
        self.postRequestWith(relativeURLString: SWLogin.loginPath, params: tempDic.copy() as? NSDictionary,completion: callBack )
    }
    public func requestVerifyCode(_ phone:String,completion:@escaping (_ result : NSDictionary)->())->Void{
        let parameters:NSDictionary = ["phone":phone,"purpose": 10]
        self.postRequestWith(relativeURLString: SWLogin.verifyCodePath, params: parameters ) { (dictionary) in
            completion(dictionary)
        }
    }
    public func resetPassword(_ verifyCode:String, _ phone:String,_ newPassword:String,completion:@escaping(_ result:NSDictionary)->())->Void{
        let passwordData = newPassword.data(using: String.Encoding.utf8)!
        let base64Str = passwordData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        let parameters:NSDictionary = ["code":verifyCode,"phone": phone,"passwd":base64Str]
        self.postRequestWith(relativeURLString: SWLogin.resetPasswordPath, params: parameters) { (dictionary) in
            completion(dictionary)
        }
    }
}
extension SalesManAFNetworkAPI{
    //MARK:Private Methods
    public func saveCookies(){
        let cookieData = NSKeyedArchiver.archivedData(withRootObject: HTTPCookieStorage.shared.cookies as Any)
        UserDefaults.standard.set(cookieData, forKey: self.cookieString())
        UserDefaults.standard.synchronize()
        
    }
    private func removeCookies(){
        let userDefaut = UserDefaults.standard
        userDefaut.set(Data.init(), forKey: self.cookieString())
        let cookieStorage = HTTPCookieStorage.shared
        let cookies :NSArray? = cookieStorage.cookies as NSArray?
        guard let _ = cookies else {
            return
        }
        for cookie in cookies! {
            cookieStorage.deleteCookie(cookie as! HTTPCookie)
        }
    }
    private func loadCookies(){
        let data = UserDefaults.standard.object(forKey: self.cookieString())
        guard let _ = data else {
            return
        }
        let cookies:NSArray = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSArray
        let cookieStorage = HTTPCookieStorage.shared
        for cookie in cookies {
            cookieStorage.setCookie(cookie as! HTTPCookie)
        }
    }
    private func cookieString()->String {
        var bundle:String = Bundle.main.bundleIdentifier!
        bundle.append(".cookie")
        return bundle
    }
    private func postRequestWith(relativeURLString:String,params:NSDictionary?,completion:@escaping (_ result : NSDictionary)->()) {
        self.loadCookies()
        let baseURLString = self.baseURL()
        let urlString:String = baseURLString+relativeURLString
        let manager: AFURLSessionManager = AFURLSessionManager.init()
        let request = AFHTTPRequestSerializer.init().request(withMethod: "POST", urlString: urlString, parameters: nil, error: nil)
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Accept")
        request.setValue("ios", forHTTPHeaderField: "device-type")
        request.httpShouldHandleCookies = true
        if let tempParams = params {
            do{
                let paramData = try JSONSerialization.data(withJSONObject: tempParams, options: .prettyPrinted)
                request.httpBody = paramData
            }catch{
                
            }
            
        }
        let task =   manager.dataTask(with: request as URLRequest, uploadProgress: nil, downloadProgress: nil) { (response, responseObject, error) in
            if let resultDic:NSDictionary = responseObject as? NSDictionary {
                let tempDic :NSMutableDictionary = NSMutableDictionary.init(dictionary: resultDic)
                let status:String? = resultDic.object(forKey: "status") as? String
                if let _ = status {
                    //error
                    if status == "ERROR"{
                        tempDic.setValue(false, forKey: "status")
                    } else {
                        //ok
                        tempDic.setValue(true, forKey: "status")
                    }
                }else {
                    // no status
                    
                }
                completion(tempDic)
            } else if let tempError:NSError = error as NSError?{
                let tempDic:NSMutableDictionary = NSMutableDictionary.init()
                switch tempError.code {
                case -1009:
                    tempDic.setValue(false, forKey: "status")
                    tempDic.setValue(SWError.networkError, forKey: SWGlobal.message)
                case -1007:
                    self.removeCookies()
                    tempDic.setValue(false, forKey: "status")
                    tempDic.setValue(SWError.cookieExpired, forKey: SWGlobal.message)
                    let notificationName = Notification.Name(rawValue: SWNotification.SWCookieExpiredNotification)
                    NotificationCenter.default.post(name: notificationName, object: nil)
                default:
                    tempDic.setValue(false, forKey: "status")
                    tempDic.setValue(tempError.localizedDescription, forKey: SWGlobal.message)
                }
                completion(tempDic)
            } else {
                
            }
        }
        task.resume()
    }
}
