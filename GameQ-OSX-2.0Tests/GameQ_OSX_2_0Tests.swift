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
        MasterController.game = Game.Dota
        MasterController.status = Status.InLobby
    }
    
    override func tearDown() {
        MasterController.reset()
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
        XCTAssert(MasterController.status == Status.GameReady, "Test Passed")
        tearDown()
    }
    
    func testOneFile() {

        setUp()
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/Dota/Jun 4, 2015, 4:33:04 PM.csv")
        XCTAssert(MasterController.status == Status.GameReady, "Test Passed")
        tearDown()
    }
}
