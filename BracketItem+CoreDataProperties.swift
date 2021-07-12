//
//  BracketItem+CoreDataProperties.swift
//  Fencing
//
//  Created by Ben K on 7/10/21.
//
//

import Foundation
import CoreData


extension BracketItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BracketItem> {
        return NSFetchRequest<BracketItem>(entityName: "BracketItem")
    }

    @NSManaged public var type: Int16
    @NSManaged public var number: String?
    @NSManaged public var singleFencer: Fencer?
    @NSManaged public var multiFencer: NSOrderedSet?
    
    var uType: BracketItemType {
        get {
            return BracketItemType(rawValue: self.type)!
        }
        set {
            self.type = newValue.rawValue
        }
    }
    
    var uNumber: String {
        return number ?? ""
    }
    
    var uMultiFencer: [Fencer] {
        return multiFencer?.array as? [Fencer] ?? []
    }

}

extension BracketItem : Identifiable {

}

extension BracketItem {
    convenience init(fencer: Fencer, number: String, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.uType = .single
        self.singleFencer = fencer
        self.number = number
    }
    
    convenience init(fencers: [Fencer], number: String, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.uType = .multi
        self.number = number
        self.multiFencer = NSOrderedSet(array: fencers)
    }
    
    convenience init(type: BracketItemType, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.uType = type
    }
}
