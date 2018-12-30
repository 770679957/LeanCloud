//
//  CommentCell.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/28.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
//221
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var commentLbl: KILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // alignment
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        commentLbl.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加约束
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-5-[username]-(-2)-[comment]-5-|",
            options: [], metrics: nil, views: ["username": usernameBtn, "comment": commentLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-15-[date]",
            options: [], metrics: nil, views: ["date": dateLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[ava(40)]",
            options: [], metrics: nil, views: ["ava": avaImg]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[ava(40)]-13-[comment]-20-|",
            options: [], metrics: nil, views: ["ava": avaImg, "comment": commentLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[ava]-13-[username]",
            options: [], metrics: nil, views: ["ava": avaImg, "username": usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[date]-10-|",
            options: [], metrics: nil, views: ["date": dateLbl]))
        
        avaImg.layer.cornerRadius = avaImg.frame.width / 2
        avaImg.clipsToBounds = true
    }
    
}
