// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Cocoa
import NetworkExtension
class SettingViewController: NSViewController {


    @IBOutlet weak var topnavigationview: NSView!



    @IBOutlet weak var staticconnectionstatuslbl: NSTextField!

    @IBOutlet weak var staticdatareceivedlbl: NSTextField!

    @IBOutlet weak var staticdatasentlbl: NSTextField!

    @IBOutlet weak var staticdarkthemelbl: NSTextField!


    @IBOutlet weak var staticshareapplbl: NSTextField!

    @IBOutlet weak var statuslbl: NSTextField!



    @IBOutlet weak var titlelbl: NSTextField!
    @IBOutlet weak var lastdurationlbl: NSTextField!

    @IBOutlet weak var timelbl: NSTextField!

    @IBOutlet weak var contentview: NSView!

    @IBOutlet weak var mainview: NSView!
    @IBOutlet weak var receiveddatalbl: NSTextField!

    @IBOutlet weak var sentdatalbl: NSTextField!

    @IBOutlet weak var darkthemeupperview: NSView!

    @IBOutlet weak var shareupperview: NSView!
    var myreloadtimer: Timer?

    var tunnelsManager: TunnelsManager?

    //MARK: ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        topnavigationview.wantsLayer = true
        topnavigationview.layer?.backgroundColor = NSColor(hexString: "#DFE1E5").cgColor

        darkthemeupperview.wantsLayer = true
        darkthemeupperview.layer?.backgroundColor = NSColor(hexString: "#DFE1E5").cgColor

        shareupperview.wantsLayer = true
        shareupperview.layer?.backgroundColor = NSColor(hexString: "#DFE1E5").cgColor
//        titlelbl.wantsLayer = true
//        titlelbl.backgroundColor = NSColor.clear
//        staticconnectionstatuslbl.wantsLayer = true
//        staticconnectionstatuslbl.backgroundColor = NSColor.clear
//        staticdatareceivedlbl.wantsLayer = true
//        staticdatareceivedlbl.backgroundColor = NSColor.clear
//        staticdatareceivedlbl.wantsLayer = true
//        staticdatareceivedlbl.backgroundColor = NSColor.clear
//        staticdatasentlbl.wantsLayer = true
//        staticdatasentlbl.backgroundColor = NSColor.clear
//
//        staticdarkthemelbl.wantsLayer = true
//        staticdarkthemelbl.backgroundColor = NSColor.clear
//
//        staticshareapplbl.wantsLayer = true
//        staticshareapplbl.backgroundColor = NSColor.clear
//
//        timelbl.wantsLayer = true
//        timelbl.backgroundColor = NSColor.clear
//        sentdatalbl.wantsLayer = true
//        sentdatalbl.backgroundColor = NSColor.clear
//
//        receiveddatalbl.wantsLayer = true
//        receiveddatalbl.backgroundColor = NSColor.clear

