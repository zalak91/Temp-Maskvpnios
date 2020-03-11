// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
class CountryListModel : NSObject , NSCoding{
    func encode(with coder: NSCoder) {
       coder.encode(locationId, forKey: "locationId")
        coder.encode(locationCode , forKey: "locationCode")
        coder.encode(locationName,forKey: "locationName")
        coder.encode(locationCountry ,forKey: "locationCountry")
        coder.encode(locationFlag ,forKey: "locationFlag")
    }

    required init?(coder: NSCoder) {

        self.locationId = coder.decodeObject(forKey: "locationId") as! String
        self.locationCode = coder.decodeObject(forKey: "locationCode") as! String
        self.locationName = coder.decodeObject(forKey: "locationName") as! String
        self.locationCountry = coder.decodeObject(forKey: "locationCountry") as! String
        self.locationFlag = coder.decodeObject(forKey: "locationFlag") as! String

    }


    var locationId = ""
    var locationCode = ""
    var locationName = ""
    var locationCountry = ""
    var locationFlag = ""


    init( locationId:String , locationCode:String , locationName:String ,locationCountry:String ,locationFlag:String ) {

        self.locationId = locationId
        self.locationCode = locationCode
        self.locationName = locationName
        self.locationCountry = locationCountry
        self.locationFlag = locationFlag
    }
    override init() {

    }

}
