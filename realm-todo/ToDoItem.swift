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
    // model層
    // stateとして is_visible_on_clientを持つ
    // 更新シークエンス
    // 0. 原則としてすべてのデータをクライアントに配信する(データは削除されない)
    // 1. 最新のデータをフェッチしてくる
    // 2. 全件保存、クライアントはis_visible_on_clientのデータのみを表示する
    // ex) 後々の改修でデータボリュームが大きくなってきた場合に改修する
    dynamic var id = 0
    dynamic var name = ""
    dynamic var finished = false
    
    override class func primaryKey() -> String {
        return "id"
    }
    
}
