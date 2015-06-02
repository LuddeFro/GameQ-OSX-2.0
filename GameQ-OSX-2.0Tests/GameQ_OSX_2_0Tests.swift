//
//  GameQ_OSX_2_0Tests.swift
//  GameQ-OSX-2.0Tests
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa
import XCTest

class GameQ_OSX_2_0Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        DotaDetector.running = true
    }
    
    override func tearDown() {
        DotaDetector.reset()
        super.tearDown()
    }
    
    func testAllFiles(){
        
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath("/Users/fabianwikstrom/Desktop/GameQ-Caps/dota/")
        while let file = files?.nextObject() as? String {
            if file.hasSuffix("csv") { // checks the extension
                testIterator(file)
            }
        }
    }
    
    func testIterator(file:String) {
       
        println(file)
        setUp()
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/dota/" + file)
        XCTAssert(DotaDetector.status == Status.GameReady, "Test Passed")
        tearDown()
    }
    
    func testOneFile() {

        setUp()
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/dota/d22-game.csv")
        XCTAssert(DotaDetector.status == Status.GameReady, "Test Passed")
        tearDown()
    }
}
