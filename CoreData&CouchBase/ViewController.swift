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

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var uniqueIDTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchButtonOutlet: UIButton!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    
    @IBOutlet weak var idLabel: UILabel!
    
    
    
    var database: CBLDatabase!
    var query: CBLQuery!
    var queryEnumerator: CBLQueryEnumerator?
    var queryRow: CBLQueryRow!
    let person = Person()

    let core = CoreDataHandler()
    var corePerson: [Persons]? = nil
    
   
    
    //MARK: - Initialization
    func useDatabase(database: CBLDatabase!) -> Bool {
        
        guard database != nil else {return false}
        self.database = database
        
        database.viewNamed("byID").setMapBlock({ (doc, emit) in
            if let id = doc["id"] as? String {
                print(id)
                emit(id, doc)
            } else {
                print(doc["id"])
            }
        }, reduce: nil, version: "7.9")
        
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
        
        
        // Database-related initialization:
        if useDatabase(database: appDelegate.database) {
            // Create a query sorted by descending date, i.e. newest items first:
            /*query = database.viewNamed("byID").createQuery().asLive()
            //query.descending = true
            guard self.query != nil else {
                return
            }
            self.query?.limit = UInt(UINT32_MAX)
            
            self.addNormalLiveQueryObserverAndStartObserving()
            
            self.query?.runAsync({ (enumerator, error) in
                switch error {
                case nil:
                    // 5: The "enumerator" is of type CBLQueryEnumerator and is an enumerator for the results
                    self.queryEnumerator = enumerator
                    
                default:
                    //self.showAlertWithTitle(NSLocalizedString("Data Fetch Error!", comment: ""), message: error.localizedDescription)
                    print(error)
                }
            })*/
            
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.cblDatabaseChange, object: database, queue: nil) {
                (notification) -> Void in
                if let changes = notification.userInfo!["changes"] as? [CBLDatabaseChange] {
                    for change in changes {
                        NSLog("Document '%@' changed.", change.documentID)
                        let document =  self.database.document(withID: change.documentID)
                        var properties = document?.properties
                        if let id = properties?["id"] as? String, let name = properties?["name"] as? String, let age = properties?["age"] as? String {
                        
                            self.person.uniqueIDs = Int(id)
                        print(self.person.uniqueIDs ?? "i")
                        self.person.names = name
                        print(self.person.names ?? "n")
                        self.person.ages = Int(age)
                        print(self.person.ages ?? "a")
                        
                        self.core.savedObjects(id: Int(self.person.uniqueIDs), name: String(self.person.names), age: Int(self.person.ages))
                        }
                    }
                }
            }
            
            
        }
    }
    
    
    func addNormalLiveQueryObserverAndStartObserving(query1: CBLLiveQuery) {
        query1.addObserver(self, forKeyPath: "rows", options: NSKeyValueObservingOptions.new, context: nil)
        
        /*do {
            try query.run()
        } catch {
            print(error)
        }*/
        
        query1.start()
    }

    /*override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rows" {
            
            self.query?.runAsync({ (enumerator, error) in
                switch error {
                case nil:
                    // 5: The "enumerator" is of type CBLQueryEnumerator and is an enumerator for the results
                    self.queryEnumerator = enumerator
                    
                default:
                    //self.showAlertWithTitle(NSLocalizedString("Data Fetch Error!", comment: ""), message: error.localizedDescription)
                    print(error)
                }
            })
        }
    }*/
    
    
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
            
            let newDocument = checkDocumentValidation(id: id!)
            if newDocument != nil {
                let documentId = newDocument.documentID
                let doc = database.document(withID: documentId)
                var propertie = doc?.properties
            
                propertie?["id"] = id as AnyObject
                propertie?["name"] = name as AnyObject
                propertie?["age"] = age as AnyObject
                propertie?["created_at"] = CBLJSON.jsonObject(with: NSDate() as Date) as AnyObject
                do {
                    try doc?.putProperties(propertie!)
                    print("Database Created")
                } catch let error as NSError {
                    
                    print("this is \(error)")
                }
                
            } else {
            
                // Save the document:
                let doc = database.createDocument()
                do {
                    try doc.putProperties(properties)
                    print("Database Created")
                } catch let error as NSError {
                    
                    print("this is \(error)")
                }
            
            }
        }
        uniqueIDTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        searchTextField.resignFirstResponder()
    }
    
    func checkDocumentValidation(id: String) -> CBLDocument {
        let query1: CBLLiveQuery!
            
         query1 = database.viewNamed("byID").createQuery().asLive()
        //query.descending = true
        //query1.startKey = id
        //query1.endKey = id
        var newQueryEnumerator: CBLQueryEnumerator!
        var queryDocument: CBLDocument!
        
        self.addNormalLiveQueryObserverAndStartObserving(query1: query1)
        
        do {
            try newQueryEnumerator = query1.run()
            print(newQueryEnumerator.count)
        
            //newQueryEnumerator.enumerated()
            if newQueryEnumerator?.count != nil {
                newQueryEnumerator.reset()
               
                let queryR = newQueryEnumerator.nextRow()
                print(queryR)
                queryDocument = queryR?.document
                print(queryDocument)
                
            }
            
        } catch  {
            print(error)
        }
    
        /*print("query")
        print(newQueryEnumerator)
        newQueryEnumerator?.reset()
        do {
            
           
            print(newQueryEnumerator?.reset())
            queryRow = newQueryEnumerator?.nextRow()
            print(queryRow)
                queryDocument = queryRow?.document
            print(queryDocument)
        }*/
        
        return queryDocument
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
            
            var loopChecker = false
            
            for i in corePerson! {
                
                if core.searchID == Int(i.id){
                    loopChecker = true
                    idLabel.isHidden = false
                    nameLabel.isHidden = false
                    ageLabel.isHidden = false
                    idLabel.text = "ID: \(String(i.id))"
                    print(i.id)
                    nameLabel.text = "Name: \(String(describing: i.name!))"
                    print((String(describing: i.name!)))
                    ageLabel.text = "Age: \(String(i.age))"
                    print((String(i.age)))
                } else {
                    if !loopChecker{
                        idLabel.isHidden = true
                        nameLabel.isHidden = true
                        ageLabel.isHidden = true
                    }
                }
            }            
        } else {
            uniqueIDTextField.text = nil
            nameTextField.text = nil
            ageTextField.text = nil
            
            self.idLabel.isHidden = true
            self.nameLabel.isHidden = true
            self.ageLabel.isHidden = true
        }
        searchTextField.resignFirstResponder()
    }
    
    
    var appDelegate : AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
}

