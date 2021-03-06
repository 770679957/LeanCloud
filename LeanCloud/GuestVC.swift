//
//  GuestVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/27.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit


var  guestArray = [AVUser]()
class GuestVC: UICollectionViewController {
    
    //从云端获取数据并存储到数组
    var puuidArray = [String]()
    var picArray = [AVFile]()
    
    //界面对象
    var refresher: UIRefreshControl!
    var page: Int = 12
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //允许垂直的拉拽刷新操作
        self.collectionView.alwaysBounceVertical = true
        
        //导航栏的顶部信息
        self.navigationItem.title = guestArray.last?.username
        
        //定义导航栏中新的返回按钮
        self.navigationItem.hidesBackButton = true
        //let backBtn = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back))
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //实现向右滑动返回
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)
        
        //设置refresher控件到集合视图之中 刷新
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for:.valueChanged)
        collectionView.addSubview(refresher)
        
        //设置集合视图的背景色
        self.collectionView.backgroundColor = .white
        
        loadPosts()

        
    }

    
    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell

        //从云端载入帖子照片
        picArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil {
                
                cell.picImg.image = UIImage(data: data!)
            }else {
                
                print(error?.localizedDescription)
            }
        }
        return cell
    }
    
    @objc func back(_:UIBarButtonItem) {
        //退回到之前的控制器
        self.navigationController?.popViewController(animated: true)
        
        //从guestArray中移除最后一个AVUser
        if !guestArray.isEmpty {
            
            guestArray.removeLast()
        }
    }
    
    //刷新方法
    @objc func refresh()  {
        self.collectionView.reloadData()
        self.refresher.endRefreshing()
    }
    
    //载入访客发布的帖子
    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: guestArray.last?.username)
        query.limit = page
        query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            //查询成功
            if error == nil{
                //清空两个数组
                self.puuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    //将查询到的数据添加到数组中
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
                self.collectionView.reloadData()
            }else {
                print(error?.localizedDescription)
            }
        }
    }
     //配置header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //定义header
        let header = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        //载入访客的基本信息
        let infoQuery = AVQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestArray.last?.username)
        infoQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil {
                //判断是否有用户信息
                guard let objects = objects, objects.count > 0 else {
                    let alert = UIAlertController(title: "\(guestArray.last?.username)", message: "用尽洪荒之力，画也没有g发现该用户的存在！", preferredStyle:.alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert,animated: true, completion: nil)
                    
                    return
                }
                //找到用户的相关信息
                for object in objects {
                    header.fullnameLbl.text = ((object as AnyObject).object(forKey:"fullname") as? String)?.uppercased()
                    header.bioLbl.text = (object as AnyObject).object(forKey:"bio") as? String
                    header.bioLbl.sizeToFit()
                    header.webTxt.text = (object as AnyObject).object(forKey:"web") as? String
                    header.webTxt.sizeToFit()
                    
                    let avaFile = (object as AnyObject).object(forKey:"ava") as? AVFile
                    avaFile?.getDataInBackground({ (data:Data?, error:Error?) in
                        
                        header.avaImg.image = UIImage(data:data!)
                    })
                }
            }else {
                print(error?.localizedDescription)
            }
        }
        
        //设置当前用户和访客之间的关注状态
        let followeeQuery = AVUser.current()?.followeeQuery()
        followeeQuery?.whereKey("user", equalTo: AVUser.current())
        followeeQuery?.whereKey("followee", equalTo: guestArray.last)
        followeeQuery?.countObjectsInBackground({ (count:Int, error:Error?) in
            guard error == nil else { print(error?.localizedDescription);return}
            
            if count == 0 {
                header.button.setTitle("关注", for: .normal)
                header.button.backgroundColor = .lightGray
            }else {
                header.button.setTitle("√ 已关注", for: .normal)
                header.button.backgroundColor = .green
            }
        })
        
        //计算统计数据
        //访客的帖子数
        let posts = AVQuery(className: "Posts")
        posts.whereKey("username", equalTo: guestArray.last?.username)
        print(guestArray.last?.username)
        posts.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil {
                header.posts.text = "\(count)"
                //header.posts.text = "3"
                
                
                
                // header.followers.text = String(count)
            }else {
                print(error?.localizedDescription)
            }
        }
        //访客的关注者数
        let followers = AVUser.followerQuery((guestArray.last?.objectId)!)
        followers.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil {
                header.followers.text = "\(count)"
                // header.followers.text = "2"
            }else {
                print(error?.localizedDescription)
            }
        }
        
        //访客的关注数
        let followings = AVUser.followeeQuery((guestArray.last?.objectId)!)
        followings.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil {
                header.followings.text = "\(count)"
                //header.followings.text = "1"
            }else {
                print(error?.localizedDescription)
            }
        }
        
        //实现统计数据的单击手势
        //单击posts label
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTap(_:)))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        //单击关注者label
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap(_:)))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        //单击关注数 label
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(followingsTap(_:)))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        
      return header
    }
    
    @objc func postsTap (_ recognizer:UITapGestureRecognizer) {
        if !picArray.isEmpty{
            let index = IndexPath(item: 0, section: 0)
            self.collectionView.scrollToItem(at: index, at: .top, animated: true)
        }
    }
    
    @objc func followersTap (_ recognizer:UITapGestureRecognizer) {
        //从故事版中载入FollowersVC的视图
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followers.user = guestArray.last!.username!
        followers.show = "关 注 者"
        
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    @objc func followingsTap (_ recognizer:UITapGestureRecognizer) {
        //从故事版中载入FollowersVC的视图
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        
        followings.user = guestArray.last!.username!
        followings.show = "关 注"
        
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    //当用户在集合视图中单击某个单元格会调用此方法
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //发送post uuid 到 postuuid中
        postuuid.append(puuidArray[indexPath.row])
        //导航到postVC控制器
        let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostVC")
        self.navigationController?.pushViewController(postVC!, animated: true)
    }

    
}
