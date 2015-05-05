//
//  ChannelConrtoller.swift
//  doubanFM
//
//  Created by OliHire-HellowJingQiu on 15/5/4.
//  Copyright (c) 2015年 OliHire-HellowJingQiu. All rights reserved.
//

import WatchKit

class ChannelConrtoller: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    
    var delegate:ChannelProtocol?
    
    //数据中心单例
    var data:Data = Data.shared
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.delegate = context as? ChannelProtocol
        
        table.setNumberOfRows(data.channels.count, withRowType: "channelRow")
        for (index,json) in enumerate(data.channels){
            let row = table.rowControllerAtIndex(index) as! ChannelRow
            var title = json["name"].stringValue
            row.labelTitle.setText(title)
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let channelId = data.channels[rowIndex]["channel_id"].stringValue
        delegate?.onChangeChannel(channelId)
        self.dismissController()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate(){
        super.willActivate()
    }
}

protocol ChannelProtocol{
    //定义回调方法,将频道ID传回主视图
    func onChangeChannel(channel_id:String)
}