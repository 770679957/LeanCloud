//
//  NewsCell.swift
//  LeanCloud
//
//  Created by yangyingwei on 2019/1/1.
//  Copyright © 2019 yangyingwei. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var inforLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 头像变圆
        self.avaImg.layer.cornerRadius = avaImg.frame.width / 2
        self.avaImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
