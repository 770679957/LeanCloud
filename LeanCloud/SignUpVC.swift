//
//  SignUpVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/26.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var avaImg: UIImageView!
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passworTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextField!
    @IBOutlet weak var webTxt: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // 根据需要，设置滚动视图的高度
    var scrollViewHeight: CGFloat = 0
    
    // 获取虚拟键盘的大小
    var keyboard: CGRect = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 滚动视图的frame size
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = self.view.frame.height
        
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
        
        //改变imag 的外观为圆形
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
        //设置背景图
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        bg.image = UIImage(named: "2.jpg")
        self.view.addSubview(bg)
        
        bg.layer.zPosition = -1 //图层最底层
        self.view.addSubview(bg)

        
    }
    
    @IBAction func signUpBtn_clicked(_ sender: Any) {
        //隐藏键盘
        self.view.endEditing(true)
        
        if (usernameTxt.text?.isEmpty)! || (passworTxt.text?.isEmpty)! || (repeatPasswordTxt.text?.isEmpty)! || (emailTxt.text?.isEmpty)! || (fullnameTxt.text?.isEmpty)! || (bioTxt.text?.isEmpty)! || (webTxt.text?.isEmpty)!{
            
            //弹出提示对话框
            let alert = UIAlertController(title: "请注意", message: "请填写好所有的字段", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true,completion: nil)
            
            //如果两次输入的密码不同
            if passworTxt.text != repeatPasswordTxt.text {
                let alert = UIAlertController(title: "请注意", message: "两次输入的密码不一致", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert,animated: true, completion: nil)
                
            }
            return
        }
        
        //发送注册数据到服务器相关的列，
        let user = AVUser()
        print(usernameTxt.text as! String)
        user.username = usernameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user.password = passworTxt.text
        
        //添加特定的个人用户信息，这四个脚标代表用户的非通用信息
        user["fullname"] = fullnameTxt.text?.lowercased()
        user["bio"] = bioTxt.text
        user["web"] = webTxt.text?.lowercased()
        user["gende"] = ""
        
        // 获取图片的Data数据
        let avaData = UIImage.jpegData(avaImg.image!)(compressionQuality: 0.5)!
        let avaFile = AVFile(data: avaData, name: "ava.jpg")
        user["ava"] = avaFile
        
        //后台数据提交
        user.signUpInBackground{(success:Bool,error:Error?) in
            if success{
                
                print("用户注册成功！")
                
                //用户登录
                AVUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: {(user:AVUser?,error:Error?) in
                    if let user = user{
                        print("登录成功")
                        //记住登录的用户
                        UserDefaults.standard.set(user.username, forKey: "username")
                        UserDefaults.standard.synchronize()
                        
                        //从AppDelegate类中调用login方法
                        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.login()

                    }else{
                        print("登录失败")
                        
                    }
                    
                })
                
            }else{
               
                print(error?.localizedDescription)
            }
        }
    }
    
    
    @IBAction func cancelBtn_clicked(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @objc func showKeyboard(notification: Notification) {
        
        // 定义keyboard大小
        let rect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        // 当虚拟键盘出现以后，将滚动视图的实际高度缩小为屏幕高度减去键盘的高度。
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.size.height
        }
    }
    
    @objc func hideKeyboard(notification: Notification) {
        // 当虚拟键盘消失后，将滚动视图的实际高度改变为屏幕的高度值。
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.view.frame.height
        }
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
    
 
}
