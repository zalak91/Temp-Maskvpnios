// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Cocoa

class CountryListViewController: NSViewController {

    @IBOutlet weak var topnavigationview: NSView!

    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var cellmainview: NSView!
    @IBOutlet weak var scrollview: NSScrollView!
    @IBOutlet weak var countrytableview: NSTableView!
    var countryListModel = CountryListModel()
    var countryListModelarr = Array<CountryListModel>()

    //MARK: ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()

        getCountryList()
        topnavigationview.wantsLayer = true
        topnavigationview.layer?.backgroundColor = NSColor(hexString: "#DFE1E5").cgColor
        scrollview.hasHorizontalScroller = false
        countrytableview.headerView = nil

        // Do view setup here.
    }

    //MARK: backbtn method
    @IBAction func backbtn(_ sender: Any) {
        self.navigationController.popViewController(animated: true)
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

    //MARK: GetCountrylist api

    fileprivate func callCountryapi() {

        ApiManager.sharedInstance.networkcheckapicall(timeoutinterval: 5) { (networkstatus) in

            if networkstatus == false{
                print("network off")
                DispatchQueue.main.async {
                    self.dialogOKCancel(question: Constants.tunnelName, text:"No internet connection!" )

                }


            }
            else{
                self.getCountryList()
                print("country arr",self.countryListModelarr.count)
                print("network on")
            }
        }

    }

    func getCountryList() {

        self.countryListModelarr.removeAll()
        ApiManager.sharedInstance.getAPICalls(apiURL:Constants.APIURLS.globalapiUrl+Constants.MethodName.countrylist, onSuccess: { jsondata in
            print("json value from api",jsondata)

            do {
                let json = try JSONSerialization.jsonObject(with: jsondata, options: [])
                print(json)


                if let responseData = json as? [String: Any] { // Parse dictionary
                    if let closeDtoList = responseData["response"] as? [[String: Any]] {// Parse an array containing dictionaries
                        if closeDtoList.count > 0 {

                            for data in closeDtoList{
                                print("locationid",data["locationId"] as! String)
                                print("locationCountry",data["locationCountry"] as! String)
                                print("location name",data["locationName"] as! String)
                                print("location name",data["locationCode"] as! String)


                                let locationId = data["locationId"] as! String
                                // Access pivot dictionary
                                let locationCode = data["locationCode"] as! String
                                // Get type from pivot dictionary
                                let locationName = data["locationName"] as! String
                                let locationCountry = data["locationCountry"] as! String
                                let locationFlag = data["locationFlag"] as! String

                                self.countryListModel = CountryListModel(locationId: locationId, locationCode: locationCode, locationName: locationName, locationCountry: locationCountry, locationFlag: locationFlag)
                                self.countryListModelarr.append(self.countryListModel)


                            }
                            DispatchQueue.main.async {
                                self.countrytableview.reloadData()
                            }

                        }
                        else{
                            DispatchQueue.main.async {
                                 self.dialogOKCancel(question: Constants.tunnelName, text:"No country found!" )

                            }
                        }
                    }
                }
            } catch {
                print(error)
            }

        }, onFailure: { error in

            DispatchQueue.main.async {
                self.dialogOKCancel(question: Constants.tunnelName, text:error.localizedDescription )


            }
        })
    }
}

extension CountryListViewController: NSTableViewDataSource, NSTableViewDelegate{

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.countryListModelarr.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {


        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "countryCell"), owner: self) as! customcell
        cell.countrynamelbl?.stringValue = "\(self.countryListModelarr[row].locationName)"

        let imageurl = self.countryListModelarr[row].locationFlag
        if let strUrl = imageurl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let imgUrl = URL(string: strUrl) {
            cell.countryflagimgview.loadImageWithUrl(imgUrl)

        }
        cell.mainview.wantsLayer = true
        cell.mainview.layer?.cornerRadius = 20
        cell.mainview.layer?.shadowColor = NSColor.lightGray.cgColor
        cell.mainview.layer?.borderWidth = 0
        cell.mainview.layer?.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner , .layerMaxXMaxYCorner,.layerMinXMaxYCorner]

        if self.countryListModelarr[row].locationName == UserDefaults.standard.getlocationName() {
             cell.mainview.layer?.backgroundColor = NSColor(hexString: "#22CC77").withAlphaComponent(0.10).cgColor
            //cell.countrynamelbl.textColor = ThemeManager.currentTheme().CountryListSelectedTextBackgroundColor
           cell.tickimgview.isHidden = false
        }else{
            //cell.countrynamelbl.textColor = ThemeManager.currentTheme().CountryListTextBackgroundColor
            cell.tickimgview.isHidden = true
        }



        return cell

    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 72
    }


    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableclick = notification.object as! NSTableView
        print("country list no ",tableclick.selectedRow)
        print("selected country is ",countryListModelarr[tableclick.selectedRow].locationName)

        let countryobject: [String: Any] = ["countryId": self.countryListModelarr[tableclick.selectedRow].locationId, "countryName": self.countryListModelarr[tableclick.selectedRow].locationName]
        NotificationCenter.default.post(name: .refresh, object: countryobject)

        UserDefaults.standard.setselectedLocationId(value: self.countryListModelarr[tableclick.selectedRow].locationId)
        UserDefaults.standard.setselectedLocationName(value: self.countryListModelarr[tableclick.selectedRow].locationName)

        UserDefaults.standard.synchronize()

        self.navigationController?.popToRootViewController(animated: true)


    }

}
