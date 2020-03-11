// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Cocoa
import Foundation
import NetworkExtension
import os.log



class FirstMacOSViewController: NSViewController {
    private var statusObservationToken: AnyObject?
    var tunnelsManager: TunnelsManager?
    var countrymodel = CountryListModel()
    var countryitmelist =  Array<CountryListModel>()
    var tunnelsTracker: TunnelsTracker?
    var statusItemController: StatusItemController?
    var tunnelViewModel: TunnelViewModel?
    var clicked: Bool = false
    var tunnelname = ""
    var devicetoken = ""
    var vpnkey = ""
    var pvkey = ""
    var pubkey = ""
    var dns = ""
    var myaddress = ""
    var endpoint = ""
    var presharekey = ""
    var defaultlocationId = "0"
    var selectedlocationid = ""
    var isExists = ""
    var mydate : Date?
    var receivedata:UInt64?
    var sentdata:UInt64?
    var connectiontype = ""
    var myreloadtimer: Timer?
    var echoapitimer: Timer?
    var modifytunnel = ""
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    static let peerFields: [TunnelViewModel.PeerField] = [
        .publicKey, .preSharedKey, .endpoint,
        .allowedIPs, .persistentKeepAlive,
        .rxBytes, .txBytes, .lastHandshakeTime
    ]


    init(tunnelsManager: TunnelsManager) {
        self.tunnelsManager = tunnelsManager
        super.init(nibName: nil, bundle: nil)
    }

    //    required init?(coder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    @IBOutlet weak var locationview: NSView!

    @IBOutlet weak var countrynamelbl: NSTextField!

    @IBOutlet weak var internetcheckpopupview: NSView!
    @IBOutlet public var connectbtn: NSButton!

    @IBOutlet weak var countrymenu: NSPopUpButton!

    @IBOutlet weak var timeheightconstant: NSLayoutConstraint!

    @IBOutlet weak var mainview: NSView!


    @IBOutlet weak var statusview: NSView!

    @IBOutlet weak var statuslbl: NSTextField!

    @IBOutlet weak var loadermainview: NSView!

    @IBOutlet weak var loaderindicator: NSProgressIndicator!

    @IBOutlet weak var bottomlbl: NSTextField!
    @IBOutlet weak var statusimgview: NSImageView!

    @IBOutlet weak var connectedtimelbl: NSTextField!

    @IBAction func connectbtn(_ sender: NSButton) {

        let p = connectbtn.title
        print("p value", p)


        if Reachabilitycheck.isConnectedToNetwork() {
            //   print("Yes! internet is available.")
            if let tunnelsManager = self.tunnelsManager {

                if(UserDefaults.standard.isLoggedIn() == false) {

                    self.addNewTunnel(tunnelsManager: tunnelsManager)

                } else
                {
                    print("already installed")

                    let tunnel = tunnelsManager.tunnel(named: Constants.tunnelName)!

                    // print("tunnel name", tunnel.name)

                    if tunnel.status == .active {
                        showView(view: internetcheckpopupview, hidden: true)
                        self.internetcheckpopupview.wantsLayer = true
                        self.internetcheckpopupview.layer?.backgroundColor = NSColor(hexString: "#22BB77").cgColor
                        tunnelsManager.startDeactivation(of: tunnel)
                    } else {
                        hideView(view: internetcheckpopupview, hidden: false)
                        tunnelsManager.startActivation(of: tunnel)
                        checkmanager()
                    }
                }
            }
            else {

            }
        }
        else
        {
            print("no internet connection")
            dialogOKCancel(question: Constants.tunnelName, text: "No internet connection!")
            nointernetErrorUI()
        }
    }


    @IBAction func countrylistbtn(_ sender: NSButton) {
        let countryvc = self.storyboard?.instantiateController(withIdentifier: "country") as! CountryListViewController
        self.selectedlocationid = ""
        self.navigationController.pushViewController(countryvc, animated: true)
    }

    @IBAction func drawerbtn(_ sender: NSButton) {
        let settingvc = self.storyboard?.instantiateController(withIdentifier: "settingsVC") as! SettingViewController
        settingvc.setTunnelsManager(tunnelsManager: self.tunnelsManager!)
        self.navigationController.pushViewController(settingvc, animated: true)
    }

