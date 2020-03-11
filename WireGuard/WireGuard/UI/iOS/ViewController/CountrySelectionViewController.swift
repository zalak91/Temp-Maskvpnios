// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON
import MKProgress
import HCSStarRatingView



class CountrySelectionViewController: UIViewController {




    @IBOutlet weak var countrytableview: UITableView!

    var barbuttontitle = ""
    var lastselectedlocation = ""
    var countryListModel = CountryListModel()
    var countryListModelarr = Array<CountryListModel>()

    var countrylistuserdefaults: UserDefaults = UserDefaults.standard

    @IBOutlet weak var ratingmainview: UIView!

    @IBOutlet weak var ratingpopupview: UIView!
    @IBOutlet var sv: UIView!

    @IBOutlet weak var ratingbar: HCSStarRatingView!


    @IBOutlet weak var feedbacktextview: UITextView!

    var cache = NSCache<NSString, CountryListModel>()


    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()

        ThemeManager.applyTheme(theme: ThemeManager.currentTheme())

//        self.navigationController?.navigationBar.titleTextAttributes =
//        [NSAttributedString.Key.foregroundColor: UIColor.white,
//         NSAttributedString.Key.font: UIFont(name: "SairaStencilOne-Regular", size: 32)!]


        self.navigationItem.title = "Country List"  //Country List
        let backButton = UIBarButtonItem()
        backButton.title = barbuttontitle
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
        countrytableview.register(UINib(nibName: "CountryTableViewCell", bundle: nil), forCellReuseIdentifier: "countryCell")
        customLoaderUI()
}





    override func viewWillAppear(_ animated: Bool) {
        print("inside country viewwillappear")



        if let savedPeople = countrylistuserdefaults.object(forKey: "countryList") as? Data
        {

            // Get saved values using below method
            countryListModelarr = NSKeyedUnarchiver.unarchiveObject(with: savedPeople) as! [CountryListModel]
            print("countrylist array",countryListModelarr[5].locationName)
            DispatchQueue.main.async {
                self.countrytableview.reloadData()
                self.countrytableview.setNeedsLayout()
                self.countrytableview.layoutIfNeeded()
            }
//            countryListModelarr = NSKeyedUnarchiver.unarchiveObject(with: savedPeople) as! [CountryListModel]
        }
            callCountryapi()

        adddidbecomeactiveobserver()

    }

    override func viewDidDisappear(_ animated: Bool) {
        print("inside country viewDidDisappear")
        removedidbecomeactiveobserver()

    }

    @objc func applicationDidBecomeActive() {
        // handle event
        if let savedPeople = countrylistuserdefaults.object(forKey: "countryList") as? Data
                {

                    // Get saved values using below method
                    countryListModelarr = NSKeyedUnarchiver.unarchiveObject(with: savedPeople) as! [CountryListModel]
                    print("countrylist array",countryListModelarr[5].locationName)
                    DispatchQueue.main.async {
                        self.countrytableview.reloadData()
                        self.countrytableview.setNeedsLayout()
                        self.countrytableview.layoutIfNeeded()
                    }
        //            countryListModelarr = NSKeyedUnarchiver.unarchiveObject(with: savedPeople) as! [CountryListModel]
                }
                    callCountryapi()

        print("setting page observer fire")


    }


    fileprivate func customLoaderUI() {
        //  MKProgress.config.hudType = .radial
        MKProgress.config.circleBorderColor = UIColor(hexString: "#22CC77")
        MKProgress.config.logoImage = UIImage(named: "AppLogo")
        MKProgress.config.logoImageSize = CGSize(width: 110, height: 110)
        MKProgress.config.backgroundColor = .gray
        MKProgress.config.circleBorderWidth = 8
        MKProgress.config.height = 180.0
        MKProgress.config.width = 180.0
        MKProgress.config.circleRadius = 80.0
        MKProgress.config.hudColor = .clear

    }

    // MARK: Getcountrylist api method
    fileprivate func callCountryapi() {

        ApiManager.sharedInstance.networkcheckapicall(timeoutinterval: 5) { (networkstatus) in

            if networkstatus == false{
                print("network off")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: Constants.tunnelName,
                                                  message: "Please check your Internet Connection",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)

                }


            }
            else{
                self.getCountryList()

                print("country arr",self.countryListModelarr.count)
                print("network on")
            }
        }

    }

    // MARK: Theme change methods


    deinit {
       NotificationCenter.default.removeObserver(self, name: .themeUpdated, object: nil)
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }


    fileprivate func removedidbecomeactiveobserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    fileprivate func adddidbecomeactiveobserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, // UIApplication.didBecomeActiveNotification for swift 4.2+
            object: nil)

    }



    fileprivate func internetConnectionCheck() {

        ApiManager.sharedInstance.networkcheckapicall(timeoutinterval: 3, completion: {networkstatus in
            if networkstatus == false{
                print("network off")

                DispatchQueue.main.async {

                    let alert = UIAlertController(title: Constants.tunnelName,
                                                  message: "No Internet Connection!",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }

                //                LoaderController.sharedInstance.removeLoader()
            }
            else{
                print("network on")
                self.getCountryList()

                // LoaderController.sharedInstance.removeLoader()
            }
        })


    }





    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        self.view.backgroundColor = view.backgroundColor
        self.countrytableview.backgroundColor = ThemeManager.currentTheme().CountryTableviewBackgroundColor

        self.navigationController?.navigationBar.barTintColor = ThemeManager.currentTheme().NavigationBarBackgroundColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().TitleColor]

        self.navigationController?.navigationBar.tintColor = ThemeManager.currentTheme().backbuttonColor
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

                                let locationCode = data["locationCode"] as! String

                                let locationName = data["locationName"] as! String
                                let locationCountry = data["locationCountry"] as! String
                                let locationFlag = data["locationFlag"] as! String

                                self.countryListModel = CountryListModel(locationId: locationId, locationCode: locationCode, locationName: locationName, locationCountry: locationCountry, locationFlag: locationFlag)
                                self.countryListModelarr.append(self.countryListModel)


                            }
                            if (self.countrylistuserdefaults.object(forKey: "countryList") as? Data) != nil
                            {

                            }else{
                                DispatchQueue.main.async {
                                    self.countrytableview.reloadData()
                                    self.countrytableview.setNeedsLayout()
                                    self.countrytableview.layoutIfNeeded()
                                }
                            }


                            let saveData = NSKeyedArchiver.archivedData(withRootObject: self.countryListModelarr)
                            self.countrylistuserdefaults.set(saveData, forKey: "countryList")

                        }
                        else{
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: Constants.tunnelName,
                                                              message: "No country found!",
                                                              preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }

        }, onFailure: { error in

            DispatchQueue.main.async {
                let alert = UIAlertController(title: Constants.tunnelName,
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)


            }
        })
    }

}

