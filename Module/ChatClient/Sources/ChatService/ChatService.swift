//
//  ChatService.swift
//  ChatClient
//
//  Created by chenwei on 2017/10/2.
//  Copyright © 2017年 cwwise. All rights reserved.
//

import Foundation
import XMPPFramework

class ChatService: BaseService<ChatManagerDelegate>, XMPPStreamDelegate{
    
    /// 会话缓存
    fileprivate var conversationCache: [String: Conversation] = [:]
    
    /// 消息存储
    lazy private(set) var messageStore: MessageStore = {
        let messageStore = MessageStore(userId: ChatClient.share.currentAccount)
        return messageStore
    }()
    
    /// 会话存储
    lazy private(set) var conversationStore: ConversationStore = {
        let conversationStore = ConversationStore(userId: ChatClient.share.currentAccount)
        return conversationStore
    }()
    
    /// xmpp消息发送部分
    private(set) var messageTransmitter: MessageTransmitter
    /// 消息发送管理
    private(set) var dispatchManager: MessageDispatchManager
    /// 消息接收解析
    private(set) var messageParse: MessageParse
    
    override init() {
        // 消息发送和解析
        messageTransmitter = MessageTransmitter()
        messageParse = MessageParse()
        dispatchManager = MessageDispatchManager()
        super.init()
        messageParse.delegate = self
    }
    

    /// 收到消息执行
    /// 执行 消息变化和会话变化的代理，保存消息
    ///
    /// - Parameter message: 接收到的消息
    public func receive(message: Message) {
        
        
        
        
        // 保存消息
        messageStore.insert(message: message)
        // 执行delegate
        executeDidReceiveMessages(message)
        // 更新会话
        updateConversation(with: message)
    }
    
    public func saveMessage(_ message: Message)  {
        
        updateConversation(with: message)
        // 保存消息
        //messageStore.insert(message: message)
    }
    
    func updateConversation(with message: Message) {
        // 更新会话
        var exist: Bool = false
        let conversation = conversationStore.fecthConversation(type: message.chatType,
                                                               conversationId: message.conversationId,
                                                               isExist: &exist)
        conversation.append(message: message)
        // 执行代理方法
        executeConversationUpdate(conversation)
        // 如果会话不存在 则保存到数据库
        if exist == false {
            conversationStore.insert(conversation: conversation)
        }
    }
    
    /// 执行代理方法
    ///
    /// - Parameter message: 消息实体
    private func executeDidReceiveMessages(_ message: Message) {
        
        self.asyncExecute { (delegate) in
            delegate.didReceive(message: message)
        }
    }
    
    private func executeConversationUpdate(_ conversation: Conversation) {
        
        self.asyncExecute { (delegate) in
            delegate.conversationDidUpdate(conversation)
        }
        
    }
    
    // MARK: XMPPStreamDelegate
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        messageParse.handle(message: message)
    }
    
}

// MARK: - MessageParseDelegate
extension ChatService: MessageParseDelegate {
    
    func successParse(message: Message) {
        receive(message: message)
    }
    
}


extension ChatService: ChatManager {
    
    // MARK: 会话
    func fetchAllConversations() -> [Conversation] {
        let list = conversationStore.fecthAllConversations()
        for conversation in list {
            let lastMessage = messageStore.lastMessage(by: conversation.conversationId)
            conversation.append(message: lastMessage)
        }
        return list
    }
    
    func fecthConversation(chatType: ChatType,
                           conversationId: String) -> Conversation {
        let conversation = conversationStore.fecthConversation(type: chatType,
                                                               conversationId: conversationId)
        return conversation
    }
    
    func deleteConversation(_ conversationId: String, deleteMessages: Bool) {
        conversationStore.deleteConversation(with: conversationId)
        if deleteMessages {
            messageStore.deleteAllMessage(conversationId: conversationId)
        }
    }
    
    /// 更新消息
    func updateMessage(_ message: Message) {
        messageStore.updateMessage(message)
    }
    
    func sendMessage(_ message: Message,
                     progress: SendMessageProgressBlock?,
                     completion: @escaping SendMessageCompletionHandle) {
        
        saveMessage(message)
        
        // 切换到主线程来处理
        let _progress: SendMessageProgressBlock = { (progressValue) in
            DispatchQueue.main.async(execute: { 
                progress?(progressValue)
            })
        }
        
        let _completion: SendMessageCompletionHandle = { (message, error) in
            DispatchQueue.main.async(execute: {
                completion(message, error)
            })
        }
        
       dispatchManager.sendMessage(message, progress: _progress, completion: _completion)
        
    }
    
    func revokeMessage(_ message: Message, completion: SendMessageCompletionHandle) {
        
    }
    
}

