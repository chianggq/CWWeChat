//
//  MessageOperation.swift
//  ChatClient
//
//  Created by chenwei on 2017/10/2.
//  Copyright © 2017年 cwwise. All rights reserved.
//

import Foundation

///重复发送次数
private let kMaxRepeatCount: Int = 5

class MessageOperation: Operation {
    
    /// 消息实体
    var message: Message
    /// 进度回调的block
    var progress: SendMessageProgressBlock?
    /// 完成结果
    var completion: SendMessageCompletionHandle?
    
    /// 消息发送结果
    var messageSendResult: Bool
    /// 重复执行的次数
    var repeatCount: Int = 0
    
    /// 控制并发的变量
    override var isExecuting: Bool {
        return localExecuting
    }
    
    override var isFinished: Bool {
        return localFinished
    }
    
    override var isCancelled: Bool {
        return localCancelled
    }
    
    override var isReady: Bool {
        return localReady
    }
    
    /// 实现并发需要设置为YES
    override var isConcurrent: Bool {
        return true
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    /// 控制并发任务的变量
    // 执行中
    private var localExecuting: Bool = false {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
        }
        didSet {
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var localFinished: Bool = false {
        willSet {
            self.willChangeValue(forKey: "isFinished")
        }
        didSet {
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    private var localCancelled: Bool = false {
        willSet {
            self.willChangeValue(forKey: "isCancelled")
        }
        didSet {
            self.didChangeValue(forKey: "isCancelled")
        }
    }
    
    private var localReady:Bool = true {
        willSet {
            self.willChangeValue(forKey: "isReady")
        }
        didSet {
            self.didChangeValue(forKey: "isReady")
        }
    }
    
    class func operation(with message: Message,
                         progress: SendMessageProgressBlock? = nil,
                         completion: SendMessageCompletionHandle? = nil) -> MessageOperation {
        
        switch message.messageType {
        case .text:
            return TextMessageOperation(message: message, 
                                          progress: progress, 
                                          completion: completion)
        default:
            return MessageOperation(message: message,
                                    progress: progress,
                                    completion: completion)
        }
        
    }
    
    init(message: Message,
         progress: SendMessageProgressBlock? = nil, 
         completion: SendMessageCompletionHandle? = nil) {
        
        self.message = message
        self.messageSendResult = false
        self.progress = progress
        self.completion = completion
        super.init()
    }
    
    ///函数入口
    override func start() {
        
        if self.isCancelled {
            self.endOperation()
            return
        }
        
        self.localExecuting = true
        self.performSelector(inBackground: #selector(startOperation), with: nil)
    }
    
    @objc func startOperation() {
        //发送消息的任务
        sendMessage()
    }
    
    func sendMessage() {
        noticationWithOperationState(false)
    }
    
    /**
     结束线程
     */
    func endOperation() {
        self.localExecuting = false
        self.localFinished = true
    }
    
    /// 消息状态
    func noticationWithOperationState(_ state: Bool = false) {
        self.messageSendResult = state
        endOperation()
        if state {
            message.sendStatus = .successed
            completion?(message, nil)
        } else {
            message.sendStatus = .failed
            let error = ChatClientError(error: "")
            completion?(message, error)
        }
    }
    
    func messageSendCallback(_ result: Bool) {
        if result == false {
            repeatCount += 1
            if repeatCount > kMaxRepeatCount {
                noticationWithOperationState(false)
            } else {
                sendMessage()
            }
        } else {
            noticationWithOperationState(true)
        }
    }
    
    override var description: String {
        var string = "<\(self.classForCoder) id:\(self.message.messageId) "
        string += " executing:" + (self.localExecuting ?"YES":"NO")
        string += " finished:" + (self.localFinished ?"YES":"NO")
        string += " cancelled:" + (self.localCancelled ?"YES":"NO")
        string += " sendResult:" + (self.messageSendResult ?"YES":"NO")
        string += " >"
        return string
    }
    
    deinit {
        log.debug("MessageOperation销毁")
    }
    
}
