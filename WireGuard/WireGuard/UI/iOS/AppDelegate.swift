// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import os.log
import NetworkExtension
import Firebase
import Alamofire
import SwiftyJSON
import UserNotifications
import FirebaseAuth
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    var window: UIWindow?
    var mainVC: CheckfirstViewController?
    var loginVC: SocialLoginViewController?
    var myGroup = DispatchGroup()
    var tunnelmanager: TunnelsManager?
    var devicetoken = ""
//    var vpnkey = ""
//    var pvkey = ""
//    var pubkey = ""
//    var dns = ""
//    var myaddress = ""
//    var endpoint = ""
//    var presharekey = ""
    var isLaunchedForSpecificAction = false
    let gcmMessageIDKey = "gcm.message_id"
    var mytunnelmanager: TunnelsManager?
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logger.configureGlobal(tagged: "APP", withFilePath: FileManager.logFileURL?.path)

        if let launchOptions = launchOptions {
            if launchOptions[.url] != nil || launchOptions[.shortcutItem] != nil {
                isLaunchedForSpecificAction = true
            }
        }

        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        ThemeManager.applyTheme(theme: ThemeManager.currentTheme())

     //  UIApplication.shared.statusBarView?.backgroundColor = UIColor(hexString: "#3C4943")
//        UIApplication.shared.statusBarView?.backgroundColor = UIColor.red
        //step 1
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

        // step 2
        Messaging.messaging().delegate = self as? MessagingDelegate

        // step 3
        InstanceID.instanceID().instanceID { result, error in
            if let error = error {
       //         print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
          //      print("Remote instance ID token: \(result.token)")

                self.devicetoken = result.token
                UserDefaults.standard.setdevicetoken(value: self.devicetoken)
                UserDefaults.standard.synchronize()

            }
        }

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 4.0))



        // Create the tunnels manager, and when it's ready, inform tunnelsListVC
        TunnelsManager.create { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):

                ErrorPresenter.showErrorAlert(error: error, from: self)
            case .success(let tunnelsManager):

                self.tunnelmanager = tunnelsManager

            //    print("tunnel count in button click", tunnelsManager.numberOfTunnels())

                if(tunnelsManager.numberOfTunnels() > 0 ) {
                  //  self.mainVC?.setTunnelsManager(tunnelsManager: tunnelsManager)

                } else {
                    UserDefaults.standard.setLoggedIn(value: false)
                    UserDefaults.standard.synchronize()
                   //  self.mainVC?.setTunnelsManager(tunnelsManager: tunnelsManager)

                }

                if(UserDefaults.standard.isSocialLoggedIn() == true)
                {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "MainStoryboard", bundle:nil)
                    self.mainVC = storyBoard.instantiateViewController(withIdentifier: "firstVC") as? CheckfirstViewController
                    self.mainVC?.setTunnelsManager(tunnelsManager: tunnelsManager)

                    let nav = UINavigationController(rootViewController: self.mainVC!)
                    nav.isNavigationBarHidden = true
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    self.window?.rootViewController = nav
                    //self.window?.backgroundColor = ThemeManager.currentTheme().backgroundColor
                    self.window?.makeKeyAndVisible()
                }else{
                    let storyBoard : UIStoryboard = UIStoryboard(name: "MainStoryboard", bundle:nil)
                    self.loginVC = storyBoard.instantiateViewController(withIdentifier: "loginVC") as? SocialLoginViewController
                    self.loginVC?.setTunnelsManager(tunnelsManager: tunnelsManager)
                    let nav = UINavigationController(rootViewController: self.loginVC!)
                    nav.isNavigationBarHidden = true
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    self.window?.rootViewController = nav
                    //self.window?.backgroundColor = ThemeManager.currentTheme().backgroundColor
                    self.window?.makeKeyAndVisible()
                }



            }

        }

        return true
    }



    //MARK: Google login methods
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }


