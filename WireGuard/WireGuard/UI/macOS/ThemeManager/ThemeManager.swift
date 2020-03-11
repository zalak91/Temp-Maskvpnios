//
//  ThemeManager.swift
//  Pigeon-project
//
//  Created by Roman Mizin on 8/2/17.
//  Copyright © 2017 Roman Mizin. All rights reserved.
//



import AppKit

let SelectedThemeKey = "SelectedTheme"

extension NSNotification.Name {
  static let themeUpdated = NSNotification.Name(Bundle.main.bundleIdentifier! + ".themeUpdated")
}

struct ThemeManager {

  static func applyTheme(theme: Theme) {
    userDefaults.updateObject(for: userDefaults.selectedTheme, with: theme.rawValue)

//    UITabBar.appearance().barStyle = theme.barStyle
//    UINavigationBar.appearance().isTranslucent = false
//    UINavigationBar.appearance().barStyle = theme.barStyle
//    UINavigationBar.appearance().barTintColor = theme.barBackgroundColor
//    UITabBar.appearance().barTintColor = theme.barBackgroundColor



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

    var generalBackgroundColor: NSColor {
        switch self {
        case .Default:
            return .white
        case .Dark:
            return NSColor(hexString: "#141820")

        }
    }

    var backbuttonColor: NSColor {
        switch self {
        case .Default:

            return NSColor(hexString: "#3E434D")
        case .Dark:
             return .white


        }
    }


    var ConnectedBottomView: NSColor {
        switch self {
        case .Default:
             return NSColor(hexString: "#F2F2F2")
        case .Dark:
             return NSColor(hexString: "#262B35")
        }
    }

    var LocationViewColor: NSColor {
        switch self {
        case .Default:
            return NSColor.lightGray
        case .Dark:
            return NSColor.white
        }
    }


    var NavigationBarBackgroundColor: NSColor {
        switch self {
        case .Default:
            return NSColor.white
        case .Dark:
          return NSColor(hexString: "#262B35")

        }
    }

    var CountryTableviewBackgroundColor: NSColor {
        switch self {
        case .Default:
            return .white
        case .Dark:
            return NSColor(hexString: "#141820")

        }
    }

    var CountryListSelectedTextBackgroundColor: NSColor {
        switch self {
        case .Default:
              return NSColor(hexString: "#3D434E")
        case .Dark:
            return NSColor(hexString: "#FFFFFF")

        }
    }

    var CountryListTextBackgroundColor: NSColor {
        switch self {
        case .Default:
            return NSColor(hexString: "#677080")
        case .Dark:
            return NSColor(hexString: "#AEB4BE")

        }
    }

    var CountryTableviewCellbackgroundColor: NSColor {
        switch self {
        case .Default:
            return NSColor(hexString: "#22CC77").withAlphaComponent(0.10)
        case .Dark:
            return NSColor(hexString: "##E9EFF0").withAlphaComponent(0.10)

        }
    }


  var barBackgroundColor: NSColor {
    switch self {
    case .Default:
      return .white
    case .Dark:
      return .black
    }
  }

    var SepratedViewColor: NSColor {
        switch self {
        case .Default:
            return NSColor(hexString: "#000000").withAlphaComponent(0.10)
        case .Dark:
            return NSColor(hexString: "#FFFFFF").withAlphaComponent(0.10)
        }
    }


  var generalTitleColor: NSColor {
    switch self {
    case .Default:
      return NSColor.black
    case .Dark:
      return NSColor.white
    }
  }

  var generalSubtitleColor: NSColor {
    switch self {
    case .Default:
      return NSColor(red:0.67, green:0.67, blue:0.67, alpha:1.0)
    case .Dark:
      return NSColor(red:0.67, green:0.67, blue:0.67, alpha:1.0)
    }
  }


    var ConnectedTextColor: NSColor {
        switch self {
        case .Default:
            return NSColor(hexString: "#22CC77")
        case .Dark:
            return NSColor(hexString: "#DFE1E5")
        }
    }

    var DisConnectedTextColor: NSColor {
        switch self {
        case .Default:
            return NSColor(hexString: "#FF0033")
        case .Dark:
             return NSColor(hexString: "#DFE1E5")

        }
    }


    //location & under switch text
    var locationAndOtherTextColor: NSColor {
        switch self {
        case .Default:
           return NSColor(hexString: "#AEB4BE")
        case .Dark:
            return NSColor(hexString: "#AEB4BE")

        }
    }


    var TitleColor: NSColor {
        switch self {
        case .Default:
           return NSColor(hexString: "#3D434E")

        case .Dark:
            return NSColor(hexString: "#FFFFFF")

        }
    }



    var DetailTextColor: NSColor {
        switch self {
        case .Default:
             return NSColor(hexString: "#677080")

        case .Dark:
            return NSColor(hexString: "#AEB4BE")
        }
    }




    var DisconnectSwitchColor: NSColor {
        switch self {
        case .Default:

            return NSColor(hexString: "#C1C1C1")
        case .Dark:

             return NSColor(hexString: "#363B45")

        }
    }

    var ConnectSwitchColor: NSColor {
        switch self {
        case .Default:

            return NSColor(hexString: "#22CC77")
        case .Dark:

            return NSColor(hexString: "#22CC77")

        }
    }


    var settingimg: NSImage{
        switch self {
        case .Default:
            return NSImage(named: "Settingimg")!
        case .Dark:
            return NSImage(named: "SettingimgDark")!
        }
    }

    var statusimg: NSImage{
        switch self {
        case .Default:
            return NSImage(named: "Statusimg")!
        case .Dark:
            return NSImage(named: "StatusimgDark")!
        }
    }

    var shareimg: NSImage{
        switch self {
        case .Default:
            return NSImage(named: "Shareimg")!
        case .Dark:
            return NSImage(named: "ShareimgDark")!
        }
    }

    var themeimg: NSImage{
        switch self {
        case .Default:
            return NSImage(named: "Themeimg")!
        case .Dark:
            return NSImage(named: "ThemeimgDark")!
        }
    }

    var countrypinmainimg: NSImage{
        switch self {
        case .Default:
            return NSImage(named: "LocationpinimgMain")!
        case .Dark:
            return NSImage(named: "LocationpinimgMainDark")!
        }
    }

    var countrypinsettingimg: NSImage{
        switch self {
        case .Default:
            return NSImage(named: "LocationPinSetting")!
        case .Dark:
            return NSImage(named: "LocationPinSettingDark")!
        }
    }

    var dropmenumainimg: NSImage{
        switch self {
        case .Default:
            return NSImage(named: "DropmenuMainimg")!
        case .Dark:
            return NSImage(named: "DropmenuMainimgDark")!
        }
    }

    var dropmenusettingimg: NSImage{
        switch self {
        case .Default:
            return NSImage(named: "DropmenuimgSetting")!
        case .Dark:
            return NSImage(named: "DropmenuimgSettingDark")!
        }
    }








  var cellSelectionColor: NSColor {
    switch self {
    case .Default:
      return  NSColor(red:0.95, green:0.95, blue:0.95, alpha:1.0) //F1F1F1
    case .Dark:
      return NSColor(red:0.10, green:0.10, blue:0.10, alpha:1.0) //191919
    }
  }

  var inputTextViewColor: NSColor {
    switch self {
    case .Default:
      return NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    case .Dark:
      return NSColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
    }
  }

  var controlButtonsColor: NSColor {
    switch self {
    case .Default:
      return   NSColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
    case .Dark:
      return NSColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
    }
  }

  var searchBarColor: NSColor {
    switch self {
    case .Default:
      return NSColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 0.5)
    case .Dark:
      return NSColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 0.8)
    }
  }

  var mediaPickerControllerBackgroundColor: NSColor {
    switch self {
    case .Default:
      return NSColor(red: 209.0/255.0, green: 213.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    case .Dark:
      return NSColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)
    }
  }

  var splashImage: NSImage {
    switch self {
    case .Default:
      return NSImage(named: "whiteSplash")!
    case .Dark:
      return NSImage(named: "blackSplash")!
    }
  }

    var mainimage: NSImage{
        switch self {
        case .Default:
            return NSImage(named: "backimgdark")!
        case .Dark:
            return NSImage(named: "backimglight")!
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

  var enterPhoneNumberBackground: NSImage {
    switch self {
    case .Default:
      return  NSImage(named: "LightAuthCountryButtonNormal")!
    case .Dark:
      return NSImage(named: "DarkAuthCountryButtonNormal")!
    }
  }

  var enterPhoneNumberBackgroundSelected: NSImage {
    switch self {
    case .Default:
      return NSImage(named:"LightAuthCountryButtonHighlighted")!
    case .Dark:
      return NSImage(named:"DarkAuthCountryButtonHighlighted")!
    }
  }

  var personalStorageImage: NSImage {
    switch self {
    case .Default:
      return  NSImage(named: "PersonalStorage")!
    case .Dark:
      return NSImage(named: "PersonalStorage")!
    }
  }







  var backgroundColor: NSColor {
    switch self {
    case .Default:
      return NSColor.white
    case .Dark:
      return NSColor.black
    }
  }

  var secondaryColor: NSColor {
    switch self {
    case .Default:
      return NSColor(red: 242.0/255.0, green: 101.0/255.0, blue: 34.0/255.0, alpha: 1.0)
    case .Dark:
      return NSColor(red: 34.0/255.0, green: 128.0/255.0, blue: 66.0/255.0, alpha: 1.0)

    }
  }
}

struct FalconPalette {
  static let defaultBlue = NSColor(red:0.00, green:0.50, blue:1.00, alpha: 1.0)
  static let dismissRed = NSColor(red:1.00, green:0.23, blue:0.19, alpha:1.0)
  static let appStoreGrey = NSColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
}
