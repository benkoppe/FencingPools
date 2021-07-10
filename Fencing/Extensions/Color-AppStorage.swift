//
//  Color-AppStorage.swift
//  Fencing
//
//  Created by Ben K on 7/6/21.
//

import Foundation
import SwiftUI

extension Color: RawRepresentable {
    // TODO: Sort out alpha
    public init?(rawValue: Int) {
        let red =   Double((rawValue & 0xFF0000) >> 16) / 0xFF
        let green = Double((rawValue & 0x00FF00) >> 8) / 0xFF
        let blue =  Double(rawValue & 0x0000FF) / 0xFF
        self = Color(red: red, green: green, blue: blue)
    }

    public var rawValue: Int {
        let red = Int(coreImageColor.red * 255 + 0.5)
        let green = Int(coreImageColor.green * 255 + 0.5)
        let blue = Int(coreImageColor.blue * 255 + 0.5)
        return (red << 16) | (green << 8) | blue
    }

    private var coreImageColor: CIColor {
        return CIColor(color: UIColor(self))
    }
}
