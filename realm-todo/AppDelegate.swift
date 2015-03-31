//
//  AppDelegate.swift
//  realm-todo
//
//  Created by ShoYoshida on 2015/03/30.
//  Copyright (c) 2015年 ShoYoshida. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Realm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Migration
        RLMRealm.setSchemaVersion(1, forRealmAtPath: RLMRealm.defaultRealmPath(),
            withMigrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 1 {
                    var index: Int = 0
                    migration.enumerateObjects(ToDoItem.className()) { oldObject, newObject in
                        index += 1
                        newObject["id"] = index
                    }
                }
        })
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()

        
        let vc = TableViewController()
        let nc = UINavigationController(rootViewController: vc)
        
        window?.rootViewController = nc
        window?.makeKeyAndVisible()
        
        Api.TodoItem.Update("username", params:["myName" : "test"]).then { (value: JSON?, _) -> Void in
        }.failure{ (error, isCanceled) -> Void in
        }

        Api.TodoItem.Read("myName").then { (value: JSON?, _) -> Void in
            var json = value?.arrayObject as Array<Dictionary<String,AnyObject>>
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            for item in json {
                ToDoItem.createOrUpdateInDefaultRealmWithObject(item)
            }
            realm.commitWriteTransaction()
        }.failure { (error, isCancelled) -> Void in
            return
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

