//
//  ForgetPasswordViewController.swift
//  SalesManLogin
//
//  Created by 谢艳 on 2018/11/5.
//

import UIKit
import SalesManNetwork

class SWForgetPasswordViewController: UITableViewController {
    @IBOutlet weak var submitBtn: UIButton!
    var valueDic:Dictionary<String, (String,Bool)>?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改密码"
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.swGreyColor()
        self.stanardizeStyle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        print("name")
    }
}
//MARK:Tableview Delegate
extension SWForgetPasswordViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SWForgetPasswordTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SWForgetPasswordTableViewCell
        var type:SWTextFieldTypeEnum
        var title:String = ""
        switch indexPath.section {
        case 0:
            type = indexPath.row == 0 ? SWTextFieldTypeEnum.phone : SWTextFieldTypeEnum.verfycode
            title = indexPath.row == 0 ? "手机":"验证码"
        case 1:
            type = indexPath.row == 0 ? SWTextFieldTypeEnum.password : SWTextFieldTypeEnum.confirmPassword
            title = indexPath.row == 0 ? "新密码":"重复新密码"
        default:
            type = SWTextFieldTypeEnum.phone
        }
        cell.configSubviewWithType(type: type,title: title)
        cell.delegate = self
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
         return 10
    }
}
//MARK:Delegate
extension SWForgetPasswordViewController:SWForgetPasswordTableViewCellDelegate{
    func actionButtonClickedAtCell(cell: SWForgetPasswordTableViewCell) {
        guard self.valueDic != nil else {
            self.view.showTextHud(text: "请输入电话号码", autoHide: true)
            return
        }
        let value = self.valueDic![SWTextFieldTypeEnum.phone.rawValue]
        if (value?.1)! {
            //request verify code
            self.requestVerifyCode((value?.0)!)
        } else {
            self.view.showTextHud(text: "请输入正确的电话号码", autoHide: true)
        }
    }
    func textFieldDidChangedAtCell(cell: SWForgetPasswordTableViewCell, newValue: String, isValid: Bool) {
        let tempDic:NSMutableDictionary
        if let tempValueDic = self.valueDic {
            tempDic = NSMutableDictionary.init(dictionary: tempValueDic)
        } else {
            tempDic = NSMutableDictionary.init()
        }
        tempDic.setValue((newValue,isValid), forKey: cell.type.rawValue)
        self.valueDic = tempDic.copy() as? Dictionary<String, (String, Bool)>
        self.enableSubmitBtn()
    }
}

//MARK:Action
extension SWForgetPasswordViewController {
    @IBAction func submitAction(_ sender: Any) {
        let phoneTuple = self.valueDic![SWTextFieldTypeEnum.phone.rawValue]
        let verifyCodeTuple = self.valueDic![SWTextFieldTypeEnum.verfycode.rawValue]
        let passwordTuple = self.valueDic![SWTextFieldTypeEnum.password.rawValue]
        self.resetPassword((verifyCodeTuple?.0)!, (phoneTuple?.0)!,(passwordTuple?.0)!){[unowned self] (dictionary) in
            if dictionary.object(forKey: SWGlobal.status) as! Bool {
                self.view.showTextHud(text: "修改成功", autoHide: true)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.view.showTextHud(text: dictionary.object(forKey: SWGlobal.message) as! String, autoHide: true)
            }
        }
    }
}

//MARK:Network
extension SWForgetPasswordViewController{
    func requestVerifyCode(_ phone:String) {
        self.view.showTextHud(text: "验证码已发送至手机", autoHide: true)
        SalesManAFNetworkAPI.shareInstance.requestVerifyCode(phone) {[unowned self] (resultDic) in
            self.view.hideHud()
            let indexPath = IndexPath.init(row: 1, section: 0)
            let cell = self.cellAtIndexPath(indexPath: indexPath)
            if resultDic.object(forKey: SWGlobal.status) as! Bool{
                cell.startCounting()
            } else{
                cell.stopCounting()
                self.view.showTextHud(text: resultDic.object(forKey: SWGlobal.message) as! String, autoHide: true)
            }
        }
    }
    func resetPassword(_ verifyCode:String,_ phone:String,_ password:String,completion:@escaping ((_ resultDic:NSDictionary)->Void)) -> Void {
        self.view.showLoadingHud(loadingText: "正在修改密码")
        SalesManAFNetworkAPI.shareInstance.resetPassword(verifyCode,phone, password){(resultDic) in
            self.view.hideHud()
            completion(resultDic)
        }
    }
}

//MARK: Private
extension SWForgetPasswordViewController {
    func stanardizeStyle() {
        self.submitBtn.layer.masksToBounds = true
        self.submitBtn.layer.cornerRadius = 44/2
        self.submitBtn.setTitleColor(UIColor.white, for: .normal)
        self.submitBtn.setTitle("确定", for: .normal)
        self.submitBtn.isEnabled = false
        self.submitBtn.setBackgroundImage(UIImage.imageFromColor(color: UIColor.swLightGreyColor()), for: .disabled)
        self.submitBtn.setBackgroundImage(UIImage.imageFromColor(color: UIColor.swThemeColor()), for: .normal)
    }
    func cellAtIndexPath(indexPath:IndexPath) -> SWForgetPasswordTableViewCell {
        return self.tableView.cellForRow(at: indexPath) as! SWForgetPasswordTableViewCell
    }
    func enableSubmitBtn(){
        guard let _ = self.valueDic else {
            return
        }
        let phoneTuple = self.valueDic![SWTextFieldTypeEnum.phone.rawValue]
        let verifyCodeTuple = self.valueDic![SWTextFieldTypeEnum.verfycode.rawValue]
        let passwordTuple = self.valueDic![SWTextFieldTypeEnum.password.rawValue]
        let confirmPasswordTuple = self.valueDic![SWTextFieldTypeEnum.confirmPassword.rawValue]
        guard let _ = phoneTuple,let _ = verifyCodeTuple,let _ = passwordTuple,let _ = confirmPasswordTuple else {
            return
        }
        guard passwordTuple?.0 == confirmPasswordTuple?.0 else {
            self.submitBtn.isEnabled = false
            return
        }
        guard (phoneTuple?.1)!,(verifyCodeTuple?.1)!,(passwordTuple?.1)!,(confirmPasswordTuple?.1)! else {
            self.submitBtn.isEnabled = false
            return
        }
       self.submitBtn.isEnabled = true
    }
}
