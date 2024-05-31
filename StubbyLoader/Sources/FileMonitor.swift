//
//  FileMonitor.swift
//  StubbyLoader
//
//  Created by Chittapon Thongchim on 29/5/2567 BE.
//

import Foundation

protocol FileMonitorDelegate: AnyObject {
    func fileDidChange(_ file: String)
}

final class FileMonitor {

    let url: URL
    var fileHandle: FileHandle?
    var source: DispatchSourceFileSystemObject?
    weak var delegate: FileMonitorDelegate?
    let queue = DispatchQueue(label: "FileMonitor", qos: .default)
    var previousData: Data?
    
    init(url: URL) throws {
        self.url = url
    }

    deinit {
        source?.cancel()
    }
    
    func start() throws {
        let fileHandle = try FileHandle(forReadingFrom: url)
        self.fileHandle = fileHandle
        
        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileHandle.fileDescriptor,
            eventMask: .all,
            queue: queue
        )

        source?.setEventHandler { [self] in
            self.processEvent()
        }

        source?.setCancelHandler {
            fileHandle.closeFile()
        }
        
        previousData = fileHandle.readDataToEndOfFile()
        
        source?.resume()
    }
    
    func stop() {
        fileHandle?.closeFile()
    }

    func processEvent() {
        let data = fileHandle?.readDataToEndOfFile()
        guard data != previousData else {
            return
        }
        previousData = data
        stop()
        try? start()
        delegate?.fileDidChange(url.path)
    }
}
