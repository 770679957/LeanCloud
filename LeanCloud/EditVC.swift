//
//  EditVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/27.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class EditVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
   
    
//154
    
    //PickerView和PickerViewData
    var genderPicker:UIPickerView!
    let genders = ["男","女"]
    
    var keyboard = CGRect()
    
    @IBOutlet weak var scrollCiew: UIScrollView!
    
    @IBOutlet weak var avaImg: UIImageView!
    
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var telTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
    
    
    @IBAction func save_clicked(_ sender: Any) {
        if !validateEmail(email: emailTxt.text!) {
           alert(error: "错误的Email地址", message: "请输入正确的电子邮件地址")
            return
        }
        
        if !validateWeb(web: webTxt.text!) {
            alert(error: "错误的网页链接", message: "请输入正确的网址")
            return
        }
        
        if !telTxt.text!.isEmpty {
            if !validateMobilePhoneNumber(mobilePhoneNumber: telTxt.text!) {
                alert(error: "错误的手机号码", message: "请输入正确的手机号码")
                return
            }
        }
        
        //保存Field信息到服务器中
        let user = AVUser.current()
        user?.username = usernameTxt.text?.lowercased()
        user?.email = emailTxt.text?.lowercased()
        user?["fullname"] = fullnameTxt.text?.lowercased()
        user?["web"] = webTxt.text?.lowercased()
        user?["bio"] = bioTxt.text
        
        // 如果 tel 为空，则发送""给mobilePhoneNumber字段，否则传入信息
        if telTxt.text!.isEmpty {
            user?.mobilePhoneNumber = ""
        }else {
            user?.mobilePhoneNumber = telTxt.text
        }
        
        // 如果 gender为空，则发送""给gender字段，否则传入信息
        if genderTxt.text!.isEmpty {
            user?["gender"] = ""
        }else {
            user?["gender"] = genderTxt.text
        }
        
        //发送用户信息到服务器
        user?.saveInBackground({ (success:Bool, error:Error?) in
            if success {
                //隐藏键盘
                self.view.endEditing(true)
                
                //退出EditVC 控制器
                self.dismiss(animated: true, completion: nil)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
            }else {
                print(error?.localizedDescription)
            }
        })
        
    }
    
    @IBAction func cancel_clicked(_ sender: Any) {
       self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //在视图中创建PickerView
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        //检测键盘出现或消失的状态
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        //声明隐藏虚拟键盘的操作
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //image添加手势识别
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        imgTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(imgTap)
        
        alignment()
        information()

        
    }
    
    //布局约束
    func alignment() {
        //设置bioTxt为圆角
        bioTxt.layer.cornerRadius = bioTxt.frame.width / 50
        bioTxt.clipsToBounds = true
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    //获取器选项的title
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    //从获取器得到用户选择的Item
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }
    
    @objc func showKeyboard(notification:Notification)  {
        //定义Keyboard大小
        let rect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        
        //当虚拟键盘消失以后，将滚动视图实际高度缩小为屏幕高度减去键盘的高度
        UIView.animate(withDuration: 0.4) {
            self.scrollCiew.contentSize.height = self.view.frame.height + self.keyboard.height / 2
        }
    }
    
    @objc func hideKeyboard(notification:Notification) {
        //当虚拟键盘消失后，将滚动视图的内容高度值改变为0，这样滚动视图会根据实际内容设置大小
        self.scrollCiew.frame.size.height = self.view.frame.height
        
    }
    
    //隐藏视图中的虚拟键盘
    @objc func hideKeyboardTap(recognizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //创建照片获取器
    @objc func loadImg(recognizer:UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
        
    }
    
    //添加imagePickerController的协议 关联选择好的照片图像到image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        avaImg.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    //获取用户信息
    func information() {
        let ava = AVUser.current()?.value(forKey: "ava") as! AVFile
        ava.getDataInBackground { (data:Data?, error:Error?) in
            self.avaImg.image = UIImage(data: data!)
            
            //接收个人用户的文本信息
            self.usernameTxt.text = AVUser.current()?.username
            self.fullnameTxt.text = AVUser.current()?.value(forKey: "fullname") as! String
            self.bioTxt.text = AVUser.current()?.value(forKey: "bio") as! String
            self.webTxt.text  = AVUser.current()?.value(forKey: "web") as! String
            self.emailTxt.text = AVUser.current()?.email
            self.telTxt.text = AVUser.current()?.mobilePhoneNumber
            self.genderTxt.text = AVUser.current()?.value(forKey: "gender") as? String
        }
    }
    
    
    // 正则检查Email有效性
    func validateEmail(email: String) -> Bool {
        let regex = "\\w[-\\w.+]*@([A-Za-z0-9][-A-Za-z0-9]+\\.)+[A-Za-z]{2,14}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    // 正则检查Web有效性
    func validateWeb(web: String) -> Bool {
        let regex = "www\\.[A-Za-z0-9._%+-]+\\.[A-Za-z]{2,14}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    // 正则检查手机号码有效性
    func validateMobilePhoneNumber(mobilePhoneNumber: String) -> Bool {
        let regex = "0?(13|14|15|18)[0-9]{9}"
        let range = mobilePhoneNumber.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    
    //消息警告
    func alert(error:String,message:String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true,completion: nil)
    }

    
    
    

}
