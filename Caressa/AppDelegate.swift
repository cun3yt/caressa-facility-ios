//
//  AppDelegate.swift
//  Caressa
//
//  Created by Hüseyin Metin on 22.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit
import AVKit
import CoreData
import PushNotifications
import UserNotifications
import PusherSwift
import Sentry

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let beamsClient = PushNotifications.shared
    var pusher: Pusher!
    var checkinChannel: PusherChannel!
    var deviceStatusChannel: PusherChannel!
    var serverTimeState: TimeState?
    

    public static var audioPlayer: AVPlayer? {
        didSet {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print(error)
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Defaults
        if (UserSettings.shared.API_BASE ?? "").isEmpty             { UserSettings.shared.API_BASE = "https://caressa.herokuapp.com" }
        if (UserSettings.shared.PUSHER_INSTANCE_ID ?? "").isEmpty   { UserSettings.shared.PUSHER_INSTANCE_ID = "e3b941ef-5a8f-4faa-ad87-baea465c28b6" }
        if (UserSettings.shared.PUSHER_KEY ?? "").isEmpty           { UserSettings.shared.PUSHER_KEY = "c984c4342b09e06c02a0" }
        if (UserSettings.shared.PUSHER_INTEREST_NAME ?? "").isEmpty { UserSettings.shared.PUSHER_INTEREST_NAME = "debug-facility" }
        if (UserSettings.shared.PUSHER_CLUSTER ?? "").isEmpty       { UserSettings.shared.PUSHER_CLUSTER = "us2" }
        if (UserSettings.shared.SENTRY_DSN ?? "").isEmpty       { UserSettings.shared.SENTRY_DSN = "https://69eae423c9754258bd30d4a7fcd097b0@sentry.io/1471072" }
        
        do {
            #if DEV
            Client.shared = try Client(dsn: UserSettings.shared.SENTRY_DSN!)
            #else
            Client.shared = try Client(dsn: "https://f9864d01e0b1434280a130db7fbb4a5a@sentry.io/1470922")
            #endif
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
        }
        
        // Notification
        self.beamsClient.start(instanceId: UserSettings.shared.PUSHER_INSTANCE_ID!)
        self.beamsClient.registerForRemoteNotifications()
        try? self.beamsClient.addDeviceInterest(interest: UserSettings.shared.PUSHER_INTEREST_NAME!)
        UNUserNotificationCenter.current().delegate = self

        //Real Time Channels
        let options = PusherClientOptions(host: .cluster(UserSettings.shared.PUSHER_CLUSTER!))
        pusher = Pusher(key: UserSettings.shared.PUSHER_KEY!, options: options)
        pusher.connect()
        
        getServerDateTime()
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (_) in
            self.getServerDateTime()
        }
        
        application.applicationIconBadgeNumber = 0
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.beamsClient.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //print(userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let aps = userInfo["aps"] as? [String: Any],
            let payload = aps["payload"] as? [String: Any],
            let type = payload["type"] as? String {
            
            let value = payload["value"] as? String
            
            switch type {
            case "residents"     : pushTo(tab: 0, parameter: nil)
            case "messages"      : pushTo(tab: 1, parameter: nil)
            case "calendar"      : pushTo(tab: 2, parameter: value)
            case "photos"        : pushTo(tab: 3, parameter: value)
            case "settings"      : pushTo(tab: 4, parameter: nil)
            case "message_thread": pushTo(tab: 1, parameter: value)
            case "profile"       : pushTo(tab: 0, parameter: value)
            case "morning_status": pushTo(tab: 0, parameter: "morning_status")
            default: break
            }
        }
        completionHandler()
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Caressa")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getServerDateTime() {
        WebAPI.shared.disableActivity = true
        WebAPI.shared.get(APIConst.timeState) { (response: TimeState) in
            WebAPI.shared.disableActivity = false
            self.serverTimeState = response
        }
    }
    
    // MARK: PUSH TO ...
    func pushTo(tab index: Int, parameter: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let tabBarC = self.window?.rootViewController as? UITabBarController {
                tabBarC.selectedIndex = index
                if let baseNC = tabBarC.selectedViewController as? UINavigationController,
                    let base = baseNC.viewControllers.first as? BaseViewController {
                    base.pushParameter = parameter
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushControl"), object: nil)
                    return
                }
                if let base = tabBarC.selectedViewController as? BaseViewController {
                    base.pushParameter = parameter
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushControl"), object: nil)
                    return
                }
            }
        }
    }
}

