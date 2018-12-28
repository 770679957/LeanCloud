//
//  CommentVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/28.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

var commentuuid = [String]()
var commentowner = [String]()

class CommentVC: UIViewController, UITextViewDelegate {
//221
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    var refresh = UIRefreshControl()

    // 重置UI的默认值
    var tableViewHeight: CGFloat = 0
    var commentY: CGFloat = 0
    var commentHeight: CGFloat = 0

    // 存储keyboard大小的变量
    var keyboard = CGRect()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "评论"
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
         self.tableView.backgroundColor = .red
        
        // 在开始的时候，禁止sendBtn按钮
      // self.sendBtn.isEnabled = false
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        
        //检测键盘出现或消失的状态
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //声明隐藏虚拟键盘的操作
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)

        
        alignment()

       
    }
    
    // 控制器视图出现在屏幕上调用的方法
    override func viewWillAppear(_ animated: Bool) {
        // 隐藏底部标签栏
        self.tabBarController?.tabBar.isHidden = true

        // 调出键盘
        self.commentTxt.becomeFirstResponder()
    }


    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    // 对齐UI控件
    func alignment() {
        let width = self.view.frame.width
        let height = self.view.frame.height

        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - self.navigationController!.navigationBar.frame.height - 20)

        tableView.estimatedRowHeight = width / 5.33
        tableView.rowHeight = UITableView.automaticDimension

        commentTxt.frame = CGRect(x: 10, y: tableView.frame.height + height / 56.8, width: width / 1.306, height: 33)

        commentTxt.layer.cornerRadius = commentTxt.frame.width / 50

        commentTxt.delegate = self

        sendBtn.frame = CGRect(x: commentTxt.frame.origin.x + commentTxt.frame.width + width / 32, y: commentTxt.frame.origin.y, width: width - (commentTxt.frame.origin.x + commentTxt.frame.width) - width / 32 * 2, height: commentTxt.frame.height)

        
        tableViewHeight = tableView.frame.height
        commentHeight = commentTxt.frame.height
        commentY = commentTxt.frame.origin.y
        
        commentTxt.delegate = self
    }
    
    @objc func back(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
        
        // 从数组中清除评论的uuid
        if !commentuuid.isEmpty {
            commentuuid.removeLast()
        }
        
        // 从数组中清除评论所有者
        if !commentowner.isEmpty {
            commentowner.removeLast()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        // 定义keyboard大小
        let rect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        // 当虚拟键盘出现以后，将滚动视图的实际高度缩小为屏幕高度减去键盘的高度。
        UIView.animate(withDuration: 0.4) {
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height
            self.commentTxt.frame.origin.y = self.commentY - self.keyboard.height
            self.sendBtn.frame.origin.y = self.commentTxt.frame.origin.y
            
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        // 当虚拟键盘消失后，将滚动视图的实际高度改变为屏幕的高度值。
        UIView.animate(withDuration: 0.4) {
            self.tableView.frame.size.height = self.tableViewHeight
            
            self.commentTxt.frame.origin.y = self.commentY
            
            self.sendBtn.frame.origin.y = self.commentY
        }
    }
    
    @objc func hideKeyboardTap(recognizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }


}
