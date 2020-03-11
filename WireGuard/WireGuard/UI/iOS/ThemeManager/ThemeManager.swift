//
//  ThemeManager.swift
//  Pigeon-project
//
//  Created by Roman Mizin on 8/2/17.
//  Copyright © 2017 Roman Mizin. All rights reserved.
//



import UIKit

let SelectedThemeKey = "SelectedTheme"

extension NSNotification.Name {
  static let themeUpdated = NSNotification.Name(Bundle.main.bundleIdentifier! + ".themeUpdated")
}

struct ThemeManager {

  static func applyTheme(theme: Theme) {
    userDefaults.updateObject(for: userDefaults.selectedTheme, with: theme.rawValue)

    UITabBar.appearance().barStyle = theme.barStyle
    UINavigationBar.appearance().isTranslucent = false
    UINavigationBar.appearance().barStyle = theme.barStyle
    UINavigationBar.appearance().barTintColor = theme.barBackgroundColor
    UITabBar.appearance().barTintColor = theme.barBackgroundColor



    NotificationCenter.default.post(name: .themeUpdated, object: nil)
  }

  static func currentTheme() -> Theme {
    if let storedTheme = userDefaults.currentIntObjectState(for: userDefaults.selectedTheme) {
      return Theme(rawValue: storedTheme)!
    } else {
      return .Default
    }
  }
}
enum Theme: Int {
  case Default, Dark

    var generalBackgroundColor: UIColor {
        switch self {
        case .Default:
            return .white
        case .Dark:
            return UIColor(hexString: "#2E3633")

        }
    }

    var middleViewbackgroundColor: UIColor {
        switch self {
        case .Default:
            return UIColor(hexString: "#F5F2E9")
        case .Dark:
            return UIColor(hexString: "#2E3633")

        }
    }

    var bottomViewbackgroundColor: UIColor {
        switch self {
        case .Default:
            return UIColor(hexString: "#E5DBBF")
        case .Dark:
            return UIColor(hexString: "#3C4943")

        }
    }




    var backbuttonColor: UIColor {
        switch self {
        case .Default:

            return UIColor(hexString: "#3E434D")
        case .Dark:
             return .white


        }
    }


    var ConnectedBottomView: UIColor {
        switch self {
        case .Default:
             return UIColor(hexString: "#F2F2F2")
        case .Dark:
             return UIColor(hexString: "#262B35")
        }
    }

    var LocationViewColor: UIColor {
        switch self {
        case .Default:
            return UIColor.lightGray
        case .Dark:
            return UIColor.white
        }
    }


    var NavigationBarBackgroundColor: UIColor {
        switch self {
        case .Default:
            return UIColor.white
        case .Dark:
          return UIColor(hexString: "#262B35")

        }
    }

    var CountryTableviewBackgroundColor: UIColor {
        switch self {
        case .Default:
            return .white
        case .Dark:
            return UIColor(hexString: "#141820")

        }
    }

    var CountryListSelectedTextBackgroundColor: UIColor {
        switch self {
        case .Default:
              return UIColor(hexString: "#3D434E")
        case .Dark:
            return UIColor(hexString: "#FFFFFF")

        }
    }

    var CountryListTextBackgroundColor: UIColor {
        switch self {
        case .Default:
            return UIColor(hexString: "#677080")
        case .Dark:
            return UIColor(hexString: "#AEB4BE")

        }
    }

    var CountryTableviewCellbackgroundColor: UIColor {
        switch self {
        case .Default:
            return UIColor(hexString: "#22CC77").withAlphaComponent(0.10)
        case .Dark:
            return UIColor(hexString: "##E9EFF0").withAlphaComponent(0.10)

        }
    }


  var barBackgroundColor: UIColor {
    switch self {
    case .Default:
      return .white
    case .Dark:
      return .black
    }
  }

    var SepratedViewColor: UIColor {
        switch self {
        case .Default:
            return UIColor(hexString: "#000000").withAlphaComponent(0.10)
        case .Dark:
            return UIColor(hexString: "#FFFFFF").withAlphaComponent(0.10)
        }
    }


  var generalTitleColor: UIColor {
    switch self {
    case .Default:
      return UIColor.black
    case .Dark:
      return UIColor.white
    }
  }

  var generalSubtitleColor: UIColor {
    switch self {
    case .Default:
      return UIColor(red:0.67, green:0.67, blue:0.67, alpha:1.0)
    case .Dark:
      return UIColor(red:0.67, green:0.67, blue:0.67, alpha:1.0)
    }
  }