//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//      // ...
//      if let error = error {
//        // ...
//        return
//      }
//
//      guard let authentication = user.authentication else { return }
//      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                        accessToken: authentication.accessToken)
//      // ...
//        Auth.auth().signIn(with: credential) { (authResult, error) in
//          if let error = error {
//            // ...
//            return
//          }
//
//              // Perform any operations on signed in user here.
//              let userId = user.userID                  // For client-side use only!
//              let idToken = user.authentication.idToken // Safe to send to the server
//              let fullName = user.profile.name
//              let givenName = user.profile.givenName
//              let familyName = user.profile.familyName
//              let email = user.profile.email
//
//            print("Email",email)
//            let storyBoard : UIStoryboard = UIStoryboard(name: "MainStoryboard", bundle:nil)
//            self.mainVC = storyBoard.instantiateViewController(withIdentifier: "firstVC") as? CheckfirstViewController
//
//
//
//
//            self.mainVC?.setTunnelsManager(tunnelsManager: self.tunnelmanager!)
//
//            let nav = UINavigationController(rootViewController: self.mainVC!)
//            nav.isNavigationBarHidden = true
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            self.window?.rootViewController = nav
//            //self.window?.backgroundColor = ThemeManager.currentTheme().backgroundColor
//            self.window?.makeKeyAndVisible()
//
//            UserDefaults.standard.setSocialLoggedIn(value: true)
//            UserDefaults.standard.synchronize()
//            print("User successfully signin in app using google")
//          // User is signed in
//          // ...
//        }
//
//
//    }






    func showAlertAppDelegate(title : String,message : String,buttonTitle : String,window: UIWindow){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: nil))
        window.rootViewController?.present(alert, animated: true, completion: nil)
    }


        // MARK: Check user permission on notification allow
        // check user has give the permission for notification

        func checkNotificationpermission() {


            UNUserNotificationCenter.current().getNotificationSettings { settings in

                if settings.authorizationStatus == .authorized {


                } else {
                    if(self.tunnelmanager!.numberOfTunnels() > 0 ) {
                         let tunnel = self.tunnelmanager!.tunnel(named: Constants.tunnelName)!
                            self.tunnelmanager?.startDeactivation(of: tunnel)
                    }

                    // Either denied or notDetermined
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                        _, _ in
                        // add your own
                        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
                        let alertController = UIAlertController(title: "Notification Alert", message: "Please enable notifications", preferredStyle: .alert)
                        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ -> Void in
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { _ in
                                })
                            }
                        }
                        //let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                       // alertController.addAction(cancelAction)
                        alertController.addAction(settingsAction)
                        DispatchQueue.main.async {
                           // self.present(alertController, animated: true, completion: nil)
                           self.window?.rootViewController?.present(alertController, animated: true, completion: nil)

                        }
                    }
                }
            }
        }

