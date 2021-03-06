//
//  SendCurrentAppWalletDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Geth

struct GasLimit {
    let type: String
    let gasLimit: Int64
    init(json: JSON) {
        self.type = json["type"].stringValue
        self.gasLimit = json["gasLimit"].int64Value
    }
}

class SendCurrentAppWalletDataManager {
    
    static let shared = SendCurrentAppWalletDataManager()
    
    private var gasLimits: [GasLimit]
    private var nonce: Int64
    private var wallet = CurrentAppWalletDataManager.shared.getCurrentAppWallet()
    private var wethAddress: GethAddress?
    
    private init() {
        self.gasLimits = []
        self.nonce = 0
        self.wethAddress = nil
        self.loadGasLimitsFromJson()
        self.getNonceFromServer()
        self.getWethAddress()
    }
    
    func getWethAddress() {
        var address = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
        if let weth = TokenDataManager.shared.getTokenBySymbol("WETH") {
            address = weth.protocol_value
        }
        var error: NSError? = nil
        self.wethAddress = GethNewAddressFromHex(address, &error)
    }
    
    func getNonce() -> Int64 {
        getNonceFromServer()
        return self.nonce
    }
    
    func getGasLimits() -> [GasLimit] {
        return gasLimits
    }
    
    // TODO: Why we need to load gas_limit from a json file instead of writing as code.
    // load
    func loadGasLimitsFromJson() {
        if let path = Bundle.main.path(forResource: "gas_limit", ofType: "json") {
            let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let json = JSON(parseJSON: jsonString!)
            for subJson in json.arrayValue {
                let token = GasLimit(json: subJson)
                gasLimits.append(token)
            }
        }
    }

    func getGasLimitByType(type: String) -> Int64? {
        var gasLimit: Int64? = nil
        for case let gas in gasLimits where gas.type.lowercased() == type.lowercased() {
            gasLimit = gas.gasLimit
            break
        }
        return gasLimit
    }
    
    func getNonceFromServer() {
        if let address = CurrentAppWalletDataManager.shared.getCurrentAppWallet()?.address {
            EthereumAPIRequest.eth_getTransactionCount(data: address, block: BlockTag.pending, completionHandler: { (data, error) in
                guard error == nil, let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    if data.respond.isHex() {
                        self.nonce = Int64(data.respond.dropFirst(2), radix: 16)!
                    } else {
                        self.nonce = Int64(data.respond)!
                    }
                }
            })
        }
    }
    
    func sendTransactionToServer(_ signedTransaction: String, completion: @escaping (String?, Error?) -> Void) {
        EthereumAPIRequest.eth_sendRawTransaction(data: signedTransaction) { (data, error) in
            guard error == nil && data != nil else {
                completion(nil, error)
                return
            }
            completion(data!.respond, nil)
        }
    }
    
    func _keystore() {
        // TODO: improve the following code.
        // Get Keystore string value
        let keystoreStringValue: String = wallet!.getKeystore().description
        print(keystoreStringValue)
        
        // Create key directory
        let fileManager = FileManager.default
        
        let keyDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("KeyStoreSendAssetViewController")
        try? fileManager.removeItem(at: keyDirectory)
        try? fileManager.createDirectory(at: keyDirectory, withIntermediateDirectories: true, attributes: nil)
        print(keyDirectory)
        
        let walletDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("WalletSendAssetViewController")
        try? fileManager.removeItem(at: walletDirectory)
        try? fileManager.createDirectory(at: walletDirectory, withIntermediateDirectories: true, attributes: nil)
        print(walletDirectory)
        
        // Save the keystore string value to keyDirectory
        let fileURL = keyDirectory.appendingPathComponent("key.json")
        try! keystoreStringValue.write(to: fileURL, atomically: false, encoding: .utf8)
        
        // let keyStore = try! KeyStore(keyDirectory: keyDirectory, walletDirectory: walletDirectory)
        print(keyDirectory.absoluteString)
        let keydir = keyDirectory.absoluteString.replacingOccurrences(of: "file://", with: "", options: .regularExpression)
        let gethKeystore = GethKeyStore.init(keydir, scryptN: GethLightScryptN, scryptP: GethLightScryptP)!
        let gethAccount = EthAccountCoordinator.default.launch(keystore: gethKeystore, password: wallet!.password)
        print(gethAccount!.getAddress().getHex())
    }
    
    // convert weth -> eth
    func _withDraw(amount: GethBigInt, gasPrice: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard self.wallet != nil else {
            return
        }
        let transferFunction = EthFunction(name: "withdraw", inputParameters: [amount])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = getGasLimitByType(type: "withdraw")!
        _transfer(data: data, address: wethAddress!, amount: GethBigInt(0), gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    // convert eth -> weth
    func _deposit(amount: GethBigInt, gasPrice: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard self.wallet != nil else {
            return
        }
        let transferFunction = EthFunction(name: "deposit", inputParameters: [])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = getGasLimitByType(type: "deposit")!
        _transfer(data: data, address: wethAddress!, amount: amount, gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    // transfer eth
    func _transferETH(amount: GethBigInt, gasPrice: GethBigInt, toAddress: GethAddress, completion: @escaping (String?, Error?) -> Void) {
        guard self.wallet != nil else {
            return
        }
        let data = "0x".data(using: .utf8)!
        let gasLimit: Int64 = getGasLimitByType(type: "transfer")!
        _transfer(data: data, address: toAddress, amount: amount, gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    // transfer tokens including weth
    func _transferToken(contractAddress: GethAddress, toAddress: GethAddress, amount: GethBigInt, gasPrice: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        guard self.wallet != nil else {
            return
        }
        // Transfer function
        let transferFunction = EthFunction(name: "transfer", inputParameters: [toAddress, amount])
        let data = web3swift.encode(transferFunction)
        let gasLimit: Int64 = getGasLimitByType(type: "transfer")!
        _transfer(data: data, address: contractAddress, amount: GethBigInt(0), gasPrice: gasPrice, gasLimit: GethBigInt(gasLimit), completion: completion)
    }
    
    func _transfer(data: Data, address: GethAddress, amount: GethBigInt, gasPrice: GethBigInt, gasLimit: GethBigInt, completion: @escaping (String?, Error?) -> Void) {
        _keystore()
        var userInfo: [String: Any] = [:]
        do {
            let nonce: Int64 = getNonce()
            let signedTransaction = web3swift.sign(address: address, encodedFunctionData: data, nonce: nonce, amount: amount, gasLimit: gasLimit, gasPrice: gasPrice, password: wallet!.password)
            if let signedTransactionData = try signedTransaction?.encodeRLP() {
                sendTransactionToServer("0x" + signedTransactionData.hexString, completion: completion)
            } else {
                userInfo["message"] = NSLocalizedString("Failed to sign/encode", comment: "")
                let error = NSError(domain: "TRANSFER", code: 0, userInfo: userInfo)
                completion(nil, error)
            }
        } catch {
            userInfo["message"] = NSLocalizedString("Failed to encode transaction", comment: "")
            let error = NSError(domain: "TRANSFER", code: 0, userInfo: userInfo)
            completion(nil, error)
        }
    }
}
