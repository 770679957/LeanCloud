//
//  SignInVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/26.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    
    @IBOutlet weak var Label: UILabel!
    
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var signInBtn: UIButton!//登录
    @IBOutlet weak var signUpBtn: UIButton!//注册
    @IBOutlet weak var forgotBtn: UIButton!
    
    
    @IBAction func signInBtn_click(_ sender: Any) {
        //隐藏键盘
        self.view.endEditing(true)
        
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty {
            
            //弹出提示对话框
            let alert = UIAlertController(title: "请注意", message: "请填写好所有的字段", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true,completion: nil)
            
            //
            
            return
        }
        
        //实现用户登录功能
        AVUser.logInWithUsername(inBackground: usernameTxt.text!, password: passwordTxt.text!) { (user:AVUser?,error:Error?) in
            if error == nil {
                //记住用户
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                //调用appDelegate类的login方法
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
        }
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //隐藏键盘
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //label字体设置
        Label.font = UIFont(name: "Pacifico", size: 25)
        
        //设置背景图
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        bg.image = UIImage(named: "5.jpg")
        self.view.addSubview(bg)
        
        bg.layer.zPosition = -1 //图层最底层
        self.view.addSubview(bg)
    }
    
    @objc func hideKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    

   

}
