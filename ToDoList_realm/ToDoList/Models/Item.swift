//
//  Item.swift
//  ToDoList
//
//  Created by Nik on 16.07.2020.
//  Copyright © 2020 Mykyta Gumeniuk. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items" )
}
