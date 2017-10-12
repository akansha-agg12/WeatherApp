//
//  ViewController.swift
//  WeatherApp
//
//  Created by Akansha Aggarwal on 9/26/17.
//  Copyright © 2017 USC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var conditionLbl: UILabel!
    @IBOutlet weak var degreeLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    /* Creating these global variables and not direclty updating the values because we cannot update anything in the user interface while we are still in the active background thread. We need to dispatch a queue to the main thread and then update the labels.
     */
    
    var degree: Int!
    var condition : String!
    var imageURL : String!
    var city: String!
    var exixts = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.delegate = self
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let urlRequest = URLRequest(url: URL(string: "http://api.apixu.com/v1/current.json?key=fd5578e0f2e5464e93a44557172709&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))")!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    if let current = json["current"] as? [String:AnyObject]{
                        
                        if let temp = current["temp_c"] as? Int{
                            self.degree = temp
                        }
                        if let condition = current["condition"] as? [String:AnyObject]{
                            self.condition = condition["text"] as! String
                            let icon = condition["icon"] as! String
                            self.imageURL = "http:\(icon)"
                        }
                    }
                    
                    if let location = json["location"] as? [String:AnyObject]{
                        self.city = location["name"] as! String
                    }
                    
                    if let _ = json["error"]{
                        // city does not exists
                        self.exixts = false
                    }
                    
                    //Dispatch main queue
                    DispatchQueue.main.async {
                        if self.exixts{
                            self.degreeLbl.isHidden = false
                            self.conditionLbl.isHidden = false
                            self.imgView.isHidden = false
                            self.degreeLbl.text = "\(self.degree.description)°"
                            self.cityLbl.text = self.city
                            self.conditionLbl.text = self.condition
                            self.imgView.downloadImage(from: self.imageURL!)
                        }
                        //In case the requested city is not found.
                        else{
                            self.degreeLbl.isHidden = true
                            self.conditionLbl.isHidden = true
                            self.imgView.isHidden = true
                            self.cityLbl.text = "No matching city found."
                            
                            //To get new requests after this
                            self.exixts = true
                        }
                    }
                }
                catch let jsonError{
                    print(jsonError.localizedDescription)
                }
            }
        }
        task.resume()
    }

}

extension UIImageView{
    func downloadImage(from url: String){
        let urlRequest = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil{
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!)
                }
            }
        }
        task.resume()
    }
}

/*
 Apixu api : gives any weather condition about any specific city.
 Reason to choose apixu api is : if you give any city name it gives the weather conditions for the most popular city matching that name. 
 
 */
