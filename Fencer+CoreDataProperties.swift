//
//  Fencer+CoreDataProperties.swift
//  Fencing
//
//  Created by Ben K on 7/3/21.
//
//

import Foundation
import CoreData


extension Fencer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Fencer> {
        return NSFetchRequest<Fencer>(entityName: "Fencer")
    }

    @NSManaged public var name: String?
    @NSManaged public var number: Int16
    @NSManaged public var assignedPool: Pool?
    @NSManaged public var leftBouts: NSSet?
    @NSManaged public var rightBouts: NSSet?
    
    public var uName: String {
        return name ?? ""
    }
    
    public var uNumber: Int {
        return Int(number)
    }

}

// MARK: Generated accessors for leftBouts
extension Fencer {

    @objc(addLeftBoutsObject:)
    @NSManaged public func addToLeftBouts(_ value: Bout)

    @objc(removeLeftBoutsObject:)
    @NSManaged public func removeFromLeftBouts(_ value: Bout)

    @objc(addLeftBouts:)
    @NSManaged public func addToLeftBouts(_ values: NSSet)

    @objc(removeLeftBouts:)
    @NSManaged public func removeFromLeftBouts(_ values: NSSet)

}

// MARK: Generated accessors for rightBouts
extension Fencer {

    @objc(addRightBoutsObject:)
    @NSManaged public func addToRightBouts(_ value: Bout)

    @objc(removeRightBoutsObject:)
    @NSManaged public func removeFromRightBouts(_ value: Bout)

    @objc(addRightBouts:)
    @NSManaged public func addToRightBouts(_ values: NSSet)

    @objc(removeRightBouts:)
    @NSManaged public func removeFromRightBouts(_ values: NSSet)

}

extension Fencer : Identifiable {

}

extension Fencer {
    static func ==(lhs: Fencer, rhs: Fencer) -> Bool {
        return lhs.uName == rhs.uName
    }
}

extension Fencer {
    convenience init(name: String, number: Int, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.name = name
        self.number = Int16(number)
    }
}
