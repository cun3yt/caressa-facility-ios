//
//  BaseModel.swift
//  Caressa
//
//  Created by Hüseyin Metin on 22.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

class BaseResponse: NSObject, Codable {
    let error: String?
    let error_description: String?
}
