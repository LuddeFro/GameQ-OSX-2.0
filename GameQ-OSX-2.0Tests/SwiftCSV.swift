//
//  CSV.swift
//  SwiftCSV
//
//  Created by naoty on 2014/06/09.
//  Copyright (c) 2014年 Naoto Kaneko. All rights reserved.
//

import Foundation

public class CSV {
    public var headers: [String] = []
    public var rows: [Dictionary<String, String>] = []
    public var columns = Dictionary<String, [String]>()
    var delimiter = NSCharacterSet(charactersInString: ",")
    
    public init?(contentsOfFile url: String, delimiter: NSCharacterSet, encoding: UInt, error: NSErrorPointer) {
        let csvString = String(contentsOfFile: url, encoding: encoding, error: error);
        if let csvStringToParse = csvString {
            self.delimiter = delimiter
            
            let newline = NSCharacterSet.newlineCharacterSet()
            var lines: [String] = []
            csvStringToParse.stringByTrimmingCharactersInSet(newline).enumerateLines { line, stop in lines.append(line) }
            
            self.headers = self.parseHeaders(fromLines: lines)
            self.rows = self.parseRows(fromLines: lines)
            self.columns = self.parseColumns(fromLines: lines)
        }
    }
    
    public convenience init?(contentsOfFile path: String, error: NSErrorPointer) {
        let comma = NSCharacterSet(charactersInString: ",")
        self.init(contentsOfFile: path, delimiter: comma, encoding: NSUTF8StringEncoding, error: error)
    }
    
    public convenience init?(contentsOfFile path: String, encoding: UInt, error: NSErrorPointer) {
        let comma = NSCharacterSet(charactersInString: ",")
        self.init(contentsOfFile: path, delimiter: comma, encoding: encoding, error: error)
    }
    
    func parseHeaders(fromLines lines: [String]) -> [String] {
        return ["src", "dst", "time", "iplen"]
    }
    
    func parseRows(fromLines lines: [String]) -> [Dictionary<String, String>] {
        var rows: [Dictionary<String, String>] = []
        
        for (lineNumber, line) in enumerate(lines) {
            var row = Dictionary<String, String>()
            let values = line.componentsSeparatedByCharactersInSet(self.delimiter)
            for (index, header) in enumerate(self.headers) {
                let value = values[index]
                row[header] = value
            }
            rows.append(row)
        }
        
        return rows
    }
    
    func parseColumns(fromLines lines: [String]) -> Dictionary<String, [String]> {
        var columns = Dictionary<String, [String]>()
        
        for header in self.headers {
            let column = self.rows.map { row in row[header]! }
            columns[header] = column
        }
        
        return columns
    }
    
    class func readOneCSV(pathIn:String?){
        
        if let path = pathIn {
            var error: NSErrorPointer = nil
            if let csv = CSV(contentsOfFile: path, error: error) {
                
                // Rows
                let rows = csv.rows
                
                for row in reverse(rows){
                    var src:Int = row["src"]!.toInt()!
                    var dst:Int = row["dst"]!.toInt()!
                    var iplen:Int = row["iplen"]!.toInt()!
                    var time:Double = (row["time"]! as NSString).doubleValue
                    
                    LoLDetector.handleTest(src, dstPort: dst, iplen: iplen, time: time)
                }
            }
        }
    }
}