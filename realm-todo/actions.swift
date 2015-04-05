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

public protocol ActionProtocol {
    func dispatch() -> ActionTask
}

class Actions {
    
    class ReadTodos {
        
        func dispatch() -> ActionTask {
            println("Actions.ReadTodos#dispatch")
            return ActionTask { (progress, fulfill, reject, configure) -> Void in
                Api.TodoItem.Read().success { (value: JSON) -> Void in
                    //
                    var json = value.dictionaryObject as [String: AnyObject]?
                    //let realm = RLMRealm.defaultRealm()
                    //realm.beginWriteTransaction()
                    //for item in json {
                    //    ToDoItem.createOrUpdateInDefaultRealmWithObject(item)
                    //}
                    //realm.commitWriteTransaction()
                }.failure { (error, isCancelled) -> Void in
                        return
                }
                return
            }
        }
        
    }
    
    class CreateTodo: ActionProtocol {
        
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