    var ConnectedTextColor: UIColor {
        switch self {
        case .Default:
            return UIColor(hexString: "#22BB77")
        case .Dark:
            return UIColor(hexString: "#E5DBBF")
        }
    }

    var DisConnectedTextColor: UIColor {
        switch self {
        case .Default:
            return UIColor(hexString: "#DD0033")
        case .Dark:
             return UIColor(hexString: "#E5DBBF")

        }
    }

    var DisConnectedCounterlabeltext: UIColor {
        switch self {
        case .Default:
            return UIColor(hexString: "#E5DBBF")
        case .Dark:
             return UIColor(hexString: "#3C4943")

        }
    }
    var ConnectedCounterlabeltext: UIColor {
           switch self {
           case .Default:
               return UIColor(hexString: "#2E3633")
           case .Dark:
                return UIColor(hexString: "#ECF5F1")

           }
       }


    //location & under switch text
    var locationAndOtherTextColor: UIColor {
        switch self {
        case .Default:
           return UIColor(hexString: "#3C4943")
        case .Dark:
            return UIColor(hexString: "#FFFFFF")

        }
    }
    var bottomlabeltext: UIColor {
        switch self {
        case .Default:
           return UIColor(hexString: "#B4A474")
        case .Dark:
            return UIColor(hexString: "#739687")

        }
    }



    var TitleColor: UIColor {
        switch self {
        case .Default:
           return UIColor(hexString: "#3D434E")

        case .Dark:
            return UIColor(hexString: "#FFFFFF")

        }
    }



    var DetailTextColor: UIColor {
        switch self {
        case .Default:
             return UIColor(hexString: "#677080")

        case .Dark:
            return UIColor(hexString: "#AEB4BE")
        }
    }




    var DisconnectSwitchColor: UIColor {
        switch self {
        case .Default:

            return UIColor(hexString: "#C1C1C1")
        case .Dark:

             return UIColor(hexString: "#363B45")

        }
    }

    var ConnectSwitchColor: UIColor {
        switch self {
        case .Default:

            return UIColor(hexString: "#22CC77")
        case .Dark:

            return UIColor(hexString: "#22CC77")

        }
    }


    var settingimg: UIImage{
        switch self {
        case .Default:
            return UIImage(named: "Settingimg")!
        case .Dark:
            return UIImage(named: "SettingimgDark")!
        }
    }

    var statusimg: UIImage{
        switch self {
        case .Default:
            return UIImage(named: "Statusimg")!
        case .Dark:
            return UIImage(named: "StatusimgDark")!
        }
    }

    var shareimg: UIImage{
        switch self {
        case .Default:
            return UIImage(named: "Shareimg")!
        case .Dark:
            return UIImage(named: "ShareimgDark")!
        }
    }

    var themeimg: UIImage{
        switch self {
        case .Default:
            return UIImage(named: "Themeimg")!
        case .Dark:
            return UIImage(named: "ThemeimgDark")!
        }
    }

    var countrypinmainimg: UIImage{
        switch self {
        case .Default:
            return UIImage(named: "LocationpinimgMain")!
        case .Dark:
            return UIImage(named: "LocationpinimgMainDark")!
        }
    }

    var countrypinsettingimg: UIImage{
        switch self {
        case .Default:
            return UIImage(named: "LocationPinSetting")!
        case .Dark:
            return UIImage(named: "LocationPinSettingDark")!
        }
    }
    var reviewsettingimg: UIImage{
        switch self {
        case .Default:
            return UIImage(named: "Feedbackimg")!
        case .Dark:
            return UIImage(named: "FeedbackimgDark")!
        }
    }

    var dropmenumainimg: UIImage{
        switch self {
        case .Default:
            return UIImage(named: "DropmenuMainimg")!
        case .Dark:
            return UIImage(named: "DropmenuMainimgDark")!
        }
    }

    var dropmenusettingimg: UIImage{
        switch self {
        case .Default:
            return UIImage(named: "DropmenuimgSetting")!
        case .Dark:
            return UIImage(named: "DropmenuimgSettingDark")!
        }
    }








