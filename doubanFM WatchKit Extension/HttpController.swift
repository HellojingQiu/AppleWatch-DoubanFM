//
//  HttpController.swift
//  doubanFM
//
//  Created by OliHire-HellowJingQiu on 15/4/30.
//  Copyright (c) 2015年 OliHire-HellowJingQiu. All rights reserved.
//

import WatchKit

class HttpController: NSObject {
    //代理
    var delegate:HttpProtocol?
    //接受网址,请求数据,回调代理方法,传回数据
    func onSearch(url:String){
        Alamofire.request(Method.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, json, error) -> Void in
            if var data: AnyObject = json{
                self.delegate?.didRecieveResults(data)
            }
        }
    }
}

protocol HttpProtocol{
    //定义一个方法,接受一个参数,AnyObject
    func didRecieveResults(result:AnyObject)
}