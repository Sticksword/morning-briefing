//
//  AdditionalViewController.swift
//  Morning Briefing
//
//  Created by Michael Chen on 2/16/16.
//  Copyright © 2016 Michael Chen. All rights reserved.
//

import UIKit

class AdditionalViewController: UIViewController {

    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var newsButton: UIButton!
    @IBOutlet weak var xkcdTitleLabel: UILabel!
    @IBOutlet weak var xkcdImageView: UIImageView!
    
    var articleUrl = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCountdown();
        setupNews();
        setupXKCD();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setupCountdown() {
        /* This sets up the format the date should be in */
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        /* This initializes the two dates we want to find the time difference between */
        
        let targetDate: NSDate? = dateFormatter.dateFromString("2016-06-20")
        let todayDate: NSDate? = NSDate()
        
        /* After we have the difference between the two dates, we can display it with our label */
        
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian);
        let components = calendar?.components(.Day, fromDate:todayDate!, toDate:targetDate!, options: [])
        let dateString = NSDateFormatter.localizedStringFromDate(targetDate!, dateStyle: .ShortStyle, timeStyle: .ShortStyle); //format date correctly
        self.countdownLabel.text = "📅 Days until \(dateString):\n\(components!.day)"
    }
    
    func setupNews() {
        /* This is the URL for getting the top NYTimes stories */
        
        let url = NSURL(string: "http://api.nytimes.com/svc/topstories/v1/home.json?api-key=cf9ece3591fde74684d354879f3df115:8:73978099")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    if let items = jsonResult["results"] as? NSArray {
                        
                        /* Because we just want 1 story, we get the first item in the dictionary */
                        
                        if let topArticle = items[0] as? NSDictionary {
                            let articleTitle = topArticle["title"] as! String
                            self.articleUrl = topArticle["url"] as! String
                            
                            /* We set the title of the button to be the article title */
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.newsButton.setTitle(articleTitle, forState: .Normal)
                            });
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }
    
    /* This function will get "triggered" everytime the button is tapped.
    In our case, we want it to open the article URL (in mobile Safari). */
    
    @IBAction func buttonTapped(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: self.articleUrl)!)
    }
    
    func setupXKCD() {
        /* This gets the most current xkcd comic */
        
        let url = NSURL(string: "http://xkcd.com/info.0.json")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    let imageLink = jsonResult["img"] as! String
                    let title = jsonResult["title"] as! String
                    
                    let url = NSURL(string: imageLink)
                    let data = NSData(contentsOfURL: url!)
                    
                    /* Once we have the imageLink and title, we can display it. */
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.xkcdTitleLabel.text = title;
                        self.xkcdImageView.image = UIImage(data: data!)
                    });
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }

}
