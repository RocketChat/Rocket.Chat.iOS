//
//  LocationChatItem.swift
//  Rocket.Chat
//
//  Created by Luís Machado on 06/02/2019.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController
import MapKit

extension String {
    func getCoordinates() -> CLLocationCoordinate2D {
        var coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let coordinatesText = self.replacingOccurrences(of: "https://maps.google.com/?q=", with: "")

        let splitCoordinates = coordinatesText.split(separator: ",")
        if splitCoordinates.count == 2, let latitude = Double(splitCoordinates[0]), let longitude = Double(splitCoordinates[1]) {
            coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        return coordinates
    }
}

final class LocationChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return LocationCell.identifier
    }

    var url: String
    var coordinates: CLLocationCoordinate2D
    var shortAddress: String
    var longAdress: String

    init(url: String, title: String, message: UnmanagedMessage?) {

        self.url = url
        self.coordinates = url.getCoordinates()
        self.shortAddress = ""
        self.longAdress = ""
        let completeAddress = title.replacingOccurrences(of: "\n\(url)", with: "")

        let splitAddresses = completeAddress.split(separator: "\n")

        if splitAddresses.count <= 1 {
            let addressParts = completeAddress.split(separator: ",")
            if addressParts.count > 0 {
                self.shortAddress = String(addressParts[0])
            }

            self.longAdress = completeAddress
        } else if splitAddresses.count == 2 {
            self.shortAddress = String(splitAddresses[0])
            self.longAdress = String(splitAddresses[1])
        }

        super.init(user: nil, message: message)
    }

    func generateImage(completion: @escaping (UIImage?) -> Void) {
        let mapSnapshotOptions = MKMapSnapshotter.Options()

        let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.006)
        let region = MKCoordinateRegion(center: coordinates, span: span)

        // Set the region of the map that is rendered.
        mapSnapshotOptions.region = region

        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale

        // Set the size of the image output.
        mapSnapshotOptions.size = CGSize(width: 300, height: 300)

        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true

        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        let rect = CGRect(x: 0, y: 0, width: 300, height: 300)

        snapShotter.start { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                completion(nil)
                return
            }

            UIGraphicsBeginImageContextWithOptions(mapSnapshotOptions.size, true, 0)
            snapshot.image.draw(at: .zero)

            let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            let pinImage = pinView.image

            var point = snapshot.point(for: self.coordinates)

            if rect.contains(point) {
                let pinCenterOffset = pinView.centerOffset
                point.x -= pinView.bounds.size.width / 2
                point.y -= pinView.bounds.size.height / 2
                point.x += pinCenterOffset.x
                point.y += pinCenterOffset.y
                pinImage?.draw(at: point)
            }

            let image = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()

            completion(image)
        }
    }

    var differenceIdentifier: String {
        return url
    }

    func isContentEqual(to source: LocationChatItem) -> Bool {
        return shortAddress == source.shortAddress &&
            longAdress == source.longAdress &&
                url == source.url
    }
}
