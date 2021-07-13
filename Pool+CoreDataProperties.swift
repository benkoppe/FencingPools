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
    @NSManaged public var defaultName: String?
    @NSManaged public var date: String?
    @NSManaged public var dDate: Date?
    @NSManaged public var url: String?
    @NSManaged public var strip: String?
    @NSManaged public var trackName: String?
    @NSManaged public var bouts: NSOrderedSet?
    @NSManaged public var fencers: NSOrderedSet?
    @NSManaged public var id: Int16
    @NSManaged public var currentBout: Int16
    
    @NSManaged public var uuid: UUID?
    
    @NSManaged public var deleteItem: Bool
    
    public var uName: String {
        return name ?? ""
    }
    
    public var uDefaultName: String {
        return defaultName ?? ""
    }
    
    public var uDate: String {
        return date ?? ""
    }
    
    public var uUrl: String {
        return url ?? ""
    }
    
    public var uStrip: String {
        return strip ?? ""
    }
    
    public var uTrackName: String {
        return trackName ?? ""
    }
    
    public var uCurrentBout: Int {
        return Int(currentBout)
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
    func getTracked() -> Fencer? {
        return self.getFencer(name: uTrackName)
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
    
    func hasWon(fencer: Fencer, opponent: Fencer) -> Bool {
        if let bout = getBout(fencer: fencer, opponent: opponent) {
            return bout.getScore(for: fencer) > bout.getScore(for: opponent)
        } else {
            return false
        }
    }
    
    func hasWon(fencer: Int, opponent: Int) -> Bool {
        guard let f = self.getFencer(number: fencer) else { return false }
        guard let o = self.getFencer(number: opponent) else { return false }
        return hasWon(fencer: f, opponent: o)
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
    
    func isBoutScored(fencer: Int, opponent: Int) -> Bool {
        guard let f = self.getFencer(number: fencer) else { return false }
        guard let o = self.getFencer(number: opponent) else { return false }
        if let bout = getBout(fencer: f, opponent: o) {
            return bout.hasScore
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
    
    func isBoutTracked(bout: Bout) -> Bool {
        if bout.uLeft.uName == uTrackName || bout.uRight.uName == uTrackName {
            return true
        } else {
            return false
        }
    }
    
    func getCurrentBout() -> Bout {
        if Int(currentBout) == uBouts.count {
            let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            return uBouts.last ?? Bout(context: moc)
        } else {
            return uBouts[Int(currentBout)]
        }
    }
    func setCurrentBout(_ to: Int) {
        currentBout = Int16(to)
    }
    func isTableComplete() -> Bool {
        return Int(currentBout) == uBouts.count
    }
    
    func isNameDefault() -> Bool {
        return uDefaultName == uName
    }
    
    func deleteFencer(fencer: Fencer) {
        var fencerArr = uFencers
        for index in 0..<fencerArr.count {
            if fencerArr[index] == fencer {
                fencerArr.remove(at: index)
            }
        }
        
        var boutArr = uBouts
        for index in 0..<boutArr.count {
            if boutArr[index].isFencerIn(fencer) {
                boutArr.remove(at: index)
            }
        }
        
        fencers = NSOrderedSet(array: fencerArr)
        bouts = NSOrderedSet(array: boutArr)
    }
}

extension Pool {
    func setDate(date: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy h:mm a"
        dDate = formatter.date(from: uDate) ?? Date()
    }
}

extension Pool {
    convenience init(fencers: [String], bouts: [String], name: String, date: String, number: Int, strip: String, url: String, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.name = name
        self.defaultName = name
        self.date = date
        self.setDate(date: date)
        self.strip = strip
        self.url = url
        self.id = Int16(number)
        
        self.uuid = UUID()
        
        self.deleteItem = false
        
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
        self.defaultName = name
        self.date = "December 1, 2020"
        self.setDate(date: date ?? "")
        self.id = Int16(1)
        self.deleteItem = false
        
        self.bouts = NSOrderedSet(array: [Bout(number: 0, context: context), Bout(number: 1, context: context), Bout(number: 2, context: context)])
    }
    
    convenience init(deletePool: Pool) {
        self.init(entity: Pool.entity(), insertInto: nil)
        
        self.name = deletePool.name
        self.fencers = deletePool.fencers
        self.bouts = deletePool.bouts
        self.currentBout = deletePool.currentBout
    }
}
