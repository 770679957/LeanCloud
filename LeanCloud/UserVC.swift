//
//  UserVC.swift
//  LeanCloud
//
//  Created by yangyingwei on 2019/1/1.
//  Copyright © 2019 yangyingwei. All rights reserved.
//

import UIKit
//添加集合视图相关的协议声明
class UserVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //搜索栏
    var searchBar = UISearchBar()
    
    //从云端获取信息后保存数据的数组
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    
    //集合视图
    var collectionView: UICollectionView!
    //存储云端数据的数组
    var picArray = [AVFile]()
    var puuidArray = [String]()
    var page:Int = 24

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //实现search Bar 功能
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.width - 30
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        

        loadUsers()
        collectionviewlaunch()
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return usernameArray.count
    }
    //设置单元格的高度为屏幕的四分之一
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.width / 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowersCell
        
        cell.followBtn.isHidden = true
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil {
                
               cell.avaImg.image = UIImage(data: data!)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 获取当前用户选择的单元格对象
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        if cell.usernameLbl.text == AVUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        }else {
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameLbl.text)
            query.findObjectsInBackground { (objects:[Any]?, error:Error?) in
                if let object = objects?.last {
                    guestArray.append(object as! AVUser)
                    
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "GUestVC") as! GuestVC
                    
                    self.navigationController?.pushViewController(guest, animated: true)
                }
            }
        }
    }
    
    
    //实现搜索功能的s代码
    func loadUsers() {
        let usersQuery = AVUser.query()
        usersQuery.addAscendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil {
                // 清空数组
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    print((object as AnyObject).username!)
                    self.usernameArray.append((object as AnyObject).username!)
                    self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                }
                
                // 刷新表格视图
                self.tableView.reloadData()
            }else {
                print(error?.localizedDescription)
            }
        }
    }
    //当用户在搜索栏中输入的时候会调用此方法
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let userQuery = AVUser.query()
        userQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        userQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil {
                //清空数组
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.usernameArray.append((object as AnyObject).username!)
                    self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                }
                self.tableView.reloadData()
                
            }else {
                //清空数组
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.usernameArray.append((object as AnyObject).username!)
                    self.avaArray.append((object as AnyObject).value(forKey: "ava") as! AVFile)
                }
                self.tableView.reloadData()
            }
        }
        return true
    }
    
    //当用户在搜索栏输入文字时 调用该方法
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 当开始搜索的时候，隐藏集合视图
        collectionView.isHidden = true
        
        searchBar.showsCancelButton = true
    }
    
    //当用户点击cancel调用该方法
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //当搜索结束后显示集合视图
        collectionView.isHidden = false
        
        searchBar.resignFirstResponder()
        
        searchBar.showsCancelButton = false
        
        searchBar.text = " "
    
        loadUsers()
    }
    
    //集合视图相关的方法
    func collectionviewlaunch() {
        let layout = UICollectionViewFlowLayout()
        
        // 定义item的尺寸
        layout.itemSize = CGSize(width: self.view.frame.width / 3, height: self.view.frame.width / 3)
        
        // 设置滚动方向
        layout.scrollDirection = .vertical
        
        // 定义滚动视图在视图中的位置
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - self.tabBarController!.tabBar.frame.height - self.navigationController!.navigationBar.frame.height - 20)
        
        // 实例化滚动视图
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        
        self.view.addSubview(collectionView)
        
        // 定义集合视图中的单元格
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        // 载入帖子
        loadPosts()
    }
    
    
    
    //设置每个section中行之间的间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //设置每个section中item的间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    //集合视图有几个单元格
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let picImg = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        cell.addSubview(picImg)
        
        picArray[indexPath.row].getDataInBackground { (data:Data?, error:Error?) in
            if error == nil {
                picImg.image = UIImage(data: data!)
            }else {
                print(error?.localizedDescription)
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 从uuidArray数组获取到当前所点击的帖子的uuid，并压入到全局数组postuuid中
        postuuid.append(puuidArray[indexPath.row])
        
        // 呈现PostVC控制器
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.limit = page
        query.findObjectsInBackground {  (objects:[Any]?, error:Error?) in
            if error == nil {
                // 清空数组
                self.picArray.removeAll(keepingCapacity: false)
                self.puuidArray.removeAll(keepingCapacity: false)
                
                // 获取相关数据
                for object in objects! {
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                }
                self.collectionView.reloadData()
                
            }else {
                
                 print(error?.localizedDescription)
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            self.loadMore()
        }
    }
    
    func loadMore() {
        // 如果有更多的帖子需要载入
        if page <= picArray.count {
            // 增加page的数量
            page = page + 24
            // 载入更多的帖子
            let query = AVQuery(className: "Posts")
            query.limit = page
            query.findObjectsInBackground {  (objects:[Any]?, error:Error?) in
                if error == nil {
                    // 清空数组
                    self.picArray.removeAll(keepingCapacity: false)
                    self.puuidArray.removeAll(keepingCapacity: false)
                    
                    // 获取相关数据
                    for object in objects! {
                        self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                        self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    }
                    self.collectionView.reloadData()
                    
                }else {
                    
                    print(error?.localizedDescription)
                }
            }
        }
    }
}
