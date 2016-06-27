//
//  ViewController.swift
//  frustratingpieceofshit
//
//  Created by Christopher Katnic on 7/30/15.
//  Copyright (c) 2015 Christopher Katnic. All rights reserved.
//

import UIKit
import Foundation
import CloudKit

class ViewController: UIViewController {

    
    // Definitions for labels
    @IBOutlet weak var nutwoodLabel: UILabel!
    @IBOutlet weak var stateCollegeLabel: UILabel!
    @IBOutlet weak var eastsideLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var structureSelector: UISegmentedControl!
    @IBOutlet weak var predictiveStructureSelector: UISegmentedControl!
    @IBOutlet weak var saveEntryButton: UIButton!
    @IBOutlet weak var predictButton: UIButton!
    
    
    // Hardcoded urls
    let url = NSURL(string: "https://parking.fullerton.edu/parkinglotcounts/mobile.aspx")
    let nutwoodString: String = "<span id=\"gvAvailability_ctl02_Label4\">"
    let stateCollegeString = "<span id=\"gvAvailability_ctl03_Label4\">"
    let eastsideString = "<span id=\"gvAvailability_ctl04_Label4\">"
    let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
    
    
    var timer = NSTimer()
    var timerCounterSeconds : Int = 0
    var timerCounterMinutes : Int = 0
    let date = NSDate()
    let dateFormatter = NSDateFormatter()
    let dayFormatter = NSDateFormatter()
    let timeFormatter = NSDateFormatter()
    var keyString : String?
    var parkTime : String?
    var records: [CKRecord] = [CKRecord]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveEntryButton.enabled = false
        predictButton.enabled = false
        // date and time will be distinct values
        dateFormatter.dateFormat = "MMM dd"
        dayFormatter.dateFormat = "EEEE"
        timeFormatter.dateFormat = "HHmm"
        
        print("Today is \(dayFormatter.stringFromDate(date)) \(dateFormatter.stringFromDate(date))")
        
        // get previous values in case prediction is chosen
        populateList()
        
        // get data from website corresponding to open spaces
        getUpdatedValues()
        
        //test()
        //testRetrieval()
        //testWeekdayRetrieval()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // fetches data from the web and parses through html and gets the desired values
    func getUpdatedValues() {
        
        var error: NSError?
        let html: NSString?
        do {
            html = try NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding)
        } catch let error1 as NSError {
            error = error1
            html = nil
        }
        
