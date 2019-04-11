//
//  MessageRead+CoreDataProperties.swift
//  
//
//  Created by Hüseyin Metin on 11.04.2019.
//
//

import Foundation
import CoreData


extension MessageRead {

    @nonobjc public class func fetch() -> NSFetchRequest<MessageRead> {
        return NSFetchRequest<MessageRead>(entityName: "MessageRead")
    }

    @NSManaged public var id: Int32
    @NSManaged public var read: Bool

}