    func hideView(view: NSView, hidden: Bool) {

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 2.0
            view.animator().alphaValue = 0
            // set properties to animate
        }, completionHandler: {


            // do stuff
        })
    }

    func showView(view: NSView, hidden: Bool) {

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 2.0
            view.animator().alphaValue = 1
            // set properties to animate
        }, completionHandler: {


            // do stuff
        })
    }

    fileprivate func showloader() {
        loaderindicator.startAnimation(self)
        loadermainview.isHidden = false

    }

    fileprivate func stoploader() {

        loaderindicator.stopAnimation(self)
        loadermainview.isHidden = true
    }

    func dialogOKCancel(question: String, text: String) {
        let a = NSAlert()
        a.messageText = question
        a.informativeText = text
        a.addButton(withTitle: "Ok")

        a.alertStyle = NSAlert.Style.warning

        a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                print("Okey press")
            }
        })
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
     //   self.startObservingTunnelStatuses()
        self.countrynamelbl.stringValue = "Bengaluru india"
        print("Inside FirstMacosVC Viewdidload")
         mainview.wantsLayer = true
        mainview.layer?.backgroundColor = NSColor(hexString: "#677080").cgColor

        loaderindicator.wantsLayer = true
        loadermainview.wantsLayer = true
        loadermainview.layer?.backgroundColor = NSColor(hexString: "#DCDCDC").withAlphaComponent(0.10).cgColor
        loaderindicator.layer?.backgroundColor = NSColor.clear.cgColor


        NotificationCenter.default.addObserver(self, selector: #selector(refreshList), name: .refresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tunnelStatus), name: .tunnelStatus, object: nil)

//        removeobserverCheckStatus()
//        addobserverCheckStatus()
    }


    override func viewWillAppear() {
        print("Inside FirstMacosVC viewWillAppear")

        StatusviewUIDesign()
        locationViewUiDesign()
        mainview.wantsLayer = true
        statusview.wantsLayer = true
        statusview.layer?.backgroundColor = NSColor(hexString: "#FFFFFF").cgColor
        let buttoncolor = NSColor(hexString: "#0077CC")
        self.connectbtn.set(textColor: buttoncolor)
        ApiManager.sharedInstance.networkcheckapicall(timeoutinterval: 3) { (networkstatus) in
            if(UserDefaults.standard.isLoggedIn() == true) {
                let tunnel = self.tunnelsManager!.tunnel(named: Constants.tunnelName)!
                if networkstatus == false{
                    print("network off")
                    if tunnel.status == .active {
                        DispatchQueue.main.async {
                            self.nointernetconnectUI()
                        }

                    }
                    else if tunnel.status == .inactive{
                        DispatchQueue.main.async {
                            self.nointernetErrorUI()
                        }
                    }
                }
                else{
                    print("network on")
                    self.refereshView()
                }
            }else{

                if networkstatus == false{

                        DispatchQueue.main.async {
                            self.nointernetconnectUI()
                        }

                }
                else{
                    DispatchQueue.main.async {
                        self.disconnectUI()
                        print("new user with no config under viewwillappear")
                        self.refereshView()
                    }

                }


            }
        }
    }



    override func viewWillDisappear() {
        print("Inside FirstMacosVC viewWillDisappear")
        stopechoTimer()
       // removeobserverCheckStatus()
        stopTimer()
    }



    func addobserverCheckStatus()   {
        NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: nil,
            queue: nil) { notification in
                print("received NEVPNStatusDidChangeNotification")
                let nevpnconn = notification.object as? NEVPNConnection
                let status = nevpnconn?.status
                self.checkNEStatus(status: status!)
        }
    }

    func removeobserverCheckStatus()  {
         NotificationCenter.default.removeObserver(self, name: .NEVPNStatusDidChange, object: nil)
    }

    //MARK: Refreshview after viewdidbecome active call

    fileprivate func refereshView() {


        checkTunnelStatusByTunnelmanager(tunnelmanager: self.tunnelsManager!)

        print("Tunnel manager count",self.tunnelsManager?.numberOfTunnels())
        if (self.tunnelsManager?.numberOfTunnels())! > 0
        {
            if(UserDefaults.standard.isLoggedIn() == true)
            {

                let tunnel = self.tunnelsManager!.tunnel(named: Constants.tunnelName)!

                tunnelViewModel = TunnelViewModel(tunnelConfiguration: tunnel.tunnelConfiguration)
                if tunnel.status == .active {
                    checkmanager()
                    if !self.selectedlocationid.isEmpty{

                        tunnelsManager!.startDeactivation(of: tunnel)


                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            // your code here

                            self.modifytunnel = "modify"
                            self.callRegisterapi()
                        }
                    }else{

                        print("country name",UserDefaults.standard.getlocationName())
                        DispatchQueue.main.async {
                            self.connectUI()
                             self.countrynamelbl.stringValue = UserDefaults.standard.getlocationName()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.callEchoAPI()
                        }
                        //   self.countrymenu.setTitle(UserDefaults.standard.getlocationName())
                    }

                }
                else if tunnel.status == .inactive
                {

                    if !self.selectedlocationid.isEmpty
                    {

                        self.connectingUI()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            // your code here
                            self.modifytunnel = "modify"
                            self.callRegisterapi()
                        }
                    }
                    else
                    {
                        disconnectUI()
                        removeConnectedDate()
                        callRegisterapi()
                    }

                }

            }
            else{
                callRegisterapi()
            }
        }else{

            UserDefaults.standard.setLoggedIn(value: false)
            UserDefaults.standard.setstatusapi(value: false)
            UserDefaults.standard.synchronize()
            callRegisterapi()
        }
    }


    //MARK: InternetConnectivity check by api call

    fileprivate func internetConnectionCheck() {

        ApiManager.sharedInstance.networkcheckapicall(timeoutinterval: 10) { (networkstatus) in
            if(UserDefaults.standard.isLoggedIn() == true) {
                let tunnel = self.tunnelsManager!.tunnel(named: Constants.tunnelName)!
                if networkstatus == false{
                    print("network off")
                    if tunnel.status == .active {
                        DispatchQueue.main.async {
                            self.nointernetconnectUI()
                        }

                    }
                    else if tunnel.status == .inactive{
                        DispatchQueue.main.async {
                             self.nointernetErrorUI()
                        }

                    }

                }
                else{
                    print("network on")
                    self.refereshView()
//                    if tunnel.status == .active {
//                        DispatchQueue.main.async {
//                            self.locationview.isHidden = false
//                            self.statuslbl.stringValue = "Connected"
//                        }
//                    } else if tunnel.status == .inactive{
//
//                    }

                }
            }
        }
    }



    func checkmanager()
    {
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
                                        UserDefaults.standard.set(connecteddate, forKey: "ConnectedDate")
                                        UserDefaults.standard.synchronize()
                                    }


                                    print("manager tunnel name",managers?[i].tunnelConfiguration?.name)
                                    NSLog("Found VPN with target \(managers?[i].localizedDescription)")
                                }
                            }

                        }
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





    // MARK: Getcountry by Noticiation
    @objc func refreshList(_ notification: Notification) {
        //self.modifytunnel = "modify"
        if let object = notification.object as? [String: Any] {
            if let countryId = object["countryId"] as? String {
                self.selectedlocationid = countryId
                print("countryID in notification get method in home VC = ",countryId)
            }
            if let countryName = object["countryName"] as? String {
                self.countrynamelbl.stringValue =  countryName
                print("country Name in notification get method in home VC = ",countryName)
            }
        }
    }

    // MARK: TunnelStatus by Noticiation
    @objc func tunnelStatus(_ notification: Notification) {
        if let object = notification.object as? NEVPNStatus {

            print("tunnel notification status",object)
            checkNEStatus(status: object)

        }
    }


    //MARK: VPN Status

    func checkTunnelStatusByTunnelmanager(tunnelmanager : TunnelsManager) {
        if let tunnelsManager = tunnelsManager {
            tunnelsManager.refreshStatuses()
            if(UserDefaults.standard.isLoggedIn() == false) {

            } else {
                // print("tunnel count in Refresh button while app become active", tunnelsManager.numberOfTunnels())

                if(tunnelsManager.numberOfTunnels() > 0 ) {
                    let tunnel = tunnelsManager.tunnel(named: Constants.tunnelName)!
                    //     print("tunnel name", tunnel.name)

                    if tunnel.status == .active {



                    } else {

                    }
                }
                else {


                }

            }

        }
    }


    //MARK: Countrymenubtn


