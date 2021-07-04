//
//  Pool+CoreDataProperties.swift
//  Fencing
//
//  Created by Ben K on 7/3/21.
//
//

import Foundation
import CoreData


extension Pool {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pool> {
        return NSFetchRequest<Pool>(entityName: "Pool")
    }

    @NSManaged public var name: String?
    @NSManaged public var date: String?
    @NSManaged public var trackName: String?
    @NSManaged public var bouts: NSOrderedSet?
    @NSManaged public var fencers: NSOrderedSet?
    @NSManaged public var id: Int16
    
    public var uName: String {
        return name ?? ""
    }
    
    public var uDate: String {
        return date ?? ""
    }
    
    public var uTrackName: String {
        return trackName ?? ""
    }
    
    public var uBouts: [Bout] {
        return bouts?.array as? [Bout] ?? []
    }
    
    public var uFencers: [Fencer] {
        return fencers?.array as? [Fencer] ?? []
    }

}

// MARK: Generated accessors for bouts
extension Pool {

    @objc(insertObject:inBoutsAtIndex:)
    @NSManaged public func insertIntoBouts(_ value: Bout, at idx: Int)

    @objc(removeObjectFromBoutsAtIndex:)
    @NSManaged public func removeFromBouts(at idx: Int)

    @objc(insertBouts:atIndexes:)
    @NSManaged public func insertIntoBouts(_ values: [Bout], at indexes: NSIndexSet)

    @objc(removeBoutsAtIndexes:)
    @NSManaged public func removeFromBouts(at indexes: NSIndexSet)

    @objc(replaceObjectInBoutsAtIndex:withObject:)
    @NSManaged public func replaceBouts(at idx: Int, with value: Bout)

    @objc(replaceBoutsAtIndexes:withBouts:)
    @NSManaged public func replaceBouts(at indexes: NSIndexSet, with values: [Bout])

    @objc(addBoutsObject:)
    @NSManaged public func addToBouts(_ value: Bout)

    @objc(removeBoutsObject:)
    @NSManaged public func removeFromBouts(_ value: Bout)

    @objc(addBouts:)
    @NSManaged public func addToBouts(_ values: NSOrderedSet)

    @objc(removeBouts:)
    @NSManaged public func removeFromBouts(_ values: NSOrderedSet)

}

extension Pool : Identifiable {

}

extension Pool {
    
    func getFencer(name: String) -> Fencer? {
        for fencer in uFencers {
            if fencer.uName == name {
                return fencer
            }
        }
        return nil
    }
    func getFencer(number: Int) -> Fencer? {
        for fencer in uFencers {
            if fencer.uNumber == number {
                return fencer
            }
        }
        return nil
    }
    func getBout(fencer: Fencer, opponent: Fencer) -> Bout? {
        for bout in uBouts {
            if bout.isFencerIn(fencer) && bout.isFencerIn(opponent) {
                return bout
            }
        }
        return nil
    }
    
    func getScore(fencer: Fencer, opponent: Fencer) -> String? {
        if let bout = getBout(fencer: fencer, opponent: opponent) {
            let score = formatScore(yourScore: bout.getScore(for: fencer), otherScore: bout.getScore(for: opponent))
            return score
        } else {
            return nil
        }
    }
    
    func getScore(fencer: Int, opponent: Int) -> String? {
        guard let f = self.getFencer(number: fencer) else { return nil }
        guard let o = self.getFencer(number: opponent) else { return nil }
        return getScore(fencer: f, opponent: o)
    }
    
    
    func isBoutComplete(fencer: Int, opponent: Int) -> Bool {
        guard let f = self.getFencer(number: fencer) else { return false }
        guard let o = self.getFencer(number: opponent) else { return false }
        if let bout = getBout(fencer: f, opponent: o) {
            return bout.isCompleted
        } else {
            return false
        }
    }
    
    func isTracked(fencer: Fencer) -> Bool {
        if fencer.uName == uTrackName {
            return true
        } else {
            return false
        }
    }
}

extension Pool {
    convenience init(fencers: [String], bouts: [String], name: String, date: String, number: Int, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.name = name
        self.date = date
        self.id = Int16(number)
        
        var fencerArray: [Fencer] = []
        
        for i in 0..<fencers.count {
            fencerArray.append(Fencer(name: fencers[i], number: i, context: context))
        }
        self.fencers = NSOrderedSet(array: fencerArray)
        
        var boutArray: [Bout] = []
        
        for i in 0..<(bouts.count/2) {
            guard let right = self.getFencer(name: bouts[i*2]) else { return }
            guard let left = self.getFencer(name: bouts[i*2+1]) else { return }
            boutArray.append(Bout(right: right, left: left, number: i, context: context))
        }
        self.bouts = NSOrderedSet(array: boutArray)
    }
    
    convenience init(name: String, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.name = name
        self.date = "December 1, 2020"
        self.id = Int16(1)
        
        self.bouts = NSOrderedSet(array: [Bout(number: 0, context: context), Bout(number: 1, context: context), Bout(number: 2, context: context)])
    }
}
