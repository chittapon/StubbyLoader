//
//  StubbyLoader.swift
//  StubbyLoader
//
//  Created by Chittapon Thongchim on 29/5/2567 BE.
//

import Foundation
import Swifter
import Yams

@objc(StubbyLoader)
public final class StubbyLoader: NSObject {
    
    // MARK: - Public
    public static var instance: StubbyLoader!
    public var stubClosure: ((HttpRequest) -> HttpResponse?)?
    public var environment: StubbyLoaderEnvironment = StubbyLoaderEnvironment()
    public var defaultHeaders = ["Content-Type": "text/html;charset=utf-8"]
    
    // MARK: - Internal
    var server = HttpServer()
    var stub: [StubModel] = []
    var fileMonitor: FileMonitor?
    let logPrefix = "StubbyLoader"
    
    override init() {
        super.init()
        StubbyLoader.instance = self
        startServer()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stopServer),
            name: Notification.Name.UIApplicationWillTerminate, object: nil
        )
    }
    
    // MARK: - Public
    
    public func startServer() {
        server.stop()
        server = HttpServer()
        loadConfigFile()
        do {
            add(stubModels: stub)
            server.notFoundHandler = { request in
                if let customResponse = self.stubClosure?(request) {
                    return customResponse
                }
                return HttpResponse.notFound
            }
            try server.start(environment.port, forceIPv4: true)
            print("ℹ️ \(logPrefix) server \(server.state) at \(try server.port())")
        } catch let error {
            print("⚠️ \(logPrefix) start server failed: \(error)")
        }
    }
    
    public func add(stub: Stub) {
        server[stub.path] = { request in
            if let customResponse = self.stubClosure?(request) {
                return customResponse
            }
            return stub.closure(request)
        }
    }
    
    public func add(stubModel: StubModel) {
        addRoute(stubModel: stubModel)
    }
    
    public func add(stubs: [Stub]) {
        for stub in stubs {
            add(stub: stub)
        }
    }
    
    public func add(stubModels: [StubModel]) {
        for stubModel in stubModels {
            add(stubModel: stubModel)
        }
    }
    
    @objc public func stopServer() {
        server.stop()
        print("ℹ️ \(logPrefix) server \(server.state)")
    }
    
    public func tearDown() {
        stopServer()
        stubClosure = nil
        environment = StubbyLoaderEnvironment()
        stub.removeAll()
        stopObserveFilesChanged()
    }
    
    // MARK: - Internal
    
    func loadConfigFile() {
        environment.loadConfig()
        guard let configFileURL = environment.configFileURL else {
            print("⚠️ \(logPrefix) invalid STUBBY_PATH")
            return
        }
        do {
            let fileHandle = try FileHandle(forReadingFrom: configFileURL)
            let data = fileHandle.readDataToEndOfFile()
            fileHandle.closeFile()
            observeFilesChanged()
            let decoder = YAMLDecoder()
            stub = try decoder.decode([StubModel].self, from: data)
        } catch let error {
            print("⚠️ \(logPrefix) could not load \(configFileURL)\n\(error)")
        }
    }
    
    func observeFilesChanged() {
        guard let configURL = environment.configFileURL, fileMonitor?.url != configURL else {
            return
        }
        do {
            fileMonitor = try FileMonitor(url: configURL)
            fileMonitor?.delegate = self
            try fileMonitor?.start()
            print("ℹ️ \(logPrefix) loaded config file: \(configURL.path)")
        } catch let error {
            print("⚠️ \(logPrefix) failed to observeFilesChanged: \(error)")
        }
    }
    
    func stopObserveFilesChanged() {
        fileMonitor?.stop()
        fileMonitor = nil
    }
    
    func addRoute(stubModel: StubModel) {
        guard let response = stubModel.response else { return }
        let statusCode = response.status
        let headers = getHeaders(override: response.headers)
        if let filePath = response.file {
            server[stubModel.request.url] = { request in
                if let customResponse = self.stubClosure?(request) {
                    return customResponse
                }
                return HttpResponse.raw(statusCode, "", headers) { writer in
                    if response.isAbsolutePath ?? false {
                        try self.writeFile(filePath, writer: writer)
                    } else {
                        guard let stubbyDir = self.environment.stubbyDir else { return }
                        let fileURL = stubbyDir.appendingPathComponent(filePath)
                        try self.writeFile(fileURL.path, writer: writer)
                    }
                }
            }
        } else if let body = response.body {
            server[stubModel.request.url] = { request in
                if let customResponse = self.stubClosure?(request) {
                    return customResponse
                }
                return HttpResponse.raw(statusCode, "", headers) { writer in
                    try self.writeBody(body, writer: writer)
                }
            }
        }
    }
    
    func getHeaders(override: [String: String]?) -> [String: String]? {
        var headers = defaultHeaders
        let overrideHeaders = override ?? [:]
        for override in overrideHeaders {
            headers[override.key] = override.value
        }
        return headers
    }
    
    func writeFile(_ file: String, writer: HttpResponseBodyWriter) throws {
        do {
            let file = try file.openForReading()
            try writer.write(file)
            file.close()
        } catch let error {
            let data = [UInt8](error.localizedDescription.utf8)
            try writer.write(data)
        }
    }
    
    func writeBody(_ body: String, writer: HttpResponseBodyWriter) throws {
        let data = [UInt8](body.utf8)
        try writer.write(data)
    }
}

extension StubbyLoader: FileMonitorDelegate {
    func fileDidChange(_ file: String) {
        print("ℹ️ \(logPrefix) reload file \(file) changed")
        startServer()
    }
}
