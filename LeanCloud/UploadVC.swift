//
//  UploadVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/27.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class UploadVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
//173
    
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleView: UITextView!
    @IBOutlet weak var publishBtn: UIButton!//发布
    @IBOutlet weak var removeBtn: UIButton!
    
    
    @IBAction func removeBtn_clicked(_ sender: Any) {
         self.viewDidLoad()
        
    }
    
    
    
    
    @IBAction func publishBtn_clicked(_ sender: Any) {
        //隐藏键盘
        self.view.endEditing(true)
        //为其负值
        let object = AVObject(className: "Posts")
        object["username"] = AVUser.current()?.username
        object["ava"] = AVUser.current()?.value(forKey: "ava") as! AVFile
        object["puuid"] = "\(AVUser.current()!.username!) \(NSUUID().uuidString)"
        
        //titleTxt 是否为空
        if titleView.text.isEmpty {
            object["title"] = ""
        }else {
            //trimmingCharacters用于过滤特殊符号
            object["title"] = titleView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        //生成照片数据
        let imageData = UIImage.jpegData(picImg.image!)(compressionQuality: 0.5)!
        let imageFile = AVFile(data: imageData, name: "Post.jpg")
        object["pic"] = imageFile
        
        //将数据存到leancloud云端
        object.saveInBackground { (success:Bool, error:Error?) in
            if error == nil {
                //发送uploaded通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                // 将TabBar控制器中索引值为0的子控制器，显示在手机屏幕上。
                self.tabBarController?.selectedIndex = 0
                
                self.viewDidLoad()
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //隐藏移除按钮
        removeBtn.isHidden = true
        
        //默认状态下禁用publishBtn按钮
        publishBtn.isEnabled = false
        publishBtn.backgroundColor = .lightGray
        
        //单击image view
        let picTap = UITapGestureRecognizer(target: self, action: #selector(selectImg))
        picTap.numberOfTapsRequired = 1
        self.picImg.isUserInteractionEnabled = true
        self.picImg.addGestureRecognizer(picTap)
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //让UI控件回到最初状态
        picImg.image = UIImage(named: "pbg.jpg")
        titleView.text = " "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        alignment()
    }
    
    //布局约束
    func alignment()  {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        picImg.frame = CGRect(x: 15, y: 15, width: width / 4.5, height: width / 4.5)
        
        titleView.frame = CGRect(x: picImg.frame.width + 25, y: picImg.frame.origin.y, width: width - titleView.frame.origin.x - 10, height: picImg.frame.height)
        
        publishBtn.frame = CGRect(x: 0, y: height - width / 8, width: width, height: width / 8)
        
       removeBtn.frame = CGRect(x: picImg.frame.origin.x, y: picImg.frame.origin.y + picImg.frame.height, width: picImg.frame.width, height: 30)
        
    }
    
    @objc func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
    }
    
    //将选择的照片放入PicImg,并销毁照片获取器
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picImg.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        //显示移除按钮
        removeBtn.isHidden = false
        
        //允许publish btn
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0 / 255.0, green: 169.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
        
        //实现第二次单击放大图片
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    //放大或缩小图片
    @objc func zoomImg() {
        //放大后的Image View 的位置
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x - self.navigationController!.navigationBar.frame.height * 1.5, width: self.view.frame.width, height: self.view.frame.width)
        
        let unzoomed = CGRect(x: 15, y: 15, width: self.view.frame.width / 4.5, height: self.view.frame.width / 4.5)
        
        //如果image是初始大小
        if picImg.frame == unzoomed {
            UIView.animate(withDuration: 0.3, animations: {
                self.picImg.frame = zoomed
                
                self.view.backgroundColor = .black
                self.titleView.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
            //如果是放大后的状态
        }else {
            UIView.animate(withDuration: 0.3,animations: {
                self.picImg.frame = unzoomed
                
                self.view.backgroundColor = .white
                self.titleView.alpha = 1
                self.publishBtn.alpha = 1
                self.removeBtn.alpha = 1
            })
        }
    }
    
    @objc func hideKeyboardTap(recognizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    



}
