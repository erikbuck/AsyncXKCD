//
//  ViewController.swift
//  XKCD_Spring2022
//
//  Created by wsucatslabs on 3/28/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet var comicsTable : UITableView?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model.numberOfComics()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let number = appDelegate.model.numberOfComics()
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! ComicCell

        if let comic = appDelegate.model.numberedComic(number: number - indexPath.row) {
            cell.comicImageView?.image = UIImage(data: comic.imageData)
            cell.comicImageView?.alpha = 1.0
            cell.notAvalableLabel?.alpha = 0.0
        } else {
            cell.comicImageView?.alpha = 0.0
            cell.notAvalableLabel?.alpha = 1.0
        }
        
        return cell;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("modelDidUpdate"), object: nil, queue: nil) { Notification in
            self.comicsTable?.reloadData()
        }
    }
}

