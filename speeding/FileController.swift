//
//  FileController.swift
//  speeding
//
//  Created by hackintosh on 4/7/19.
//  Copyright © 2019 wilksmac. All rights reserved.
//

import Foundation

class FileController {
    
    static var speedLogs: [String] = []
    
    static func getDocumentsDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func getAllDocuments()-> [URL]{
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print(fileURLs)
            return fileURLs
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            return []
        }
    }
    
    static func getFileURL(_ file: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(file)
    }
    
    static func checkFile(_ filename: String){
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent(filename).path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            print("log available")
        } else {
            print("no log file")
            createLog()
        }
    }
    
    static func createLog(){
        
        let file = "log.txt"
        let text = "Speed LOG"
        
        let path = getFileURL(file)
        
        do {
            try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            print("ERROR: creating log")
        }
    }
    
    static func logSpeed(_ logString: String){
        do {
            let url = FileController.getFileURL("log.txt")
            let stringSpace = logString + "\n"
            //let data = stringSpace.data(using: String.Encoding.utf8)!
            speedLogs.append(stringSpace)
            try stringSpace.appendToURL(url)
        } catch {
            print("ERROR: could not write to log file")
        }
    }
    
}
