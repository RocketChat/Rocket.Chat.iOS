//
//  SharedLocationViewController.swift
//  Rocket.Chat
//
//  Created by Luís Machado on 07/02/2019.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit
import MapKit

enum CurrentFocus {
    case sharedLocation
    case userLocation
    case both
}

class SharedLocationViewController: UIViewController, UIGestureRecognizerDelegate {

    var sharedLocation: CLLocationCoordinate2D?
    var usernameWhoShared: String = ""
    var isSelf: Bool = true
    var locationWasAllowed: Bool = false

    var currentFocus: CurrentFocus = .sharedLocation
    @IBOutlet weak var changeFocusButton: UIBarButtonItem!

    var userLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    var currentPopover: LocationPopover?
    var showingSatellite: Bool = false

    let myAnnotation = MKPointAnnotation()
    var timeDistanceButton: UIButton?
    var mapRegionTimer: Timer?

    weak var delegate: LocationControllerDelegate?

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var mapOptionsButton: UIButton!

    func setTitle2(title: String, subtitle: String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -5, width: 0, height: 0))

        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.gray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.black
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)

        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width

        if widthDiff > 0 {
            var frame = titleLabel.frame
            frame.origin.x = widthDiff / 2
            titleLabel.frame = frame.integral
        } else {
            var frame = subtitleLabel.frame
            frame.origin.x = abs(widthDiff) / 2
            titleLabel.frame = frame.integral
        }

        return titleView
    }

    func setTitle(title: String, subtitle: String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .gray
        titleLabel.font =  UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .black
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()

        let maxWidth = self.view.frame.width - 50

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: min(max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), maxWidth), height: 30))

        if titleLabel.frame.size.width > maxWidth {
            titleLabel.frame = CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y, width: maxWidth, height: titleLabel.frame.size.height)
        }

        if subtitleLabel.frame.size.width > maxWidth {
            subtitleLabel.frame = CGRect(x: subtitleLabel.frame.origin.x, y: subtitleLabel.frame.origin.y, width: maxWidth, height: subtitleLabel.frame.size.height)
        }

        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)

        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width

        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }

        return titleView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        self.map.showsUserLocation = true
        self.map.showsCompass = false
        self.map.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    func setup(sharedLocation: CLLocationCoordinate2D, username: String, isSelf: Bool) {
        self.sharedLocation = sharedLocation
        self.usernameWhoShared = username
        self.isSelf = isSelf

        sharedLocation.getLocationName { (address) in
            let vie = self.setTitle(title: address.placeName, subtitle: address.headerAddress)
            self.navigationItem.titleView = vie
        }
    }

    @IBAction func sharePressed(_ sender: Any) {
        guard let sharedLoc = sharedLocation else { return }
        openMaps(location: sharedLoc, region: map.region, driving: false)
    }

    @IBAction func changeFocusPressed(_ sender: Any) {

        if !locationWasAllowed {
            currentFocus = .sharedLocation
            changeMapFocus()
            Alert(key: "location_disabled").present()
            return
        }

        switch currentFocus {
        case .sharedLocation:
            currentFocus = .userLocation
        case .userLocation:
            currentFocus = .both
        case .both:
            currentFocus = .sharedLocation
        }
        changeMapFocus()
    }

    private func changeMapFocus() {
        var annotationsToShow: [MKAnnotation] = []

        for annotation in self.map.annotations {
            map.deselectAnnotation(annotation, animated: true)
            if annotation is MKPointAnnotation && (currentFocus == .sharedLocation || currentFocus == .both) {
                annotationsToShow.append(annotation)
            } else if annotation is MKUserLocation && (currentFocus == .userLocation || currentFocus == .both) {
                annotationsToShow.append(annotation)
            }
        }

        map.showAnnotations(annotationsToShow, animated: true)
        if annotationsToShow.count == 1 {
            map.selectAnnotation(annotationsToShow[0], animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let location = self.sharedLocation {
            setupForLocation(location: location)
        }
    }

    @objc func centerOnUser() {
        if let userLocation = map.userLocation.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let mapRegion = MKCoordinateRegion(center: userLocation, span: span)
            map.setRegion(mapRegion, animated: true)
        }
    }

    @IBAction func mapOptionsPressed(_ sender: Any) {
        showingSatellite = !showingSatellite
        self.changeMapView(showSatellite: showingSatellite)
    }

    func changeMapView(showSatellite: Bool) {
        mapOptionsButton.setImage(showSatellite ? #imageLiteral(resourceName: "map") : #imageLiteral(resourceName: "satellite"), for: .normal)
        map.mapType = showSatellite ? .hybrid : .standard
    }

    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
        dismissPopover()
    }

    private func dismissPopover() {
        currentPopover?.dismiss(animated: false, completion: nil)
        currentPopover = nil
    }
}

