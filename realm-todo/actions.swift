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

public protocol ActionProtocol {
    func dispatch() -> Task<Int,AnyObject,NSError>
}

class Actions {
    
    
    class CreateTodo: ActionProtocol {
        
        private let name: String
        
        init(name: String) {
            self.name = name
        }
        
        func dispatch() -> Task<Int, AnyObject, NSError> {
            return Task<Int,AnyObject,NSError>{ (progress, fulfill, reject, configure) in
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