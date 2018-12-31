//
//  CommentVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/28.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit
import AVOSCloud

var commentuuid = [String]()
var commentowner = [String]()

class CommentVC: UIViewController, UITextViewDelegate,UITableViewDelegate,UITableViewDataSource{
  
//221
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
  
 
    @IBAction func sendBtn_clicked(_ sender: Any) {
        //在表格中添加一行
        usernameArray.append(AVUser.current()!.username!)
        avaArray.append(AVUser.current()?.object(forKey: "ava") as! AVFile)
        dateArray.append(Date())
        commentArray.append(commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        tableView.reloadData()
        
        //发送到云端
        let commentObj = AVObject(className: "Comments")
        commentObj["to"] = commentuuid.last!
        commentObj["username"] = AVUser.current()?.username
        commentObj["ava"] = AVUser.current()?.object(forKey: "ava")
        commentObj["comment"] = commentTxt.text.trimmingCharacters(in: .whitespacesAndNewlines)
        commentObj.saveEventually()
        //发送hashtag到云端
        let words:[String] = commentTxt.text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            //定义正则表达式
            let pattern = "#[^#]+";
            let regular = try! NSRegularExpression(pattern: pattern, options:.caseInsensitive)
            let results = regular.matches(in: word, options: .reportProgress , range: NSMakeRange(0, word.characters.count))
            
            //输出截取结果
            print("符合的结果有\(results.count)个")
            for result in results {
                word = (word as NSString).substring(with: result.range)
            }
            
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = AVObject(className: "Hashtags")
                hashtagObj["to"] = commentuuid.last
                hashtagObj["by"] = AVUser.current()!.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = commentTxt.text
                hashtagObj.saveInBackground({ (success:Bool, error:Error?) in
                    if success {
                        print("hashtag \(word) 已经被创建。")
                    }else {
                        print(error?.localizedDescription)
                    }
                })
            }
        }
        
        
        // STEP 4. 当遇到@mention发送通知
        var mentionCreated = Bool()
        
