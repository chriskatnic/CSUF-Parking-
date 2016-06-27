//
//  PredictiveParkingViewController.swift
//  frustratingpieceofshit
//
//  Created by Christopher Katnic on 8/18/15.
//  Copyright (c) 2015 Christopher Katnic. All rights reserved.
//

import UIKit
import Foundation
import CloudKit

class PredictiveParkingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var predictiveParkingEntryMessage: UILabel!
    @IBOutlet weak var predictiveParkingTable: UITableView!
    
    var structure: String?
    var date: String?
    var day: String?
    var records: [CKRecord]?
    var totalSeconds: Int = 0
    var uglyCounter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        predictiveParkingTable.dataSource = self
        predictiveParkingTable.delegate  = self
        
        if records != nil {
            print("Recieved \(records!.count) records")
        } else {
            print("Recieved no records!")
        }
        
        updateLabel()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabel() {
        let message : String = String(format: "Your selected parking structure was %@. Below you will find the average parking times every hour on %@s at %@", structure!, day!, structure!)
    
        predictiveParkingEntryMessage.text = message
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if records != nil {
            return records!.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            return insertAverageCell()
        }
        else {let r: CKRecord = records?[indexPath.row - 1] as CKRecord!
        
        
        // collect total seconds for all values, the number of values can be changed later
        
        
        let cell = UITableViewCell()
        let label = UILabel(frame: CGRectMake(0, 0, 200, 50))
        label.text = String(format: "%@ %@ : %@", r.valueForKey("date") as! String, r.valueForKey("time") as! String, r.valueForKey("parkTime") as! String)
        label.sizeToFit()
        cell.addSubview(label)
            return cell}
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func insertAverageCell() -> UITableViewCell {
        let cell = UITableViewCell()
        let label = UILabel(frame: CGRectMake(0, 0, 200, 50))
        var c: Int = 0
        
        // calculate totals, do math
        for r in records!{
        let values = (r.valueForKey("parkTime") as! String)
        let minutesSeconds = values.componentsSeparatedByString(",")
        for item in minutesSeconds {
            var numbers: [String] = item.componentsSeparatedByString(":")
            totalSeconds += Int(numbers[0]) * 60
            totalSeconds += Int(numbers[1])
            c++ // ;)
            }}
        
        totalSeconds /= c
        
        let formattedAverage = String(format: "%.02d:%.02d", (totalSeconds / 60), (totalSeconds - ((totalSeconds / 60) * 60)))
        
        label.text = String(format: "Average park time on %@s: %@", day!, formattedAverage )
        label.sizeToFit()
        cell.addSubview(label)
        return cell
    }

}