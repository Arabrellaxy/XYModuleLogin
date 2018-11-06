//
//  ForgetPasswordTableViewCell.swift
//  SalesManLogin
//
//  Created by 谢艳 on 2018/11/5.
//

import UIKit
import Masonry
import Foundation
enum SWTextFieldTypeEnum {
    case phone
    case verfycode
    case password
    case confirmPassword
}
class SWForgetPasswordTableViewCell: UITableViewCell {
    @IBOutlet weak var actionBtnTrailConstraints: NSLayoutConstraint!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var valueTextfield: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    var _timer:Timer? = nil
    var _counting:Int = 60
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.stanardizeStyle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    public func configSubviewWithType(type:SWTextFieldTypeEnum) {
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
        case .password,.confirmPassword:
            self.valueTextfield.isSecureTextEntry = true
            self.configDefaultValueForTextfield(defaultValue: type == .password ? "请输入密码" : "请再次输入密码")
            self.hideActionButton()
        }
    }
    //MARK:Private
    func stanardizeStyle() {
        self.titleLabel.textColor = UIColor.darkText
        self.valueTextfield.textColor = UIColor.darkText
        self.valueTextfield.delegate = self
        self.actionButton.layer.masksToBounds = true
        self.actionButton.layer.cornerRadius = 40/2
        self.actionButton.addTarget(self, action: #selector(actionEvents), for: UIControlEvents.touchUpInside)
    }
    func hideActionButton() {
        self.actionButton.mas_updateConstraints { (make) in
            make?.width.mas_equalTo()(0)
            make?.trailing.mas_equalTo()(self.contentView)?.offset()(0)
        }
    }
    func showActionButton() {
        self.actionButton.mas_remakeConstraints { (make) in
            make?.trailing.mas_equalTo()(self.contentView)?.offset()(-8)
            make?.width.mas_equalTo()(80)
            make?.height.mas_equalTo()(40)
        }
        self.configTitleForActinButton(title: "发送验证码")
    }
    func configTitleForActinButton(title:String) {
        self.actionButton.setTitle(title, for: UIControlState.normal)
        
    }
    func configDefaultValueForTextfield(defaultValue:String) {
        self.valueTextfield.placeholder = defaultValue
    }
    func isValidPhone() -> Bool {
        let value = self.valueTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (value?.count)! > 0 else {
            return false
        }
        let CM_NUM = "^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$"
        let CU_NUM = "^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$"
        let CT_NUM = "^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$"
        let CMMatch = NSPredicate.init(format: "SELF MATCHES \(CM_NUM)").evaluate(with: value)
        let CUMatch = NSPredicate.init(format: "SELF MATCHES \(CU_NUM)").evaluate(with: value)
        let CTMatch = NSPredicate.init(format: "SELF MATCHES \(CT_NUM)").evaluate(with: value)

        if CMMatch || CUMatch || CTMatch {
            return true
        }
        return false
    }
}
//MARK:UITextfield Delegate
extension SWForgetPasswordTableViewCell:UITextFieldDelegate {
    
}

//MARK:ActionEvent
extension SWForgetPasswordTableViewCell {
    @objc func actionEvents() {
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
    @objc func timerTriggered(){
        _counting  = _counting-1
        guard _counting > 0 else {
            self.stopCounting()
            return
        }
        let title:String = "\(_counting)秒后重新发送"
        self.configTitleForActinButton(title: title)
    }
    func stopCounting() {
        self.actionButton.isEnabled = true
        self.configTitleForActinButton(title: "发送验证码")
        _timer?.invalidate()
    }
}