        for var word in words {
            if word.hasPrefix("@") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let newsObj = AVObject(className: "News")
                newsObj["by"] = AVUser.current()!.username
                newsObj["ava"] = AVUser.current()!.object(forKey: "ava") as! AVFile
                newsObj["to"] = word
                newsObj["owner"] = commentowner.last
                newsObj["puuid"] = commentuuid.last
                newsObj["type"] = "mention"
                newsObj["checked"] = "no"
                newsObj.saveEventually()
                
                mentionCreated = true
            }
        }
        
        // STEP 5. 发送评论时候的通知
        if commentowner.last != AVUser.current()?.username && mentionCreated == false {
            let newsObj = AVObject(className: "News")
            newsObj["by"] = AVUser.current()?.username
            newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
            newsObj["to"] = commentowner.last
            newsObj["owner"] = commentowner.last
            newsObj["puuid"] = commentuuid.last
            newsObj["type"] = "comment"
            newsObj["checked"] = "no"
            newsObj.saveEventually()
        }
        
        //scroll to bottom
        self.tableView.scrollToRow(at: IndexPath(item: commentArray.count - 1, section: 0), at: .bottom, animated:  false)
        
        //重置UI
        commentTxt.text = ""
        commentTxt.frame.size.height = commentHeight
        commentTxt.frame.origin.y = sendBtn.frame.origin.y
        tableView.frame.size.height = tableViewHeight - keyboard.height - commentTxt.frame.height + commentHeight
    }
    
    @IBAction func usernameBtn_clicked(_ sender: Any) {
        //按钮的 index
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        //通过i获取到用户所单击的单元格
        let cell = tableView.cellForRow(at: i) as! CommentCell
        //如果用户单击的事自己的username,则调用homeVC ，否则是GuestVC
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username{
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        }else {
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameBtn.titleLabel?.text)
            query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                if let object = objects?.last {
                    guestArray.append(object as! AVUser)
                    
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                    self.navigationController?.pushViewController(guest, animated: true)

                }
            }
        }
    }
    
    
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
        //let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
         //self.tableView.backgroundColor = .white
        
        // 在开始的时候，禁止sendBtn按钮
        self.sendBtn.isEnabled = false
        
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
        
        //点击这个帖子之后可以浏览这个人发布的所有信息
        cell.commentLbl.userHandleLinkTapHandler = { label, handle, rang in
           
            var mention = handle
            mention = String(mention.characters.dropFirst())
            
            if mention.lowercased() == AVUser.current()!.username {
                let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                self.navigationController?.pushViewController(home, animated: true)
            }else {
                let query = AVUser.query()
                query.whereKey("username", equalTo: mention.lowercased())
                query.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                    if let object = objects?.last {
                        guestArray.append(object as! AVUser)
                        
                        let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                        self.navigationController?.pushViewController(guest, animated: true)
                    }
                })
            }
        }
        
        // #hashtag is tapped
        cell.commentLbl.hashtagLinkTapHandler = { label, handle, rang in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention)
            
            let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "HashtagesVC") as! HashtagesVC
            self.navigationController?.pushViewController(hashvc, animated: true)
            
        }
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
       return cell
    }
    //给指定单元格估一个高度值
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    
    // 所有单元格可编辑
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
    
    //设置所有单元格可编辑
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //获取用户所滑动的单元格对象
        let cell = tableView.cellForRow(at: indexPath) as! CommentCell
        //Delete
        let delete = UITableViewRowAction(style: .normal, title: "  ") { (UITableViewRowAction, IndexPath) in
            //从云端删除评论
            let commentQuery = AVQuery(className: "Comments")
            commentQuery.whereKey("to", equalTo: commentuuid.last!)
            commentQuery.whereKey("comment", equalTo: cell.commentLbl.text!)
            commentQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil {
                    
                    for object in objects! {
                        
                        (object as AnyObject).deleteEventually!()
                    }
                }else {
                    print(error?.localizedDescription)
                }
            })
            
            //  从云端删除 hashtag
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("to", equalTo: commentuuid.last)
            hashtagQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel?.text)
            hashtagQuery.whereKey("comment", equalTo: cell.commentLbl.text)
            hashtagQuery.findObjectsInBackground({ (object:[Any]?, error:Error?) in
                if error == nil {
                    
                    (object as AnyObject).deleteEventually()
                }
            })
            
            // STEP 3. 删除评论和@mention的消息通知
            let newsQuery = AVQuery(className: "News")
            newsQuery.whereKey("by", equalTo: cell.usernameBtn.titleLabel!.text)
            newsQuery.whereKey("to", equalTo: commentowner.last!)
            newsQuery.whereKey("type", containedIn: ["mention", "comment"])
            newsQuery.findObjectsInBackground({ (objects:[Any]?, error:Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteEventually!()
                    }
                }
            })
            
            
            //从表格视图中删除单元格
            self.commentArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.avaArray.remove(at: indexPath.row)
            self.usernameArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            //关闭单元格编辑状态
            self.tableView.setEditing(false, animated: true)
        }
        
        //Address
        let address = UITableViewRowAction(style: .normal, title: "   ") {(action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            // 在Text View中包含Address
            self.commentTxt.text = "\(self.commentTxt.text + "@" + self.usernameArray[indexPath.row] + " ")"
            // 让发送按钮生效
            self.sendBtn.isEnabled = true
            // 关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }
        
        //投诉评论
        let complain = UITableViewRowAction(style: .normal, title: " ") { (action:UITableViewRowAction, indexPath:IndexPath) in
            //发送投诉到云端
            // 发送投诉到云端
            let complainObj = AVObject(className: "Complain")
            complainObj["by"] = AVUser.current()!.username
            complainObj["post"] = commentuuid.last
            complainObj["to"] = cell.commentLbl.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text

            complainObj.saveInBackground({ (success:Bool, error:Error?) in
                if success {
                    self.alert(error: "投诉信息已经被成功提交！", message: "感谢您的支持，我们将关注您提交的投诉！")
                }else{
                    self.alert(error: "错误", message: error!.localizedDescription)
                }
            })
            
            // 关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }
        
        //按钮的背景颜色
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete.png")!)
        address.backgroundColor = UIColor(patternImage: UIImage(named: "address.png")!)
        complain.backgroundColor = UIColor(patternImage: UIImage(named: "complain.png")!)
        //根据不同的情况生成不同的Action组
        if cell.usernameBtn.titleLabel?.text == AVUser.current()!.username {
            
            return[delete,address]
        }else if commentowner.last == AVUser.current()!.username {
            
            return[delete,address,complain]
        }else {
            return[address,complain]
        }
    }
    
    // 消息警告
    func alert(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    


}
