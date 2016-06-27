//
//  GlanceController.swift
//  frustratingpieceofshit WatchKit Extension
//
//  Created by Christopher Katnic on 7/30/15.
//  Copyright (c) 2015 Christopher Katnic. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    //two labels that change
    @IBOutlet weak var footer: WKInterfaceLabel!
    @IBOutlet weak var mainLabel: WKInterfaceLabel!
    
    // Hardcoded urls
    let url = NSURL(string: "https://parking.fullerton.edu/parkinglotcounts/mobile.aspx")
    let nutwoodString: String = "<span id=\"gvAvailability_ctl02_Label4\">"
    let stateCollegeString = "<span id=\"gvAvailability_ctl03_Label4\">"
    let eastsideString = "<span id=\"gvAvailability_ctl04_Label4\">"
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        getUpdatedValues()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        getUpdatedValues()
        
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //adapted from previous sample in ViewController.swift
    func getUpdatedValues() {
        
        var error: NSError?
        let html: NSString?
        do {
            html = try NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding)
        } catch let error1 as NSError {
            error = error1
            html = nil
        }
        
        var nutwoodSpots : String?
        var eastsideSpots : String?
        var stateCollegeSpots : String?
        
        for var i = 0; i < (html!.length - nutwoodString.characters.count); i++
        {
            var x = html!.substringWithRange(NSMakeRange(i, nutwoodString.characters.count))
            if x.lowercaseString == nutwoodString.lowercaseString{
                print("Found nutwood")
                let numspots = html!.substringWithRange(NSMakeRange((i+nutwoodString.characters.count), 4))
                print(numspots)
                nutwoodSpots = numspots.extractNumbers()
            }
            if x.lowercaseString == eastsideString.lowercaseString{
                print("Found eastside")
                let numspots = html!.substringWithRange(NSMakeRange((i+nutwoodString.characters.count), 4))
                print(numspots)
                eastsideSpots = numspots.extractNumbers()
            }
            if x.lowercaseString == stateCollegeString.lowercaseString{
                print("Found stateCollege")
                let numspots = html!.substringWithRange(NSMakeRange((i+nutwoodString.characters.count), 4))
                print(numspots)//.extractNumbers())
                stateCollegeSpots = numspots.extractNumbers()
            }
            
        }
        

        mainLabel.setText("Nutwood: \(nutwoodSpots!)\nEast Side: \(eastsideSpots!)\nState College: \(stateCollegeSpots!)")
        
    }

}
