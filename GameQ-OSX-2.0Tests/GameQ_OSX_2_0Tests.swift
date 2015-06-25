////
////  GameQ_OSX_2_0Tests.swift
////  GameQ-OSX-2.0Tests
////
////  Created by Ludvig Fröberg on 18/05/15.
////  Copyright (c) 2015 GameQ AB. All rights reserved.
////
//
//import Cocoa
//import XCTest
//
//class GameQ_OSX_2_0Tests: XCTestCase {
//    
//    override func setUp() {
//        super.setUp()
//        GameDetector.status = Status.InLobby
//        GameDetector.isTesting = true
//    }
//    
//    override func tearDown() {
//        GameDetector.resetDetection()
//        GameDetector.isTesting = false
//        super.tearDown()
//    }
//    
//    func testAllFilesDota2(){
//        GameDetector.updateGame(Game.Dota)
//        let filemanager:NSFileManager = NSFileManager()
//        let files = filemanager.enumeratorAtPath("/Users/fabianwikstrom/Desktop/GameQ-Caps/DOTA2/")
//        while let file = files?.nextObject() as? String {
//            if file.hasSuffix("csv") { // checks the extension
//                testIteratorDota2(file)
//            }
//        }
//    }
//    
//    func testIteratorDota2(file:String) {
//       
//        println(file)
//        setUp()
//        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/DOTA2/" + file)
//        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
//        tearDown()
//    }
//    
//    func testOneFileDota2(){
//        GameDetector.updateGame(Game.Dota)
//        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/DOTA2/Jun 23, 2015, 105140 PM.csv")
//        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
//    }
//    
//    func testAllFilesCS(){
//        GameDetector.updateGame(Game.CSGO)
//        let filemanager:NSFileManager = NSFileManager()
//        let files = filemanager.enumeratorAtPath("/Users/fabianwikstrom/Desktop/GameQ-Caps/CSGO/")
//        while let file = files?.nextObject() as? String {
//            if file.hasSuffix("csv") { // checks the extension
//                testIteratorCS(file)
//            }
//        }
//    }
//    
//    func testIteratorCS(file:String) {
//        
//        println(file)
//        setUp()
//        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/CSGO/" + file)
//        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
//        tearDown()
//    }
//    
//    func testOneFileCS(){
//        GameDetector.updateGame(Game.CSGO)
//        CSV.readOneCSV("/Users/fabianwikstrom/Desktop/GameQ-Caps/CSGO/Jun 24, 2015, 10742 PM.csv")
//        XCTAssert(GameDetector.status == Status.GameReady || GameDetector.status == Status.InGame, "Test Passed")
//    }
//    
//}
