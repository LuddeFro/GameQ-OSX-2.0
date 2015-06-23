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
        MasterController.updateGame(Game.Dota)
        MasterController.status = Status.InLobby
        MasterController.isTesting = true
    }
    
    override func tearDown() {
        MasterController.reset()
        MasterController.isTesting = false
        super.tearDown()
    }
    
    func testAllFiles(){
        
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath("/Users/fabianwikstrom/Desktop/GameQ-Caps/DOTA2/")
        while let file = files?.nextObject() as? String {
            if file.hasSuffix("csv") { // checks the extension
                testIterator(file)
            }
        }
    }
    
    func testIterator(file:String) {
       
        println(file)
        setUp()
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/DOTA2/" + file)
        XCTAssert(MasterController.status == Status.GameReady || MasterController.status == Status.InGame, "Test Passed")
        tearDown()
    }
    
    func testOneFile() {
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/DOTA2/1234.csv")
        XCTAssert(MasterController.status == Status.GameReady || MasterController.status == Status.InGame, "Test Passed")
    }
}
