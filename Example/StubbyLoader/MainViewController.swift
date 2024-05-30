//
//  MainViewController.swift
//  StubbyLoader
//
//  Created by Chittapon Thongchim on 05/29/2024.
//  Copyright (c) 2024 Chittapon Thongchim. All rights reserved.
//

import UIKit
import StubbyLoader

var port = 8080
var baseURL = "http://localhost:\(port)"

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshButton()
    }
    
    func addRefreshButton() {
        let button = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonDidTap))
        navigationItem.rightBarButtonItem = button
    }
    
    @objc func refreshButtonDidTap() {}
    
}

class MainViewController: UIViewController {}

extension String {
    func toURL() -> URL? {
        URL(string: self)
    }
    func toURLRequest() -> URLRequest? {
        toURL().map{URLRequest(url: $0)}
    }
}
