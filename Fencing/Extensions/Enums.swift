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
    
    var info: (image: String, description: String, extendedDescription: String) {
        switch self {
        
        case .blank:
            return ("square.dashed", "Blank", "A blank space in the toolbar.")
        case .leftArrow:
            return ("arrow.left", "Left one bout", "Move backwards one bout, hold to jump to start.")
        case .rightArrow:
            return ("arrow.right", "Right one bout", "Move forwards one bout, hold to jump to end.")
        case .scrollToItem:
            return ("arrow.down.to.line", "Scroll to current bout", "Scroll directly to the current bout.")
        case .editScore:
            return ("square.and.pencil", "Edit bout score", "Edit the score for bouts with the tracked fencer.")
        
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

let defaultToolbar: [ToolbarItemType] = [.leftArrow, .rightArrow, .scrollToItem, .editScore, .blank, .blank, .blank, .blank]
let defaultToolbarSize = 4

enum colorScheme: Int, Codable, Identifiable, CaseIterable, Hashable {
    case system = 0
    case dark = 1
    case light = 2
    
    var id: Int { rawValue }
    
    func getActualScheme() -> Optional<ColorScheme> {
        switch self {
        case .system:
            return .none
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
}