//    @IBAction func countrypopbtn(_ sender: Any) {
//        print("inside popmenu")
//        let id = countrymenu.indexOfSelectedItem
//        print("countryid %@ country name %@",self.countryitmelist[id].locationId,self.countryitmelist[id].locationName)
//        self.selectedlocationid = String(self.countryitmelist[id].locationId)
//        callRegisterapi()
//        self.countrymenu.setTitle(UserDefaults.standard.getlocationName())
//
//
//    }


    //MARK: Registerapi method

    func callRegisterapi()
    {
        if(UserDefaults.standard.isLoggedIn() == true) {

            //  print("Don't genrate public key and private key")
            //All ready installed in app and genrated keys for same.
            // Use all ready Genrated publickey and private key

            self.registerdevice(pubkey: UserDefaults.standard.ispublickey(), devicetoken:UserDefaults.standard.isdevicetoken())


            print("private key",UserDefaults.standard.isprivatekey())
        }
        else
        {
            if(UserDefaults.standard.isgetapiatatus() == true)
            {

                //  print("Don't genrate public key and private key")
                //All ready installed in app and genrated keys for same.
                // Use all ready Genrated publickey and private key
                print("private key",UserDefaults.standard.isprivatekey())
                self.registerdevice(pubkey: UserDefaults.standard.ispublickey(), devicetoken:UserDefaults.standard.isdevicetoken())



            }
            else{
                //New installation in app and genrated keys for same.
                // print("genrate public key and private key")
                // Genrate publickey and private key

                let privateKey = Curve25519.generatePrivateKey()
                let publicKey = Curve25519.generatePublicKey(fromPrivateKey: privateKey)
                //    print("private key",privateKey.base64Key())
                //   print("public key",publicKey.base64Key())



                UserDefaults.standard.setpublickkey(value: publicKey.base64Key()!)
                UserDefaults.standard.setprivatekkey(value: privateKey.base64Key()!)
                UserDefaults.standard.setstatusapi(value: true)
                UserDefaults.standard.synchronize()



                self.registerdevice(pubkey: UserDefaults.standard.ispublickey(), devicetoken: UserDefaults.standard.isdevicetoken())
            }
        }
    }


    //MARK: EchoApi status method

    @objc func echocall()
    {
        callEchoAPI()
    }
     fileprivate func callEchoAPI() {

        ApiManager.sharedInstance.networkcheckapicall(timeoutinterval: 200) { (networkstatus) in

            if networkstatus == false{
                print("network off")
                let tunnel = self.tunnelsManager!.tunnel(named: Constants.tunnelName)!
                self.tunnelsManager?.startDeactivation(of: tunnel)
                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "GreenSignal",
//                                                  message: "Please check your Internet Connection",
//                                                  preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//
//                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
//
                }


            }
            else{
               // self.getEchoCall()

                print("network on")
            }
        }

    }

    func getEchoCall() {


        ApiManager.sharedInstance.getAPICalls(apiURL:Constants.APIURLS.echoapiUrl, onSuccess: { jsondata in
            print("json value from api",jsondata)

            do {
                let json = try JSONSerialization.jsonObject(with: jsondata, options: [])
                print(json)


                if let responseData = json as? [String: Any] { // Parse dictionary
                    if (responseData["isConnected"] as? Bool) != nil  {
                        let serverstatus = responseData["isConnected"] as? Bool
                        if serverstatus == true{
                            print("server connected from echo api call")
                        }else{
                            print("server notconnected from echo api call")
                            let tunnel = self.tunnelsManager!.tunnel(named: Constants.tunnelName)!
                            self.tunnelsManager?.startDeactivation(of: tunnel)
                        }


                    }
                }
            } catch {
                print("error in echo call->",error)
            }

        }, onFailure: { error in

            DispatchQueue.main.async {
//                let alert = UIAlertController(title: "GreenSignal",
//                                              message: error.localizedDescription,
//                                              preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//
//                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)


            }
        })




    }



    //MARK: RegisterDevice method

    func registerdevice(pubkey : String, devicetoken:String)
    {

        ApiManager.sharedInstance.networkcheckapicall(timeoutinterval: 3) { (networkstatus) in


                if networkstatus == false{
                    print("network off in registerdevice")


                }
                else
                {
                    print("network on in registerdevice")
                    DispatchQueue.main.async {
                        self.showloader()

                    }

                    var countryId = ""
                    if !self.selectedlocationid.isEmpty{
                        countryId = self.selectedlocationid

                    }else{
                        if(UserDefaults.standard.isLoggedIn() == true)
                        {
                            if(UserDefaults.standard.getlocationId() == ""){
                                countryId = self.defaultlocationId
                            }
                            else{
                                countryId = UserDefaults.standard.getlocationId()
                            }
                        }else{
                            countryId = self.defaultlocationId
                        }
                    }

                    let params = [Constants.Apikeys.Devicepublickkey:pubkey,
                                  Constants.Apikeys.Devicetoken:devicetoken,
                                  Constants.Apikeys.Countryid : countryId,
                                  Constants.Apikeys.Devicetype : "2"]

                    ApiManager.sharedInstance.postAPICalls(apiURL: Constants.APIURLS.globalapiUrl+Constants.MethodName.resgitermethod, params: params, onSuccess: {
                        jsondata in

                        do {
                            let json = try JSONSerialization.jsonObject(with: jsondata, options: [])
                            print("Rsponse JSON data",json)


                            if let responseData = json as? [String: Any] { // Parse dictionary


                                if let successcode = responseData["code"] as? Int{
                                    if successcode == 200{
                                        if let data = responseData["response"] as? [String: Any] {
                                            //  Parse an array containing dictionaries

                                            if data["clientIp"] != nil{
                                                self.myaddress =  data["clientIp"]! as! String

                                                //      print("clientiIp",data!["clientIp"])
                                            }
                                            if data["dnsIp"] != nil{
                                                self.dns = data["dnsIp"]! as! String
                                                //     print("dnsIp",data!["dnsIp"])
                                            }
                                            if data["serverIp"] != nil{

                                                //    print("serverIp",data!["serverIp"])
                                            }
                                            if data["serverPublicKey"] != nil{
                                                self.pubkey = data["serverPublicKey"]! as! String
                                                //    print("serverPublicKey",data!["serverPublicKey"])
                                            }
                                            if data["serverEndpoint"] != nil{
                                                self.endpoint = data["serverEndpoint"]! as! String
                                                //    print("serverEndpoint",data!["serverEndpoint"])
                                            }
                                            if data["allowedIPs"] != nil{

                                                //   print("allowedIPs",data!["allowedIPs"])
                                            }
                                            if data["devicePublicKey"] != nil{

                                                //   print("devicePublicKey",data!["devicePublicKey"])
                                            }

                                            if data["isExists"] != nil{

                                                self.isExists = data["isExists"]! as! String
                                            }

                                            if data["locationId"] != nil{

                                                UserDefaults.standard.setselectedLocationId(value: data["locationId"]! as! String)
                                            }

                                            if data["locationName"] != nil{

                                                UserDefaults.standard.setselectedLocationName(value: data["locationName"]! as! String)
                                            }

                                            let vpnkeystring: String = "[Interface]\nPrivateKey = \(UserDefaults.standard.isprivatekey())\nAddress = \(self.myaddress)\nDNS = \(self.dns)\n\n[Peer]\nPublicKey = \(self.pubkey)\nAllowedIPs = 0.0.0.0/0, ::/0\nEndpoint =\(self.endpoint)\n"

                                            print("vpnketstring in api method",vpnkeystring)

                                            UserDefaults.standard.setvpnkey(value: vpnkeystring)
                                            UserDefaults.standard.synchronize()
                                            //   print("vpnkey userdefault",UserDefaults.standard.isvpnkey())


                                            if(UserDefaults.standard.isLoggedIn() == true)
                                            {
                                                if !self.selectedlocationid.isEmpty || self.isExists == "0"
                                                {
                                                    if self.modifytunnel == "modify"{

                                                        self.modifyTunnel(tunnelsManager: self.tunnelsManager!)
                                                       // self.removeTunnel(tunnelsManager: self.tunnelsManager!)
                                                    }
                                                }
                                            }
                                            DispatchQueue.main.async {
                                                self.countrynamelbl.stringValue = (data["locationName"]! as! String)
                                                //MKProgress.hide(true)
                                            }


                                        }
                                    }else{

                                    }
                                    DispatchQueue.main.async {
                                        self.stoploader()
                                    }

                                }
                            }
                        } catch {
                            print(error)
                        }
                    }, onFailure: {
                        error in
                        DispatchQueue.main.async {
                                           self.stoploader()
                            self.dialogOKCancel(question: Constants.tunnelName, text: error.localizedDescription)
                        }

                    })

                }

        }
    }