extension CountrySelectionViewController : UITableViewDelegate, UITableViewDataSource {


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryListModelarr.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{

        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath) as! CountryTableViewCell

        if self.countryListModelarr[indexPath.row].locationName == UserDefaults.standard.getlocationName() {
            cell.contentView.backgroundColor = ThemeManager.currentTheme().CountryTableviewCellbackgroundColor
            cell.countrynamelbl.textColor = ThemeManager.currentTheme().CountryListSelectedTextBackgroundColor
            cell.selectedrowimg.isHidden = false
        }else{
            cell.countrynamelbl.textColor = ThemeManager.currentTheme().CountryListTextBackgroundColor
            cell.selectedrowimg.isHidden = true
        }


        cell.countrynamelbl.text = self.countryListModelarr[indexPath.row].locationName

        let imageurl = self.countryListModelarr[indexPath.row].locationFlag
        if let strUrl = imageurl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let imgUrl = URL(string: strUrl) {

            cell.countryflagimg.loadImageWithUrl(imgUrl)
        }


        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {






        let countryobject: [String: Any] = ["countryId": self.countryListModelarr[indexPath.row].locationId, "countryName": self.countryListModelarr[indexPath.row].locationName]
        NotificationCenter.default.post(name: .refresh, object: countryobject)

        UserDefaults.standard.setselectedLocationId(value: self.countryListModelarr[indexPath.row].locationId)
        UserDefaults.standard.setselectedLocationName(value: self.countryListModelarr[indexPath.row].locationName)

        UserDefaults.standard.synchronize()

        self.navigationController?.popToRootViewController(animated: true)

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
