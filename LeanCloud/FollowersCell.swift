//
//  FollowersCell.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/26.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class FollowersCell: UITableViewCell {
//112
    var user: AVUser!
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    
    @IBAction func followBtn_clicked(_ sender: Any) {
        //请求空
        let title = followBtn.title(for: .normal)
        
        if title == "关注" {
            
            print("添加关注")
            guard user != nil else { return }
            AVUser.current()?.follow(user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success {
                    self.followBtn.setTitle("√ 已关注", for: .normal)
                    self.followBtn.backgroundColor = .green
                }else {
                    print(error?.localizedDescription)
                }
            })
        }else if title == "√ 已关注"{
            print("取消关注")
            
            guard self.user != nil else { return }
            AVUser.current()?.follow(self.user.objectId!, andCallback: { (success:Bool, error:Error?) in
                if success {
                    self.followBtn.setTitle("关注", for: .normal)
                    self.followBtn.backgroundColor = .lightGray
                }else {
                    print(error?.localizedDescription)
                }
            })
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //将头像制作成圆形
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
