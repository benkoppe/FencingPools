//
//  Bout+CoreDataProperties.swift
//  Fencing
//
//  Created by Ben K on 7/3/21.
//
//

import Foundation
import CoreData


extension Bout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bout> {
        return NSFetchRequest<Bout>(entityName: "Bout")
    }

    @NSManaged public var left: Fencer?
    @NSManaged public var right: Fencer?
    @NSManaged public var number: Int16
    @NSManaged public var pool: Pool?
    
    @NSManaged public var isCompleted: Bool
    @NSManaged public var hasScore: Bool
    @NSManaged public var leftScore: Int16
    @NSManaged public var rightScore: Int16
    
    public var uLeft: Fencer {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        return left ?? Fencer(context: moc)
    }
    
    public var uRight: Fencer {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        return right ?? Fencer(context: moc)
    }
    
    public var num: Int {
        return Int(number)
    }
    
    public var uLeftScore: Int {
        return Int(leftScore)
    }
    
    public var uRightScore: Int {
        return Int(rightScore)
    }

}

extension Bout : Identifiable {

}

extension Bout {
    func isFencerIn(_ fencer: Fencer) -> Bool {
        if fencer == uLeft || fencer == uRight {
            return true
        } else {
            return false
        }
    }
    
    func getOpponent(_ fencer: Fencer) -> Fencer? {
        if fencer == uLeft {
            return uRight
        } else if fencer == uRight {
            return uLeft
        } else {
            return nil
        }
    }
    
    func getScore(for fencer: Fencer) -> Int {
        if fencer == uLeft {
            return uLeftScore
        } else if fencer == uRight {
            return uRightScore
        } else {
            return -1
        }
    }
    
    func setScore(for fencer: Fencer, score: Int) {
        if fencer == uLeft {
            leftScore = Int16(score)
        } else if fencer == uRight {
            rightScore = Int16(score)
        }
    }
    
    
}

extension Bout {
    convenience init(right: Fencer, left: Fencer, number: Int, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.right = right
        self.left = left
        self.number = Int16(number)
    }
    
    convenience init(number: Int, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.number = Int16(number)
    }
}