        mainview.wantsLayer = true
        mainview.layer?.backgroundColor = NSColor(hexString: "#FFFFFF").cgColor

    }




    override func viewWillAppear() {
        ApiManager.sharedInstance.networkcheckapicall(timeoutinterval: 3) { (networkstatus) in
            if(UserDefaults.standard.isLoggedIn() == true) {
                let tunnel = self.tunnelsManager!.tunnel(named: Constants.tunnelName)!
                if networkstatus == false{
                    print("network off")
                    if tunnel.status == .active {
                        DispatchQueue.main.async {
                            self.noInterNetUI()
                        }

                    }
                    else if tunnel.status == .inactive{
                        DispatchQueue.main.async {
                            self.disConnectedUI()
                        }
                    }

                }
                else{
                    print("network on")
                    if tunnel.status == .active {
                        DispatchQueue.main.async {
                            self.checktunnelstatus()
                        }

                    }
                    else if tunnel.status == .inactive{
                        DispatchQueue.main.async {
                            self.getLastConnected()
                        }
                    }

                }
            }
        }


    }


    override func viewWillDisappear() {
        self.stopTimer()
    }


    //MARK: backbtn method

    @IBAction func backbtn(_ sender: Any) {
        self.navigationController.popViewController(animated: true)
    }

    @IBAction func darkthemeswitchbtn(_ sender: ITSwitch) {

    }


    @IBAction func shareappbtn(_ sender: Any) {
    }

    @IBAction func quitbtn(_ sender: Any) {

        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.quit()
    }

    //MARK: settunnelmanager method

    func setTunnelsManager(tunnelsManager: TunnelsManager) {

        print("Inside SettingvcMacOS setTunnelsManager")

        if(UserDefaults.standard.isLoggedIn() == false) {
            self.tunnelsManager = tunnelsManager

        } else {

            //   print("tunnel is set")
            self.tunnelsManager = tunnelsManager

        }
    }




    // MARK: Timer methods

    func starttimer()
    {
        if myreloadtimer == nil {
            myreloadtimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SettingViewController.timeCount), userInfo: nil, repeats: true)
        }
    }

    func stopTimer()
    {
        if myreloadtimer != nil {
            myreloadtimer!.invalidate()
            myreloadtimer = nil
        }
    }

    fileprivate func getLastConnected() {
        stopTimer()
        lastdurationlbl.stringValue = "Last Handshake"
        statuslbl.stringValue = "Not Connected!"
        statuslbl.textColor = NSColor(hexString: "#FF0033")

        sentdatalbl.stringValue = "-"
        receiveddatalbl.stringValue = "-"
        if let LastHandshake = UserDefaults.standard.object(forKey: "LastHandshake"){

            self.timelbl.stringValue = self.prettyTimeAgo(timestamp: LastHandshake as! Date)
        }
    }

    @objc func timeCount()
    {
        let tunnel = self.tunnelsManager!.tunnel(named: Constants.tunnelName)!
        tunnel.getRuntimeTunnelConfiguration { [weak self] tunnelConfiguration in
            guard let tunnelConfiguration = tunnelConfiguration else { return }

            if let sentdata = tunnelConfiguration.peers[0].txBytes{
                self?.sentdatalbl.stringValue = (self?.prettyBytes(sentdata))!
                print("send data from configuration",self?.prettyBytes(sentdata))
            }


            if let recievedata = tunnelConfiguration.peers[0].rxBytes{
                self?.receiveddatalbl.stringValue = (self?.prettyBytes(recievedata))!
                print("recievedata from configuration ",self?.prettyBytes(recievedata))
            }

            if let LastHandshake = tunnelConfiguration.peers[0].lastHandshakeTime{
                UserDefaults.standard.set(LastHandshake, forKey: "LastHandshake")
                UserDefaults.standard.synchronize()
            }



            if let connecteddate = UserDefaults.standard.object(forKey: "ConnectedDate"){
                print("date is present in prefrences ")
                self?.timelbl.stringValue = self!.prettyTimeAgo(timestamp: connecteddate as! Date)
            }
            else{

                print("date is not present in prefrences ")
                if let connectedtime = tunnelConfiguration.peers[0].lastHandshakeTime{
                    print("connected time1",connectedtime)

                    UserDefaults.standard.set(connectedtime, forKey: "ConnectedDate")
                    UserDefaults.standard.synchronize()
                    // print("Connected time",self!.prettyTimeAgo(timestamp: connectedtime))
                    if let connecteddate = UserDefaults.standard.object(forKey: "ConnectedDate"){
                        self?.timelbl.stringValue = self!.prettyTimeAgo(timestamp: connecteddate as! Date)
                    }

                }

            }


        }

}

    private func prettyBytes(_ bytes: UInt64) -> String {
        switch bytes {
        case 0..<1024:
            return "\(bytes) B"
        case 1024 ..< (1024 * 1024):
            return String(format: "%.2f", Double(bytes) / 1024) + " KB"
        case 1024 ..< (1024 * 1024 * 1024):
            return String(format: "%.2f", Double(bytes) / (1024 * 1024)) + " MB"
        case 1024 ..< (1024 * 1024 * 1024 * 1024):
            return String(format: "%.2f", Double(bytes) / (1024 * 1024 * 1024)) + " GB"
        default:
            return String(format: "%.2f", Double(bytes) / (1024 * 1024 * 1024 * 1024)) + " TB"
        }
    }




    //MARK: CheckTunnelmanager

    fileprivate func connectedUI() {
        checkmanager()
        statuslbl.stringValue = "Conneceted!"
        statuslbl.textColor = NSColor(hexString: "#22CC77")
    }

    fileprivate func disConnectedUI() {
        stopTimer()
        lastdurationlbl.stringValue = "Last Handshake"
        statuslbl.stringValue = "Not Connected!"
        statuslbl.textColor = NSColor(hexString: "#FF0033")

        sentdatalbl.stringValue = "-"
        receiveddatalbl.stringValue = "-"
    }

    fileprivate func noInterNetUI() {

        lastdurationlbl.stringValue = "Last Handshake"
        statuslbl.stringValue = "No Internet Connection!"
        statuslbl.textColor = NSColor(hexString: "#FF0033")

        sentdatalbl.stringValue = "-"
        receiveddatalbl.stringValue = "-"
    }

    fileprivate func checktunnelstatus() {
        if(UserDefaults.standard.isLoggedIn() == true) {

            let tunnel = self.tunnelsManager!.tunnel(named: Constants.tunnelName)!
            // print("tunnel name", tunnel.name)
            //    print("tunnel status in settunnelmanager method", tunnel.status)
            if tunnel.status == .active {
                connectedUI()

            } else {

                disConnectedUI()

            }

            // print("peers count", "\(tunnel.tunnelConfiguration?.peers.count)")
        }
    }

    func checkmanager(){
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard error == nil else {
                NSLog("Unexpected error: \(error).");
                return
            }
            if (managers?.count != 0)
            {
                do
                {
                    if let list = managers {
                        print("Provider manager count",managers?.count)
                        for i in 0..<list.count {


                            if let tunnelname = (managers?[i].tunnelConfiguration?.name!){
                                if tunnelname == Constants.tunnelName{


                                    if let connecteddate = managers?[i].connection.connectedDate{
                                        print("manager tunnel time",self.prettyTimeAgo(timestamp: (managers?[i].connection.connectedDate)!))
                                        print("connected date",connecteddate)
                                        UserDefaults.standard.set(connecteddate, forKey: "startdate")
                                        UserDefaults.standard.synchronize()
                                    }




                                    print("manager tunnel name",managers?[i].tunnelConfiguration?.name)
                                    NSLog("Found VPN with target \(managers?[i].localizedDescription)")


                                }
                            }

                        }
                        self.starttimer()
                    }

                }
                catch
                {
                    NSLog("Unexpected error: \(error).");
                }
            }
            else
            {
                NSLog("Not found, creating new");

            }
        }
    }

    //MARK: Time and Data configure method

    private func prettyTimeAgo(timestamp: Date) -> String {
        let now = Date()
        let timeInterval = Int64(now.timeIntervalSince(timestamp))
        switch timeInterval {
        case ..<0: return tr("tunnelHandshakeTimestampSystemClockBackward")
        case 0: return tr("tunnelHandshakeTimestampNow")
        default:
            return  prettyTime(secondsLeft: timeInterval)
        }
    }

    private func prettyTime(secondsLeft: Int64) -> String {
        var left = secondsLeft
        var timeStrings = [String]()
        let years = left / (365 * 24 * 60 * 60)
        left = left % (365 * 24 * 60 * 60)
        let days = left / (24 * 60 * 60)
        left = left % (24 * 60 * 60)
        let hours = left / (60 * 60)
        left = left % (60 * 60)
        let minutes = left / 60
        let seconds = left % 60

        //  #if os(iOS)
        if years > 0 {
            return years == 1 ? tr(format: "tunnelHandshakeTimestampYear (%d)", years) : tr(format: "tunnelHandshakeTimestampYears (%d)", years)
        }
        if days > 0 {
            return days == 1 ? tr(format: "tunnelHandshakeTimestampDay (%d)", days) : tr(format: "tunnelHandshakeTimestampDays (%d)", days)
        }
        if hours > 0 {
            let hhmmss = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            return  hhmmss
        }
        if minutes > 0 {
            let mmss = String(format: "00:%02d:%02d", minutes, seconds)
            return  mmss
        }
        return String(format: "00:00:%02d", seconds)
        //        #elseif os(macOS)
        //        if years > 0 {
        //            timeStrings.append(years == 1 ? tr(format: "tunnelHandshakeTimestampYear (%d)", years) : tr(format: "tunnelHandshakeTimestampYears (%d)", years))
        //        }
        //        if days > 0 {
        //            timeStrings.append(days == 1 ? tr(format: "tunnelHandshakeTimestampDay (%d)", days) : tr(format: "tunnelHandshakeTimestampDays (%d)", days))
        //        }
        //        if hours > 0 {
        //            timeStrings.append(hours == 1 ? tr(format: "tunnelHandshakeTimestampHour (%d)", hours) : tr(format: "tunnelHandshakeTimestampHours (%d)", hours))
        //        }
        //        if minutes > 0 {
        //            timeStrings.append(minutes == 1 ? tr(format: "tunnelHandshakeTimestampMinute (%d)", minutes) : tr(format: "tunnelHandshakeTimestampMinutes (%d)", minutes))
        //        }
        //        if seconds > 0 {
        //            timeStrings.append(seconds == 1 ? tr(format: "tunnelHandshakeTimestampSecond (%d)", seconds) : tr(format: "tunnelHandshakeTimestampSeconds (%d)", seconds))
        //        }
        //        return timeStrings.joined(separator: ", ")
        //        #endif
    }
}
