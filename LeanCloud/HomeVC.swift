//
//  HomeVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/26.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

class HomeVC: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    //83页
    
    //刷新控件
    var refresher: UIRefreshControl!
    
    //每页载入帖子的（图片）数量
    var page: Int = 12
    var puuidArray = [String]()
    var picArray = [AVFile]()
    
    @IBAction func logout(_ sender: Any) {
        //退出用户登录
        AVUser.logOut()
        
        //从UserDefaults中移除用户记录
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.synchronize()
        
        //设置应用程序的rootViewController 为登录控制器
        let signIn = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = signIn
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //导航栏中的title设置
        self.navigationItem.title = AVUser.current()?.username?.uppercased()
        
        //设置refresher控件到集合视图之中
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for:.valueChanged)
        collectionView.addSubview(refresher)
        
        //设置集合图形在垂直方向上有反弹的效果
        self.collectionView.alwaysBounceVertical = true
        self.collectionView?.bounces = true
        
        // 从EditVC类接收Notification
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        loadPosts()

        
    }

   

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count
    }

    

    //集合视图提供指定位置的单元格对象
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //从集合视图的可复用队列中获取单元格对象
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell

        //从picArray数组中获取图片
        picArray[0].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil{
                cell.picImg.image = UIImage(data: data!)
            }else{
                print(error?.localizedDescription)
            }
        }
        return cell
    }
    //当集合视图需要在屏幕上显示就会调用该方法
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        //获取用户信息
        header.fullnameLbl.text = (AVUser.current()?.object(forKey: "fullname") as? String)?.uppercased()
        header.webTxt.text = AVUser.current()?.object(forKey: "web") as? String
        header.webTxt.sizeToFit()
        header.bioLbl.text = AVUser.current()?.object(forKey: "bio") as? String
        header.bioLbl.sizeToFit()
        //header.avaImg.image = UIImage(named: "美女7.jpg")
        
        //获取用户头像的信息  92页
        let avaQuery = AVUser.current()?.object(forKey: "ava") as! AVFile
        avaQuery.getDataInBackground { (data:Data?, error:Error?) in
            if data == nil{
                
                print(error?.localizedDescription)
            }else {
                header.avaImg.image = UIImage(data: data!)
                
            }
        }
        //初始化一个 AVQuery的对象
        let currentUser: AVUser = AVUser.current()!
        //对云端的Posts 表数据进行查询
        let postsQuery = AVQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: currentUser.username)
        print(currentUser.username)
        postsQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil {

                header.posts.text = String(count)
            }
        }

        //对云端的Posts 表数据进行查询
        let followersQuery = AVQuery(className: "_Follower")
        followersQuery.whereKey("user", equalTo: currentUser)
        print(currentUser.username)
        followersQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil {

                header.followers.text = String(count)
            }
        }

        let followeesQuery = AVQuery(className: "_Followee")
        followeesQuery.whereKey("user", equalTo: currentUser)
        print(currentUser.username)
        followeesQuery.countObjectsInBackground { (count:Int, error:Error?) in
            if error == nil {

                header.followings.text = String(count)
            }
        }
        
        //单击帖子数
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTap(_:)))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)

        //单击关注者数
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap(_:)))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)

        //单击关注数
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(followingsTap(_:)))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        return header
    }
    
    @objc func refresh() {
        
        collectionView.reloadData()
        
        //停止刷新动画
       refresher.endRefreshing()
    }
    
    //查询云端的Posts数据表
    func loadPosts() {
        // select * form Posts where username = 123
        let query = AVQuery(className: "Posts")
        print(AVUser.current()!.username as! String)
        query.whereKey("username", equalTo: AVUser.current()!.username as Any)
        query.limit = page
        query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            //查询成功
            if error == nil {
                print("查询成功")
                //清空两个数组
                self.picArray.removeAll(keepingCapacity: false)
                self.puuidArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    //将查询到的数据添加到数组中
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
                
                self.collectionView.reloadData()
            }else{
                print("查询失败")
                print(error?.localizedDescription)
            }
        }
    }
    
    @objc func postsTap (_ recognizer:UITapGestureRecognizer) {
        if !picArray.isEmpty{
            let index = IndexPath(item: 0, section: 0)
            self.collectionView.scrollToItem(at: index, at: UICollectionView.ScrollPosition.top, animated: true)
        }
    }
    
    @objc func followersTap (_ recognizer:UITapGestureRecognizer) {
        //从故事版中载入FollowersVC的视图
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followers.user = AVUser.current()!.username!
        followers.show = "关 注 者"
        
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    @objc func followingsTap (_ recognizer:UITapGestureRecognizer) {
        //从故事版中载入FollowersVC的视图
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        
        followings.user = AVUser.current()!.username!
        followings.show = "关 注"
        
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    //设置单元格大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width / 3, height: self.view.frame.width / 3)
        
        return size
    }
    
    @objc func reload(notification:Notification) {
        collectionView.reloadData()
    }
    
    //获取滚动视图的偏移量
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.height {
            self.loadMore()
        }
    }
    
    func loadMore() {
        if page <= picArray.count {
            page = page + 12
            
            
            let query = AVQuery(className: "Posts")
            query.whereKey("username", equalTo: guestArray.last?.username)
            query.limit = page
            query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                //查询成功
                if error == nil {
                    //清空数组
                    self.puuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        //将查询到的数据添加到数组中
                        self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                        self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                    }
                    print("loaded + \(self.page)")
                    self.collectionView?.reloadData()
                }else {
                    print(error?.localizedDescription)
                }
            }
        }
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