/*    func registerdevice(pubkey : String, devicetoken:String)
    {
        if NetworkReachabilityManager()?.isReachable == true {
            //  print("Yes! internet is available.")
            showloader()
            var countryId = ""
            if !self.selectedlocationid.isEmpty{
                countryId = self.selectedlocationid
            }else{
                if(UserDefaults.standard.isLoggedIn() == true)
                {
                    if(UserDefaults.standard.getlocationId() == ""){
                        countryId = self.defaultlocationId
                    }
                    else{
                        countryId = UserDefaults.standard.getlocationId()
                    }
                }else{
                    countryId = self.defaultlocationId
                }
            }


            let params = [Constants.Apikeys.Devicepublickkey:pubkey,
                          Constants.Apikeys.Devicetoken:devicetoken,
                          Constants.Apikeys.Countryid : countryId,
                          Constants.Apikeys.Devicetype : "2"]     // devicetype 3 for MAC



            let manager = Alamofire.SessionManager.default
            manager.session.configuration.timeoutIntervalForRequest = 360


            manager.request(Constants.APIURLS.globalapiUrl+Constants.MethodName.resgitermethod, method: .post, parameters: params, encoding:URLEncoding.default).responseJSON { response in
                //  print("Request: \(String(describing: response.request))")   // original url request
                //   print("Response: \(String(describing: response.response))") // http url response
                //   print("Result: \(response.result)")                         // response serialization result

                if response.result.isFailure == true {
                    return
                }

                let json = JSON(response.result.value!)


                //                if json["response"]["responseInfo"]["status"].intValue == 200 {
                //                    // we're OK to parse!
                //                }
                if json["code"].intValue == 200{

                    let response  = json["response"].dictionary
                    print("response dic",response)
                    //                self.selectedlocationid = response['locationId']

                    if response!["clientIp"] != nil{
                        self.myaddress =  response!["clientIp"]!.stringValue

                        //      print("clientiIp",response!["clientIp"])
                    }
                    if response!["dnsIp"] != nil{
                        self.dns = response!["dnsIp"]!.stringValue
                        //     print("dnsIp",response!["dnsIp"])
                    }
                    if response!["serverIp"] != nil{

                        //    print("serverIp",response!["serverIp"])
                    }
                    if response!["serverPublicKey"] != nil{
                        self.pubkey = response!["serverPublicKey"]!.stringValue
                        //    print("serverPublicKey",response!["serverPublicKey"])
                    }
                    if response!["serverEndpoint"] != nil{
                        self.endpoint = response!["serverEndpoint"]!.stringValue
                        //    print("serverEndpoint",response!["serverEndpoint"])
                    }
                    if response!["allowedIPs"] != nil{

                        //   print("allowedIPs",response!["allowedIPs"])
                    }
                    if response!["devicePublicKey"] != nil{

                        //   print("devicePublicKey",response!["devicePublicKey"])
                    }

                    if response!["isExists"] != nil{

                        self.isExists = response!["isExists"]!.stringValue
                    }

                    if response!["locationId"] != nil{

                        UserDefaults.standard.setselectedLocationId(value: response!["locationId"]!.stringValue)
                    }

                    if response!["locationName"] != nil{

                        UserDefaults.standard.setselectedLocationName(value: response!["locationName"]!.stringValue)
                    }

                    let vpnkeystring: String = "[Interface]\nPrivateKey = \(UserDefaults.standard.isprivatekey())\nAddress = \(self.myaddress)\nDNS = \(self.dns)\n\n[Peer]\nPublicKey = \(self.pubkey)\nAllowedIPs = 0.0.0.0/0, ::/0\nEndpoint =\(self.endpoint)\n"

                      print("vpnketstring in api method",vpnkeystring)

                    UserDefaults.standard.setvpnkey(value: vpnkeystring)
                    UserDefaults.standard.synchronize()
                    //   print("vpnkey userdefault",UserDefaults.standard.isvpnkey())

               //     self.countrymenu.setTitle(response!["locationName"]!.stringValue)
                    self.countrynamelbl.stringValue = response!["locationName"]!.stringValue
                    if(UserDefaults.standard.isLoggedIn() == true)
                    {
                        if !self.selectedlocationid.isEmpty || self.isExists == "0"
                        {
                            self.modifyTunnel(tunnelsManager: self.tunnelsManager!)
                        }
                    }


                    self.stoploader()

                }
                else{

                }

                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    //   print("Data: \(utf8Text)") // original server data as UTF8 string
                    //UIViewController.removeSpinner(spinner: self.sv)
                }

            }

            // do some tasks..
        }else{

        }

    }
 */


    //MARK: Tunnel configuration methods
    func addNewTunnel(tunnelsManager : TunnelsManager) {
        let scannedTunnelConfiguration = try? TunnelConfiguration(fromWgQuickConfig: UserDefaults.standard.isvpnkey(), called: Constants.tunnelName)
        guard let tunnelConfiguration = scannedTunnelConfiguration else {
            //  print("configuration failed")
            return
        }
        // print("configuration pass")
        tunnelsManager.add(tunnelConfiguration: tunnelConfiguration) { result in
            switch result {

            case .failure(let error):
                print("failed", error)

                // print("Errormessage", TunnelsManagerError.systemErrorOnAddTunnel(systemError: error))

            //                self.switchButton.setOn(false, animated: true)
            case .success:
                // print("Success")
                 print("fresh install")
                UserDefaults.standard.setLoggedIn(value: true)
                UserDefaults.standard.synchronize()

                let tunnel = tunnelsManager.tunnel(named: Constants.tunnelName)!
                //  print("tunnel name", tunnel.name)
                tunnelsManager.startActivation(of: tunnel)


            }
        }
    }




    func modifyTunnel(tunnelsManager : TunnelsManager) {

        print("Inside tunnel modify method")

        let tunnel = tunnelsManager.tunnel(named: Constants.tunnelName)!

        //           tunnelsManager.startDeactivation(of: tunnel)
        let scannedTunnelConfiguration = try? TunnelConfiguration(fromWgQuickConfig: UserDefaults.standard.isvpnkey(), called: Constants.tunnelName)
        guard let tunnelConfiguration = scannedTunnelConfiguration else {
            //  print("configuration failed")
            return
        }

        tunnelsManager.modify(tunnel: tunnel, tunnelConfiguration: tunnelConfiguration, onDemandOption: ActivateOnDemandOption.off) { [weak self] error in

            if let error = error {
               // self?.switchButton.setOn(false, animated: true)
                ErrorPresenter.showErrorAlert(error: error, from: self)
                return
            }else
            {
                print("Success modify")
                self!.tunnelsManager?.startActivation(of: tunnel)
            }
        }
  }


    func removeTunnel(tunnelsManager : TunnelsManager) {
        print("inside remove tunnel manager")
        let tunnel = tunnelsManager.tunnel(named: Constants.tunnelName)!

//        //           tunnelsManager.startDeactivation(of: tunnel)
//        let scannedTunnelConfiguration = try? TunnelConfiguration(fromWgQuickConfig: UserDefaults.standard.isvpnkey(), called: Constants.tunnelName)
//        guard let tunnelConfiguration = scannedTunnelConfiguration else {
//            //  print("configuration failed")
//            return
//        }
//


        tunnelsManager.remove(tunnel: tunnel) { error in
            if error != nil {
                ErrorPresenter.showErrorAlert(error: error!, from: self)

            } else {
                print("removed success fully")
                self.addNewTunnel(tunnelsManager: tunnelsManager)
            }
        }

    }


    //MARK: settunnelmanager method

    func setTunnelsManager(tunnelsManager: TunnelsManager) {

        print("Inside FirstMacosVC setTunnelsManager")

        if(UserDefaults.standard.isLoggedIn() == false) {
            self.tunnelsManager = tunnelsManager

        } else {
            print("already installed inside settunnel manager")
            //   print("tunnel is set")
            self.tunnelsManager = tunnelsManager

        }
    }


    //MARK: checkStatus method
    func checkNEStatus( status: NEVPNStatus) {

        var btnstatus = ""

        switch status {
        case .invalid:
            print("checkNEStatus NEVPNConnection: Invalid")
        case .disconnected:
            print("checkNEStatus NEVPNConnection: Disconnected")
            btnstatus = "Connect"
        case .connecting:
            print("checkNEStatus NEVPNConnection: Connecting")
            btnstatus = "Connecting"
        case .connected:
            print("checkNEStatus NEVPNConnection: Connected")
            btnstatus = "Disconnect"
        case .reasserting:
            print("checkNEStatus NEVPNConnection: Reasserting")
        case .disconnecting:
            btnstatus = "Disconnecting"
            print("checkNEStatus NEVPNConnection: Disconnecting")
        @unknown default:
            print("checkNEStatus NEVPNConnection: no tunnel")
        }



        let tunnel = self.tunnelsManager!.tunnel(named: Constants.tunnelName)!

        print("checkNEStatus",status)

        if("\(status)" == "disconnected") {

            if !self.selectedlocationid.isEmpty || self.modifytunnel == "modify"
            {
                print("inside the check status new country click")
                self.connectingUI()
                self.tunnelsManager?.startActivation(of: tunnel)

            }else{
                self.disconnectUI()
            }

            removeConnectedDate()


        } else if("\(status)" == "connected") {

            if !self.selectedlocationid.isEmpty || self.modifytunnel == "modify"
            {
                self.selectedlocationid = ""
                self.modifytunnel = ""
            }
            connectUI()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.callEchoAPI()
            }

        }
        else if("\(status)" == "disconnecting" || "\(status)" == "connecting")
        {
            connectingUI()
        }


        connectbtn.title = btnstatus
      //  self.statuslbl.stringValue = btnstatus
    }

    func removeConnectedDate()
    {
        UserDefaults.standard.removeObject(forKey: "ConnectedDate")
        UserDefaults.standard.synchronize()
    }

    func starttimer()
    {
        if myreloadtimer == nil {
             myreloadtimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(FirstMacOSViewController.Timecount), userInfo: nil, repeats: true)
        }
    }

    func stopTimer()
    {
        if myreloadtimer != nil {
            myreloadtimer!.invalidate()
            myreloadtimer = nil
        }
    }

    func startechotimer()
    {
        if echoapitimer == nil {
            echoapitimer = Timer.scheduledTimer(timeInterval:150, target: self, selector: #selector(FirstMacOSViewController.echocall), userInfo: nil, repeats: true)
        }
    }

    func stopechoTimer()
    {
        if echoapitimer != nil {
            echoapitimer!.invalidate()
            echoapitimer = nil
        }
    }


    func disconnectUI()  {

        DispatchQueue.main.async() {
            self.stoploader()
            self.stopTimer()
            self.connectedtimelbl.stringValue = "00:00:00"
            self.timeheightconstant.constant = 0
            self.timeheightconstant.constant = 0

            self.statuslbl.stringValue = "Not Connected"
            self.statusimgview.image = NSImage(named: "Disconnectedimg")
            self.locationview.isHidden = false
            self.bottomlbl.stringValue = "Connect to search securely"
            self.connectbtn.title = "Connect"
            self.mainview.layer?.backgroundColor = NSColor(hexString: "#677080").cgColor
            let buttoncolor = NSColor(hexString: "#0077CC")
            self.connectbtn.set(textColor:buttoncolor)
        }
    }

    func nointernetErrorUI()  {

        DispatchQueue.main.async() {
             self.stoploader()
            self.stopTimer()
            self.connectedtimelbl.stringValue = "00:00:00"
            self.timeheightconstant.constant = 0
            self.timeheightconstant.constant = 0
            self.locationview.isHidden = true
            //self.countrymenu.isHidden = true
            self.statuslbl.stringValue = "Error"
            self.statusimgview.image = NSImage(named: "Errorimg")

            self.bottomlbl.stringValue = "Currently not connected to the internet"
            self.connectbtn.title = "Reconnect"

            self.mainview.layer?.backgroundColor = NSColor(hexString: "#677080").cgColor
            let buttoncolor = NSColor(hexString: "#0077CC")
            self.connectbtn.set(textColor:buttoncolor)
        }
    }

    func nointernetconnectUI()  {

        DispatchQueue.main.async() {
             self.stoploader()
            self.stopTimer()
            self.connectedtimelbl.stringValue = "00:00:00"
            self.timeheightconstant.constant = 0
            self.timeheightconstant.constant = 0
            self.locationview.isHidden = true
            //self.countrymenu.isHidden = true
            self.statuslbl.stringValue = "Error"
            self.statusimgview.image = NSImage(named: "Errorimg")

            self.bottomlbl.stringValue = "Currently not connected to the internet"
            self.connectbtn.title = "Reconnect"
            self.mainview.layer?.backgroundColor = NSColor(hexString: "#677080").cgColor
            let buttoncolor = NSColor(hexString: "#0077CC")
            self.connectbtn.set(textColor:buttoncolor)
        }
    }



    func connectUI()  {

        DispatchQueue.main.async() {

            self.stoploader()
            self.starttimer()
            self.locationview.isHidden = false
            self.statuslbl.stringValue = "Connected"
            self.timeheightconstant.constant = 50
            self.bottomlbl.stringValue = "Secured time"
            self.statusimgview.image = NSImage(named: "Connectedimg")
            self.mainview.layer?.backgroundColor = NSColor(hexString: "#22BB77").cgColor
            self.connectbtn.title = "Disconnect"
            let buttoncolor = NSColor(hexString: "#F2002F")
            self.connectbtn.set(textColor: buttoncolor)
        }
    }
    func connectingUI()  {

        DispatchQueue.main.async() {

            self.connectedtimelbl.stringValue = "00:00:00"
            self.timeheightconstant.constant = 0
            self.timeheightconstant.constant = 0
            self.locationview.isHidden = false
            self.statuslbl.stringValue = "Connecting"
            self.statusimgview.image = NSImage(named: "Connectingimg")

            self.bottomlbl.stringValue = "Please hold on for a momment"
            self.connectbtn.title = "Connecting"
            self.mainview.layer?.backgroundColor = NSColor(hexString: "#677080").cgColor
            let buttoncolor = NSColor(hexString: "#0077CC")
            self.connectbtn.set(textColor:buttoncolor)
        }

//        DispatchQueue.main.async() {
//            // your UI update code
//            let buttoncolor = NSColor(hexString: "#0077CC")
//            self.connectbtn.set(textColor:buttoncolor)
//        }
//        self.statusimgview.image = NSImage(named: "Connectingimg")
    }

    //MARK: StatusviewUIDesign

    fileprivate func locationViewUiDesign() {
        self.locationview.wantsLayer = true
        self.locationview.layer?.cornerRadius = locationview.frame.size.height / 2
        self.locationview.layer?.borderColor = ThemeManager.currentTheme().LocationViewColor.cgColor
        self.locationview.layer?.borderWidth = 1
    }

    func StatusviewUIDesign(){
            statusview.wantsLayer = true
            statusview.layer?.backgroundColor = NSColor.white.cgColor
            statusview.layer?.cornerRadius = 20
            statusview.layer?.shadowOpacity = 1
            statusview.layer?.shadowRadius = 10.0
            statusview.layer?.shadowOffset = CGSize(width: 0, height: 0)
            statusview.layer?.shadowColor = NSColor.lightGray.cgColor
            statusview.layer?.borderWidth = 0
            statusview.layer?.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        //            layerMinXMaxYCorner - Bottom left corner
        //            layerMinXMinYCorner - Top left corner
        //            layerMaxXMaxYCorner - Bottom right corner
        //            layerMaxXMinYCorner - Top right corner

   }


    @objc func Timecount()
    {

        let tunnel = tunnelsManager!.tunnel(named: Constants.tunnelName)!
        tunnel.getRuntimeTunnelConfiguration { [weak self] tunnelConfiguration in
            guard let tunnelConfiguration = tunnelConfiguration else { return }
            if let connecteddate = UserDefaults.standard.object(forKey: "ConnectedDate"){
                print("date is present in prefrences ")
                self!.connectedtimelbl.stringValue = self!.prettyTimeAgo(timestamp: connecteddate as! Date)
            }
            else
            {
                print("date is not present in prefrences ")
                if let connectedtime = tunnelConfiguration.peers[0].lastHandshakeTime
                {
                    print("connected time1",connectedtime)
                    UserDefaults.standard.set(connectedtime, forKey: "LastHandshake")
                    UserDefaults.standard.set(connectedtime, forKey: "ConnectedDate")
                    UserDefaults.standard.synchronize()
                    // print("Connected time",self!.prettyTimeAgo(timestamp: connectedtime))
                    if let connecteddate = UserDefaults.standard.object(forKey: "ConnectedDate")
                    {
                        self!.connectedtimelbl.stringValue = self!.prettyTimeAgo(timestamp: connecteddate as! Date)
                    }
                }
            }
        }
    }

    //MARK: Time and Data configure method

    private func prettyBytes(_ bytes: UInt64) -> String {
        switch bytes {
        case 0..<1024:
            return "\(bytes) B"
        case 1024 ..< (1024 * 1024):
            return String(format: "%.2f", Double(bytes) / 1024) + " KiB"
        case 1024 ..< (1024 * 1024 * 1024):
            return String(format: "%.2f", Double(bytes) / (1024 * 1024)) + " MiB"
        case 1024 ..< (1024 * 1024 * 1024 * 1024):
            return String(format: "%.2f", Double(bytes) / (1024 * 1024 * 1024)) + " GiB"
        default:
            return String(format: "%.2f", Double(bytes) / (1024 * 1024 * 1024 * 1024)) + " TiB"
        }
    }

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



//extension NSView {
//
//    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
//        let path = NSBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        self.layer!.mask = mask
//    }
//
//}