//    func checkPushNotification(checkNotificationStatus isEnable : ((Bool)->())? = nil){
//
//        if #available(iOS 10.0, *) {
//
//            UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
//
//                switch setttings.authorizationStatus{
//                case .authorized:
//
//                    print("enabled notification setting")
//                    isEnable?(true)
//                case .denied:
//
//                    print("setting has been disabled")
//                    isEnable?(false)
//                case .notDetermined:
//
//                    print("something vital went wrong here")
//                    isEnable?(false)
//
//
//                }
//            }
//        } else {
//
//            let isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
//            if isNotificationEnabled == true{
//
//                print("enabled notification setting")
//                isEnable?(true)
//
//            }else{
//
//                print("setting has been disabled")
//                isEnable?(false)
//            }
//        }
//    }




    // MARK: Notification configuration methods

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
       // print(userInfo)
        if application.applicationState == .active {
            if let messageID = userInfo[gcmMessageIDKey] {
               // print("Message ID: \(messageID)")
            }
        } else {
            if let messageID = userInfo[gcmMessageIDKey] {
              //  print("Message ID: \(messageID)")
            }
        }
    }


    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {

        if application.applicationState == .active {

            if let messageID = userInfo[gcmMessageIDKey] {
              //  print("Message ID: \(messageID)")
            }
        } else {
            if let messageID = userInfo[gcmMessageIDKey] {
           //     print("Message ID: \(messageID)")
            }
        }

       // print(userInfo)

        let imageKey = AnyHashable("image_url")

     //   print("imagekey for notification",imageKey)
        let aps = userInfo[AnyHashable("aps")] as? NSDictionary
        let alert = aps?["alert"] as? NSDictionary
        let title = alert?["title"] as! String
        let body = alert?["body"] as! String



        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       // print("APNs token retrieved: \(deviceToken)")

    }


    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
        Messaging.messaging().subscribe(toTopic: "GreenSignaliOS") { error in
            print("Subscribed to weather topic")
        }
    }



    func applicationDidBecomeActive(_ application: UIApplication) {
       // self.showAlertAppDelegate(title: "Alert",message: "Opened From AppDelegate",buttonTitle: "ok",window: self.window!);

        if(UserDefaults.standard.isLoggedIn() == false) {

        }
        else
        {
            self.checkNotificationpermission()
        }

        ReachabilityManager.shared.startMonitoring()
        //mainVC?.viewDidLoad()
        mainVC?.loadViewIfNeeded()
        mainVC?.refreshTunnelConnectionStatuses()

        //mainVC?.callRegisterapi()

    }

    func applicationWillResignActive(_ application: UIApplication) {
        ReachabilityManager.shared.stopMonitoring()
        guard let allTunnelNames = mainVC?.allTunnelNames() else { return }
        application.shortcutItems = QuickActionItem.createItems(allTunnelNames: allTunnelNames)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        ReachabilityManager.shared.stopMonitoring()
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard shortcutItem.type == QuickActionItem.type else {
            completionHandler(false)
            return
        }
        let tunnelName = shortcutItem.localizedTitle
        mainVC?.showTunnelDetailForTunnel(named: tunnelName, animated: false, shouldToggleStatus: true)
        completionHandler(true)
    }
}

extension AppDelegate {

    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return !self.isLaunchedForSpecificAction
    }

    func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        guard let vcIdentifier = identifierComponents.last else { return nil }
        if vcIdentifier.hasPrefix("TunnelDetailVC:") {
            let tunnelName = String(vcIdentifier.suffix(vcIdentifier.count - "TunnelDetailVC:".count))
            if let tunnelsManager = mainVC?.tunnelsManager {
                if let tunnel = tunnelsManager.tunnel(named: tunnelName) {
                    return TunnelDetailTableViewController(tunnelsManager: tunnelsManager, tunnel: tunnel)
                }
            } else {
                // Show it when tunnelsManager is available
                mainVC?.showTunnelDetailForTunnel(named: tunnelName, animated: false, shouldToggleStatus: false)
            }
        }
        return nil
    }

}

extension UserDefaults {

