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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
}

