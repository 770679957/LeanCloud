//
//  AppDelegate.swift
//  LeanCloud
//
//  Created by yangyingwei on 2018/12/26.
//  Copyright © 2018 yangyingwei. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AVOSCloud.setApplicationId("uFlD9AlnfGVUHTUFioNShPvS-gzGzoHsz", clientKey: "K10GdXRuyqBLFwYBUgsvRe8a")
        //如果想跟踪统计应用的打开情况，可以添加下面代码
        AVAnalytics.trackAppOpened(launchOptions: launchOptions)
        login()
        return true
    }
    
    func login() {
        //获取UserDefaults中存储的key为username的值
        let username:String? = UserDefaults.standard.string(forKey: "username")
        // 如果之前成功f登录过
        if username != nil {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let myTabBar = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
            window?.rootViewController = myTabBar
        }        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

