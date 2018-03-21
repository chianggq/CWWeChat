//
//  ImageMessageOperation.swift
//  ChatClient
//
//  Created by chenwei on 2017/10/18.
//

import UIKit
import Alamofire
import SwiftyJSON

class ImageMessageOperation: MessageOperation {
    
    override func sendMessage() {
        let imageBody = message.messageBody as! ImageMessageBody
        /// 如果图片上传成功，则发送信息到对方，否则进行图片上传
        if imageBody.originalURL != nil {
            sendContentMessage()
        } else {
            uploadImage()
        }
    }
    
    /// 上传图片
    func uploadImage() {
        let imageBody = message.messageBody as! ImageMessageBody
        
        let url = "https://api.cwwise.com/v1/files/upload"
        
        let fileURL = URL(fileURLWithPath: imageBody.originalLocalPath!)
        let parameters = ["filename": fileURL.lastPathComponent]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileURL, withName: "image")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: url) { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    self.progress?(Float(progress.fractionCompleted))
                })
                
                upload.responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        imageBody.originalURL = URL(string: "https://api.cwwise.com/images/\(json["filename"].stringValue)")
                        self.sendContentMessage()
                        
                    case .failure(let error):
                        log.error(error)
                    }
                }
                
            case .failure(let encodingError): 
                log.error(encodingError)
            }
        }
        
    }
    
    func sendContentMessage() {
        // 需要添加判断 判断originalURL是存在 存在则上传成功
        
        let imageBody = message.messageBody as! ImageMessageBody
        
        var info = ["size": NSStringFromCGSize(imageBody.size)]
        if let urlString = imageBody.originalURL?.absoluteString {
            info["url"] = urlString
        }
        
        let data = try! JSONSerialization.data(withJSONObject: info, options: .prettyPrinted)
        let string = String(data: data, encoding: .utf8)!
        
        let toId = message.conversationId
        let messageId = message.messageId
        
        let messageTransmitter = ChatClient.share.chatService.messageTransmitter
        messageTransmitter.sendMessage(content: string,
                                       targetId: toId,
                                       messageId: messageId,
                                       chatType: message.chatType.rawValue,
                                       type: message.messageType.rawValue)
    }
}
