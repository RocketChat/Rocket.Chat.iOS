//
//  LocationShareDelegate.swift
//  Rocket.Chat
//
//  Created by Luís Machado on 30/01/2019.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit
import MapKit

protocol LocationControllerDelegate: class {
    func shareLocation(with coordinates: CLLocationCoordinate2D, address: Address?)
}
