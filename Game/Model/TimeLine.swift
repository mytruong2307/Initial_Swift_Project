//
//  TimeLine.swift
//  VAC Agent
//
//  Created by Mytruong on 5/23/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import UIKit

struct TimeLine {
    var isFirst:Bool //isFirst = true -> dau
    var isLast:Bool
    var time:String
    var subject:String
    var detail:String
    var color:UIColor
    var beforeColor:UIColor?
    
    init(time:String, subject:String, detail:String, color:UIColor, beforeColor:UIColor?, isFirst:Bool, isLast:Bool) {
        self.time = time
        self.subject = subject
        self.detail = detail
        self.color = color
        self.beforeColor = beforeColor
        self.isLast = isLast
        self.isFirst = isFirst
    }
}
