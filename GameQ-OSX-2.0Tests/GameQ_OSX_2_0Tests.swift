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
        GameDetector.detector.status = Status.InLobby
        GameDetector.detector.isTesting = true
    }
    
    override func tearDown() {
        GameDetector.detector.isTesting = true
        GameDetector.detector.resetDetection()
        GameDetector.isTesting = false
        super.tearDown()
        println("Test Finished")
    }
    
    func testAllFilesDota2(){
        GameDetector.detector = DotaDetector.self
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath("/Users/fabianwikstrom/Desktop/GameQ-Caps/dota 2/")
        while let file = files?.nextObject() as? String {
            if file.hasSuffix("csv") { // checks the extension
                testIteratorDota2(file)
            }
        }
    }
    
    func testIteratorDota2(file:String) {
        GameDetector.detector = DotaDetector.self
        GameDetector.game = Game.Dota2
        println("starting:" + file)
        setUp()
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/dota 2/" + file)
        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
        if(GameDetector.status != Status.GameReady){println("failed: " + file)}
        tearDown()
    }
    
    func testOneFileDota2(){
        GameDetector.detector = DotaDetector.self
        GameDetector.game = Game.Dota2
        var file:String = "Jul 14, 2015, 31925 PM.csv"
        println("starting " + file)
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/Dota 2ForcedFails/" + file)
        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
        if(GameDetector.status != Status.GameReady){println("failed: " + file)}
    }
    
    func testAllFilesCS(){
        GameDetector.detector = CSGODetector.self
        GameDetector.game = Game.CSGO
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath("/Users/fabianwikstrom/Desktop/GameQ-Caps/Counter Strike Global Offensive/")
        while let file = files?.nextObject() as? String {
            if file.hasSuffix("csv") { // checks the extension
                testIteratorCS(file)
            }
        }
    }
    
    func testIteratorCS(file:String){
        GameDetector.detector = CSGODetector.self
        GameDetector.game = Game.CSGO
        println("starting:" + file)
        setUp()
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/Counter Strike Global Offensive/" + file)
        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
        if(GameDetector.status != Status.GameReady){println("failed: " + file)}
        tearDown()
    }
    
    func testOneFileCS(){
        GameDetector.detector = CSGODetector.self
        GameDetector.game = Game.CSGO
        var file:String = "Jun 24, 2015, 12652 PM.csv"
        println("starting:" + file)
        setUp()
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/Counter Strike Global Offensive/" + file)
        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
        tearDown()
    }
    
    func testAllFilesLoL(){
        GameDetector.detector = LoLDetector.self
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath("/Users/fabianwikstrom/Desktop/GameQ-Caps/League of Legends/")
        while let file = files?.nextObject() as? String {
            if file.hasSuffix("csv") { // checks the extension
                testIteratorLoL(file)
            }
        }
    }
    
    func testIteratorLoL(file:String){
        println("starting " + file)
        setUp()
        GameDetector.detector = LoLDetector.self
        GameDetector.game = Game.LoL
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/League of Legends/" + file)
        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
        if(GameDetector.status != Status.GameReady){println("failed: " + file)}
        tearDown()
    }
    
    func testOneFileLoL(){
        GameDetector.detector = LoLDetector.self
        GameDetector.game = Game.LoL
        var file:String = "Jun 29, 2015, 65528 PM.csv"
        println("starting " + file)
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/League of Legends/" + file)
        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
        if(GameDetector.status != Status.GameReady){println("failed: " + file)}
    }
}
