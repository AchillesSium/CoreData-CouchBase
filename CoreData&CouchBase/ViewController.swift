//
//  ViewController.swift
//  CoreData&CouchBase
//
//  Created by MbProRetina on 23/12/17.
//  Copyright © 2017 MbProRetina. All rights reserved.
//

import UIKit
import CoreData
import CouchbaseLite

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var uniqueIDTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchButtonOutlet: UIButton!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    
    @IBOutlet weak var testTableView: UITableView!
    
    @IBOutlet weak var idLabel: UILabel!
    
    
    
    var database: CBLDatabase!
    var query: CBLQuery!
    let person = Person()
    var cell = CustomTableViewCell()
    let core = CoreDataHandler()
    var corePerson: [Persons]? = nil
    
    var docsEnumerator: CBLQueryEnumerator? {
        didSet {
            //core.cleanCoreData()
            self.testTableView.reloadData()
        }
    }
    
    
    enum datas: String {
        case uniqueID = "id"
        case name = "name"
        case age = "age"
    }
    
    
    //MARK: - Initialization
    func useDatabase(database: CBLDatabase!) -> Bool {
        
        guard database != nil else {return false}
        self.database = database
       
        database.viewNamed("byDate").setMapBlock({ (doc, emit) in
            if let ID = doc["created_at"] as? String {
                emit(ID, doc)
            }
        }, reduce: nil, version: "1.4.0")
        
        return true
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uniqueIDTextField.delegate = self
        self.nameTextField.delegate = self
        self.ageTextField.delegate = self
        self.searchTextField.delegate = self
        
        self.idLabel.isHidden = true
        self.nameLabel.isHidden = true
        self.ageLabel.isHidden = true
        
        
        self.testTableView.dataSource = self
        self.testTableView.delegate = self
        self.testTableView.isHidden = true
        
        // Database-related initialization:
        if useDatabase(database: appDelegate.database) {
            // Create a query sorted by descending date, i.e. newest items first:
           
            /*NotificationCenter.default.addObserver(forName: NSNotification.Name.cblDatabaseChange, object: database, queue: nil) {
                (notification) -> Void in
                if let changes = notification.userInfo!["changes"] as? [CBLDatabaseChange] {
                    for change in changes {
                        NSLog("Document '%@' changed.", change.documentID)
                        let document =  self.database.document(withID: change.documentID)
                        var abs = document?.properties
                        let name = abs!["name"] as? String
                        print(name ?? "")
                    }
                }
            }*/
            
            
            
            
            self.query = database.viewNamed("byDate").createQuery().asLive()
            
            self.query.descending = true
            
            guard self.query != nil else {
                return
            }
 
            //self.query?.limit = UInt(UINT32_MAX)
            
            self.addNormalLiveQueryObserverAndStartObserving()
            
            self.query?.runAsync({ (enumerator, error) in
                switch error {
                case nil:
                    
                    self.docsEnumerator = enumerator
                    
                default:
                    
                    print(error)
                }
            })
            
        }
    }

    func addNormalLiveQueryObserverAndStartObserving() {
        self.query.addObserver(self, forKeyPath: "rows", options: NSKeyValueObservingOptions.new, context: nil)
        
        do {
            try self.query.run()
        } catch {
            print(error)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.testTableView.reloadData()
    }

    @IBAction func saveButtonAction(_ sender: Any) {
        
        if uniqueIDTextField.text != "" && nameTextField.text != "" && ageTextField.text != "" {
            let id = uniqueIDTextField.text
            let name = nameTextField.text
            let age = ageTextField.text
            
            uniqueIDTextField.text = nil
            nameTextField.text = nil
            ageTextField.text = nil
            
            let properties: [String : AnyObject] = [
                "id": id as AnyObject,
                "name": name as AnyObject,
                "age": age as AnyObject,
                "created_at": CBLJSON.jsonObject(with: NSDate() as Date) as AnyObject
            ]
            
            // Save the document:
            let doc = database.createDocument()
            do {
                try doc.putProperties(properties)
                print("Database Created")
            } catch let error as NSError {
              
                print("this is \(error)")
            }
            
            
        }
        uniqueIDTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        searchTextField.resignFirstResponder()
        self.testTableView.reloadData()
    }
    
    //Table view to retrive datas
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Int(self.docsEnumerator?.count ?? 0))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        
        print("this is number of row \(String(describing: self.docsEnumerator?.count))")
            cell.label?.text = ""
            self.dataRetriveFromCouchBase(index: indexPath.row)
        return cell
    }
    
    
    func dataRetriveFromCouchBase(index: Int){
        if let queryRow = self.docsEnumerator?.row(at: UInt(index)) {
            if let userProps = queryRow.document?.userProperties, let uniqueID = userProps[datas.uniqueID.rawValue] as? String, let name = userProps[datas.name.rawValue] as? String, let age = userProps[datas.age.rawValue] as? String {
                
                person.uniqueIDs = Int(uniqueID)
                print("This is ID = \(person.uniqueIDs)")
                person.names = name
                print("This is name = \(person.names)")
                person.ages = Int(age)
                print("This is age = \(person.ages)")
                
                core.savedObjects(id: Int(person.uniqueIDs), name: String(person.names), age: Int(person.ages))
                
            }
        }
    }
    
    
    public func addChangeListener(_ block: @escaping (CBLDatabaseChange) -> Void) -> NSObjectProtocol {
        print("Change Listener")
        
        return "" as NSObjectProtocol
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rows" {
            self.query?.runAsync({ (enumerator, error) in
                switch error {
                case nil:
                    self.docsEnumerator = enumerator
                    
                default:
                    
                    print(error)
                }
            })
            
            
            //core.cleanCoreData()
            self.testTableView.reloadData()
        }
    }
    
    //TextField Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        uniqueIDTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        searchTextField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        if uniqueIDTextField.text == "" {
            return
        }
        if nameTextField.text == "" {
            return
        }
        
        if ageTextField.text == "" {
            return
        }
        
        
        return
    }
    
    
    
    @IBAction func searchAction(_ sender: Any) {
        if searchTextField.text != "" {
            let searchedText = Int(searchTextField.text!)
            core.searchID = searchedText
            
            searchTextField.text = nil
            
            corePerson = core.filterData()
            
            for i in corePerson! {
                idLabel.isHidden = false
                nameLabel.isHidden = false
                ageLabel.isHidden = false
                idLabel.text = "ID: \(String(i.id))"
                print(i.id)
                nameLabel.text = "Name: \(String(describing: i.name!))"
                print((String(describing: i.name!)))
                ageLabel.text = "Age: \(String(i.age))"
                print((String(i.age)))
            }
            
            if (corePerson?.count == 0) {
                idLabel.isHidden = true
                nameLabel.isHidden = true
                ageLabel.isHidden = true
            }
            
           /* corePerson = core.fetchID()
            for i in corePerson! {
                 if (searchedText == Int(i.id)) {
                    idLabel.isHidden = false
                    nameLabel.isHidden = false
                    ageLabel.isHidden = false
                    idLabel.text = "ID: \(String(i.id))"
                    print(i.id)
                    nameLabel.text = "Name: \(String(describing: i.name!))"
                    print((String(describing: i.name!)))
                    ageLabel.text = "Age: \(String(i.age))"
                    print((String(i.age)))
                 }
            }*/
        } else {
            uniqueIDTextField.text = nil
            nameTextField.text = nil
            ageTextField.text = nil
            
            self.idLabel.isHidden = true
            self.nameLabel.isHidden = true
            self.ageLabel.isHidden = true
        }
        searchTextField.resignFirstResponder()
        self.testTableView.reloadData()
    }
    
    
    var appDelegate : AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
}

