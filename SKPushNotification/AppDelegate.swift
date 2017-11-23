//
//  AppDelegate.swift
//  SKPushNotification
//
//  Created by xiaobin liu on 2017/11/21.
//  Copyright © 2017年 Sky. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            self.registerNotificationCategory()
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.delegate = self
            let types = UNAuthorizationOptions([.alert,.badge,.sound])
            notificationCenter.requestAuthorization(options: types, completionHandler: { (flag, error) in
                if flag {
                    print("注册成功")
                } else {
                    print("注册失败:\(error.debugDescription)")
                }
            })
        } else {
            let setting = UIUserNotificationSettings.init(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(setting)
        }
        /// 向 APNs 请求 token：
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }

    /// mark - iOS9 及之前方法
    // (iOS9及之前)本地通知回调函数，当应用程序在前台时调用
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        debugPrint(notification.userInfo ?? "")
    }
    
    /// MARK - 远程推送的通知回调
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        debugPrint(userInfo)
        if application.applicationState == .active {
            // 前台接受消息app
        } else {
            // 后台接受到消息
        }
    }
    
    /// MARK - iOS10
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugPrint(userInfo)
        UIApplication.shared.applicationIconBadgeNumber = 10
        completionHandler(.newData)
    }
    
    /// MARK - iOS10->前台收到通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint(notification)
        completionHandler([.sound,.alert,.badge])
    }

    //MARK:iOS10->后台点击通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        switch response.notification.request.content.categoryIdentifier {
        case "Helllo":
            UIAlertController.showConfirmAlertFromTopViewController(message: response.actionIdentifier)
            break
        default:
            break
        }
        completionHandler()
    }
    
    
    /// MARK - 获取token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugPrint(deviceToken.hexString)
    }
    
    /// MARK - 注册远程通知失败
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(error)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    
    @available(iOS 10.0, *)
    private func registerNotificationCategory() {
        
        let saySomethingCategory: UNNotificationCategory = {
                
                let lookAction = UNNotificationAction(
                    identifier: "action.look",
                    title: "查看",
                    options: [.foreground])
                
                let cancelAction = UNNotificationAction(
                    identifier: "action.cancel",
                    title: "取消",
                    options: [.destructive])
                
                // 2 identifier 非常重要 远程推送的时候需要设置 category 属性为这个值
                return UNNotificationCategory(identifier:"Helllo", actions: [lookAction, cancelAction], intentIdentifiers: [], options: [.customDismissAction])
        }()
        UNUserNotificationCenter.current().setNotificationCategories([saySomethingCategory])
    }
}

extension Data {
    
    var hexString: String {
        return withUnsafeBytes {(bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: count)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 })
        }
    }
}


extension UIAlertController {
    static func showConfirmAlert(message: String, in viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        viewController.present(alert, animated: true)
    }
    
    static func showConfirmAlertFromTopViewController(message: String) {
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            showConfirmAlert(message: message, in: vc)
        }
    }
}

