//
//  WSUXKCDComics.swift
//  XKCD_Spring2022
//
//  Created by wsucatslabs on 4/1/22.
//

import Foundation

// Encode information available for each comic
struct XKCDInfo: Codable {
    let month : String
    let num : Int
    let link : String
    let year : String
    let news : String
    let safe_title : String
    let transcript : String
    let alt : String
    let img : String
    let title : String
    let day : String
}

struct Comic {
    let info : XKCDInfo
    let imageData : Data
    
    init(info : XKCDInfo, imageData : Data) {
        self.info = info
        self.imageData = imageData
    }
}

// This is the Model for storing XKCD Commics keyed by
// commic number
class WSUXKCDCommics {
    var comics = Dictionary<Int, Comic>()
    
    func didUpdate() {
        NotificationCenter.default.post(name: NSNotification.Name("modelDidUpdate"), object: nil)
    }
    
    // XKCD API is at https://xkcd.com/json.html
    // Current comic info is at https://xkcd.com/info.0.json
    // Arbitrary comic info is at
    // https://xkcd.com/NNNNN/info.0.json where NNNNN is
    // the number of the comic
    // if number is zero, cownload the current comic and store
    // it at zero in comics
    func downloadComic(number : Int) {
        DispatchQueue.global().async {
            do {
                // Assme we wantthe current comic
                var urlString = "https://xkcd.com/info.0.json"
                
                if(number != 0) {
                    // get numbered comic info
                    urlString = "https://xkcd.com/\(number)/info.0.json"
                }
                let info = try Data(contentsOf: URL(string: urlString)!)
                let jsonDecoder = JSONDecoder()
                let parsedJSON = try jsonDecoder.decode(XKCDInfo.self, from: info)
                let imageData = try Data(contentsOf: URL(string: parsedJSON.img)!)
                DispatchQueue.main.async {
                    // ONLY mutate comics on main thread to
                    // avoid need for mutex lock around comic
                    self.comics[number] = Comic(info: parsedJSON, imageData: imageData)
                    self.didUpdate()
                }
            } catch {
            }
        }
    }
    
    func numberedComic(number : Int) -> Comic? {
        let result = comics[number]
        
        if(nil == result) {
            // download info and imag if possible
            downloadComic(number: number)
        }
        
        return result
    }
    
    func numberOfComics() -> Int {
        // If we have the current comic info, then return
        // the number of the current comic. Otherwise return 0
        // but try to download the current comic so the next
        // time we are asked, we will return non-zero
        if let comic = comics[0] {
            // We have the current comic info
            return comic.info.num
        } else {
            downloadComic(number: 0)
        }
        return 0
    }
}
