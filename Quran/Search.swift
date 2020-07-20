//
//  Search.swift
//  Quran
//
//  Created by Mohamed Afifi on 5/15/17.
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

struct SearchAutocompletion: Hashable {
    let text: String
    let highlightedRange: Range<String.Index>

    var hashValue: Int { return text.hashValue }

    static func == (lhs: SearchAutocompletion, rhs: SearchAutocompletion) -> Bool {
        return lhs.text == rhs.text
    }
}

struct SearchResult {
    let text: String
    let ayah: AyahNumber
    let page: Int
}

extension SearchResult {
    enum Source {
        case none
        case quran
        case translation(Translation)
    }
}

struct SearchResults {
    let source: SearchResult.Source
    let items: [SearchResult]
}
