//
//  ViewController.swift
//  meRoute
//
//  Created by Александр Прайд on 27.05.2022.
//

import UIKit
import MapKit
import CoreLocation

class RouteViewController: UIViewController {
    
    // properties
    let mapView: MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let addAddressButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Adress", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGray
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        return button
    }()
    
    let routeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Route", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .systemGray
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        button.isHidden = true
        return button
    }()
    let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reset", for: .normal)
        button.tintColor = .red
        button.backgroundColor = .systemGray
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        button.isHidden = true
        return button
    }()
    
    var annoationStorage = [MKAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        mapView.delegate = self

        addSubiews()
        applyConstraints()
        callActions()
    }

    private func callActions() {
        addAddressButton.addTarget(self, action: #selector(addAddressButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    

}

// MARK: - Setup UI Elements
extension RouteViewController {
    
    private func addSubiews() {
        view.addSubview(mapView)
        mapView.addSubview(addAddressButton)
        mapView.addSubview(routeButton)
        mapView.addSubview(resetButton)
    }
    
    
    private func applyConstraints() {
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            addAddressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAddressButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 40),
            addAddressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -40),
            addAddressButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        
        NSLayoutConstraint.activate([
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -110),
            routeButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -30),
            routeButton.heightAnchor.constraint(equalToConstant: 50),
            routeButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30),
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -30),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            resetButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}

// MARK: - Action for Buttons
extension RouteViewController {
    
    @objc private func addAddressButtonTapped() {
        alertAddAddress(title: "Добавить", placeholder: "Введите адрес") { [self] (text) in
            setupPlaceMark(address: text)
        }
    }
    
    @objc private func routeButtonTapped() {
        
        for i in 0...annoationStorage.count - 2 {
            
            directionReauest(startCoordinate: annoationStorage[i].coordinate, destinationCoordinate: annoationStorage[i + 1].coordinate)
        }
        
        mapView.showAnnotations(annoationStorage, animated: true)
    }
    
    @objc private func resetButtonTapped() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annoationStorage = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }
}

// MARK: - Annotations
extension RouteViewController {
    
    private func setupPlaceMark(address: String) {
        // преобразуем ввод текста из строки в координаты
        // для этого используется GEOCoder
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { [self] (placemarks, error) in
            
            if let error = error {
                print(error)
                alertError(title: "Ошибка", message: "Проблемы с сервером. Попробуйте добавить адрес ещё раз")
                return
            }
            
            guard let placemarks = placemarks else { return }
            // из массива схожих адресов берём "наилучший"
            let placemark = placemarks.first
            
            // строим аннотацию
            // экземпляр аннотаци
            let annotation = MKPointAnnotation()
            // заголовок аннотации
            annotation.title = "\(address)"
            // расположение аннотации, выстаскиваем координаты из placemark
            guard let placemarkLocation = placemark?.location else { return }
            // присваиваем нашей аннотации координаты placemark
            annotation.coordinate = placemarkLocation.coordinate
            
            // создаём массив для хранения всех аннотаций
            // массив хранит все аннотации, указанные на карте (вместо встоенного mapView.annotations)
            annoationStorage.append(annotation)
            // показываем кнопки
            if annoationStorage.count > 2 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            
            // отображаем аннотации на карте
            mapView.showAnnotations(annoationStorage, animated: true)
            
        }
    }
    
    // строим маршрут между 2 точками
    private func directionReauest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        // создаём начальную и конечную точку
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        //делаем запрос
        let request = MKDirections.Request()
        //указываем источник, откуда будет запрос
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        
        // на чём путешествовать
        request.transportType = .walking
        // показывать альтернативные маршруты
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        directions.calculate { (responce, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let responce = responce else {
                self.alertError(title: "Ошибка", message: "Маршрут недоступен!")
                return
            }
            
            // ищем миинимальный маршрут
            var minRoute = responce.routes[0]
            for route in responce.routes{
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

// MARK: - MKMapViewDelegate
extension RouteViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let rendere = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        rendere.strokeColor = #colorLiteral(red: 0.9725490196, green: 0.02352941176, blue: 0.8, alpha: 1)
        return rendere
    }
}
