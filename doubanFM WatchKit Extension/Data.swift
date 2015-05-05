import WatchKit

class Data{
    class var shared:Data{
        return Inner.instance
    }
    //延迟加载
    struct Inner {
        static let instance:Data = Data()
    }
    
    var songs = [JSON]()
    var channels = [JSON]()
    
    //申明一个字典,实现图像缓存
    var imageCache = Dictionary<String,UIImage>()
    //缓存策略,显示图像,iphone端
    func onSetImage2(url:String,img:WKInterfaceImage){
        let image = self.imageCache[url] as UIImage?
        
        if image == nil{
            Alamofire.request(Method.GET, url).response({ (_, _, data, error) -> Void in
                //将获取到的图像素具赋予imgView
                let imgData = UIImage(data: data! as! NSData)
                img.setImage(imgData)
                
                self.imageCache[url] = imgData
            })
        }else{
            //如果缓存有,就直接用
            img.setImage(image)
        }
        
    }
    //watch端的图像缓存策略
    func onSetImage(url:String,img:WKInterfaceImage){
        let device = WKInterfaceDevice.currentDevice()
        let nsURL = NSURL(string: url)
        //获取图像文件名,eko.jpg
        let imgName = nsURL?.path?.lastPathComponent
        
        if cacheContainsImageNamed(imgName!) == true{
            img.setImageNamed(imgName)
        }else{
            Alamofire.request(Method.GET, url).response({ (_, _, data, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data as! NSData)
                    self.addImageToCache(image!, name: imgName!)
                    img.setImageNamed(imgName)
                }
            })
        }
    }
    
    //根据图像名称,来判断是否有图像
    func cacheContainsImageNamed(name:String)->Bool{
        return contains(cachedImage.keys, name)
    }
    
    //将图像加入缓存,以图像名称为Key,图像数据为value
    func addImageToCache(image:UIImage,name:String){
        let device = WKInterfaceDevice.currentDevice()
        //加入缓存获取不成功,清除缓存中第一个元素,要是一直不成功,就清空所有缓存,再强行插入
        while (device.addCachedImage(image, name: name) == false){
            let removedImage = removeRandomImageFromCache()
            if !removedImage{
                device.removeAllCachedImages()
                device.addCachedImage(image, name: name)
                break
            }
        }
    }
    
    //删除图像缓存方法
    func removeRandomImageFromCache()->Bool{
        let cachedImageNames = cachedImage.keys
        if let radomImageName = cachedImageNames.first{
            WKInterfaceDevice.currentDevice().removeCachedImageWithName(radomImageName)
            return true
        }
        return false
    }
    
    var cachedImage:[String:NSNumber] = {
        return WKInterfaceDevice.currentDevice().cachedImages as! [String:NSNumber]
    }()
}