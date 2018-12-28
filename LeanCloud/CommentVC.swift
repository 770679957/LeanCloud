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

class CommentVC: UIViewController, UITextViewDelegate,UITableViewDelegate,UITableViewDataSource{
  
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
    
    //将从云端获取到的数据写进数组
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    var commentArray = [String]()
    var dateArray = [Date]()
    
    var page : Int = 15
    
    
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

        loadComments()
        loadMore()
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
        tableView.delegate = self
        tableView.dataSource = self
        
        
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
    
    //当输入的时候会调用此方法
    func textViewDidChange(_ textView: UITextView) {
        //如果没有输入则禁止按钮
        let spacing = CharacterSet.whitespacesAndNewlines
        if !commentTxt.text.trimmingCharacters(in: spacing).isEmpty {
            
            sendBtn.isEnabled = true
        }else {
            
            sendBtn.isEnabled = false
        }
        
        if textView.contentSize.height > textView.frame.height && textView.frame.height < 130 {
            
            let difference = textView.contentSize.height - textView.frame.height
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            // 上移tableView
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.height {
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        }else if textView.contentSize.height < textView.frame.height {
            let difference = textView.frame.height - textView.contentSize.height
            
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            // 上移tableView
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.height {
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentCell
        
        cell.usernameBtn.setTitle((usernameArray[indexPath.row]), for: .normal)
        cell.usernameBtn.sizeToFit()
        cell.commentLbl.text = commentArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            cell.avaImg.image = UIImage(data: data!)
        }
        
        //获取帖子的创建时间
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = Calendar.current.dateComponents(components, from: from, to: now)
        
        
        if difference.second! <= 0 {
            cell.dateLbl.text = "现在"
        }
        
        if difference.second! > 0 && difference.minute! <= 0 {
            cell.dateLbl.text = "\(difference.second) 秒."
        }
        
        if difference.minute! > 0 && difference.hour! <= 0 {
            cell.dateLbl.text = "\(difference.minute!) 分."
        }
        
        if difference.hour! > 0 && difference.day! <= 0 {
            cell.dateLbl.text = "\(difference.hour!) 时."
        }
        
        if difference.day! > 0 && difference.weekOfMonth! <= 0 {
            cell.dateLbl.text = "\(difference.day!) 天."
        }
        
        if difference.weekOfMonth! >  0 {
            cell.dateLbl.text = "\(difference.weekOfMonth!) 周."
        }
       return cell
    }
    //给指定单元格估一个高度值
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func loadComments() {
        //计算评论的数量
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground { (count:Int, error:Error?) in
            
            if self.page < count {
                self.refresh.addTarget(self, action: #selector(self.loadMore), for: .valueChanged)
                self.tableView.addSubview(self.refresh)
            }
            
            let query = AVQuery(className: "Comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil {
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        self.usernameArray.append((object as AnyObject).object(forKey: "username") as! String)
                        self.avaArray.append((object as AnyObject).object(forKey: "ava") as! AVFile)
                        self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                        self.dateArray.append((object as AnyObject).createdAt!)
                        self.tableView.reloadData()
                        self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }else {
                   print(error?.localizedDescription)
                }
            })
        }
    }
    
    @objc func loadMore() {
        // 合计出所有的评论的数量
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground { (count:Int, error:Error?) in
            //让refresher停止刷新动画
            self.refresh.endRefreshing()
            
            if self.page >= count {
                
                self.refresh.removeFromSuperview()
            }
            
            //载入更多的评论
            if self.page < count {
                self.page = self.page + 15
                
                //从云端查询page个记录
                let query = AVQuery(className: "Comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                    if error == nil {
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        
                        for object in objects! {
                            self.usernameArray.append((object as AnyObject).object(forKey: "username") as! String)
                            self.avaArray.append((object as AnyObject).object(forKey: "ava") as! AVFile)
                            self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                            self.dateArray.append((object as AnyObject).createdAt!)
                        }
                        self.tableView.reloadData()
                    }else {
                        print(error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    


}