    enum UserDefaultsKeys: String {
        case isLoggedIn
        case isSocialLoggedIn
        case userID
        case publickkey
        case privatekey
        case vpnkey
        case devicetoken
        case starttime
        case apistatus
        case locationId
        case locationName
        case virtualip
        case publicip
    }
    // MARK: Check Login
    func setLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        //synchronize()
    }

    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }


    // MARK: Check socialLogin
    func setSocialLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isSocialLoggedIn.rawValue)
        //synchronize()
    }

    func isSocialLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isSocialLoggedIn.rawValue)
    }





    // MARK: Check Login
    func setstatusapi(value: Bool) {
        set(value, forKey: UserDefaultsKeys.apistatus.rawValue)
        //synchronize()
    }

    func isgetapiatatus() -> Bool {
        return bool(forKey: UserDefaultsKeys.apistatus.rawValue)
    }



    // MARK: Check publickey
    func setpublickkey(value: String) {
        set(value, forKey: UserDefaultsKeys.publickkey.rawValue)
        //synchronize()
    }

    func ispublickey() -> String {

        return string(forKey:UserDefaultsKeys.publickkey.rawValue)!
    }


    // MARK: Check privatekey
    func setprivatekkey(value: String) {
        set(value, forKey: UserDefaultsKeys.privatekey.rawValue)
        //synchronize()
    }

    func isprivatekey() -> String {

        return string(forKey:UserDefaultsKeys.privatekey.rawValue)!
    }


    // MARK: Check vpnkey
    func setvpnkey(value: String) {
        set(value, forKey: UserDefaultsKeys.vpnkey.rawValue)
        //synchronize()
    }

    func isvpnkey() -> String {
        return string(forKey:UserDefaultsKeys.vpnkey.rawValue)!
    }

    // MARK: Check devicetoken
    func setdevicetoken(value: String) {
        set(value, forKey: UserDefaultsKeys.devicetoken.rawValue)
        //synchronize()
    }

    func isdevicetoken() -> String {
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.devicetoken.rawValue) != nil{
            return string(forKey:UserDefaultsKeys.devicetoken.rawValue)!
        }
        else{
            return ""
        }

    }


    // MARK: Check setstarttime
    func setstarttime(value: String) {
        set(value, forKey: UserDefaultsKeys.starttime.rawValue)
        //synchronize()
    }

    func getstarttime() -> String {
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.starttime.rawValue) != nil{
            return string(forKey:UserDefaultsKeys.starttime.rawValue)!
        }
        else{
            return ""
        }

    }



    // MARK: Check setselectedLocationId
    func setselectedLocationId(value: String) {
        set(value, forKey: UserDefaultsKeys.locationId.rawValue)
        //synchronize()
    }

    func getlocationId() -> String {
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.locationId.rawValue) != nil{
             return string(forKey:UserDefaultsKeys.locationId.rawValue)!
        }else{
            return ""
        }
    }



    // MARK: Check setselectedLocationName
    func setselectedLocationName(value: String) {
        set(value, forKey: UserDefaultsKeys.locationName.rawValue)
        //synchronize()
    }

    func getlocationName() -> String {
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.locationName.rawValue) != nil{
             return string(forKey:UserDefaultsKeys.locationName.rawValue)!
        }
        else{
            return ""
        }

    }

    // MARK: Check virtualip
    func setvirtualip(value: String) {
        set(value, forKey: UserDefaultsKeys.virtualip.rawValue)
        //synchronize()
    }

    func getvertualip() -> String {
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.virtualip.rawValue) != nil{
            return string(forKey:UserDefaultsKeys.virtualip.rawValue)!
        }else{
            return "-"
        }
    }

    // MARK: Check publicip
    func setpublicip(value: String) {
        set(value, forKey: UserDefaultsKeys.publicip.rawValue)
        //synchronize()
    }

    func getpublicip() -> String {
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.publicip.rawValue) != nil{
            return string(forKey:UserDefaultsKeys.publicip.rawValue)!
        }else{
            return "-"
        }
    }


}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo


        // Print full message.
    //    print(userInfo)
        let imageKey = AnyHashable("image")

       // print("imagekey for notification",imageKey)



        // Change this to your preferred presentation option
        completionHandler([])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

    //    print(userInfo)
        guard let aps = userInfo[AnyHashable("image")] else {
            return
        }

        guard let redirecturl = userInfo[AnyHashable("redirectTo")] else {
            return
        }

        guard let url = URL(string: redirecturl as! String) else {
            return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }

        let imageKey = AnyHashable("image")

       // print("imagekey for notification",aps)
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        self.devicetoken = fcmToken
        UserDefaults.standard.setdevicetoken(value: self.devicetoken)
        UserDefaults.standard.synchronize()
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
      //  print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        print("onview bounds",onView.bounds)
   //     let spinnerView = UIView()
//       spinnerView.frame = UIApplication.shared.keyWindow!.frame
        let spinnerView = UIView.init(frame: UIScreen.main.bounds)
          spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .gray)

        ai.startAnimating()
        ai.center = spinnerView.center

        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }

        return spinnerView
    }

    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension Notification.Name {
    static let refresh = Notification.Name("refresh")
    static let tunnelStatus = Notification.Name("tunnelStatus")
}

extension UIApplication {

    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }

}


