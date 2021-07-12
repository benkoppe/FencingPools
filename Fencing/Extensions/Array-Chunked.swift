//
//  Array-Chunked.swift
//  Fencing
//
//  Created by Ben K on 7/10/21.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
