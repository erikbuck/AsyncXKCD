//
//  ViewController.swift
//  WSUXKCD
//
//  Created by Erik M. Buck on 11/3/21.
//

import UIKit

class XKCDCell : UITableViewCell {
    @objc @IBOutlet var bigImageView : UIImageView?
    @objc @IBOutlet var textView : UITextView?
}

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet var tableView : UITableView?

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return Int(appDelegate.model.numberOfAvailableImages)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as!  XKCDCell
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let index = appDelegate.model.numberOfAvailableImages - Int32(indexPath.row) - 1
        if let image = appDelegate.model.imageFor(index: index) {
            cell.bigImageView?.image = image
        }
        cell.textView?.text = appDelegate.model.infos[index]?.title
        
        return cell
    }
    
    // Reload data when new infformation becomes available
    @objc func updateAvailableImages() {
        tableView?.reloadData()
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register to be notified when new information becomes available
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAvailableImages), name: NSNotification.Name("numberOfAvailableImages"), object: nil)
    }
    
}

