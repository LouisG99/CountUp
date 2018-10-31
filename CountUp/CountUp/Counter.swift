//
//  Counter.swift
//  CountUp
//
//  Created by Louis Gouirand on 9/13/18.
//  Copyright © 2018 Louis Gouirand. All rights reserved.
//

import UIKit

class Counter {
    
    // MARK: Properties
    var name: String
    var value: Int
    var increment: Int
    
    // MARK: Initialization
    init(name: String, value: Int, increment: Int){
        self.name = name
        self.value = value
        self.increment = increment
    }
}
