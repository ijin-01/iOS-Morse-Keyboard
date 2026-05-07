//
//  UserDefaults.swift
//  morse keyboard
//
//  Created by 이종현 on 5/6/26.
//

import SwiftUI

extension UserDefaults {
    static var shared: UserDefaults {
        let combined = UserDefaults(suiteName: "group.com.ijin-01.morse")
        return combined ?? UserDefaults.standard
    }
}
