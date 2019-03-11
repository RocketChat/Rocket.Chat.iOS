//
//  LocationViewController.swift
//  Rocket.Chat
//
//  Created by Luís Machado on 28/01/2019.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, UIGestureRecognizerDelegate {

    var selectedLocation: CLLocationCoordinate2D?
    var userLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    var currentPopover: LocationPopover?
    var showingSatellite: Bool = false

    let myAnnotation = MKPointAnnotation()
    var mapRegionTimer: Timer?
    var locationWasAllowed: Bool = false

    weak var delegate: LocationControllerDelegate?

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var mapOptionsButton: UIButton!

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        dismissPopover()
         self.map.removeAnnotations(self.map.annotations)
        coordinator.animate(alongsideTransition: nil) { (_) in
            self.map.addAnnotation(self.myAnnotation)
            self.map.selectAnnotation(self.myAnnotation, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "arrow"), style: .plain, target: self, action: #selector(centerOnUser))

        // For use in foreground
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.map.showsUserLocation = true
        self.map.showsCompass = false
        self.map.delegate = self

        self.title = localized("location.title")

        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { //Wait 1 second to see if user location is available
            if !self.locationWasAllowed {
                self.selectedLocation = self.map.centerCoordinate
                self.setupForLocation(location: self.map.centerCoordinate)
            }
        }
    }

    @objc func centerOnUser() {
        if let userLocation = map.userLocation.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let mapRegion = MKCoordinateRegion(center: userLocation, span: span)
            map.setRegion(mapRegion, animated: true)
        } else {
            Alert(key: "location_disabled").present()
        }
    }

    @IBAction func mapOptionsPressed(_ sender: Any) {
        showingSatellite = !showingSatellite
        self.changeMapView(showSatellite: showingSatellite)
    }

    @IBAction func cancelPressed(_ sender: Any) {
        dismissController()
    }

    func locationSelected(address: Address?) {
        delegate?.shareLocation(with: myAnnotation.coordinate, address: address)
        dismissController()
    }

    func changeMapView(showSatellite: Bool) {
        mapOptionsButton.setImage(showSatellite ? #imageLiteral(resourceName: "map") : #imageLiteral(resourceName: "satellite"), for: .normal)
        map.mapType = showSatellite ? .hybrid : .standard
    }

    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }

    private func dismissController() {
        dismissPopover()
        dismiss(animated: true, completion: nil)
    }

    private func dismissPopover() {
        currentPopover?.dismiss(animated: false, completion: nil)
        currentPopover = nil
    }
}

extension LocationViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        dismissPopover()
        mapView.view(for: myAnnotation)?.setDragState(.starting, animated: false)
        setMapRegionTimer()
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.view(for: myAnnotation)?.setDragState(.ending, animated: false)
        mapRegionTimer?.invalidate()
        map.selectAnnotation(myAnnotation, animated: true)
    }

    private func setMapRegionTimer() {
        mapRegionTimer?.invalidate()
        mapRegionTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(mapRegionTimerFired), userInfo: nil, repeats: true)
        mapRegionTimer?.fire()
    }

    @objc func mapRegionTimerFired() {
        myAnnotation.coordinate = self.map.centerCoordinate
    }
}

extension LocationViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted || status == .notDetermined {
            locationWasAllowed = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {

            if !locationWasAllowed {
                locationWasAllowed = true
                selectedLocation = location.coordinate
                setupForLocation(location: location.coordinate)
            }
        }
    }

    func setupForLocation(location: CLLocationCoordinate2D) {
        let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 200, longitudinalMeters: 200)
        map.setRegion(viewRegion, animated: true)

        myAnnotation.coordinate = location

        map.removeAnnotations(map.annotations)
        map.addAnnotation(myAnnotation)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        mapView.deselectAnnotation(view.annotation, animated: false)

        let storyboard = UIStoryboard(name: "Location", bundle: nil)
        guard let popover = storyboard.instantiateViewController(withIdentifier: "locationPopover") as? LocationPopover else { return }
        _ = popover.view

        popover.locationViewController = self

        myAnnotation.coordinate.getLocationName { (address) in
            popover.setup(for: address)
        }

        popover.modalPresentationStyle = .popover
        popover.popoverPresentationController?.permittedArrowDirections = .any
        popover.popoverPresentationController?.delegate = self
        popover.popoverPresentationController?.sourceView = view
        popover.popoverPresentationController?.sourceRect = view.bounds
        popover.popoverPresentationController?.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.85)

        // Allow these views to be accessible while popover is being displayed
        var passthroughViews: [UIView] = [mapOptionsButton, map]

        if let closeButtonView = navigationController?.navigationBar {
            passthroughViews.append(closeButtonView)
        }

        popover.popoverPresentationController?.passthroughViews = passthroughViews

        currentPopover = popover
        present(popover, animated: true, completion: nil)
    }
}

