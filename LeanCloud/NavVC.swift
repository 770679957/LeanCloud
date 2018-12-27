//
//  NavVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/27.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class NavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //导航栏中title的颜色设置
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        //导航栏中按钮的颜色
        self.navigationBar.tintColor = .white
        //导航栏的背景色
        self.navigationBar.barTintColor = UIColor(red: 18.0/255.0, green: 86.0/255.0, blue: 136.0/255.0, alpha: 1)
        //不允许透明
        self.navigationBar.isTranslucent = false
    }
    //lightContent的风格和导航栏的风格是一致的
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }
    


}
