//
//  FormatScore.swift
//  Fencing
//
//  Created by Ben K on 7/3/21.
//

import Foundation

func formatScore(yourScore: Int, otherScore: Int) -> String {
    if yourScore > otherScore {
        return "V\(yourScore)"
    } else if yourScore < otherScore {
        return "L\(yourScore)"
    } else {
        return ("T")
    }
}
