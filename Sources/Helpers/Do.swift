//
//  Do.swift
//  WeatherNow
//
//  Created by Maxim Khatskevich on 10/27/18.
//  Copyright © 2018 Maxim Khatskevich. All rights reserved.
//

import Foundation

//---

enum Do // scope
{
    /**
     Convenience method to access any specific queue once without saving it
     and by still using "unified" API across whole app codebase.
     
     NOTE: if you want to create a queue and store it in memory and reuse it,
     then no need to use this service, jsut create the queue normally and
     store it and then access its members directly.
     */
    static
    func on(
        _ queue: DispatchQueue
        ) -> DispatchQueue
    {
        return queue
    }
    
    /**
     Convenience shortcut to execute any operation in async way
     on any given queue without retaining it. By default, it
     runs on global "background" queue.
     */
    static
    func async(
        on queue: DispatchQueue = .global(qos: .background),
        _ asyncOperation: @escaping () -> Void
        )
    {
        queue.async(execute: asyncOperation)
    }
    
    /**
     Convenience shortcut to execute any operation on main queue
     in async way.
    */
    static
    func onMain(
        _ mainQueueOperation: @escaping () -> Void
        )
    {
        DispatchQueue.main.async(execute: mainQueueOperation)
    }
}
