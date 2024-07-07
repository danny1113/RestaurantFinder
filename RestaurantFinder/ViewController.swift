//
//  ViewController.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import UIKit
import MapKit

/// レストランの位置をを表示する地図
final class ViewController: UIViewController {
    
    static let annotationIdentifier = "restaurant"
    
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var locationButton: UIButton!
    
    private var shops = [RestaurantResponse.Result.Shop]()
    
    private var resultTableViewController: RestaurantResultTableViewController?
    
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.register(RestaurantAnnotation.self, forAnnotationViewWithReuseIdentifier: Self.annotationIdentifier)
        mapView.delegate = self
        
        locationManager.delegate = self
        
        if let coordinate = locationManager.location?.coordinate {
            mapView.setCenter(coordinate, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showResultTableViewController()
    }
    
    @IBAction private func locationButtonTapped() {
        guard let coordinate = locationManager.location?.coordinate else {
            self.present(error: "位置情報を取得できませんでした")
            return
        }
        mapView.setCenter(coordinate, animated: true)
    }
}

extension ViewController {
    private func present(alertController: UIAlertController) {
        if let presentedViewController = presentedViewController {
            presentedViewController.present(alertController, animated: true)
        } else {
            self.present(alertController, animated: true)
        }
    }
    
    private func present(error: String) {
        let alert = UIAlertController(title: "エラー", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        self.present(alertController: alert)
    }
    
    private func loadRestaurants(with coordinate: CLLocationCoordinate2D, range: Int) async {
        do {
            let restaurants = try await RestaurantAPIService.getNearbyRestaurants(
                with: coordinate,
                range: range
            )
            let shops = restaurants.shops
            self.shops = shops
        } catch {
            self.present(error: "レストラン情報を取得できませんでした")
        }
    }
    
    private func showAnnotations() {
        let annotations = shops.map(RestaurantAnnotation.init)
        self.mapView.showAnnotations(annotations, animated: true)
    }
    
    private func showResultTableViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tableViewController = storyboard.instantiateViewController(withIdentifier: "ResultTableView") as! RestaurantResultTableViewController
        tableViewController.delegate = self
        self.resultTableViewController = tableViewController
        
        let navigationViewController = UINavigationController(rootViewController: tableViewController)
        navigationViewController.navigationBar.prefersLargeTitles = false
        navigationViewController.isModalInPresentation = true
        
        if let sheet = navigationViewController.sheetPresentationController {
            sheet.detents = [
                .custom(identifier: .small, resolver: { _ in
                    tableViewController.calculateDetentHeight()
                }),
                .medium(),
                .large(),
            ]
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.largestUndimmedDetentIdentifier = .large
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        self.present(navigationViewController, animated: true)
    }
    
    private func loadAndShowRestaurants(with coordinate: CLLocationCoordinate2D) {
        Task {
            await loadRestaurants(with: coordinate, range: 3)
            showAnnotations()
            resultTableViewController?.updateTableView(with: shops)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if animated == false {
            resultTableViewController?.setSelectedDetent(.small)
        }
        
        for annotation in mapView.selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
        if let annotation = annotation as? RestaurantAnnotation {
            guard let resultTableViewController else {
                return
            }
            
            if let sheet = resultTableViewController.sheetPresentationController,
               sheet.selectedDetentIdentifier != .large {
                sheet.animateChanges {
                    sheet.selectedDetentIdentifier = .medium
                }
            }
            
            resultTableViewController.pushDetailView(with: annotation.shop)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            loadAndShowRestaurants(with: mapView.centerCoordinate)
        case .authorizedWhenInUse, .authorizedAlways:
            if let coordinate = manager.location?.coordinate {
                loadAndShowRestaurants(with: coordinate)
            }
        @unknown default:
            break
        }
    }
}

extension ViewController: RestaurantResultTableViewDelegate {
    func didSelect(shop: RestaurantResponse.Result.Shop) {
        for annotation in mapView.annotations {
            guard let annotation = annotation as? RestaurantAnnotation else {
                continue
            }
            if annotation.shop == shop {
                let origin = MKMapPoint(annotation.coordinate)
                let size = MKMapSize(width: 0, height: 0)
                let mapRect = MKMapRect(origin: origin, size: size)
                let inset: CGFloat = 20
                let offset = CGFloat(Int(mapView.frame.size.height) / 2 - 20)
                let edge = UIEdgeInsets(top: inset, left: inset, bottom: offset, right: inset)
                mapView.setVisibleMapRect(mapRect, edgePadding: edge, animated: true)
                
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    func searchButtonDidTap(range: Int) async {
        mapView.removeAnnotations(mapView.annotations)
        
        let coordinate = mapView.centerCoordinate
        await loadRestaurants(with: coordinate, range: range)
        showAnnotations()
        resultTableViewController?.updateTableView(with: shops)
        if let sheet = resultTableViewController?.sheetPresentationController {
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = .medium
            }
        }
    }
}
