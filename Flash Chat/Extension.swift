//
//  Extension.swift
//  Flash Chat
//
//  Created by Raj on 3/26/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

let imgCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    
    func loadImgUsingCache(userProfileImg:String){
        
        self.image = nil
        //Check for Cache First
        if let cachedImg = imgCache.object(forKey: userProfileImg as AnyObject) as?
            UIImage{
            self.image = cachedImg
            return
        }
        
        
        let url =  URL(string: userProfileImg)
        let request = NSMutableURLRequest(url:url!)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) in
            if error != nil {
                return
            }
            DispatchQueue.main.async {
                if let downloadedImg = UIImage(data: data!){
                    imgCache.setObject(downloadedImg, forKey: userProfileImg as AnyObject)
                self.image = downloadedImg
                }
            }
        }).resume()
    }
    
}
