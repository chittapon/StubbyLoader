//
//  StubbyLoaderEnvironment.swift
//  StubbyLoader
//
//  Created by Chittapon Thongchim on 29/5/2567 BE.
//

import Foundation

public final class StubbyLoaderEnvironment {
    public var path: String? { _path }
    public var configFile: String { _configFile ?? "config.yaml" }
    public var port: UInt16 { _port ?? 8080 }
    
    var stubbyDir: URL?
    var configFileURL: URL? {
        stubbyDir?.appendingPathComponent(configFile)
    }
    private var _path: String?
    private var _configFile: String?
    private var _port: UInt16?
    private let STUBBY_PATH = "STUBBY_PATH"
    private let STUBBY_PORT = "STUBBY_PORT"
    private let STUBBY_CONFIG = "STUBBY_CONFIG"
    private let logPrefix = "StubbyLoader"
    
    public init(
        path: String? = nil,
        configFile: String? = nil,
        port: Int? = nil
    ) {
        _path = path
        _configFile = configFile
        if let port = port {
            _port = UInt16(port)
        }
    }
    
    func loadConfig() {
        let environment = ProcessInfo.processInfo.environment
        if _path == nil, let path = environment[STUBBY_PATH] {
            _path = path
        }
        if _port == nil, let port = environment[STUBBY_PORT] {
            _port = UInt16(port)
        }
        if _configFile == nil, let config = environment[STUBBY_CONFIG] {
            _configFile = config
        }
        
        if let path = _path, !path.isEmpty {
            stubbyDir = URL(string: path)
        } else {
            /// Used default path:  $SRCROOT/stubby
            let bundle = Bundle(for: StubbyLoaderEnvironment.self)
            let frameworkPath = bundle.object(forInfoDictionaryKey: STUBBY_PATH) as? String
            stubbyDir = URL(string: frameworkPath ?? "")?.standardized
            let defaultStubbyFolder = "stubby"
            stubbyDir = stubbyDir?.appendingPathComponent(defaultStubbyFolder)
        }
        print("ℹ️ \(logPrefix) loaded environment:\n\(description)")
    }
}

extension StubbyLoaderEnvironment: CustomStringConvertible {
    public var description: String {
        environmentDescription()
    }
    func environmentDescription() -> String {
        var json: [String: AnyHashable] = [:]
        json[STUBBY_PATH] = stubbyDir?.path ?? "null"
        json[STUBBY_PORT] = port
        json[STUBBY_CONFIG] = configFile
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            return String(decoding: jsonData, as: UTF8.self)
        } else {
            return json.description
        }
    }
}
