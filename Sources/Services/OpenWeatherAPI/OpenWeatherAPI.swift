//
//  OpenWeatherAPI.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/25/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import Foundation

//---

final
class OpenWeatherAPI
{
    // MARK: Instance level members
    
    let baseAddress: URL
    let authKey: String // API key
    
    // MARK: Initializers
    
    /**
     PRIVATE on purpose, use 'initialize' instead!
     */
    private
    init(
        _ authKey: String,
        _ baseAddress: URL
        )
    {
        self.authKey = authKey
        self.baseAddress = baseAddress
    }
}

// MARK: - Initialization

extension OpenWeatherAPI
{
    enum InitializationError: Error
    {
        case emptyAuthKey
        case invalidBaseAddress
    }
    
    typealias InitializationResult = Result<OpenWeatherAPI, InitializationError>
    
    static
    func initialize(
        with authKey: String?,
        baseAddress: String = "https://api.openweathermap.org/data/2.5/"
        ) -> InitializationResult
    {
        guard
            let authKey = authKey,
            authKey.count > 0
        else
        {
            return .error(InitializationError.emptyAuthKey)
        }
        
        //---
        
        guard
            let baseAddress = URL(string: baseAddress)
        else
        {
            return .error(InitializationError.invalidBaseAddress)
        }
        
        //---
        
        return .value(.init(authKey, baseAddress))
    }
}

// MARK: - Shared Functionality

extension OpenWeatherAPI
{
    enum PrepareQueryError: Error
    {
        case unableToConstructURLComponents
        case unableToConstructFinalURL
    }
    
    /**
     Prepares query (absolute URL for a GET request) from 'service.baseAddress'
     extended with 'path' and 'params' URL-encoded into it.
     */
    func prepareQuery(
        path: String,
        params: [(String, Any)]
        ) -> Result<URL, PrepareQueryError>
    {
        guard
            var comps = URLComponents(
                string: self.baseAddress.appendingPathComponent(path).absoluteString
            )
        else
        {
            return .error(PrepareQueryError.unableToConstructURLComponents)
        }
        
        //---
        
        comps.queryItems = params
            .map{ URLQueryItem(name: $0.0, value: "\($0.1)") }
            + [URLQueryItem(name: "appid", value: authKey)]
        
        //---
        
        guard
            let result = comps.url
        else
        {
            return .error(PrepareQueryError.unableToConstructFinalURL)
        }
        
        //---
        
        return .value(result)
    }
    
    /**
     Actually fetches binary data from given endpoint query.
     
     NOTE: Sends synchronous request to remote server via network,
     this must be executed on a background queue!
     */
    func fetchData(
        for query: URL
        ) throws -> Data // we don't have specific error type here, ok to 'throw'
    {
        return try Data(contentsOf: query)
    }
    
    private // for internal use only, use 'decodeResponsePayload' static func!
    static
    let decoder = JSONDecoder()
    
    /**
     Decode into a Decodable type using standard 'decoder'.
     */
    static
    func decodeResponsePayload<T: Decodable>(
        _ data: Data
        ) throws -> T
    {
        return try decoder.decode(T.self, from: data)
    }
    
    /**
     Convenience helper for the corresponding static func.
     */
    func decodeResponsePayload<T: Decodable>(
        _ data: Data
        ) throws -> T
    {
        return try type(of: self).decodeResponsePayload(data)
    }
    
    /**
     Invalid request error representation.
     Example: {"cod":401, "message": "Invalid API key."}
     */
    struct RequestError: Decodable // NOT an Error, NOT supposed to be used directly as error
    {
        let cod: Int
        let message: String
    }
    
    /**
     Try to decode a request-specific error from 'rawResult'.
     */
    static
    func checkForRequestError(
        _ rawResult: Data
        ) -> RequestError?
    {
        if
            let result: RequestError = try? decodeResponsePayload(rawResult),
            // Proper response JSON has 'cod' property equal 200,
            // so if (for some reason) it will have 'message' property
            // one day, then the line above will recognize it as a valid
            // request error. Because of this,
            // let's double-check the error code, jsut to be safe.
            result.cod != 200
        {
            return result
        }
        else
        {
            return nil
        }
    }
    
    /**
     Convenience helper for the corresponding static func.
     */
    func checkForRequestError(
        _ rawResult: Data
        ) -> RequestError?
    {
        return type(of: self).checkForRequestError(rawResult)
    }
}
