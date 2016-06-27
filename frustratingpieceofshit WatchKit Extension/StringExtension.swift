//
//  StringExtension.swift
//  frustratingpieceofshit
//
//  Created by Christopher Katnic on 8/14/15.
//  Copyright (c) 2015 Christopher Katnic. All rights reserved.
//

import Foundation
extension String{

    func extractNumbers() -> String {
        
        //assign list of all digits to "digits"
        var returnString : String = ""
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        
        //compare letter against all numbers
        for temp in self.unicodeScalars   {
            if digits.longCharacterIsMember(temp.value){
                returnString.append(temp)
            }
        }
   
        return returnString
    }
    
}
