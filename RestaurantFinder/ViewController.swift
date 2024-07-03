//
//  ViewController.swift
//  RestaurantFinder
//
//  Created by 龐達業 on 2024/7/3.
//

import UIKit
import MapKit

final class ViewController: UIViewController {
    
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var searchRadiusSlider: UISlider!
    @IBOutlet private var searchButton: UIButton!
    
    private var shops = [RestaurantResponse.Result.Shop]()
    
    private var resultTableViewController: RestaurentResultTableViewController?
    
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            let restaurants = try await RestaurantAPIService.getNearbyRestaurants(with: CLLocationCoordinate2D(latitude: 34.67, longitude: 135.52))
            let shops = restaurants.shops
            self.shops = shops
        } catch {
            print(error)
        }
    }
    
    private func showAnnotations() {
        let annotations = shops.map(RestaurentAnnotation.init)
        self.mapView.showAnnotations(annotations, animated: true)
    }
    
    private func showResultTableViewController() {
        let tableViewController = RestaurentResultTableViewController()
        self.resultTableViewController = tableViewController
        tableViewController.shops = shops
        
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
