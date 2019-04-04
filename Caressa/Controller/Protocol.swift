//
//  Protocol.swift
//  Caressa
//
//  Created by Hüseyin Metin on 4.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

protocol AudioPlayerDelegate {
    func playing()
    func paused()
    func stopped()
}

protocol AudioRecorderDelegate {
    func stopped()
}
