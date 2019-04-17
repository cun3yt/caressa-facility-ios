//
//  MessageThreadRead+CoreDataProperties.swift
//  
//
//  Created by Hüseyin Metin on 16.04.2019.
//
//

import Foundation
import CoreData


extension MessageThreadRead {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageThreadRead> {
        return NSFetchRequest<MessageThreadRead>(entityName: "MessageThreadRead")
    }

    @NSManaged public var id: Int32
    @NSManaged public var read: Bool

}
