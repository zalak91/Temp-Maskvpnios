// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.
import Cocoa
import ServiceManagement
import UserNotifications
import ReachabilitySwift


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()

    var eventMonitor: EventMonitor?
    var tunnelsManager: TunnelsManager?
    var tunnelsTracker: TunnelsTracker?
    var statusItemController: StatusItemController?

    var manageTunnelsRootVC: ManageTunnelsRootViewController?

    // below code for thekeyvpn
    var firstmacosviewcontroller: FirstMacOSViewController?

    var manageTunnelsWindowObject: NSWindow?
    var onAppDeactivation: (() -> Void)?

    func applicationWillFinishLaunching(_ notification: Notification) {

        // To workaround a possible AppKit bug that causes the main menu to become unresponsive sometimes
        // (especially when launched through Xcode) if we call setActivationPolicy(.regular) in
        // in applicationDidFinishLaunching, we set it to .prohibited here.
        // Setting it to .regular would fix that problem too, but at this point, we don't know
        // whether the app was launched at login or not, so we're not sure whether we should
        // show the app icon in the dock or not.
        configureNotification()
        NSApp.setActivationPolicy(.prohibited)

    }



    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNs device token: \(deviceTokenString)")
        UserDefaults.standard.setdevicetoken(value: deviceTokenString)
        UserDefaults.standard.synchronize()
    }

    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
    }

    func configureNotification() {

        NSApplication.shared.registerForRemoteNotifications()

    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Logger.configureGlobal(tagged: "APP", withFilePath: FileManager.logFileURL?.path)
        registerLoginItem(shouldLaunchAtLogin: true)

        var isLaunchedAtLogin = false
        if let appleEvent = NSAppleEventManager.shared().currentAppleEvent {
            isLaunchedAtLogin = LaunchedAtLoginDetector.isLaunchedAtLogin(openAppleEvent: appleEvent)
        }

        NSApp.mainMenu = MainMenu()
        setDockIconAndMainMenuVisibility(isVisible: !isLaunchedAtLogin)

        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarIcon")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }


        TunnelsManager.create { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                ErrorPresenter.showErrorAlert(error: error, from: nil)
            case .success(let tunnelsManager):

                //                    let statusMenu = StatusMenu(tunnelsManager: tunnelsManager)
                //                    statusMenu.windowDelegate = self
                //
                //                    let statusItemController = StatusItemController()
                //                    statusItemController.statusItem.menu = statusMenu
                //
                //                    let tunnelsTracker = TunnelsTracker(tunnelsManager: tunnelsManager)
                //                    tunnelsTracker.statusMenu = statusMenu
                //                    tunnelsTracker.statusItemController = statusItemController
                //
                //                    self.tunnelsManager = tunnelsManager
                //                    self.tunnelsTracker = tunnelsTracker
                //                    self.statusItemController = statusItemController
                let mainViewController = NSStoryboard(name: "MacOSStoryboard", bundle: nil).instantiateController(withIdentifier: "firstVC") as! FirstMacOSViewController
                mainViewController.setTunnelsManager(tunnelsManager: tunnelsManager)

                let navigationcontroller = CCNNavigationController(rootViewController: nil)


                self.popover.contentViewController = navigationcontroller
                self.popover.contentSize = CGSize(width: 360, height: 500)
                navigationcontroller?.viewControllers = [mainViewController]
                self.popover.animates = true
                self.eventMonitor = EventMonitor(mask: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown]) { [weak self] event in
                    if let popover = self?.popover {
                        if popover.isShown {
                            self?.closePopover(event)
                        }
                    }
                }
                self.eventMonitor?.start()

                if !isLaunchedAtLogin {
                    self.showManageTunnelsWindow(completion: nil)
                }
            }
        }

    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if let appleEvent = NSAppleEventManager.shared().currentAppleEvent {
            if LaunchedAtLoginDetector.isReopenedByLoginItemHelper(reopenAppleEvent: appleEvent) {
                return false
            }
        }
        if hasVisibleWindows {
            return true
        }
        showManageTunnelsWindow(completion: nil)
        return false
    }

    @objc func quit() {
        if let manageWindow = manageTunnelsWindowObject, manageWindow.attachedSheet != nil {
            NSApp.activate(ignoringOtherApps: true)
            manageWindow.orderFront(self)
            return
        }
        registerLoginItem(shouldLaunchAtLogin: false)
        guard let currentTunnel = tunnelsTracker?.currentTunnel, currentTunnel.status == .active || currentTunnel.status == .activating else {
            NSApp.terminate(nil)

            return
        }
        let alert = NSAlert()
        alert.messageText = tr("macAppExitingWithActiveTunnelMessage")
        alert.informativeText = tr("macAppExitingWithActiveTunnelInfo")
        NSApp.activate(ignoringOtherApps: true)
        if let manageWindow = manageTunnelsWindowObject {
            manageWindow.orderFront(self)
            alert.beginSheetModal(for: manageWindow) { _ in
                NSApp.terminate(nil)
            }
        } else {
            alert.runModal()
            NSApp.terminate(nil)
        }
    }

    func appDelegate() -> AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if UserDefaults.standard.bool(forKey: "shouldSuppressAppStoreUpdateDetection") {
            wg_log(.debug, staticMessage: "App Store update detection is suppressed")
            return .terminateNow
        }
        guard let currentTunnel = tunnelsTracker?.currentTunnel, currentTunnel.status == .active || currentTunnel.status == .activating else {
            return .terminateNow
        }
        guard let appleEvent = NSAppleEventManager.shared().currentAppleEvent else {
            return .terminateNow
        }
        guard MacAppStoreUpdateDetector.isUpdatingFromMacAppStore(quitAppleEvent: appleEvent) else {
            return .terminateNow
        }
        let alert = NSAlert()
        alert.messageText = tr("macAppStoreUpdatingAlertMessage")
        if currentTunnel.isActivateOnDemandEnabled {
            alert.informativeText = tr(format: "macAppStoreUpdatingAlertInfoWithOnDemand (%@)", currentTunnel.name)
        } else {
            alert.informativeText = tr(format: "macAppStoreUpdatingAlertInfoWithoutOnDemand (%@)", currentTunnel.name)
        }
        NSApp.activate(ignoringOtherApps: true)
        if let manageWindow = manageTunnelsWindowObject {
            alert.beginSheetModal(for: manageWindow) { _ in }
        } else {
            alert.runModal()
        }
        return .terminateCancel
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ application: NSApplication) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { [weak self] in
            self?.setDockIconAndMainMenuVisibility(isVisible: false)
        }
        return false
    }

    private func setDockIconAndMainMenuVisibility(isVisible: Bool, completion: (() -> Void)? = nil) {
        let currentActivationPolicy = NSApp.activationPolicy()
        let newActivationPolicy: NSApplication.ActivationPolicy = isVisible ? .regular : .accessory
        guard currentActivationPolicy != newActivationPolicy else {
            if newActivationPolicy == .regular {
                NSApp.activate(ignoringOtherApps: true)
            }

            completion?()
            return
        }

        if newActivationPolicy == .regular && NSApp.isActive {
            // To workaround a possible AppKit bug that causes the main menu to become unresponsive,
            // we should deactivate the app first and then set the activation policy.
            // NSApp.deactivate() doesn't always deactivate the app, so we instead use
            // setActivationPolicy(.prohibited).
            onAppDeactivation = {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
                completion?()
            }
            NSApp.setActivationPolicy(.prohibited)
        } else {
            NSApp.setActivationPolicy(newActivationPolicy)
            if newActivationPolicy == .regular {
                NSApp.activate(ignoringOtherApps: true)
            }
            completion?()
        }
    }

    func applicationDidResignActive(_ notification: Notification) {
        onAppDeactivation?()
        onAppDeactivation = nil
    }


    //MARK: popover methods
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
    }

    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }


}

