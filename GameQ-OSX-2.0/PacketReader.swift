//
//  Capture.swift
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class PacketReader {
    
    
    struct Static {
        static let filter:UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>("".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!.bytes)
        static let snapLength:Int32 = 64 // length to be caught
        static let snapNum:Int32 = 0 // number of packets to be caught
        
    }
    
    
    /**
    description:
    input: 
    output:
    */
    class func start() {
        
        var fp:bpf_program = bpf_program()
        var net:bpf_u_int32 = 0
        var mask:bpf_u_int32 = 0
        
        var errbuf:UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>()
        var handle = pcap_create("0", errbuf)
        pcap_activate(handle)
        
        pcap_set_snaplen(handle, Static.snapLength)
        
        /* Compile a filter */
        if (pcap_compile(handle, &fp, Static.filter, 0, net) == -1){
            println("Coudldn't compile filter")
            return;
        }
        /* Apply a filter */
        if (pcap_setfilter(handle, &fp) == -1){
            println("Coudldn't apply filter")
            return;
        }
        
        println("start loop")
        dispatch_async(dispatch_queue_create("io.GameQ.OSX.2_0", DISPATCH_QUEUE_CONCURRENT), {
            PacketParser.start_loop(handle, numPacks: Static.snapNum, user: UnsafeMutablePointer<u_char>())
        })
        println("loop started")
    }
    
        
    
    /**
    description:
    input:
    output:
    */
    class func stop() {
        
    }
    
    
    
    
    
    
    
    
}