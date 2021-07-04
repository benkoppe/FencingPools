//
//  GridInfo.swift
//  Fencing
//
//  Created by Ben K on 7/4/21.
//

import Foundation
import SwiftUI

struct GridInfoPreference {
    let id: Int
    let bounds: Anchor<CGRect>
}

struct GridPreferenceKey: PreferenceKey {
    static var defaultValue: [GridInfoPreference] = []
    
    static func reduce(value: inout [GridInfoPreference], nextValue: () -> [GridInfoPreference]) {
        return value.append(contentsOf: nextValue())
    }
}

extension View {
    func gridInfoId(_ id: Int) -> some View {
        self.anchorPreference(key: GridPreferenceKey.self, value: .bounds) {
                [GridInfoPreference(id: id, bounds: $0)]
            }
    }
    
    func gridInfo(_ info: Binding<GridInfo>) -> some View {
        self.backgroundPreferenceValue(GridPreferenceKey.self) { prefs in
            GeometryReader { proxy -> Color in
                DispatchQueue.main.async {
                    info.wrappedValue.cells = prefs.compactMap {
                      GridInfo.Item(id: $0.id, bounds: proxy[$0.bounds])
                    }
                }
                    
                return Color.clear
            }
        }
    }
}

struct GridInfo: Equatable {
    // A array of all rendered cells's bounds
    var cells: [Item] = []
    
    // a computed property that returns the number of columns
    var columnCount: Int {
        guard cells.count > 1 else { return cells.count }

        var k = 1

        for i in 1..<cells.count {
            if cells[i].bounds.origin.x > cells[i-1].bounds.origin.x {
                k += 1
            } else {
                break
            }
        }

        return k
    }
    
    // a computed property that returns the range of cells being rendered
    var cellRange: ClosedRange<Int>? {
        guard let lower = cells.first?.id, let upper = cells.last?.id else { return nil }
        
        return lower...upper
    }
  
    // returns the width of a rendered cell
    func cellWidth(_ id: Int) -> CGFloat {
        columnCount > 0 ? columnWidth(id % columnCount) : 0
    }
    
    // returns the width of a column
    func columnWidth(_ col: Int) -> CGFloat {
        columnCount > 0 && col < columnCount ? cells[col].bounds.width : 0
    }
    
    // returns the spacing between columns col and col+1
    func spacing(_ col: Int) -> CGFloat {
        guard columnCount > 0 else { return 0 }
        let left = col < columnCount ? cells[col].bounds.maxX : 0
        let right = col+1 < columnCount ? cells[col+1].bounds.minX : left
        
        return right - left
    }
    
    func cellHeight(_ id: Int) -> CGFloat {
        columnCount > 0 ? columnHeight(id % columnCount) : 0
    }
    
    func columnHeight(_ col: Int) -> CGFloat {
        columnCount > 0 && col < columnCount ? cells[col].bounds.height : 0
    }

    // Do not forget the "Equatable", as it prevent redrawing loops
    struct Item: Equatable {
        let id: Int
        let bounds: CGRect
    }
}