extension AppDelegate {
    @objc func aboutClicked() {
        var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        if let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            appVersion += " (\(appBuild))"
        }
        let appVersionString = [
            tr(format: "macAppVersion (%@)", appVersion),
            tr(format: "macGoBackendVersion (%@)", WIREGUARD_GO_VERSION)
            ].joined(separator: "\n")
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationVersion: appVersionString,
            .version: ""
            ])
    }
}

extension AppDelegate: StatusMenuWindowDelegate {
    func showManageTunnelsWindow(completion: ((NSWindow?) -> Void)?) {
        guard let tunnelsManager = tunnelsManager else {
            completion?(nil)
            return
        }

        //        if manageTunnelsWindowObject == nil {
        //            firstmacosviewcontroller = FirstMacOSViewController(tunnelsManager: tunnelsManager)
        //            let window = NSWindow(contentViewController: manageTunnelsRootVC!)
        //            window.title = tr("macWindowTitleManageTunnels")
        //            window.setContentSize(NSSize(width: 100, height: 480))
        //          //  window.setFrameAutosaveName(NSWindow.FrameAutosaveName("ManageTunnelsWindow"))  Auto-save window position and size
        //            manageTunnelsWindowObject = window
        //            //tunnelsTracker?.manageTunnelsRootVC = manageTunnelsRootVC
        //        }
        setDockIconAndMainMenuVisibility(isVisible: true) { [weak manageTunnelsWindowObject] in
            manageTunnelsWindowObject?.makeKeyAndOrderFront(self)
            completion?(manageTunnelsWindowObject)
        }

        //        if manageTunnelsWindowObject == nil {
        ////            firstmacosviewcontroller = FirstMacOSViewController(tunnelsManager: tunnelsManager)
        //
        //           // tunnelsTracker?.firstmacosviewcontroller = firstmacosviewcontroller
        //        }
        //        setDockIconAndMainMenuVisibility(isVisible: true) { [weak manageTunnelsWindowObject] in
        //            manageTunnelsWindowObject?.makeKeyAndOrderFront(self)
        //            completion?(manageTunnelsWindowObject)
        //        }
    }
}

