//
//  FollowersVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/26.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class FollowersVC: UITableViewController {
//112
    //声明两个字符串类型的属性
    var show = String()//导航栏标题处显示的内容
    var user = String()//返回按钮上显示用户名称
    
    var followerArray = [AVUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //导航栏标题
        self.navigationItem.title = show
         self.tableView.rowHeight = 80
        
        if show == "关 注 者"{
            
            loadFollowers()
        }else {
            
            loadFollowings()
        }

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followerArray.count
    }
    
   
    
    func loadFollowers()  {
        AVUser.current()?.getFollowers({ (followers:[Any]?, error:Error?) in
            if error == nil && followers != nil{
                self.followerArray = followers! as! [AVUser]
                //刷新表格视图
                self.tableView.reloadData()
            }else {
                
                print(error?.localizedDescription)
            }
        })
    }
    
    
    func loadFollowings() {
        AVUser.current()?.getFollowees({ (followings:[Any]?, error:Error?) in
            if error == nil && followings != nil{
                self.followerArray = followings! as! [AVUser]
                //刷新表格视图
                self.tableView.reloadData()
            }else {
                
                print(error?.localizedDescription)
            }
        })
    }
    
    //创建表格视图的单元格
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowersCell
        cell.usernameLbl.text = followerArray[indexPath.row].username
        
        let ava = followerArray[indexPath.row].object(forKey: "ava") as! AVFile

        ava.getDataInBackground { (data:Data?, error:Error?) in
            if error == nil {

                cell.avaImg.image = UIImage(data: data!)
            }else {

                print(error?.localizedDescription)
            }
        }
        //利用按钮外观区分当前用户关注或未关注状态
        let query = followerArray[indexPath.row].followeeQuery()
        query.whereKey("user", equalTo: AVUser.current())
        query.whereKey("followee", equalTo: followerArray[indexPath.row])
        query.countObjectsInBackground { (count:Int, error:Error?) in
            //根据数量设置按钮的风格
            if error == nil {
                if count == 0 {
                    cell.followBtn.setTitle("关 注", for: .normal)
                    cell.followBtn.backgroundColor = .lightGray
                }else {
                    cell.followBtn.setTitle("√ 已关注", for:.normal)
                    cell.followBtn.backgroundColor = .blue
                }
            }
        }
        //将关注人对象传递给FollowersCell对象
        cell.user = followerArray[indexPath.row]

        //为当前用户隐藏关注按钮
        if cell.usernameLbl.text == AVUser.current()!.username{

            cell.followBtn.isHidden = true
        }
        return cell
    }
    
    //单击表格视图的单元格跳转到别的控制器GuestVC
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //通过indexPath获取用户所单击的单元格的用户对象
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        //如果用户单击单元格，或者进入HomeVC或者进入GuestVC
        if cell.usernameLbl.text == AVUser.current()?.username {
            let home = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        }else{
            guestArray.append(followerArray[indexPath.row])
            let guest = storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
    }
 

}
