//
//  Anot.swift
//  Map App
//
//  Created by Doruk Özdemir on 31.12.2022.
//

import Foundation
import MapKit

struct Anot {
    var id: UUID?
    let location: MKPointAnnotation

    init(id: UUID?,  location: MKPointAnnotation) {
        self.id = id
        self.location = location
    }
}
