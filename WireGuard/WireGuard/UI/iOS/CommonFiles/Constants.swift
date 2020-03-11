// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

class Constants {


//    struct APIURLS {
//        static let globalapiUrl = "https://api.greensignalvpn.com/v2/"
//        static let echoapiUrl = "https://echo.greensignalvpn.com/"
//    }

    struct APIURLS {
        static let globalapiUrl = "https://stage-api.greensignalvpn.com/v2/"
        static let echoapiUrl = "https://echo.greensignalvpn.com/"
    }

    struct MethodName {

        static let resgitermethod = "vpn/device/register"
        static let countrylist = "vpn/country-list"
        static let feedback = "vpn/feedback"
    }
    struct Apikeys {

        static let Devicepublickkey = "devicePublicKey"
        static let Devicetoken = "deviceToken"
        static let Countryid = "locationId"
        static let Devicetype = "deviceType"

        static let FeedbackType = "feedbackType"
        static let FeedbackSource = "feedbackSource"
        static let Version = "version"
        static let FeedbackMessage = "feedbackMessage"
        static let Noredirect = "noredirect"

    }


    static let tunnelName = "MaskVPN"






}
