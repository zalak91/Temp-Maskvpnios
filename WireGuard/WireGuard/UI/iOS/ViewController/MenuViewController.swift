// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import FirebaseAuth
class MenuViewController: UIViewController {

    @IBOutlet weak var topview: UIView!

    @IBOutlet weak var menutableview: UITableView!

    var barbuttontitle = ""
    @IBOutlet var mainview: UIView!
    @IBOutlet weak var containerview: UIView!

    var menuListItemArr = [String]()
//    var menuListItemImgArrLight = [String]()
//    var menuListItemImgArrDark = [String]()
    var swithbtn : SevenSwitch!
    var tunnelsManager: TunnelsManager?



    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem()
        backButton.title = barbuttontitle
         addObservers()
        ThemeManager.applyTheme(theme: ThemeManager.currentTheme())

        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
               self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = ThemeManager.currentTheme().generalBackgroundColor

        menutableview.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "menuCell")

        menuListItemArr = ["Connection Status", "Dark Theme" , "Share this App" , "Rate Us" , "Server Locations" , "FAQ" , "Legal" , "Logout"]


            // static item list for menu viewcontroller
        //        menuListItemImgArrLight = ["Statusimg","Themeimg" ,"Shareimg","Feedbackimg","LocationPinSetting"]
                       // menuListItemImgArrDark = ["StatusimgDark","ThemeimgDark","ShareimgDark","FeedbackimgDark","LocationPinSettingDark"]

        // Do any additional setup after loading the view.
    }


    @objc func changeTheme() {
        print("Under Theme changed btn method")
        if self.swithbtn.isOn(){
            let theme = Theme.Dark
            ThemeManager.applyTheme(theme: theme)
            swithbtn.setOn(true, animated: true)
           // self.containerview.backgroundColor = UIColor.red

        }
        else{
            let theme = Theme.Default
            ThemeManager.applyTheme(theme: theme)
            swithbtn.setOn(false, animated: true)
            swithbtn.inactiveColor = ThemeManager.currentTheme().DisconnectSwitchColor
           // self.containerview.backgroundColor = UIColor.blue

        }
    }





        deinit {
            NotificationCenter.default.removeObserver(self, name: .themeUpdated, object: nil)
        }

        fileprivate func addObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(changeTheme1), name: .themeUpdated, object: nil)
        }



        @objc fileprivate func changeTheme1() {
            view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
            self.view.backgroundColor = view.backgroundColor
            self.navigationController?.navigationBar.barTintColor = ThemeManager.currentTheme().NavigationBarBackgroundColor
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().TitleColor]
            self.menutableview.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
            self.navigationController?.navigationBar.tintColor = ThemeManager.currentTheme().backbuttonColor
            self.menutableview.reloadData()

        }


    func setTunnelsManager(tunnelsManager: TunnelsManager) {
        print("inside setting setTunnelsManager")
        if(UserDefaults.standard.isLoggedIn() == false) {
            self.tunnelsManager = tunnelsManager

        } else {

            self.tunnelsManager = tunnelsManager
        }
    }



}

extension MenuViewController : UITableViewDelegate, UITableViewDataSource {


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuListItemArr.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{

        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell

        cell.mainview.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        cell.menuitemlbl.textColor = ThemeManager.currentTheme().DetailTextColor
        cell.dropdownimg.image = ThemeManager.currentTheme().dropmenusettingimg

        if indexPath.row == 1{
            cell.switchCustomView.isHidden = false
            swithbtn = SevenSwitch(frame: cell.switchCustomView.bounds)
            swithbtn.tag = indexPath.row
            swithbtn.addTarget(self, action: #selector(changeTheme), for: .touchUpInside)
            swithbtn.backgroundColor = .clear
            swithbtn.tintColor = .clear
            print("p",ThemeManager.currentTheme().rawValue)
            let p = ThemeManager.currentTheme().rawValue
            if p == 1
            {
                swithbtn.inactiveColor = ThemeManager.currentTheme().ConnectSwitchColor
                swithbtn.setOn(true, animated: true)
            }
            else{
                 swithbtn.inactiveColor = ThemeManager.currentTheme().DisconnectSwitchColor
                 swithbtn.setOn(false, animated: true)
            }

//            cell.switchCustomView.backgroundColor = UIColor.red
            cell.switchCustomView.addSubview(swithbtn)
            cell.dropdownimg.isHidden = true
        }else{
            cell.dropdownimg.isHidden = false
            cell.switchCustomView.isHidden = true
        }


        let menuitem = menuListItemArr[indexPath.row]

            cell.menuitemlbl.text = menuitem
//        if indexPath.row <= 4 {
//            let menuitemimg = menuListItemImgArrLight[indexPath.row]
//            cell.menuitemimgview.image = UIImage(named: menuitemimg)
//
//        }

        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 0 {
            let vc = UIStoryboard.init(name: "MainStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "settingsVC") as? SettingsViewController
            vc?.setTunnelsManager(tunnelsManager: self.tunnelsManager!)

            self.navigationController?.pushViewController(vc!, animated: true)
        }else if indexPath.row == 1{

        }
        else if indexPath.row == 2{
            let bodytext = "Make your Internet Connection Safe and Super Fast. Use MaskVPN Mobile App. Get it FREE now."
            let myWebsite = NSURL(string:"https://testflight.apple.com/join/efOG5xOP")
            let itemsToShare:[Any] = [ bodytext, myWebsite ]

            let controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            controller.setValue("Share MaskVPN", forKey: "subject")
            controller.popoverPresentationController?.sourceView = self.view
            self.present(controller, animated: true, completion: nil)
        }
        else if indexPath.row == 3{

        }
        else if indexPath.row == 4{
            let vc = UIStoryboard.init(name: "MainStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "countrylistVC") as? CountrySelectionViewController
            vc?.barbuttontitle = ""
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if indexPath.row == 5{

        }
        else if indexPath.row == 6{
        let vc = UIStoryboard.init(name: "MainStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "legalVC") as? LegalViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if indexPath.row == 7{
                    let firebaseAuth = Auth.auth()
                    do {
                      try firebaseAuth.signOut()
            //            if let bid = Bundle.main.bundleIdentifier {
            //                UserDefaults.standard.removePersistentDomain(forName: bid)
            //
            //            }

                        UserDefaults.standard.setSocialLoggedIn(value: false)

                        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                        for aViewController in viewControllers {

                            if aViewController is SocialLoginViewController {
                                self.navigationController!.popToViewController(aViewController, animated: true)

                                print("inside swreveal if")
                                break
                            }else{
                                print("inside swreveal else")

                                let vc = UIStoryboard.init(name: "MainStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as? SocialLoginViewController
                                self.navigationController?.pushViewController(vc!, animated: true)
                                break
                            }

                        }



            //           let vc = UIStoryboard.init(name: "MainStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as? SocialLoginViewController
            //
            //            self.navigationController?.popToViewController(vc!, animated: true)


                    } catch let signOutError as NSError {
                      print ("Error signing out: %@", signOutError)
                    }
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

