//
//  Enums.swift
//  Fencing
//
//  Created by Ben K on 7/10/21.
//

import Foundation
import SwiftUI

enum BracketItemType: Int16 {
    case bye = 0
    case single = 1
    case multi = 2
}

enum ToolbarItemType: Int, Codable, Identifiable, CaseIterable, Hashable {
    case blank = 0
    case leftArrow = 1
    case rightArrow = 2
    case scrollToItem = 3
    case editScore = 4
    
    var id: Int { rawValue }
    
    var info: (image: String, description: String) {
        switch self {
        
        case .blank:
            return ("square.dashed", "Blank")
        case .leftArrow:
            return ("arrow.left", "Left one bout")
        case .rightArrow:
            return ("arrow.right", "Right one bout")
        case .scrollToItem:
            return ("arrow.down.to.line", "Scroll to current bout")
        case .editScore:
            return ("square.and.pencil", "Edit bout score")
        
        }
    }
    
    var label: some View {
        return Label("\(self.info.description)", systemImage: "\(self.info.image)")
    }
    
    func button(action: @escaping () -> Void) -> some View {
        return Button(action: action, label: {
            self.label
        })
    }
}

let defaultToolbar: [ToolbarItemType] = [.scrollToItem, .leftArrow, .rightArrow, .editScore, .blank, .blank, .blank, .blank]
let defaultToolbarSize = 4