  var cellSelectionColor: UIColor {
    switch self {
    case .Default:
      return  UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0) //F1F1F1
    case .Dark:
      return UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0) //191919
    }
  }

  var inputTextViewColor: UIColor {
    switch self {
    case .Default:
      return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    case .Dark:
      return UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
    }
  }

  var controlButtonsColor: UIColor {
    switch self {
    case .Default:
      return   UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
    case .Dark:
      return UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
    }
  }

  var searchBarColor: UIColor {
    switch self {
    case .Default:
      return UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 0.5)
    case .Dark:
      return UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 0.8)
    }
  }

  var mediaPickerControllerBackgroundColor: UIColor {
    switch self {
    case .Default:
      return UIColor(red: 209.0/255.0, green: 213.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    case .Dark:
      return UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)
    }
  }

  var splashImage: UIImage {
    switch self {
    case .Default:
      return UIImage(named: "whiteSplash")!
    case .Dark:
      return UIImage(named: "blackSplash")!
    }
  }

    var mainimage: UIImage{
        switch self {
        case .Default:
            return UIImage(named: "backimgdark")!
        case .Dark:
            return UIImage(named: "backimglight")!
        }
    }

  var typingIndicatorURL: URL? {
    switch self {
    case .Default:
      return Bundle.main.url(forResource: "typingIndicator", withExtension: "gif")
    case .Dark:
      return Bundle.main.url(forResource: "typingindicatorDark", withExtension: "gif")
    }
  }

  var enterPhoneNumberBackground: UIImage {
    switch self {
    case .Default:
      return  UIImage(named: "LightAuthCountryButtonNormal")!
    case .Dark:
      return UIImage(named: "DarkAuthCountryButtonNormal")!
    }
  }

  var enterPhoneNumberBackgroundSelected: UIImage {
    switch self {
    case .Default:
      return UIImage(named:"LightAuthCountryButtonHighlighted")!
    case .Dark:
      return UIImage(named:"DarkAuthCountryButtonHighlighted")!
    }
  }

  var personalStorageImage: UIImage {
    switch self {
    case .Default:
      return  UIImage(named: "PersonalStorage")!
    case .Dark:
      return UIImage(named: "PersonalStorage")!
    }
  }

  var incomingBubble: UIImage {
    switch self {
    case .Default:
			return UIImage(named: "DarkPigeonBubbleIncomingFull")!.resizableImage(withCapInsets: UIEdgeInsets(top: 14, left: 22, bottom: 17, right: 20))//UIImage(named: "PigeonBubbleIncomingFull")!.resizableImage(withCapInsets: UIEdgeInsetsMake(14, 22, 17, 20))
    case .Dark:
			return UIImage(named: "DarkPigeonBubbleIncomingFull")!.resizableImage(withCapInsets: UIEdgeInsets(top: 14, left: 22, bottom: 17, right: 20))
    }
  }

  var outgoingBubble: UIImage {
    switch self {
    case .Default:
			return UIImage(named: "PigeonBubbleOutgoingFull")!.resizableImage(withCapInsets: UIEdgeInsets(top: 14, left: 14, bottom: 17, right: 28))
    case .Dark: //DarkPigeonBubbleOutgoingFull
			return UIImage(named: "PigeonBubbleOutgoingFull")!.resizableImage(withCapInsets: UIEdgeInsets(top: 14, left: 14, bottom: 17, right: 28))
    }
  }

  var keyboardAppearance: UIKeyboardAppearance {
    switch self {
    case .Default:
      return  .default
    case .Dark:
      return .dark
    }
  }

  var barStyle: UIBarStyle {
    switch self {
    case .Default:
      return .default
    case .Dark:
      return .black
    }
  }

  var statusBarStyle: UIStatusBarStyle {
    switch self {
    case .Default:
      return .default
    case .Dark:
      return .lightContent
    }
  }

	var scrollBarStyle: UIScrollView.IndicatorStyle {
    switch self {
    case .Default:
      return .default
    case .Dark:
      return .white
    }
  }

  var backgroundColor: UIColor {
    switch self {
    case .Default:
      return UIColor.white
    case .Dark:
      return UIColor.black
    }
  }

  var secondaryColor: UIColor {
    switch self {
    case .Default:
      return UIColor(red: 242.0/255.0, green: 101.0/255.0, blue: 34.0/255.0, alpha: 1.0)
    case .Dark:
      return UIColor(red: 34.0/255.0, green: 128.0/255.0, blue: 66.0/255.0, alpha: 1.0)

    }
  }
}

struct FalconPalette {
  static let defaultBlue = UIColor(red:0.00, green:0.50, blue:1.00, alpha: 1.0)
  static let dismissRed = UIColor(red:1.00, green:0.23, blue:0.19, alpha:1.0)
  static let appStoreGrey = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
}
