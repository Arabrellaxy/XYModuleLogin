//
//  SWDataStorage.swift
//  SalesManDataStorage
//
//  Created by 谢艳 on 2018/10/31.
//

import Foundation

let kUserName = "kUserName"
let kPassword = "kPassword"
let kUserID   = "kUserId"

public class SWDataStorage:NSObject{
    public var username:String?{
        get{
           return self.storedUserName()
        }
    }
    public var userID:String?{
        get{
            return self.storedUserID()
        }
    }
    public func passwordForUser(username:String?) -> String?{
        guard let _ = username else {
            return nil
        }
        let keychainQueryDic = self.keychainQueryForUser(user: username!)
        var data:AnyObject?
        var password:String?
        if SecItemCopyMatching(keychainQueryDic, &data) == noErr {
            password = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? String
        }
        return password
    }
   public  func storeUserInfo(userID:String?, username:String?, password:String?) -> Bool {
        guard (username?.count)! > 0 else {
           //remove this user from userDefault and keychain
            UserDefaults.standard.removeObject(forKey: kUserName)
            UserDefaults.standard.removeObject(forKey: kUserID)
            return false
        }
        UserDefaults.standard.set(username!, forKey: kUserName)
        UserDefaults.standard.set(userID, forKey: kUserID)
        let keychainQueryDic = self.keychainQueryForUser(user: username!)
        SecItemDelete(keychainQueryDic)
        guard let _ = password else {
            return true
        }
        let passwordData = NSKeyedArchiver.archivedData(withRootObject: password!)
        keychainQueryDic.setObject(passwordData, forKey: kSecValueData as! NSCopying)
        let _ = SecItemAdd(keychainQueryDic, nil)
        return true
    }
//MARK-Private
    private func storedUserName() -> String? {
        return UserDefaults.standard.object(forKey: kUserName) as? String
    }
    private func storedUserID() -> String? {
        return UserDefaults.standard.object(forKey: kUserID) as? String
    }
    private func keychainQueryForUser(user:String)->NSMutableDictionary{
        return NSMutableDictionary.init(objects: [kSecClassGenericPassword,
                                                  Bundle.main.bundleIdentifier ?? "",
                                                  user,
                                                  kCFBooleanTrue],
                                        forKeys: [kSecClass as! NSCopying,
                                                  kSecAttrService as! NSCopying,
                                                  kSecAttrAccount as! NSCopying,
                                                  kSecReturnData as! NSCopying])
    }
}
