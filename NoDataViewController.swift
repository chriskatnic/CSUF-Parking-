//
//  NoDataViewController.swift
//  frustratingpieceofshit
//
//  Created by Christopher Katnic on 8/19/15.
//  Copyright (c) 2015 Christopher Katnic. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class NoDataViewController: UIViewController {
    
    
    @IBOutlet weak var selectedStructureImageView: UIImageView!
    @IBOutlet weak var selectedStructureLabel: UILabel!
    var selectedStructure: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // testing with eastside
        selectedStructure = "Eastside"
        
        
        //value will have been set before entering
        selectedStructureImageView.image = UIImage(named:selectedStructure!)
        
        //value will have been set before entering
        selectedStructureLabel.text = selectedStructure
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
}