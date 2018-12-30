//
//  PostCell.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/27.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
//190
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var picImg: UIImageView!//帖子照片
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var titleLbl: KILabel!
    @IBOutlet weak var puuidLbl: UILabel!
    
    @IBAction func likeBtn_clicked(_ sender: Any) {
        //获取likeBtn 按钮的title
        let title = (sender as AnyObject).title(for: .normal)
        
        if title == "unlike" {
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = puuidLbl.text
            object.saveInBackground { (success:Bool, error:Error?) in
                if success {
                    print("未标记：like!")
                    self.likeBtn.setTitle("like", for: .normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)                    
                }
            }
        }else{
            let query = AVQuery(className: "Likes")
            query.whereKey("by", equalTo: AVUser.current()?.username)
            query.whereKey("to", equalTo: puuidLbl.text)
            query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                for object in objects! {
                    //收索到记录以后从表中删除
                    (object as AnyObject).deleteInBackground({ (success:Bool, error:Error?) in
                        if success {
                            print("删除like记录，disliked")
                            self.likeBtn.setTitle("unlike", for: .normal)
                            self.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: .normal)
                            
                            //如果设置为喜爱，发送请求
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                        }
                    })
                }
            }
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //设置头像圆角
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
        //设置likeBtn按钮的title文字的颜色为无色
        likeBtn.setTitleColor(.clear, for: .normal)
        
        //双击照片添加喜爱
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeTap.numberOfTapsRequired = 2
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(likeTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
   
    @objc func likeTapped() {
        //创建一个大的灰色桃心
        let likePic = UIImageView(image: UIImage(named: "unlike.png"))
        likePic.frame.size.width = picImg.frame.width / 1.5
        likePic.frame.size.height = picImg.frame.height / 1.5
        likePic.alpha = 0.8
        self.addSubview(likePic)
        
        //通过动画隐藏likePic并且让它变小
        UIView.animate(withDuration: 0.4, animations: {
            likePic.alpha = 0
            likePic.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        })
        
        let title = likeBtn.title(for: .normal)
        
        if title == "unlike" {
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = puuidLbl.text
            object.saveInBackground { (success:Bool, error:Error?) in
                if success {
                    print("标记为：like!")
                    self.likeBtn.setTitle("like", for: .normal)
                    self.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
                    
                    //如果设置为喜爱，则发送通知给表格视图刷新表格
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                    
                    
                }
            }
        }
    }
    

}
