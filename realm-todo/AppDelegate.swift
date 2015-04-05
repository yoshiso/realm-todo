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
class AppDelegate: UIResponder, UIApplicationDelegate, ApiDelegate {

    var window: UIWindow?
    var OAuthToken: String?
    
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
        
        Api.delegate = self
        
        let delay = 5.0 * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.OAuthToken = "exist"
        })
        
        Actions.ReadTodos()
        
        return true
    }
    
    func waitForToken() {
        while (self.OAuthToken == nil) {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode,
                beforeDate: NSDate(timeIntervalSinceNow: 0.1))
        }
    }
    
    func onDefaultFailure(err: NSError) -> NSError {
        debugPrintln(err)
        return err
    }
    
    func onDefaultSuccess(response: AnyObject) -> AnyObject {
        debugPrintln(response)
        return response
    }
    
    func customReqeust(request: NSMutableURLRequest) -> NSMutableURLRequest {
        
        println("start waiting for token")
        self.waitForToken()
        println("end waiting for token")
        
        debugPrintln(request)
        
        
        return request
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

