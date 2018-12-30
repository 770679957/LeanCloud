//
//  PostVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/27.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

var postuuid = [String]()
class PostVC: UITableViewController {
    //190
    
    //从服务器获取数据写入到相应的数组中
    var avaArray = [AVFile]()
    var usernameArray = [String]()
    var dateArray = [Date]()
    var picArray = [AVFile]()
    var puuidArray = [String]()
    var titleArray = [String]()
    
    
    @IBAction func moreBtn_clicked(_ sender: Any) {
        
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! PostCell
        //删除操作
        let delete = UIAlertAction(title: "删除", style:.default) { (UIAlertAction) ->Void in
            self.usernameArray.remove(at: i.row)
            self.avaArray.remove(at: i.row)
            self.picArray.remove(at: i.row)
            self.dateArray.remove(at: i.row)
            self.titleArray.remove(at: i.row)
            self.puuidArray.remove(at: i.row)
        }
        
        //删除云端的记录
        let postQuery = AVQuery(className: "Posts")
        postQuery.whereKey("puuid", equalTo: cell.puuidLbl.text)
        postQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil {
                for object in objects! {
                    (object as AnyObject).deleteInBackground({ (success:Bool, error:Error?) in
                        if success {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                            
                            //销毁当前控制器
                            _ = self.navigationController?.popViewController(animated: true)
                        }else {
                           print(error?.localizedDescription)
                        }
                    })
                }
            }
        }
        
        //删除帖子的like记录
        let likeQuery = AVQuery(className: "Likes")
        likeQuery.whereKey("to", equalTo: cell.puuidLbl.text)
        likeQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil {
                for object in objects! {
                    (object as AnyObject).deleteEventually()
                }
            }
        }
        
        //删除帖子相关的评论
        let commentQuery = AVQuery(className: "Comments")
        commentQuery.whereKey("to", equalTo: cell.puuidLbl.text)
        commentQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil {
                for object in objects! {
                    (object as AnyObject).deleteEventually()
                }
            }
        }
        
        let hashtagQuery = AVQuery(className: "Hashtags")
        hashtagQuery.whereKey("to", equalTo: cell.puuidLbl.text)
        hashtagQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil {
                for object in objects! {
                    (object as AnyObject).deleteEventually()
                }                
            }
        }
        
        
        
        //发送投诉到云端的Complain数据表
        let complain = UIAlertAction(title: "投诉", style:.default) { (UIAlertAction) in
            let complainObject = AVObject(className: "Complain")
            complainObject["by"] = AVUser.current()!.username
            complainObject["post"] = cell.puuidLbl.text
            complainObject["to"] = cell.titleLbl.text
            complainObject["owner"] = cell.usernameBtn.titleLabel?.text
            complainObject.saveInBackground({ (success:Bool, error:Error?) in
                if success {
                    self.alert(error: "投诉信息已经被成功提交！", message: "感谢您的支持，我们将关注您提交的投诉！")
                }else{
                    self.alert(error: "错误", message: error!.localizedDescription)
                }
            })
        }
         
        // 取消操作
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        // 创建菜单控制器
        let menu = UIAlertController(title: "菜单选项", message: nil, preferredStyle: .actionSheet)
        
        if cell.usernameBtn.titleLabel?.text == AVUser.current()!.username {
            menu.addAction(delete)
            menu.addAction(cancel)
        }else {
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        // 显示菜单
        self.present(menu, animated: true, completion: nil)
    }
    
    // 消息警告
    func alert(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func usernameBtn_clicked(_ sender: Any) {
        
        // 按钮的 index
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        // 通过 i 获取到用户所点击的单元格
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        // 如果当前用户点击的是自己的username，则调用HomeVC，否则是GuestVC
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        }else {
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
            
        }
    }
    
    
    @IBAction func commentBtn_clicked(_ sender: Any) {
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        // 发送相关数据到全局变量
        commentuuid.append(cell.puuidLbl.text!)
        commentowner.append(cell.usernameBtn.titleLabel!.text!)
        
        
        // 需要在故事板中查看Storyboard ID是否设置
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        self.navigationController?.pushViewController(comment, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //定义新的返回按钮
        self.navigationItem.hidesBackButton = true
        //let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back(_:)))
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.title = "照 片"
        
        //向右滑动，返回到之前的控制器
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        
        let postQuery = AVQuery(className: "Posts")
        postQuery.whereKey("puuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackground { (object:[Any]?, error:Error?) in
            
            //清空数组
            self.avaArray.removeAll(keepingCapacity: false)
            self.usernameArray.removeAll(keepingCapacity: false)
            self.dateArray.removeAll(keepingCapacity: false)
            self.picArray.removeAll(keepingCapacity: false)
            self.puuidArray.removeAll(keepingCapacity: false)
            self.titleArray.removeAll(keepingCapacity: false)
            
            for object in object! {
                self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                self.usernameArray.append((object as AnyObject).value(forKey: "username") as! String)
                self.dateArray.append((object as AnyObject).createdAt!)
                self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                self.titleArray.append((object as AnyObject).value(forKey: "title") as! String)
                
            }
            self.tableView.reloadData()
        }
        
        //设置当PostVC接收到liked通知以后执行refresh方法
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name.init("liked"), object: nil)
        
    }
    
    @objc func refresh() {
        self.tableView.reloadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return usernameArray.count
    }
    
    @objc func back(_ sender:UIBarButtonItem) {
        //退回到之前
        _ = self.navigationController?.popViewController(animated: true)
        //从postuuid数组移除当前的帖子的uuid
        if !postuuid.isEmpty {
            postuuid.removeLast()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        //通过数组信息关联单元格的UI控件
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.usernameBtn.sizeToFit()
        cell.puuidLbl.text = puuidArray[indexPath.row]
        cell.titleLbl.text = titleArray[indexPath.row]
        cell.titleLbl.sizeToFit()
        
        //配置用户头像
        avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            cell.avaImg.image = UIImage(data: data!)
        }
        
        //配置帖子照片
        picArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            cell.picImg.image = UIImage(data: data!)
        }
        
        // 帖子的发布时间和当前时间的间隔差
        //获取帖子的创建时间
        let from = dateArray[indexPath.row]
        //获取当前的时间
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
        
        //根据用户是否喜爱维护likeaBtn按钮
        let didLike = AVQuery(className: "Likes")
        didLike.whereKey("by", equalTo: AVUser.current()?.username)
        didLike.whereKey("to", equalTo: cell.puuidLbl.text)
        didLike.countObjectsInBackground { (count:Int, error:Error?) in
            if count == 0 {
                cell.likeBtn.setTitle("unlike", for: .normal)
                cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: .normal)
            }else {
                cell.likeBtn.setTitle("like", for: .normal)
                cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
            }
        }
        //计算本帖子的喜爱总数
        let countLikes = AVQuery(className: "Likes")
        countLikes.whereKey("to", equalTo: cell.puuidLbl.text)
        countLikes.countObjectsInBackground { (count:Int, error:Error?) in
            cell.likeLbl.text = "\(count)"
        }
        //将indexPath复制给usernameBtn的layer属性的自定义变量
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        
        // @mentions is tapped
        cell.titleLbl.userHandleLinkTapHandler = { label, handle, rang in
            
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
        cell.titleLbl.hashtagLinkTapHandler = { label, handle, rang in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercased())
            
            let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "HashtagesVC") as! HashtagesVC
            self.navigationController?.pushViewController(hashvc, animated: true)
            
        }

        
        
         return cell
    }

    
   
    
}
