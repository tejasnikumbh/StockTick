//
//  Socket.swift
//  StockTick
//
//  Created by Tejas  Nikumbh on 15/09/16.
//  Copyright © 2016 Tejas  Nikumbh. All rights reserved.
//

import UIKit
import Foundation

protocol DataPointStore {
    func storeDataPoint(data: String)
}

class Socket: NSObject {
    
    var host:String!
    var port:UInt32!
    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?
    var status = false;
    var output = "message"
    var bufferSize = 1024;
    var updateDelegate: DataPointStore?
    var hasPingedServer = false
    
    init(host: String, port:UInt32){
        self.host = host
        self.port = port
        self.status = false
        output = ""
        super.init()
    }
    
    func connect() {
        print("# connecting to \(host):\(port)")
        var cfReadStream : Unmanaged<CFReadStream>?
        var cfWriteStream : Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port!, &cfReadStream, &cfWriteStream)
        inputStream = cfReadStream!.takeRetainedValue()
        outputStream = cfWriteStream!.takeRetainedValue()
        inputStream!.delegate = self
        outputStream!.delegate = self
        inputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        inputStream!.open()
        outputStream!.open()
    }
}

extension Socket: NSStreamDelegate {
    
    func stream(aStream: NSStream, handleEvent aStreamEvent: NSStreamEvent) {
        switch aStreamEvent {
        case NSStreamEvent.OpenCompleted:
            print("OpenCompleted")
            break
        case NSStreamEvent.HasBytesAvailable:
            print("HasBytesAvailable")
            if aStream == inputStream { read() }
            break
        case NSStreamEvent.HasSpaceAvailable:
            print("HasSpaceAvailable")
            if aStream == outputStream && !hasPingedServer{
                send("hello")
                hasPingedServer = true
            }
            break
        case NSStreamEvent.EndEncountered:
            print("EndEncountered")
            aStream.removeFromRunLoop(NSRunLoop.currentRunLoop(),
                                      forMode: NSDefaultRunLoopMode)
            break
        case NSStreamEvent.None:
            break
        case NSStreamEvent.ErrorOccurred:
            break
        default:
            print("# something weird happend")
            break
        }
    }
    
    func read(){
        var buffer = [UInt8](count: bufferSize, repeatedValue: 0)
        output = ""
        while (self.inputStream!.hasBytesAvailable){
            let bytesRead: Int = inputStream!.read(&buffer, maxLength: buffer.count)
            if bytesRead >= 0 {
                output += NSString(bytes: UnsafePointer(buffer), length: bytesRead, encoding: NSASCIIStringEncoding)! as String
            } else {
                print("# error")
            }
            print("> \(output)")
            let outputs = output.characters.split{$0 == "\n"}.map(String.init)
            if let updateDelegate = updateDelegate {
                updateDelegate.storeDataPoint(outputs[0])
            }
        }
    }
    
    func send(message:String){
        let data:NSData = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        self.outputStream!.write(UnsafePointer(data.bytes), maxLength: data.length)
        print("< send to \(host)")
    }
}