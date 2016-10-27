//
//  global.swift
//  Smart ParkJMU
//
//  Created by Riley Sung on 1/24/16.
//  Copyright © 2016 Riley Sung. All rights reserved.
//

import Foundation


// Global variable, accessible from all view controllers.
class Global {
    var loggedIn: Bool
    init(loggedIn:Bool) {
        self.loggedIn = false
    }
}
var globalVar = Global(loggedIn: false)