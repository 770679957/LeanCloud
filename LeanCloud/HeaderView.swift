//
//  HeaderView.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/26.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var webTxt: UITextView!
    @IBOutlet weak var bioLbl: UILabel!
    
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var followings: UILabel!
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var followingsTitle: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func followBtn_clicked(_ sender: Any) {
        let title = button.title(for: .normal)
        //获取当前的访客对象
        let user = guestArray.last
        
        if title == "关注" {
            
            guard let user = user else { return }
            
            AVUser.current()?.follow(user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success {
                    self.button.setTitle("√ 已关注", for: .normal)
                    self.button.backgroundColor = .green
                    
                    // 发送关注通知
                    let newsObj = AVObject(className: "News")
                    newsObj["by"] = AVUser.current()?.username
                    newsObj["ava"] = AVUser.current()?.object(forKey: "ava") as! AVFile
                    newsObj["to"] = guestArray.last?.username
                    newsObj["owner"] = ""
                    newsObj["puuid"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                }else {
                    print(error?.localizedDescription)
                }
            })
            
        }else if title == "√ 已关注"{
            guard let user = user else { return }
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success {
                    self.button.setTitle("关注", for: .normal)
                    self.button.backgroundColor = .lightGray
                    
                    // 删除关注通知
                    let newsQuery = AVQuery(className: "News")
                    newsQuery.whereKey("by", equalTo: AVUser.current()!.username)
                    newsQuery.whereKey("to", equalTo: guestArray.last?.username)
                    newsQuery.whereKey("type", equalTo: "follow")
                    newsQuery.findObjectsInBackground{ (objects:[Any]?, error:Error?) in
                        if error == nil {
                            for object in objects! {
                                (object as AnyObject).deleteEventually()
                            }
                        }
                    }
                }else {
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        //对齐
        let width = UIScreen.main.bounds.width
        
        //设置头像圆角
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
        button.layer.cornerRadius = button.frame.width / 50
    }
    
    
        
}