@discardableResult
func registerLoginItem(shouldLaunchAtLogin: Bool) -> Bool {
    let appId = Bundle.main.bundleIdentifier!
    let helperBundleId = "\(appId).login-item-helper"
    return SMLoginItemSetEnabled(helperBundleId as CFString, shouldLaunchAtLogin)
}


extension UserDefaults {

    enum UserDefaultsKeys: String {
        case isLoggedIn
        case userID
        case publickkey
        case privatekey
        case vpnkey
        case devicetoken
        case starttime
        case apistatus
        case locationId
        case locationName

    }
    // MARK: Check Login
    func setLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        //synchronize()
    }

    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
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

        return string(forKey:UserDefaultsKeys.devicetoken.rawValue)!
    }


    // MARK: Check setstarttime
    func setstarttime(value: String) {
        set(value, forKey: UserDefaultsKeys.starttime.rawValue)
        //synchronize()
    }

    func getstarttime() -> String {
        return string(forKey:UserDefaultsKeys.starttime.rawValue)!
    }


    //    // MARK: Check ConnectedDate
    //    func setConnectedDate(value: Date) {
    //        set(value, forKey: "ConnectedDate")
    //        //synchronize()
    //    }
    //
    //    func getConnectedDate() -> Date {
    //        if UserDefaults.standard.object(forKey: UserDefaultsKeys.locationId.rawValue) != nil{
    //            return (UserDefaults.standard.object(forKey: "ConnectedDate") as! Date?)!
    //        }else{
    //            return Date
    //        }
    //    }


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
        }else{
            return ""
        }

    }




}
extension NSColor {
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
extension Notification.Name {
    static let refresh = Notification.Name("refresh")
    static let tunnelStatus = Notification.Name("tunnelStatus")
}
