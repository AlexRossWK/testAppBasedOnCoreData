//
//  Client+CoreDataProperties.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 06.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//
//

import Foundation
import CoreData


extension Client {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client")
    }

    @NSManaged public var info: String?
    @NSManaged public var name: String?
    @NSManaged public var order: NSSet?

}

// MARK: Generated accessors for order
extension Client {

    @objc(addOrderObject:)
    @NSManaged public func addToOrder(_ value: Order)

    @objc(removeOrderObject:)
    @NSManaged public func removeFromOrder(_ value: Order)

    @objc(addOrder:)
    @NSManaged public func addToOrder(_ values: NSSet)

    @objc(removeOrder:)
    @NSManaged public func removeFromOrder(_ values: NSSet)

}
