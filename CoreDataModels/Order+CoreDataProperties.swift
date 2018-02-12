//
//  Order+CoreDataProperties.swift
//  CoreDataTestApp
//
//  Created by Алексей Россошанский on 06.02.18.
//  Copyright © 2018 Alexey Rossoshasky. All rights reserved.
//
//

import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var made: Bool
    @NSManaged public var paid: Bool
    @NSManaged public var client: Client?
    @NSManaged public var rowOfOrder: RowOfOrder?

}
