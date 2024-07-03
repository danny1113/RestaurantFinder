//
//  ViewController.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import UIKit
import MapKit

final class ViewController: UIViewController {
    
    static let annotationIdentifier = "restaurant"
    
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var searchRadiusSlider: UISlider!
    @IBOutlet private var searchButton: UIButton!
    
    private var shops = [RestaurantResponse.Result.Shop]()
    
    private var resultTableViewController: RestaurentResultTableViewController?
    
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.register(RestaurantAnnotation.self, forAnnotationViewWithReuseIdentifier: Self.annotationIdentifier)
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        /*
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }
         */
    }
    
    @IBAction private func searchButtonTapped(_ sender: UIButton) {
        Task {
            await loadRestaurants()
            showResultTableViewController()
            showAnnotations()
        }
    }
}

extension ViewController {
    private func loadRestaurants() async {
        do {
            let coordinate = CLLocationCoordinate2D(latitude: 34.67, longitude: 135.52)
            let restaurants = try await RestaurantAPIService.getNearbyRestaurants(with: coordinate)
            let shops = restaurants.shops
            self.shops = shops
        } catch {
            print(error)
        }
    }
    
    private func showAnnotations() {
        let annotations = shops.map(RestaurantAnnotation.init)
        self.mapView.showAnnotations(annotations, animated: true)
    }
    
    private func showResultTableViewController() {
        let tableViewController = RestaurentResultTableViewController()
        tableViewController.delegate = self
        tableViewController.shops = shops
        self.resultTableViewController = tableViewController
        
        let navigationViewController = UINavigationController(rootViewController: tableViewController)
        navigationViewController.navigationBar.prefersLargeTitles = false
        navigationViewController.title = "近くのレストラン"
        
        if let sheet = navigationViewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .large
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        self.present(navigationViewController, animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
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
}
