//
//  DBManager.swift
//  Caressa
//
//  Created by Hüseyin Metin on 11.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit
import CoreData

class DBManager: NSObject {
    
    static let shared = DBManager()
    
    public let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    public var context: NSManagedObjectContext!
    
    
    
    override init() {
        super.init()
        context = appDelegate.persistentContainer.viewContext
    }
    
    func entity(entitiy: String) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entitiy, in: context)
    }
    
    func manageObject(entity: NSEntityDescription) -> NSManagedObject {
        return NSManagedObject(entity: entity, insertInto: context)
    }
    
    func getUnreadMessageCount() -> Int {
        do {
            let fetchReq: NSFetchRequest<NSFetchRequestResult> = MessageRead.fetchRequest()
            fetchReq.predicate = NSPredicate(format: "read = %d", 0)
            if let results = try DBManager.shared.context.fetch(fetchReq) as? [MessageRead] {
                return results.count
            }
        } catch {
            print(error.localizedDescription)
        }
        return 0
    }
}
