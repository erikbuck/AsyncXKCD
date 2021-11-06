//
//  WSUXKCDModel.swift
//  WSUXKCD
//
//  Created by Erik M. Buck on 11/3/21.
//

import UIKit

class WSUXKCDModel : NSObject, URLSessionDataDelegate {
    
    var numberOfAvailableImages = Int32(0) {
        didSet {
            // When the number of available images changes, totify any observers
            NotificationCenter.default.post(name: NSNotification.Name("numberOfAvailableImages"), object: self)
        }
    }
    
    var infos = Dictionary<Int32, XKCDInfo>() // Info about a comic
    var images = Dictionary<Int32, UIImage>() // Image for the comic
    
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
    
    // Create a session for asnchronous downloads only when needed
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration,
                          delegate: self, delegateQueue: nil)
    }()
    
    // Asynchronously download the current comic info so that we know how many
    // comics are available
    func getCurrentInfo() {
        let url = URL(string: "http://xkcd.com/info.0.json")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let parsedJSON = try jsonDecoder.decode(XKCDInfo.self, from: data)
                    DispatchQueue.main.async {
                        // Only update shared data on teh main thread to avoid
                        // data corruption
                        let number = Int32(parsedJSON.num)
                        self.numberOfAvailableImages = number
                        self.infos[number-1] = parsedJSON
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    // If we already have the image for the specified comic index, return that image.
    // Otherwise, return nil
    func imageFor(index : Int32) -> UIImage?
    {
        if let result = self.images[index] {
            return result
        }
        if let url = URL(string:"http://xkcd.com/\(index)/info.0.json") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let parsedJSON = try jsonDecoder.decode(XKCDInfo.self, from: data)
                         let imageUrl = URL(string:parsedJSON.img)!
                        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                            if let data = data {
                                let image = UIImage(data: data)
                                DispatchQueue.main.async {
                                    // Only update shared data on teh main thread to avoid
                                    // data corruption
                                    //print(parsedJSON)
                                    self.infos[index] = parsedJSON
                                    self.images[index] = image
                                    
                                    // Now that we have the image, let any interested observers know
                                    NotificationCenter.default.post(name: NSNotification.Name("numberOfAvailableImages"), object: self)
                                }
                            }
                        }.resume()
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
        return nil
    }
}
