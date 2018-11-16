//
//  ViewController.swift
//  SalesManLogin
//
//  Created by Arabrellaxy on 10/23/2018.
//  Copyright (c) 2018 Arabrellaxy. All rights reserved.
//

import UIKit
import SalesManNetwork
import SalesManGlobal
import SalesManDataStorage
public class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var usernameTF: SWLeftViewTextFiled!
    @IBOutlet weak var passwordTF: SWLeftViewTextFiled!
    @IBOutlet weak var rememberPasswordBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    @IBOutlet weak var inputContainerViewBottomCons: NSLayoutConstraint!
    var currentTextFieldRect:CGRect?
    var rememberPassword:Bool = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.autoFillSavedUserInfo()
        self.standardizeStyle()
        self.registerKeyboardNotification()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        self.removeKeyboardNotification()
    }
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
    }
    public override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
    }
}

//MARK:Storage
extension ViewController {
    func autoFillSavedUserInfo() {
        let username = SWDataStorage.init().username
        let password = SWDataStorage.init().passwordForUser(username: username)
        guard let _ = username,let _ = password else {
            return
        }
        self.usernameTF.text = username!
        self.passwordTF.text = password!
        self.rememberPassword = true
    }
}
//MARK:UITextField Delegate
extension ViewController:UITextFieldDelegate{
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentTextFieldRect = textField.convert(textField.frame, to: self.view)
    }
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTF {
            self.passwordTF.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.usernameTF && self.passwordTF.text?.count == 0 {
            self.storedPasswordForUser()
        }
    }
}

