//
//  MapLocationController.swift
//  CWWeChat
//
//  Created by wei chen on 2017/9/20.
//  Copyright © 2017年 cwwise. All rights reserved.
//

import UIKit
import MapKit

public protocol MapLocationControllerDelegate: class {
    func sendLocation(_ location: CLLocationCoordinate2D)
}

public class MapLocationController: UIViewController {

    public weak var delegate: MapLocationControllerDelegate?
    
    public var mapView: MKMapView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MKMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        let sendItem = UIBarButtonItem(title: "发送", style: .done, target: self, action: #selector(sendLocation))
        self.navigationItem.rightBarButtonItem = sendItem
    }
    
    @objc func sendLocation() {
        
        //
        
        
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MapLocationController: MKMapViewDelegate {
    
    
    
}