extension LocationViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

struct Address {
    let shortAddress: String
    let placeName: String
    let completeAddress: String
    let headerAddress: String
}

extension CLLocationCoordinate2D {

    func getLocationName(callback: @escaping (_ address: Address) -> Void) {
        // Add below code to get address for touch coordinates.

        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)

        var shortAddress: String = "" // (PIN) Street name (thoroughfare) number (sub thoroughfare), locality
        var placeName: String = "" //Name
        var completeAddress: String = "" //thoroughfare subthoroughfare, postal code, locality, country
        var headerAddress: String = "" //thoroughfare subthoroughfare, postal code, locality, country

        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in

            // Place details
            var placeMark: CLPlacemark!

            guard let placemarks = placemarks else { return }

            if placemarks.count == 0 {
                return
            }

            placeMark = placemarks[0]

            // Short Address
            shortAddress = placeMark.name ?? ""
            var shortAddressComponents: [String] = []
            var streetComponents: [String] = []
            if let thoroughfare = placeMark.thoroughfare, !thoroughfare.isEmpty {
                streetComponents.append(thoroughfare)
            }
            if let subThoroughfare = placeMark.subThoroughfare, !subThoroughfare.isEmpty {
                streetComponents.append(subThoroughfare)
            }

            let streetComponentsJoined = streetComponents.joined(separator: " ")
            if !streetComponentsJoined.isEmpty {
                shortAddressComponents.append(streetComponentsJoined)
            }

            if let locality = placeMark.locality, !locality.isEmpty {
                shortAddressComponents.append(locality)
            }

            let shortAddressJoined = shortAddressComponents.joined(separator: ", ")
            if !shortAddressJoined.isEmpty {
                shortAddress = shortAddressJoined
            }

            // Place Name
            placeName = placeMark.name ?? shortAddress

            // Complete Address
            var addressComponentsList: [String] = []
            var addressComponentsListWOCountry: String = ""
            //// Street
            let streetAndNumber = streetComponents.joined(separator: " ")
            if !streetAndNumber.isEmpty {
                addressComponentsList.append(streetAndNumber)
            }
            //// Postal Code and Locality
            var postalCodeAndLocalityList: [String] = []
            var postalCodeAndLocality: String = ""

            if let postalCode = placeMark.postalCode, !postalCode.isEmpty {
                postalCodeAndLocalityList.append(postalCode)
            }
            if let locality = placeMark.locality, !locality.isEmpty {
                postalCodeAndLocalityList.append(locality)
            }

            postalCodeAndLocality = postalCodeAndLocalityList.joined(separator: " ")

            if !postalCodeAndLocality.isEmpty {
                addressComponentsList.append(postalCodeAndLocality)
            }
            //// Country
            addressComponentsListWOCountry = addressComponentsList.joined(separator: ", ") //Used for the header title
            if let country = placeMark.country, !country.isEmpty {
                addressComponentsList.append(country)
            }
            completeAddress = addressComponentsList.joined(separator: ", ")

            // Header Address
            if placeName.isContentEqual(to: streetAndNumber) {
                headerAddress = postalCodeAndLocality
            } else if streetAndNumber.isEmpty {
                if postalCodeAndLocality.isEmpty {
                    if let country = placeMark.country, !country.isEmpty {
                        headerAddress = "\(placeName), \(country)"
                    } else {
                        headerAddress = placeName
                    }
                } else {
                    headerAddress = "\(placeName), \(postalCodeAndLocality)"
                }
            } else {
                headerAddress = addressComponentsListWOCountry
            }

            callback(Address(shortAddress: shortAddress, placeName: placeName, completeAddress: completeAddress, headerAddress: headerAddress))
        })
    }
}
