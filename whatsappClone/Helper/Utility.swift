//
//  Utility.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 27/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit

struct Utility {
    
    static func isIpad() -> Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }
    
}
