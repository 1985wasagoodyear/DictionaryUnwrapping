//
//  main.swift
//  Created 3/9/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import Foundation

/*
    Setup with Data, JSON, Model Definition
*/
let jsonStr: String = """
{
"AED": "United Arab Emirates Dirham",
"AFN": "Afghan Afghani",
"ALL": "Albanian Lek",
"AMD": "Armenian Dram",
"ANG": "Netherlands Antillean Guilder",
"AOA": "Angolan Kwanza",
"ARS": "Argentine Peso",
"AUD": "Australian Dollar",
"AWG": "Aruban Florin"
}
"""

let jsonData = jsonStr.data(using: .utf8)!

struct Currency: Decodable {
    let acronym: String
    let fullName: String
}

// helper for printing
extension Currency: CustomStringConvertible {
    var description: String {
        "acronym: \(acronym), fullName: \(fullName)"
    }
}

// helper for printing
extension Array where Element == Currency {
    var string: String {
        map { $0.description }
            .joined(separator: "\n")
    }
}

/*
    Approach 1: Polymorphic Init on Bounded-Array-type
 
    * may or may not be technically possible?
*/
extension Array where Element == Currency {
    
    // cannot call this polymorphic function
    // for some reason.
    // could it be impossible as Arrays are statically-dispatched?
    // this is NOT a possibly polymorphic function?
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dict = try container.decode([String:String].self)
        var currencies = [Currency]()
        for key in dict.keys {
            let c = Currency(acronym: key, fullName: dict[key]!)
            currencies.append(c)
        }
        self = currencies
    }
}

// driver
func cannot_call_polymorphic_init() {
    print("cannot_call_polymorphic_init")
    let decoder = JSONDecoder()
    let currencies = try! decoder.decode([Currency].self,
                                         from: jsonData) // should crash
    print(currencies.string)
}

// cannot_call_polymorphic_init() // doesn't work

/*
    Approach 2: Wrapper Struct
 
    * simple, but, needs additional wrapper
    * driver is slightly modified to access the internal array property
*/
struct CurrencyWrapper: Decodable {
    let currency: [Currency]
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dict = try container.decode([String:String].self)
        var currencies = [Currency]()
        for key in dict.keys {
            let c = Currency(acronym: key, fullName: dict[key]!)
            currencies.append(c)
        }
        self.currency = currencies
    }
}

// driver
func wrapper_work_around() {
    print("wrapper_work_around")
    let decoder = JSONDecoder()
    let currencies = try! decoder.decode(CurrencyWrapper.self,
                                         from: jsonData) // should crash
    print(currencies.currency.string)
}

wrapper_work_around() // works, but needs extra wrapper

/*
 Approach 3: Explicit Dictionary
 
 * ignore the original problem completely
 * uses different driver completely
*/
extension Array where Element == Currency {
    init(data: Data) throws {
        let decoder = JSONDecoder()
        let dict = try decoder.decode([String:String].self, from: data)
        var currencies = [Currency]()
        for key in dict.keys {
            let c = Currency(acronym: key, fullName: dict[key]!)
            currencies.append(c)
        }
        self = currencies
    }
}

// driver
func dict_init() {
    print("dict_init")
    let currencies = try! [Currency](data: jsonData)
    print(currencies.string)
}

dict_init()
