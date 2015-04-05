//
//  actions.swift
//  realm-todo
//
//  Created by ShoYoshida on 2015/03/31.
//  Copyright (c) 2015年 ShoYoshida. All rights reserved.
//

import SwiftTask
import SwiftyJSON
import Realm

public typealias ActionTask = Task<Int,AnyObject,NSError>


class Actions {
    
    class Base {
        
        init() {
            dispatch({
                self.action()
            })
        }
        
        func dispatch(action: ()-> ActionTask) -> Void {
            println("Actions.\(className())#dispatch start")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                action().success { (value:AnyObject) in
                    println("Actions.\(self.className())#dispatch end")
                    
                }
                return
            })
        }
        
        func className() -> String {
           return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last! as String
        }
        
        func action() -> ActionTask {
            // over ride me!
            return ActionTask(value: "override me")
        }
    }
    
    class ReadTodos: Base {
        
        override func action() -> ActionTask {
            return ActionTask { (progress, fulfill, reject, configure) -> Void in
                Api.TodoItem.Read().success { (value: AnyObject) -> Void in
                    
                    let items = value as [[String:AnyObject]]
                    
                    let realm = RLMRealm.defaultRealm()
                    realm.beginWriteTransaction()
                    for item in items {
                        ToDoItem.createOrUpdateInDefaultRealmWithObject(item)
                    }
                    realm.commitWriteTransaction()
                    fulfill(items)
                }.failure { (error, isCancelled) -> Void in
                        return
                }
                return
            }
        }
        
    }
    
    class CreateTodo {
        
        private let name: String
        
        init(name: String) {
            self.name = name
        }
        
        func dispatch() -> ActionTask {
            println("Actions.CreateTodo#dispatch")
            return ActionTask{ (progress, fulfill, reject, configure) in
                let realm = RLMRealm.defaultRealm()
                    
                // init
                let item  = ToDoItem()
                item.name = self.name
                
                // commit
                realm.beginWriteTransaction()
                let lastOne = ToDoItem.allObjects().sortedResultsUsingProperty("id", ascending: false).objectAtIndex(0) as ToDoItem
                item.id   = lastOne.id + 1
                realm.addObject(item)
                realm.commitWriteTransaction()
                    
                // callback
                fulfill(item)
            }
        
        }
    }

}