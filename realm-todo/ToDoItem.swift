//
//  ToDoItem.swift
//  realm-todo
//
//  Created by ShoYoshida on 2015/03/30.
//  Copyright (c) 2015年 ShoYoshida. All rights reserved.
//

import UIKit
import Realm

class ToDoItem: RLMObject {
    
    dynamic var id = 0
    dynamic var name = ""
    dynamic var finished = false
    
    override class func primaryKey() -> String {
        return "id"
    }
    
}
