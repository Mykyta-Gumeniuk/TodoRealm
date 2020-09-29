//
//  Category.swift
//  ToDoList
//
//  Created by Nik on 16.07.2020.
//  Copyright © 2020 Mykyta Gumeniuk. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    var items = List<Item>()
    @objc dynamic var colorHexValue: String = ""
}
