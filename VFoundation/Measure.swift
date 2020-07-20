//
//  Measure.swift
//  Quran
//
//  Created by Mohamed Afifi on 4/1/17.
//
//  Quran for iOS is a Quran reading application for iOS.
//  Copyright (C) 2017  Quran.com
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

import Foundation

public func measure<T>(_ tag: String = #function, limit: TimeInterval = 0, _ body: () throws -> T) rethrows -> T {

    let measurer = Measurer(tag: tag, limit: limit)
    let result = try body()
    measurer.end()

    return result
}

public struct Measurer {
    public let start = CFAbsoluteTimeGetCurrent()
    public let tag: String
    public let limit: TimeInterval
    public init(tag: String = #function, limit: TimeInterval = 0) {
        self.tag = tag
        self.limit = limit
    }

    @discardableResult
    public func end() -> TimeInterval {
        let end = CFAbsoluteTimeGetCurrent()   // <<<<<<<<<<   end time
        let timeInterval = end - start

        if timeInterval >= limit {
            print("[\(tag)]: Time Elabsed \(timeInterval) seconds")
        }
        return timeInterval
    }
}
