//
//  StubModel.swift
//  StubbyLoader
//
//  Created by Chittapon Thongchim on 29/5/2567 BE.
//

import Swifter
import CoreServices

public struct Stub {
    public let path: String
    public let closure: (HttpRequest) -> HttpResponse
    
    public init(path: String, closure: @escaping (HttpRequest) -> HttpResponse) {
        self.path = path
        self.closure = closure
    }
}

public struct StubModel: Decodable {
    public let request: Request
    public let response: Response?
    
    public init(request: Request, response: Response?) {
        self.request = request
        self.response = response
    }
    
    public struct Request: Decodable {
        
        public let url: String
        public let method: String
        
        public init(url: String, method: String = "GET") {
            self.url = url
            self.method = method
        }
    }
    
    public struct Response: Decodable {
        public let status: Int
        public let file: String?
        public let body: String?
        public let headers: [String: String]?
        let isAbsolutePath: Bool?
        
        public init(
            status: Int,
            file: String?,
            isAbsolutePath: Bool? = false,
            body: String?,
            headers: [String: String]? = nil
        ) {
            self.status = status
            self.file = file
            self.isAbsolutePath = isAbsolutePath
            self.body = body
            self.headers = headers
        }
    }
}
