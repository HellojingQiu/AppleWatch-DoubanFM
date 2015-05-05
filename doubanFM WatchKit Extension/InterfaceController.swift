//
//  InterfaceController.swift
//  doubanFM WatchKit Extension
//
//  Created by OliHire-HellowJingQiu on 15/4/30.
//  Copyright (c) 2015 OliHire-HellowJingQiu. All rights reserved.
//

import WatchKit
import Foundation
import MediaPlayer


class InterfaceController: WKInterfaceController,HttpProtocol,ChannelProtocol,SongProtocol {
    @IBOutlet weak var image: WKInterfaceImage!
    @IBOutlet weak var labelMusic: WKInterfaceLabel!
    @IBOutlet weak var buttonPlay: WKInterfaceButton!
    @IBAction func onShowMusic() {
        self.presentControllerWithName("music", context: self)
    }
    @IBAction func onShowChannel() {
        self.presentControllerWithName("channel", context: self)
    }
    @IBAction func onPlay() {
        isPlay = !isPlay
        if isPlay{
            audioPlayer.play()
            buttonPlay.setBackgroundImageNamed("btnPause")
        }else{
            audioPlayer.pause()
            buttonPlay.setBackgroundImageNamed("btnPlay")
        }
    }
    //网络控制器的类的实例
    var eHttp:HttpController = HttpController()
    //数据单例类
    var data:Data = Data.shared
    //当前播放歌曲的索引值
    var currIndex:Int = 0
    var isPlay = true
    //声明一个媒体播放器实例
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        //频道列表数据网址
        //http://www.douban.com/j/app/radio/channels
        //频道0歌曲数据网址
        //http://www.douban,fm/j/mine/playlist?type=n&channel=0&from=mainsite
        
        eHttp.delegate = self
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        eHttp.onSearch("http://www.douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
        
        
    }
    
    func didRecieveResults(result: AnyObject) {
//        println(result)
        let json = JSON(result)
        //判断是否是频道列表数据
        if let channels = json["channels"].array{
            data.channels = channels
        }
        if let songs = json["song"].array{
            data.songs = songs
            
            onSetSong(0)
        }
    }
    
    func onChangeChannel(channel_id: String) {
        //拼频道列表的歌曲数据网络地址
        //http://www.douban.fm/j/mine/playlist?type=n&channel= 
        let url:String = "http://www.douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        eHttp.onSearch(url)
        
    }
    
    func onChangeSong(index: Int) {
        onSetSong(index)
    }
    
    func onSetSong(index:Int){
        var rowData:JSON = self.data.songs[index] as JSON
        onSetImage(rowData)
        
        //获取歌曲的文件地址
        var songUrl:String = rowData["url"].string!
        //播放歌曲
        onSetAudio(songUrl)
    }
    
    //播放歌曲方法
    func onSetAudio(songUrl:String){
        isPlay = true
        buttonPlay.setBackgroundImageNamed("btnPause")
        
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: songUrl)
        self.audioPlayer.play()
    }
    
    @IBAction func onPre() {
        currIndex++
        if currIndex > self.data.songs.count - 1{
            currIndex = 0
        }
        onSetSong(currIndex)
    }
    
    @IBAction func onNext() {
        currIndex--
        if currIndex < 0{
            currIndex = self.data.songs.count - 1
        }
        onSetSong(currIndex)
    }
    
    //设定封面方法
    func onSetImage(rowData:JSON){
        //设置封面
        let imgUrl = rowData["picture"].string
        data.onSetImage(imgUrl!, img: image)
        
        let sTitle = rowData["title"].string!
        let sArtist = rowData["artist"].string!
        let title = "\(sTitle) - \(sArtist)"
        
        labelMusic.setText(title)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if self.data.songs.count > 0{
                var rowData:JSON = self.data.songs[currIndex] as JSON
                onSetImage(rowData)
            if isPlay{
                buttonPlay.setBackgroundImageNamed("btnPause")
            }
        }
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
