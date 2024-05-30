//
//  LocalFileViewController.swift
//  StubbyLoader_Example
//
//  Created by Chittapon Thongchim on 29/5/2567 BE.
//  Copyright © 2567 BE CocoaPods. All rights reserved.
//

import UIKit
import StubbyLoader

class LocalFileViewController: BaseViewController {

    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getData()
    }
    
    func setup() {
        title = "LocalFile"
        StubbyLoader.instance.stubClosure = { request in
            
            return nil
        }
        StubbyLoader.instance.startServer()
    }
    
    func getData() {
        guard let request = baseURL.appending("/users").toURLRequest() else { return }
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