extension SharedLocationViewController {
    private func openMaps(location: CLLocationCoordinate2D, region: MKCoordinateRegion, driving: Bool) {

        let alert = UIAlertController(title: nil, message: driving ? localized("maps.choose_application") : nil, preferredStyle: .actionSheet)

        let apple = UIAlertAction(title: "Apple Maps", style: .default, handler: { _ in
            self.openAppleMaps(location: location, region: region, driving: driving)
        })

        let google = UIAlertAction(title: "Google Maps", style: .default, handler: { _ in
            self.openGoogleMaps(location: location, driving: driving)
        })

        let waze = UIAlertAction(title: "Waze", style: .default, handler: { _ in
            self.openWaze(location: location, driving: driving)
        })

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))
        alert.addAction(apple)
        if canOpenGoogleMaps() {
            alert.addAction(google)
        }

        if canOpenWaze() {
             alert.addAction(waze)
        }

        present(alert, animated: true)
    }

    private func canOpenGoogleMaps() -> Bool {
        guard let baseURL = URL(string: "comgooglemaps://") else { return false }
        return UIApplication.shared.canOpenURL(baseURL)
    }

    private func canOpenWaze() -> Bool {
        guard let baseURL = URL(string: "waze://") else { return false }
        return UIApplication.shared.canOpenURL(baseURL)
    }

    private func openWaze(location: CLLocationCoordinate2D, driving: Bool) {
        if canOpenWaze() {
            let urlString: String = "waze://?ll=\(location.latitude),\(location.longitude)&navigate=\(driving ? "yes" : "no")"
            guard let mapsURL = URL(string: urlString) else {
                Alert(key: "maps.open_external_error").present()
                return
            }

            UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
        }
    }
    private func openAppleMaps(location: CLLocationCoordinate2D, region: MKCoordinateRegion, driving: Bool) {
        let regionSpan = region
        var options: [String: Any] = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]

        if driving {
            options[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeDriving
        }

        let placemark = MKPlacemark(coordinate: location, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = usernameWhoShared
        mapItem.openInMaps(launchOptions: options)
    }

    private func openGoogleMaps(location: CLLocationCoordinate2D, driving: Bool) {
        if canOpenGoogleMaps() {
            let urlString = driving ?
                "comgooglemaps://?saddr=&daddr=\(location.latitude),\(location.longitude)&directionsmode=driving" :
            "comgooglemaps://?center=\(location.latitude),\(location.longitude)&zoom=14&views=traffic&q=\(location.latitude),\(location.longitude)"
            guard let mapsURL = URL(string: urlString) else {
                Alert(key: "maps.open_external_error").present()
                return
            }

            UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
        }
    }
}

extension SharedLocationViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView.canShowCallout = true

            // Action Button
            let smallSquare = CGSize(width: 50, height: 50)
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
            button.backgroundColor = UIColor(red: 26/255, green: 105/255, blue: 243/255, alpha: 1)
            button.setImage(UIImage(named: "car_map")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.tintColor = .white
            button.tintColor = .white
            button.setTitle("     ", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 11)
            button.imageEdgeInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 1)
            button.imageView?.contentMode = .scaleAspectFit
            timeDistanceButton = button
            annotationView.leftCalloutAccessoryView = button

            return annotationView
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let sharedLoc = sharedLocation else { return }

        if let reuseId = view.reuseIdentifier, reuseId.isContentEqual(to: "pin") {
            openMaps(location: sharedLoc, region: map.region, driving: true)
        }
    }
}

extension SharedLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted || status == .notDetermined {
            locationWasAllowed = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location, let sharedLoc = sharedLocation else { return }
        userLocation = location.coordinate
        locationWasAllowed = true

        if !isSelf {
            // Distance
            let distance = calculateDistance(between: location.coordinate, pointB: sharedLoc)
            let formatted = formatMetersToString(distance: distance)
            myAnnotation.subtitle = formatted
        }

        // ETA
        let sourcePlacemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationPlacemark = MKPlacemark(coordinate: sharedLoc, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let request = MKDirections.Request()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        directions.calculate { (response, _) in
            if let route = response?.routes.first {
                // Distances inferior to 1 min are returned as null (no need to show)
                guard let formatted = self.formatSecondsToMinutesOrHours(time: route.expectedTravelTime) else { return }

                self.timeDistanceButton?.setTitle(formatted, for: .normal)
                self.timeDistanceButton?.titleEdgeInsets = UIEdgeInsets(top: 30, left: -38, bottom: 0, right: 0)
                self.timeDistanceButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 16, right: 0)
            }
        }
    }

    func setupForLocation(location: CLLocationCoordinate2D) {
        let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 200, longitudinalMeters: 200)
        map.setRegion(viewRegion, animated: true)

        myAnnotation.coordinate = location

        var title = self.usernameWhoShared
        if isSelf {
            title.append(" (\(localized("maps.me")))")
        }

        myAnnotation.title = title
        map.removeAnnotations(map.annotations)
        map.addAnnotation(myAnnotation)
        map.selectAnnotation(myAnnotation, animated: true)
    }

    private func calculateDistance(between pointA: CLLocationCoordinate2D, pointB: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: pointA.latitude, longitude: pointA.longitude)
        let loc2 = CLLocation(latitude: pointB.latitude, longitude: pointB.longitude)

        return loc1.distance(from: loc2)
    }

    private func formatMetersToString(distance: Double) -> String {

        if distance < 1000 {
            return "\(Int(distance)) m"
        } else {
            let roundedToKms: Int = Int(distance / 1000)
            return "\(roundedToKms) km"
        }
    }

    private func formatSecondsToMinutesOrHours(time: Double) -> String? {

        if time < 80 {
            return nil
        } else if time < 3600 {
            let min = Int(time / 60)
            return "\(min) min"
        } else {
            let hours = Int(time / 60 / 60)
            return "\(hours) hr"
        }
    }
}

extension SharedLocationViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
