//
//  ViewController.swift
//  SKPushNotification
//
//  Created by xiaobin liu on 2017/11/21.
//  Copyright © 2017年 Sky. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    /// 通知按钮
    private lazy var button = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.backgroundColor = .red
        button.setTitle("通知", for: .normal)
        button.bounds = CGRect(x: 0, y: 0, width: 80, height: 40)
        button.center = self.view.center
        button.addTarget(self, action: #selector(localNotification), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    /// MARK - iOS 10之前通知
    @objc private func localNotification() {
        
        if #available(iOS 10.0, *) {
            
            // 1. 创建通知内容
            let content = UNMutableNotificationContent()
            content.title = "iOS10通知"
            content.body = "测试看看而已"
            
            // 2. 创建发送触发
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            // 3. 发送请求标识符
            let requestIdentifier = "com.onevcat.usernotification.myFirstNotification"
            
            // 4. 创建一个发送请求
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            
            // 将请求添加到发送中心
            UNUserNotificationCenter.current().add(request) { error in
                if error == nil {
                    print("Time Interval Notification scheduled: \(requestIdentifier)")
                }
            }
        } else {
            let localNotification = UILocalNotification()
            //触发通知时间
            localNotification.fireDate = Date(timeIntervalSinceNow: 1)
            
            /// 重复间隔
            localNotification.repeatInterval = .init(rawValue: 0)
            localNotification.timeZone = TimeZone.current
            
            /// 通知内容
            localNotification.alertBody = "这是一条本地通知"
            localNotification.applicationIconBadgeNumber = 1
            localNotification.soundName = UILocalNotificationDefaultSoundName
            
            /// 通知参数
            localNotification.userInfo = ["kLocalNotificationKey": "iOS8推送"]
            localNotification.category = UUID().uuidString
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

