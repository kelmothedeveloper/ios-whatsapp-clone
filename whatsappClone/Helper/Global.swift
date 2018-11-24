//
//  Global.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 23/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import Foundation

public let cellId = "cellId"
public let headerId = "headerId"
public let footerId = "footerId"

public func delay(duration: Double, completion: @escaping () -> Void) {
    let deadline = DispatchTime.now() + duration
    DispatchQueue.main.asyncAfter(deadline: deadline, execute: completion)
}
