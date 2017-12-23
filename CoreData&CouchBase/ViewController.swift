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
    
    var database: CBLDatabase!

    
    
    //MARK: - Initialization
    func useDatabase(database: CBLDatabase!) -> Bool {
        
        guard database != nil else {return false}
        self.database = database
       
        
        database.viewNamed("byDate").setMapBlock({ (doc, emit) in
            if let date = doc["created_at"] as? String {
                emit(date, doc)
                
            }
        }, reduce: nil, version: "2")
        
        database.viewNamed("byNum").setMapBlock({ (doc, emit) in
            if let num = doc["number"] as? String {
                emit(num, doc)
            }
        }, reduce: nil, version: "2")
        
        database.viewNamed("byName").setMapBlock({ (doc, emit) in
            if let name = doc["text"] as? String {
                emit(name, doc)
            }
        }, reduce: nil, version: "2")
        
        
        
        // ...and a validation function requiring parseable dates:
        database.setValidationNamed("created_at") {
            (newRevision, context) in
            if !newRevision.isDeletion,
                let date = newRevision.properties?["created_at"] as? String
                , NSDate.withJSONObject(jsonObj: date as AnyObject) == nil {
                context.reject(withMessage: "invalid date \(date)")
            }
        }
        return true
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uniqueIDTextField.delegate = self
        self.nameTextField.delegate = self
        self.ageTextField.delegate = self
        self.searchTextField.delegate = self
        
        self.nameLabel.isHidden = true
        self.ageLabel.isHidden = true
        
        
        // Database-related initialization:
        if useDatabase(database: appDelegate.database) {
            // Create a query sorted by descending date, i.e. newest items first:
            /*let query = database.viewNamed("byDate").createQuery().asLive()
             query.descending = true
             
             // Plug the query into the CBLUITableSource, which will use it to drive the table view.
             // (The CBLUITableSource uses KVO to observe the query's .rows property.)
             self.dataSource.query = query
             //docu = self.dataSource.labelProperty = "text"
             self.dataSource.labelProperty = "number"// Document property to display in the cell label*/
            
           /* self.query = database.viewNamed("byNum").createQuery().asLive()
            self.textQuery = database.viewNamed("byName").createQuery().asLive()
            
            self.query.descending = true
            self.textQuery.descending = true
            
            guard self.query != nil else {
                return
            }
            guard self.textQuery != nil else {
                return
            }
            
            self.query.startKey = "2"
            self.query.endKey = "0"
            
            self.textQuery.startKey = "e"
            self.textQuery.endKey = "a"
            
            
            self.query?.limit = UInt(UINT32_MAX)
            // self.dataSource.query = query2
            //  self.dataSource.labelProperty = "number"
            //print(docu)
            //print(query2.rows)
            self.addNormalLiveQueryObserverAndStartObserving()
            
            self.query?.runAsync({ (enumerator, error) in
                switch error {
                case nil:
                    // 5: The "enumerator" is of type CBLQueryEnumerator and is an enumerator for the results
                    self.numberQueryEnumerator = enumerator
                    
                default:
                    //self.showAlertWithTitle(NSLocalizedString("Data Fetch Error!", comment: ""), message: error.localizedDescription)
                    print(error)
                }
            })
            
            self.textQuery?.runAsync({ (enumerator, error) in
                switch error {
                case nil:
                    self.textQueryEnumerator = enumerator
                    
                default:
                    print(error)
                }
            })*/
            
            
            
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
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        if uniqueIDTextField.text != "" && nameTextField.text != "" && ageTextField.text != "" {
            let id = uniqueIDTextField.text
            let name = nameTextField.text
            let age = ageTextField.text
            
            uniqueIDTextField.text = nil
            nameTextField.text = nil
            ageTextField.text = nil
            
            let properties: [String : AnyObject] = [
                "uniqueID": id as AnyObject,
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
                print("jyfufgv")
                //self.appDelegate.showAlert(message: "Couldn't save new item", error)
                print("this is \(error)")
            }
        }
    }
    
    
    
    
    
    var appDelegate : AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
}

