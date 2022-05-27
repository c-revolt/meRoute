//
//  ViewController.swift
//  meRoute
//
//  Created by Александр Прайд on 27.05.2022.
//

import UIKit
import MapKit

class RouteViewController: UIViewController {
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIElements()
    }


}

// MARK: - Setup UI Elements
extension RouteViewController {
    
    private func setupUIElements() {
        
        createMapViewConstraints()
        
    }
    
    private func createMapViewConstraints() {
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
}

