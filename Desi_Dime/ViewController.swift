//
//  ViewController.swift
//  Desi_Dime
//
//  Created by Jeet Mac Mimi on 26/06/17.
//  Copyright © 2017 Jeet. All rights reserved.
//

import UIKit

class TableViewCellList: UITableViewCell {
    
    @IBOutlet var imgProfilePic: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblDescription: UILabel!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var btnTop: UIButton!
    @IBOutlet var btnPopular: UIButton!
    @IBOutlet var tblVwList: UITableView!
    
    var arrayList: NSArray! = []
    
    var refreshCtrl: UIRefreshControl!
    var tableData:[AnyObject]!
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.cache = NSCache()
        
        self.activity.hidesWhenStopped = true
        self.setBtnAction()
        self.callAPI(apiName: "top")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setBtnAction() -> Void {
        
        btnTop.addTarget(self, action: #selector(btnPressedTop(btn:)), for: UIControlEvents.touchUpInside)
        
        btnPopular.addTarget(self, action: #selector(btnPressedPopular(btn:)), for: UIControlEvents.touchUpInside)
        
    }
    
    func btnPressedTop(btn: UIButton) -> Void {
        
        btn.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        btn.backgroundColor = UIColor.init(colorLiteralRed: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0)
        
        btnPopular.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        btnPopular.backgroundColor = UIColor.white

        self.callAPI(apiName: "top")
        
        self.cache.removeAllObjects()
    }
    
    func btnPressedPopular(btn: UIButton) -> Void {
        
        btn.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        btn.backgroundColor = UIColor.init(colorLiteralRed: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0)
        
        btnTop.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        btnTop.backgroundColor = UIColor.white
        
        self.callAPI(apiName: "popular")
        
        self.cache.removeAllObjects()

    }
    
    func callAPI(apiName: String) -> Void {
        
        self.activity.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        let strUrl = "https://api.desidime.com/v2/deals/\(apiName).json";
        
        SingletonClass.sharedInstance().performOperationWithGet(urlString: strUrl, withSuccess: {(_ responseDict: NSDictionary, _ success: Bool) -> Void in
            if success {
                
                let arr = responseDict.value(forKey: "data") as! NSArray
                
                 self.arrayList = arr
                
                DispatchQueue.main.async{
                    
                    self.tblVwList.reloadData()
                }

            }
            else {
                
            }
            
            DispatchQueue.main.async{
                
                self.activity.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }

        })
    }

    func callGetAPI_Top() -> Void {
        
        let url = NSURL(string: "https://api.desidime.com/v2/deals/top.json")!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("text/javascript", forHTTPHeaderField: "Accept")
        request.addValue("7d7c5cacb355d043f07c7c9e4b38257ea5683f8d643b578683877a9b6a8bee1b", forHTTPHeaderField: "X-Desidime-Client")

        
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                print(error?.localizedDescription)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                
                if let parseJSON = json {
                    let resultValue:NSDictionary = parseJSON["deals"] as! NSDictionary;
                    print("result: \(resultValue)")
                    print(parseJSON)
                    
                    
                    let arr = resultValue.value(forKey: "data") as! NSArray
                    
//                    if let parseArr = arr {
                        self.arrayList = arr
 //                   }
                    
                    DispatchQueue.main.async{
                        self.tblVwList.reloadData()
                    }
                 }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (arrayList?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCellList
        
        let dic = arrayList?[indexPath.row] as! NSDictionary
        
        let strTitle = dic.value(forKey: "title") as! String

        cell.lblTitle?.text = strTitle
        
//        let strDescription = dic.value(forKey: "title") as! String
//        cell.lblDescription?.text = strDescription
        
        let strUrlImage = dic.value(forKey: "image") as! String
        
        
        cell.imgProfilePic?.image = UIImage(named: "images.jpeg")
        
        if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil){
            // 2
            // Use cache
            print("Cached image used, no need to download it")
            cell.imgProfilePic?.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
        }else{
            // 3

            let url:URL! = URL(string: strUrlImage)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                if let data = try? Data(contentsOf: url){
                    // 4
                    DispatchQueue.main.async(execute: { () -> Void in
                        // 5
                        // Before we assign the image, check whether the current cell is visible
                        if let updateCell = tableView.cellForRow(at: indexPath) as? TableViewCellList  {
                            let img:UIImage! = UIImage(data: data)
                            updateCell.imgProfilePic?.image = img
                            self.cache.setObject(img, forKey: (indexPath as NSIndexPath).row as AnyObject)
                            
 //                           self.tblVwList.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        }
                    })
                }
            })
            task.resume()
        }

        
        return cell
    }
}