        for var i = 0; i < (html!.length - nutwoodString.characters.count); i++
        {
            var x = html!.substringWithRange(NSMakeRange(i, nutwoodString.characters.count))
            if x.lowercaseString == nutwoodString.lowercaseString{
                print("Found nutwood: ", appendNewline: false)
                let numspots = html!.substringWithRange(NSMakeRange((i+nutwoodString.characters.count), 4))
                print(numspots.extractNumbers())
                nutwoodLabel.text = numspots.extractNumbers()
            }
            if x.lowercaseString == eastsideString.lowercaseString{
                print("Found eastside: ", appendNewline: false)
                let numspots = html!.substringWithRange(NSMakeRange((i+nutwoodString.characters.count), 4))
                print(numspots.extractNumbers())
                eastsideLabel.text = numspots.extractNumbers()
            }
            if x.lowercaseString == stateCollegeString.lowercaseString{
                print("Found stateCollege: ", appendNewline: false)
                let numspots = html!.substringWithRange(NSMakeRange((i+nutwoodString.characters.count), 4))
                print(numspots.extractNumbers())
                stateCollegeLabel.text = numspots.extractNumbers()
            }
            
        }
    }

    
    @IBAction func startTimer(sender: AnyObject) {
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: ("updateTimer"), userInfo: nil, repeats: true)
        
        saveEntryButton.enabled = false
    
    }
    
    

    @IBAction func endtimer(sender: AnyObject) {

        timer.invalidate()
        saveEntryButton.enabled = true
        
        
        print(String(format: "Timer stopped at %02d:%02d on ", timerCounterMinutes, timerCounterSeconds), appendNewline: false)
        print(dateFormatter.stringFromDate(date), appendNewline: false)
        print(" at ", appendNewline: false)
        print(timeFormatter.stringFromDate(date))
        
        // key in db will be date, value will be minutes/seconds
        parkTime = (String(format: "%02d:%02d", timerCounterMinutes, timerCounterSeconds))

    }
    
    func updateTimer() {
        
        ++timerCounterSeconds
        if timerCounterSeconds == 60 {
            
            timerCounterSeconds = 0
            ++timerCounterMinutes
            
        }
        
        timerLabel.text = String(format: "%02d:%02d %@", arguments: [timerCounterMinutes, timerCounterSeconds, (structureSelector.titleForSegmentAtIndex(structureSelector.selectedSegmentIndex)!)])
        
    }
    
    @IBAction func clearTimer(sender: AnyObject) {
        
        // just in case the timer wasn't already invalidated...
        timer.invalidate()
        timerCounterMinutes = 0
        timerCounterSeconds = 0
        timerLabel.text = "00:00 \(structureSelector.titleForSegmentAtIndex(structureSelector.selectedSegmentIndex)!)"
        
        saveEntryButton.enabled = false
        
    }
    
    
    @IBAction func saveEntry(sender: AnyObject) {
        
        saveData()
        
    }
    
    // save new or modify existing data
    func saveData() {
        
        // turn off save entry button for duration of saveData
        saveEntryButton.enabled = false
        
        let structureIdentifier: String = self.structureSelector.titleForSegmentAtIndex(self.structureSelector.selectedSegmentIndex)!
        
        // initialize new record, then fill in key:value pairs
        let newRecord = CKRecord(recordType: "parkingData")
        newRecord.setObject(dateFormatter.stringFromDate(date), forKey: "date")
        newRecord.setObject(dayFormatter.stringFromDate(date), forKey: "day")
        newRecord.setObject(timeFormatter.stringFromDate(date), forKey: "time")
        newRecord.setObject(structureIdentifier, forKey: "structure")
        newRecord.setObject(parkTime!, forKey: "parkTime")
        
        // this is what we're going to query to see if a similar record exists
        var predicate = NSPredicate(format: "date = %@ AND day = %@ AND time = %@ AND structure = %@", argumentArray: [dateFormatter.stringFromDate(date), dayFormatter.stringFromDate(date), timeFormatter.stringFromDate(date), structureIdentifier])
        
        
        // create query based on predicate above
        var query = CKQuery(recordType: "parkingData", predicate: predicate)
    
        // check to see if there exists a record that matches the predicate. If there is, modify. If not, add new record
        publicDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { results, error in
            if error != nil {
                print("Error querying database: \(error!.description)")
            } else {
                if results!.count > 0 {
                    
                    // there exists a record with the same Date and weekday, append new time
                    let record = results!.first as! CKRecord
                    print(String(format: "Found preexisting item: %@ %@ %@ %@", record.valueForKey("date") as! String ,record.valueForKey("day") as! String , record.valueForKey("time") as! String, structureIdentifier ))
                    
                    
                    var pTimes: String = record.valueForKey("parkTime") as! String
                    pTimes += String(format: ",%@", self.parkTime!)
                    record.setObject(pTimes, forKey: "parkTime")
                    
                    // save back into database with updated value
                    self.publicDatabase.saveRecord(record, completionHandler: { savedRecord, saveError in
                        if saveError != nil {
                            print("Save error: \(saveError.description)")
                        } else {
                            print("Successfully updated record!")
                        }
                    })
                }
                if results!.count == 0 {
                    // there exists no records that match the query
                    self.publicDatabase.saveRecord(newRecord, completionHandler: { savedRecord, saveError in
                        
                        if saveError != nil {
                            print("Save error: \(saveError!.description)")
                        } else {
                            print("Successfully created record!")
                        }
                    })
                }
            }
        })
        
    }
    
    @IBAction func changeSelected(sender: AnyObject) {
        
        //timerLabel.text = "\(timerCounterMinutes):\(timerCounterSeconds) \(sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!)"
        
        timerLabel.text = String(format: "%02d:%02d %@", arguments: [timerCounterMinutes, timerCounterSeconds, (sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!)])
    }
    

    
    @IBAction func predictiveParkingStructureChanged(sender: AnyObject) {
        populateList()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //stuff
        // the new view controller is going to need the date and parking structure
        //we know where we're going
        
        predictButton.enabled = false
        if let dvc = segue.destinationViewController as? PredictiveParkingViewController{
            dvc.structure = predictiveStructureSelector.titleForSegmentAtIndex(predictiveStructureSelector.selectedSegmentIndex)!
            dvc.date = dateFormatter.stringFromDate(date)
            dvc.day = dayFormatter.stringFromDate(date)
            if records.isEmpty == false {
                dvc.records = records
            } else {
                dvc.records = nil
            }
            
        }
    }
    
    // function to create the CKRecord array being passed
    func populateList() {
        // perform query, saving information to [CKRecord]
        records.removeAll()
        
        var weekdayPredicate = NSPredicate(format: "day = %@ AND structure = %@", argumentArray: [dayFormatter.stringFromDate(date), predictiveStructureSelector.titleForSegmentAtIndex(predictiveStructureSelector.selectedSegmentIndex)!])
        var weekdayQuery = CKQuery(recordType: "parkingData", predicate: weekdayPredicate)
        
        publicDatabase.performQuery(weekdayQuery, inZoneWithID: nil, completionHandler: { results, error in
            if error != nil {
                print("Error querying database: \(error!.description)")
            }
            else {
                if results!.count > 0 {
                    print("Discovered \(results!.count) records...")
                    for record in results {
                        self.records.append(record as! CKRecord)
                    }}
                else {
                    print("No error, no results")
                    self.records.removeAll(keepCapacity: false)
                }
            
                self.predictButton.enabled = true
            }
            
            
        })

    }
    
    
    @IBAction func noDataPredict(sender: AnyObject) {
        if records.isEmpty {
            self.performSegueWithIdentifier("NoDataSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("DataSegue", sender: self)
        }
    }

    func test() {
            publicDatabase.fetchRecordWithID(CKRecordID(recordName: "Aug180746"), completionHandler: { fetchedData, error in
                if error != nil{
                    print("Error fetching existing data: Aug180746 \(error!.localizedDescription)")
                } else {
                    print(fetchedData.valueForKey("Aug180746")!)
                    print("Changing value by appending new value 99:99")
                    
                    // get existing times and append new time to end of value
                    var times: String = fetchedData.valueForKey("Aug180746")! as! String
                    times += ",99:99"
                    
                    fetchedData.setObject(times, forKey: "Aug180746")
                    self.publicDatabase.saveRecord(fetchedData, completionHandler: { savedRecord, saveError in
                        if saveError != nil {
                            print("Error saving record: \(savedRecord.description)\nSave Error: \(saveError.localizedDescription)")
                        } else {
                            print("Update complete! Check iCloud for data")
                        }})
                    
                }
            })
    }
    
    
    func testRetrieval() {
        publicDatabase.fetchRecordWithID(CKRecordID(recordName: "Aug18State College"), completionHandler: { fetchedData, error in
            if error != nil{
                print("Error fetching existing data: Aug180746 \(error.localizedDescription)")
            } else {
                print("Retrieving values...")
                print(fetchedData.valueForKey("parkingTime")!)
                
                // take min:sec values and store into array
                let values: String = fetchedData.valueForKey("parkingTime") as! String
                let vArray = values.componentsSeparatedByString(",")
                
                print("Found \(vArray.count) elements")
                var total: Int = 0
                
                // convert minutes to seconds by getting the first two digits and multiplying by 60
                // then add it to the last two digits
                for item in vArray {
                    
                    let numbers : [String] = item.componentsSeparatedByString(":")
                    total += Int(numbers[0])! * 60
                    total += Int(numbers[1])!
                }
                
                // calculate gross average, and then convert data into minutes+ remainder seconds
                // set in format mm:ss
                var average = total / vArray.count
                var averageMinutes: Int = average / 60
                var averageSeconds: Int = average - averageMinutes * 60
                print("Total number of seconds: \(total)")
                print(String(format: "Average number of seconds: %d\nAverage minutes:seconds to park: %02d:%02d", average, averageMinutes, averageSeconds), appendNewline: false)
                
                
            }
        })
    }
    
    
    func testWeekdayRetrieval() {
        
        //hopefully this Predicate will retrieve a ton of data
        var weekdayPredicate = NSPredicate(format: "day = %@", argumentArray: [dayFormatter.stringFromDate(date)])
        var weekdayQuery = CKQuery(recordType: "parkingData", predicate: weekdayPredicate)
        
        publicDatabase.performQuery(weekdayQuery, inZoneWithID: nil, completionHandler: { results, error in
            if error != nil {
                print("Error querying database: \(error.description)")
            }
            else {
                if results.count > 0 {
                    print("Records existing for \(self.dayFormatter.stringFromDate(self.date))")
                    for record in results {
                        print(String(format: "%@ %@ : %@", self.dateFormatter.stringFromDate(self.date), self.timeFormatter.stringFromDate(self.date), record.valueForKey("parkTime") as! String))
                    }}
                else {
                    print("No error, no results")
                }
            }
        
        
        })
    }
    
    
}

