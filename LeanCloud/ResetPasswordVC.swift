//
//  ResetPasswordVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/26.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class ResetPasswordVC: UIViewController {
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBAction func resetBtn_clicked(_ sender: Any) {
        //隐藏键盘
        self.view.endEditing(true)
        
        
        if emailTxt.text!.isEmpty {
            let alert = UIAlertController(title: "请注意", message: "电子邮件不能为空", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert,animated: true,completion: nil)
            
            return
        }
        
        AVUser.requestPasswordResetForEmail(inBackground: emailTxt.text!) { (success:Bool, error:Error?) in
            if success {
                
                let alert = UIAlertController(title: "请注意", message: "重置密码连接已经发送到您的电子邮件！", preferredStyle:.alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.dismiss(animated: true, completion: nil) })
                alert.addAction(ok)
                self.present(alert,animated: true,completion: nil)
            }else{
                
                print(error?.localizedDescription)
            }
        }
        
    }
    
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置背景图
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        bg.image = UIImage(named: "2.jpg")
        self.view.addSubview(bg)
        
        bg.layer.zPosition = -1 //图层最底层
        self.view.addSubview(bg)

      
    }
    


}
