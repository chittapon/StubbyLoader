//
//  CustomStubViewController.swift
//  StubbyLoader_Example
//
//  Created by Chittapon Thongchim on 29/5/2567 BE.
//  Copyright © 2567 BE CocoaPods. All rights reserved.
//

import UIKit
import StubbyLoader

class CustomStubViewController: BaseViewController {

    @IBOutlet var pathTextFields: [UITextField]!
    @IBOutlet var submitButtons: [UIButton]!
    @IBOutlet var resultTextView: [UITextView]!
    
    deinit {
        StubbyLoader.instance.tearDown()
    }
    
    var paths: [String] = [
        "/redirect?destination=https://www.lipsum.com",
        "/mock/users",
        "/custom"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        title = "CustomStub Programmatically"
        StubbyLoader.instance.startServer()
        
        // Intercept or Custom stub
        StubbyLoader.instance.stubClosure = { request in
            let path = request.path
            print("request Path: \(request.path)")
            if path == "/custom" {
                return .ok(.text("Hello!"))
            }
            return nil
        }
        
        StubbyLoader.instance.add(stub: .init(path: "/redirect", closure: { request in
            if let value = request.queryParams.first(where: { $0.0 == "destination" }) {
                let destination = value.1
                if destination.toURL()?.host != nil {
                    return .movedTemporarily(destination)
                }else {
                    return .badRequest(.text("Invalid destination"))
                }
            }
            return .badRequest(.text("No queryParameter: destination"))
        }))
        
        let request = StubModel.Request(url: "/mock/*")
        let usersFile = Bundle.main.url(forAuxiliaryExecutable: "users.json")?.path
        let response = StubModel.Response(status: 400, file: usersFile, isAbsolutePath: true, body: nil)
        let stubModel = StubModel(request: request, response: response)
        StubbyLoader.instance.add(stubModel: stubModel)
        
        for (index, textField) in pathTextFields.enumerated() {
            textField.text = paths[index]
            textField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        }
    }
    
    func getData(url: String, completion: @escaping (_ data: Data?) -> Void) {
        guard let request = url.toURLRequest() else { return }
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async{ completion(data) }
        }.resume()
    }
    
    @IBAction func submitDidTap(_ sender: UIButton) {
        let index = sender.tag
        pathTextFields[index].resignFirstResponder()
        let textView = resultTextView[index]
        let path = paths[index]
        let url = baseURL.appending(path)
        getData(url: url){ self.displayTextView(textView, data: $0) }
    }
    
    func displayTextView(_ textView: UITextView, data: Data?) {
        if let data = data, !data.isEmpty {
            if let jsonString = data.prettyJSONString {
                textView.text = jsonString
            } else if let htmlString = data.htmlToAttributedString {
                textView.attributedText = htmlString
            } else {
                let text = String(decoding: data, as: UTF8.self)
                textView.text = text
            }
        } else {
            textView.text = "No data"
        }
    }
    
    @objc func textFieldDidChanged(_ sender: UITextField) {
        paths[sender.tag] = sender.text ?? ""
    }
}

extension Data {
    var htmlToAttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(
                data: self,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        } catch {
            return  nil
        }
    }
    
    var prettyJSONString: String? {
        guard let json = try? JSONSerialization.jsonObject(with: self) else { return nil }
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            return String(decoding: jsonData, as: UTF8.self)
        }
        return nil
    }
}
