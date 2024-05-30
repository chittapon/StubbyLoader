//
//  BundleFileViewController.swift
//  StubbyLoader_Example
//
//  Created by Chittapon Thongchim on 29/5/2567 BE.
//  Copyright © 2567 BE CocoaPods. All rights reserved.
//

import UIKit
import StubbyLoader

class BundleFileViewController: BaseViewController {

    @IBOutlet var textView: UITextView!
    
    deinit {
        StubbyLoader.instance.tearDown()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getData()
    }
    
    func setup() {
        title = "BundleFile"
        /// Note - You can exclude stub resource bundle on the Production environment by  setting EXCLUDED_SOURCE_FILE_NAMES on your build configuration
        let bundlePath = Bundle.main.path(forResource: "StubbyLoader_Resource", ofType: "bundle")
        let environment = StubbyLoaderEnvironment(path: bundlePath, configFile: "bundle_config.yaml")
        StubbyLoader.instance.environment = environment
        StubbyLoader.instance.startServer()
    }
    
    func getData() {
        guard let request = baseURL.appending("/posts").toURLRequest() else { return }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    let text = String(data: data, encoding: .utf8)
                    self.textView.text = text
                }
            }
        }.resume()
    }
    
    override func refreshButtonDidTap() {
        getData()
    }

}
