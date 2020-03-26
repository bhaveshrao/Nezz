//
//  AppDelegate.swift
//  BlindTune
//
//  Created by Rao, Bhavesh (external - Project) on 24/01/19.
//  Copyright © 2019 Bhavesh Rao. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import Reachability
import AVFoundation
import UserNotifications
import Mixpanel
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?
    static var delegateFlag = 0
    static var reachablity:Reachability!
    static var user:User!
    static var username:String!
    static var pushSettings:PushNotificationSetting!
    static var isFirstTime = false
    static var isUserRegistered = false
    static var currentAudioPlayer = [AVAudioPlayer]()
    static var isSkipClicked = false
    static var isCheckedForUpdate = false
    static var isFromPushNotification = false
    static var userInfo = [String:String]()
    var deviceIdArray = [Dictionary<String, Any>]()
    static var localNotificationCount = -1
    
    static var controllerType = ""


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
AppDelegate.isCheckedForUpdate = false
        
//        let options = FirebaseOptions(googleAppID: "1:414820251131:ios:d42e967989ffa14f", gcmSenderID: "414820251131")
//        options.bundleID = "com.umar.nezz"
//        options.apiKey = "AIzaSyDL5fFCPJH-AQ5X-WRyywwgvpTPNqdR2jU"
//        options.projectID = "nezz-ios-app"
//        options.clientID = "com.googleusercontent.apps.414820251131-06hmohqp126nsrkladh05dnu9v0rrefp"
//        FirebaseApp.configure(options: options)

        
        do {
            AppDelegate.reachablity = try Reachability()
        }catch{
            print(error)
        }
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        
    
        Messaging.messaging().shouldEstablishDirectChannel = true
        
//        if let deviceID = AppDelegate.user.deviceId as? String  {
//            if let fcmToken = Messaging.messaging().fcmToken {
//                
//            }else{
//                Messaging.messaging().fcmToken = deviceID
//            }
//        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self

        
        if UserDefaults.standard.object(forKey: "LoggedInUser") == nil {
            
            let firebaseRefUsers = Database.database().reference(withPath: "Users")
            firebaseRefUsers.observe(.value) { (snapshot) in
                
                if let tempArray = snapshot.value as? [String:Any] {
                    self.deviceIdArray = (Array(tempArray.values) as? [Dictionary<String, Any>])!
                    self.deviceIdArray = self.deviceIdArray.filter({ (value) -> Bool in
                        value["deviceId"] as! String == UIDevice.current.identifierForVendor!.uuidString
                    })
                }
                if !AppDelegate.isUserRegistered {
//                    self.setRootController(isFirstTimeUser: self.deviceIdArray.isEmpty)
                    AppDelegate.isSkipClicked = true
//                    self.setHomeToRoot()
                }
            }
        }else{
            
            AppDelegate.isSkipClicked = false

            AppDelegate.user = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "LoggedInUser") as! Data) as! User)
//            setHomeToRoot()
        }
        
        
        AppDelegate.isFromPushNotification = false
        
        // Mix pannel intialization
        
        Mixpanel.initialize(token: "2b3fac675d22aceb0d13e9b998a9d65c")
        
        // Opt a user out of data collection
        Mixpanel.mainInstance().optOutTracking()

        // Check a user's opt-out status
        // Returns true if user is opted out of tracking locally
        _ = Mixpanel.mainInstance().hasOptedOutTracking()


        return true
    }
        
    
    func tokenRefreshNotification(notification: NSNotification) {
      //  print("refresh token call")
        
        InstanceID.instanceID().instanceID { (result, error) in
               if let error = error {
                   print("Error fetching remote instange ID: \(error)")
               } else if let result = result {
            }
           }
    }

    
   
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
//        if let notificationCount = UserDefaults.standard.value(forKey: "localNotificationCount") {
//                  application.applicationIconBadgeNumber = (notificationCount as! Int)
//              }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    
//        ParentDashboardViewController.isFromViewDidAppear = true
//        if let notificationCount = UserDefaults.standard.value(forKey: "localNotificationCount") {
//            UserDefaults.standard.set((notificationCount as! Int) +  UIApplication.shared.applicationIconBadgeNumber , forKey: "localNotificationCount")
//             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setNotificationCount"), object: nil)
//        }else if UIApplication.shared.applicationIconBadgeNumber > 0 {
//            UserDefaults.standard.set( UIApplication.shared.applicationIconBadgeNumber , forKey: "localNotificationCount")
//                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setNotificationCount"), object: nil)
//        }
//        
       

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
//        if let notificationCount = UserDefaults.standard.value(forKey: "localNotificationCount") {
//            application.applicationIconBadgeNumber = (notificationCount as! Int)
//        }
//
        
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print(fcmToken)

    }
    private func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print(fcmToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       
       
//            setHomeToRoot()
             AppDelegate.userInfo = ["postId":userInfo["postId"] as! String ,"commentedBy":userInfo["commentedBy"] as! String]
            
        if userInfo["notificationType"] as! String != "addPost" {
            if application.applicationState != .active {
                           
                           AppDelegate.isFromPushNotification = true

                           if AppDelegate.user._id != userInfo["commentedBy"] as! String {
                               
                               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callCommentScreenBy"), object: nil)
                                              NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setNotificationCount"), object: nil)
                           }
                            
                }
        }
           
            
          
    
    }
    
    
    
//    - (void)sendDataMessageFailure:(NSNotification *)notification {
//    NSString *messageID = (NSString *)message.object;
//    }
//    - (void)sendDataMessageSuccess:(NSNotification *)notification {
//    NSString *messageID = (NSString *)message.object;
//    NSDictionary *userInfo = message.userInfo; // contains error info etc
//    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "BlindTune")
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
    
    static func appDelegate() -> AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func setRootController(isFirstTimeUser:Bool){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController:UIViewController
        if isFirstTimeUser {
            AppDelegate.isFirstTime = true
            initialViewController = storyboard.instantiateViewController(withIdentifier: "SigninNav")
        }else{
            AppDelegate.isFirstTime = false
            initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginNav")
        }
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }

    
  
    
    func isUpdateAvailable() throws -> Bool {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
            throw VersionError.invalidBundleInfo
        }
        let data = try Data(contentsOf: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw VersionError.invalidResponse
        }
        if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
            print("version in app store", (version as NSString).doubleValue, (currentVersion as NSString).doubleValue)
            
            return  (version as NSString).doubleValue !=  (currentVersion as NSString).doubleValue
        }
        throw VersionError.invalidResponse
    }
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }

}


extension UITextView{
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}