//MARK: Button Action
extension ViewController{
    @objc func rememberPasswordAction() {
        self.rememberPassword = !self.rememberPassword
        self.resetImageForRememberPassword()
    }
    @objc func loginAction(){
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        var userName = self.usernameTF.text
        var password = self.passwordTF.text
        userName = userName?.trimmingCharacters(in: whitespace)
        password = password?.trimmingCharacters(in: whitespace)
        guard (userName?.count)! > 0 && (password?.count)! > 0 else{
            self.view.showTextHud(text: "请检查用户名和密码", autoHide: true)
            return
        }
        self.requestLogin(username: userName!, password: password!)
    }
    @objc func forgetPasswordAction(){
        let bundle1 = Bundle.init(for: ViewController.classForCoder())
        let path = bundle1.path(forResource: "XYModuleLogin", ofType: "bundle")!
        let bundle:Bundle = Bundle.init(path:path)!
        let vc = UIStoryboard.init(name: "Main", bundle: bundle).instantiateViewController(withIdentifier: "forgetpassword")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK:Network
extension ViewController{
    func requestLogin(username:String,password:String) {
        let callBack = { (result : NSDictionary)  in
            self.view.hideHud()
            let status = result.object(forKey: SWGlobal.status) as? Bool
            guard let _ = status else {
                return
            }
            let responseDic = APIReformer.init().reformAPIResponse(responseObject: result)
            if status! {
                //success
                let userID:String  = responseDic.object(forKey: "userId") as! String
                //store username and password
                if self.rememberPassword {
                    let _ = SWDataStorage.init().storeUserInfo(userID: userID, username: username, password: password)
                } else {
                    let _ = SWDataStorage.init().storeUserInfo(userID: userID, username: username, password: nil)
                }
                //store cookie
                SalesManAFNetworkAPI.shareInstance.saveCookies()
                //dismiss
                self.dismiss(animated: true, completion: nil)
            } else {
                //error
                var message = responseDic.object(forKey: SWGlobal.message) as? String
                guard let _ = message else{
                    message = "账号或密码错误"
                    self.view.showTextHud(text: message!, autoHide: true)
                    return
                }
                self.view.showTextHud(text: message!, autoHide: true)
            }
        }
        self.view.showLoadingHud(loadingText: "正在登录")
        SalesManAFNetworkAPI.shareInstance.loginWithParam([SWLogin.username:username,
                                                           SWLogin.password:password,
                                                           SWGlobal.callBack:callBack])
    }
}
//MARK: Private
extension ViewController{
    func standardizeStyle() {
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.titleLabel.text = "业务员管理系统"
        
        self.standardizeTFStyle(textField: self.usernameTF)
        self.standardizeTFStyle(textField: self.passwordTF)
        
        self.usernameTF.placeholder = "请输入用户名"
        self.usernameTF.leftView = UIImageView.init(image: UIImage.imageNamed(name: "user", classCoder: self.classForCoder, bundleName: bundleName))
        self.usernameTF.returnKeyType = .next
        self.passwordTF.isSecureTextEntry = true
        self.passwordTF.clearsOnBeginEditing = true
        self.passwordTF.placeholder = "请输入密码"

        self.rememberPasswordBtn.setImage(UIImage.imageNamed(name: self.rememberPassword ? "checkSelected" : "checkUnselected", classCoder: self.classForCoder, bundleName: bundleName), for: .normal)
        self.passwordTF.leftView = UIImageView.init(image: UIImage.imageNamed(name: "password", classCoder: self.classForCoder, bundleName: bundleName))
        self.passwordTF.returnKeyType = .done
        
        let attributedTitle = NSAttributedString.init(string: "记住密码", attributes:
            [
                NSAttributedStringKey.foregroundColor : UIColor.swDarkTextColor(),
                NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14.1)
            ])
        self.rememberPasswordBtn.setAttributedTitle(attributedTitle, for: .normal)
        self.rememberPasswordBtn.tintColor = UIColor.swGrayTextColor()
        self.rememberPasswordBtn.titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: -8)
        self.rememberPasswordBtn.addTarget(self, action: #selector(rememberPasswordAction), for: .touchUpInside)

        let loginTitle = NSAttributedString.init(string: "登录", attributes:
            [
                NSAttributedStringKey.foregroundColor : UIColor.white,
                NSAttributedStringKey.font:UIFont.systemFont(ofSize: 17)
            ])
        self.loginBtn.setAttributedTitle(loginTitle, for: .normal)
        self.loginBtn.titleEdgeInsets = .init(top: 0, left: 0, bottom: 4, right: 0)
        self.loginBtn.setBackgroundImage(UIImage.imageNamed(name: "loginBtn", classCoder: self.classForCoder, bundleName: bundleName), for: .normal)
        self.loginBtn.addTarget(self, action: #selector(loginAction), for: .touchUpInside)

        let forgetTitle = NSAttributedString.init(string: "忘记密码?", attributes:
            [
                NSAttributedStringKey.foregroundColor : UIColor.swGrayTextColor(),
                NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14.1)
            ])
        self.forgetPasswordBtn.setAttributedTitle(forgetTitle, for: .normal)
        self.forgetPasswordBtn.addTarget(self, action: #selector(forgetPasswordAction), for: .touchUpInside)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.swThemeColor()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let dict:NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.white,NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18)]
        self.navigationController?.navigationBar.titleTextAttributes = dict as? [NSAttributedStringKey : AnyObject]
    }
    func standardizeTFStyle(textField:SWLeftViewTextFiled) {
        textField.leftViewMode = .always
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.swGrayTextColor().cgColor
        textField.layer.cornerRadius = 22.5
        textField.delegate = self
    }
    func storedPasswordForUser() {
        let password:String? = SWDataStorage.init().passwordForUser(username: self.usernameTF.text)
        guard let _ = password else {
            return
        }
        let alertVC = UIAlertController.init(title: "登录", message: "是否填充在钥匙串中记录的密码", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "填充", style: .default, handler: { (action) in
            self.passwordTF.text = password
            self.rememberPassword = true
            self.resetImageForRememberPassword()
        }))
        alertVC.addAction(UIAlertAction.init(title: "不了", style: .cancel, handler: { (action) in
            self.passwordTF.becomeFirstResponder()
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    func resetImageForRememberPassword() {
         self.rememberPasswordBtn.setImage(UIImage.imageNamed(name:  self.rememberPassword ? "checkSelected" : "checkUnselected", classCoder: self.classForCoder, bundleName: bundleName), for: .normal)
    }
}
//MARK:keyboard event
extension ViewController {
    func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { (notification:Notification) in
            let userInfo:NSDictionary = notification.userInfo! as NSDictionary
            let keyboardFrame = userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey) as! CGRect
            let time :TimeInterval = userInfo.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
            let  offset = fmin(-13, 180-keyboardFrame.height);
            UIView.animate(withDuration: time, animations: {
                self.inputContainerViewBottomCons.constant = offset
            self.view.layoutIfNeeded()
            })
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { (notification:Notification) in
            let userInfo:NSDictionary = notification.userInfo! as NSDictionary
            let time :TimeInterval = userInfo.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
            UIView.animate(withDuration: time, animations: {
                self.inputContainerViewBottomCons.constant = -13
                self.view.layoutIfNeeded()
            })
        }
    }
    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
}

