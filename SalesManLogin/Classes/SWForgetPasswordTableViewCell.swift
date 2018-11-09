//
//  ForgetPasswordTableViewCell.swift
//  SalesManLogin
//
//  Created by 谢艳 on 2018/11/5.
//

import UIKit
import Masonry
import Foundation

enum SWTextFieldTypeEnum:String {
    case phone = "phone"
    case verfycode = "verfycode"
    case password = "password"
    case confirmPassword = "confirmPassword"
}
@objc protocol SWForgetPasswordTableViewCellDelegate{
    @objc func textFieldDidChangedAtCell(cell:SWForgetPasswordTableViewCell,newValue:String,isValid:Bool)
    @objc func actionButtonClickedAtCell(cell:SWForgetPasswordTableViewCell)
}
class SWForgetPasswordTableViewCell: UITableViewCell {
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var valueTextfield: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    weak var  delegate: SWForgetPasswordTableViewCellDelegate?
    var _timer:Timer? = nil
    var _counting:Int = 60
    public private(set) var type:SWTextFieldTypeEnum = .phone
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.stanardizeStyle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    deinit {
        _timer?.invalidate()
        _timer = nil
    }
    public func configSubviewWithType(type:SWTextFieldTypeEnum,title:String) {
        switch type {
        case .phone:
            self.valueTextfield.isSecureTextEntry = false
            self.valueTextfield.keyboardType = UIKeyboardType.namePhonePad
            self.configDefaultValueForTextfield(defaultValue: "请输入电话号码")
            self.hideActionButton()
        case .verfycode:
            self.valueTextfield.isSecureTextEntry = false
            self.valueTextfield.keyboardType = UIKeyboardType.numberPad
            self.configDefaultValueForTextfield(defaultValue: "请输入验证码")
            self.showActionButton()
            self.configTitleForActinButton(title: "发送验证码")
        case .password,.confirmPassword:
            self.valueTextfield.isSecureTextEntry = true
            self.configDefaultValueForTextfield(defaultValue: type == .password ? "请输入密码" : "请再次输入密码")
            self.hideActionButton()
        }
        self.titleLabel.text = title
        self.type = type
    }
    public  func startCounting() -> Void {
        self.actionButton.isEnabled = false
        if #available(iOS 10.0, *) {
            _timer =  Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                self.timerTriggered()
            }
        } else {
            // Fallback on earlier versions
            _timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerTriggered), userInfo: nil, repeats: true)
        }
    }
    public func stopCounting() -> Void {
        self.actionButton.isEnabled = true
        self.configTitleForActinButton(title: "发送验证码")
        _timer?.invalidate()
    }
}
//MARK:UITextfield Delegate
extension SWForgetPasswordTableViewCell:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let originStr:NSString = (textField.text as NSString?)!
        let newValue = originStr.replacingCharacters(in: range, with: string)
        var valid = false
        switch self.type {
        case .phone:
            valid = self.isValidPhone(newValue)
        case .verfycode:
            valid = self.isValidVerifyCode(newValue)
        case .password,.confirmPassword:
            valid = self.isValidPassword(newValue)
        }
        if let delegate = self.delegate {
            delegate.textFieldDidChangedAtCell(cell: self, newValue:newValue , isValid: valid)
        }
        return true
    }
}

//MARK:ActionEvent
extension SWForgetPasswordTableViewCell {
    @objc func actionEvents() {
        if let delegate = self.delegate {
            delegate.actionButtonClickedAtCell(cell: self)
        }
    }
  
    @objc func timerTriggered(){
        _counting  = _counting-1
        guard _counting > 0 else {
            self.stopCounting()
            return
        }
        let title:String = "\(_counting)秒后重新发送"
        self.configTitleForActinButton(title: title)
    }
}
//MARK:Private
extension SWForgetPasswordTableViewCell{
    func stanardizeStyle() {
        self.titleLabel.textColor = UIColor.darkText
        self.valueTextfield.textColor = UIColor.darkText
        self.valueTextfield.delegate = self
        self.actionButton.layer.masksToBounds = true
        self.actionButton.layer.cornerRadius = 40/2
        self.actionButton.addTarget(self, action: #selector(actionEvents), for: UIControlEvents.touchUpInside)
        self.actionButton.setBackgroundImage(UIImage.imageFromColor(color: UIColor.swLightGreyColor()), for: UIControlState.disabled)
        self.actionButton.setBackgroundImage(UIImage.imageFromColor(color: UIColor.swThemeColor()), for: UIControlState.normal)
        self.actionButton.setTitleColor(UIColor.white, for: UIControlState.normal)
    }
    func hideActionButton() {
        self.actionButton.mas_remakeConstraints { (make) in
            make?.width.mas_equalTo()(0)
            make?.trailing.mas_equalTo()(self.contentView)?.offset()(0)
        }
        self.layoutIfNeeded()
    }
    func showActionButton() {
        self.actionButton.mas_remakeConstraints { (make) in
            make?.trailing.mas_equalTo()(self.contentView)?.offset()(-8)
            make?.leading.mas_equalTo()(self.valueTextfield.mas_trailing)?.offset()(8)
            make?.width.mas_equalTo()(110)
            make?.height.mas_equalTo()(40)
            make?.centerY.mas_equalTo()(self.contentView)?.offset()(0)
        }
        self.layoutIfNeeded()
    }
    func configTitleForActinButton(title:String) {
        self.actionButton.setTitle(title, for:.normal)
        
    }
    func configDefaultValueForTextfield(defaultValue:String) {
        self.valueTextfield.placeholder = defaultValue
    }
    func isValidPhone(_ phone:String) -> Bool {
        guard (phone.count) > 0 else {
            return false
        }
        let CM_NUM = "^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$"
        let CU_NUM = "^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$"
        let CT_NUM = "^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$"
        let CMMatch = NSPredicate(format: "SELF MATCHES %@", CM_NUM).evaluate(with: phone)
        let CUMatch = NSPredicate(format: "SELF MATCHES %@",CU_NUM).evaluate(with: phone)
        let CTMatch = NSPredicate(format: "SELF MATCHES %@",CT_NUM).evaluate(with: phone)
        
        if CMMatch || CUMatch || CTMatch {
            return true
        }
        return false
    }
    func isValidVerifyCode(_ code:String) -> Bool {
        return code.count == 6
    }
    func isValidPassword(_ password:String) -> Bool {
        return (password.count) > 0
    }
}
