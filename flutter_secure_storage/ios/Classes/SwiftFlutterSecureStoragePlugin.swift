//
//  SwiftFlutterSecureStoragePlugin.swift
//  flutter_secure_storage
//
//  Created by Julian Steenbakker on 22/08/2022.
//

import Flutter

enum PluginError: Error {
    case invalidArguments(String)
    case missingArguments(String)
    
    var flutterError: FlutterError {
        switch self {
        case let .invalidArguments(message):
            return FlutterError(code: "-101", message: "invalidArguments:\(message)", details: nil)
        case let .missingArguments(message):
            return FlutterError(code: "-102", message: "missingArguments:\(message)", details: nil)
        }
    }
}

public class SwiftFlutterSecureStoragePlugin: NSObject, FlutterPlugin {
    
    private let flutterSecureStorageManager: FlutterSecureStorage = FlutterSecureStorage()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugins.it_nomads.com/flutter_secure_storage", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterSecureStoragePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "read":
            read(call, result)
        case "write":
            write(call, result)
        case "delete":
            delete(call, result)
        case "deleteAll":
            deleteAll(call, result)
        case "readAll":
            readAll(call, result)
        case "containsKey":
            containsKey(call, result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func read(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        do {
            let query = try parseCall(call)
            if (query.key == nil) {
                result(PluginError.missingArguments("`read` requires key parameter"))
                return
            }
            
            let response = flutterSecureStorageManager.read(query)
            result(response.value)
        } catch {
            handle(error, result)
        }
    }
    
    private func write(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        
        do {
            let query = try parseCall(call)
            guard query.key != nil, query.value != nil else {
                result(PluginError.missingArguments("`write` requires key and value parameter"))
                return
            }
            
            let response = flutterSecureStorageManager.write(query)
            result(response)
        } catch {
            handle(error, result)
        }
    }
    
    private func delete(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        do {
            let query = try parseCall(call)
            guard query.key != nil else {
                result(PluginError.missingArguments("delete requires key parameter").flutterError)
                return
            }
            let response = flutterSecureStorageManager.delete(query)
            result(response)
        } catch {
            handle(error, result)
        }
    }
    
    private func deleteAll(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        do {
            let query = try parseCall(call)
            let response = flutterSecureStorageManager.deleteAll(groupId: query.groupId, accountName: query.accountName, synchronizable: query.synchronizable)
            
            result(response)
        } catch {
            handle(error, result)
        }
    }
    
    private func readAll(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        do {
            let query = try parseCall(call)
            let response = flutterSecureStorageManager.readAll(query)
            result(response.value);
        } catch {
            handle(error, result)
        }
    }
    
    private func containsKey(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        do {
            let query = try parseCall(call)
            guard query.key != nil else {
                result(PluginError.missingArguments("`containsKey` requires key parameter").flutterError)
                return
            }
            
            let response = flutterSecureStorageManager.containsKey(query)
            result(response);
        } catch {
            handle(error, result)
        }
    }
    
    private func parseCall(_ call: FlutterMethodCall) throws -> FlutterSecureStorageRequest {
        guard let arguments = call.arguments else {
            throw PluginError.missingArguments("requires arguments")
        }
        let data = try JSONSerialization.data(withJSONObject: arguments, options: .prettyPrinted)
        return try JSONDecoder().decode(FlutterSecureStorageRequest.self, from: data)
    }
    
    private func handle(_ error: Error, _ result: @escaping FlutterResult) {
        if let err = error as? PluginError {
            result(err.flutterError)
        }
        else {
            result(FlutterError(code: "-999", message: error.localizedDescription, details: nil))
        }
    }
}
