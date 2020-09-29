//
//  ViewController.swift
//  ToDoList
//
//  Created by Nik on 04.07.2020.
//  Copyright © 2020 Mykyta Gumeniuk. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    var itemArray: Results<Item>?
    var selectedCategory: Category?{
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError()
        }
        if let categoryColor = selectedCategory?.colorHexValue{
            if let color = UIColor(hexString: categoryColor){
                navBar.backgroundColor = color
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(color, returnFlat: true)]
                navBar.tintColor = ContrastColorOf(color, returnFlat: true)
                navBar.barTintColor = ContrastColorOf(color, returnFlat: true)
                searchBar.barTintColor = color
                if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField{
                    if let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView{
                        
                        glassIconView.tintColor = ContrastColorOf(color, returnFlat: true)
                        textFieldInsideSearchBar.textColor = ContrastColorOf(color, returnFlat: true)
                        
                    }}
                title = selectedCategory?.name}
        }
        
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = itemArray?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            cell.backgroundColor = UIColor(hexString: selectedCategory!.colorHexValue)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count))
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            print("\(indexPath.row) \(CGFloat(indexPath.row) / CGFloat(itemArray!.count))")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if let item = itemArray?[indexPath.row]{
            do{
                try realm.write(){
                    item.done = !item.done
                }
            }catch{
                print("error changing done status \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = itemArray?[indexPath.row] {
            do {
                try realm.write(){
                    realm.delete(itemForDeletion)
                }
            } catch {
                print("error deleting item \(error)")
            }
        }
    }
    
    // MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let itemCategory = self.selectedCategory{
                do{
                    try self.realm.write(){
                        let item = Item()
                        item.title = textField.text!
                        item.dateCreated = Date()
                        itemCategory.items.append(item)
                    }
                    
                }catch{
                    print("error adding new item \(error)")
                }
            }
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New item name"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        //
    }
    
    
    // MARK: - Save and load items
    
    func loadItems() {
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

extension ToDoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath: "title", ascending: true)
        
        
        tableView.reloadData()
        
        print(searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}

