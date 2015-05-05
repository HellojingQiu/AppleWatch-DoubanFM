//
//  SongController.swift
//  doubanFM
//
//  Created by OliHire-HellowJingQiu on 15/5/4.
//  Copyright (c) 2015年 OliHire-HellowJingQiu. All rights reserved.
//

import WatchKit

class SongController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    
    var delegate:SongProtocol?
    var data:Data = Data.shared
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.delegate = context as? SongProtocol
        
        table.setNumberOfRows(data.songs.count, withRowType: "musicList")
        
        for(index,json) in enumerate(data.songs){
            let row = table.rowControllerAtIndex(index) as! SongRow
            let title = json["title"].stringValue
            let artist = json["artist"].stringValue
            let imageURL = json["picture"].stringValue
            row.labelTitle.setText(title)
            row.labelArtist.setText(artist)
            //内部自动赋值
            data.onSetImage(imageURL, img: row.image)
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        delegate?.onChangeSong(rowIndex)
        self.dismissController()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}

protocol SongProtocol{
    func onChangeSong(index:Int)
}