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
        let files = filemanager.enumeratorAtPath("/Users/fabianwikstrom/Desktop/GameQ-Caps/DOTA2/")
        while let file = files?.nextObject() as? String {
            if file.hasSuffix("csv") { // checks the extension
                testIteratorDota2(file)
            }
        }
    }
    
    func testIteratorDota2(file:String) {
       
        println(file)
        setUp()
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/DOTA2/" + file)
        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
        tearDown()
    }
    
    func testOneFileDota2(){
        GameDetector.detector = DotaDetector.self
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/DOTA2/asd5.csv")
        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
    }
    
    func testAllFilesCS(){
        GameDetector.detector = CSGODetector.self
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath("/Users/fabianwikstrom/Desktop/GameQ-Caps/CSGO/")
        while let file = files?.nextObject() as? String {
            if file.hasSuffix("csv") { // checks the extension
                testIteratorCS(file)
            }
        }
    }
    
    func testIteratorCS(file:String){
        println(file)
        setUp()
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/CSGO/" + file)
        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
        tearDown()
    }
    
    func testOneFileCS(){
       GameDetector.detector = CSGODetector.self
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/CSGO/Jun 24, 2015, 10742 PM.csv")
        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
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
        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/League of Legends/Jul 10, 2015, 53029 PM.csv")
        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
    }
}
