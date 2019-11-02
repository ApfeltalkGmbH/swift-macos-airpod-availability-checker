//
//  Models.swift
//  AirPods Pro Checker
//
//  Created by Tobias Scholze on 01.11.19.
//  Copyright © 2019 Tobias Scholze. All rights reserved.
//

import Foundation

// MARK: - Container -

struct Container: Codable
{
    let body: Body
}

// MARK: - Body -

struct Body: Codable
{
    let stores: [Store]
}

// MARK: - Store -

struct Store: Codable
{
    let name: String
    let city: String
    let partsAvailability: PartsAvailability

    enum CodingKeys: String, CodingKey
    {
        case name = "storeName"
        case city
        case partsAvailability
    }
}

// MARK: - PartsAvailability -

struct PartsAvailability: Codable
{
    let mwp22ZmA: Mwp22ZmA

    enum CodingKeys: String, CodingKey
    {
        case mwp22ZmA = "MWP22ZM/A"
    }
}

// MARK: - Mwp22ZmA -

struct Mwp22ZmA: Codable
{
    let pickupSearchQuote: String
    
    var sanitizedAvailableDate: String
    {
        // Parse required information from string.
        let today =  Calendar.current.startOfDay(for: Date())
        let value = pickupSearchQuote.replacingOccurrences(of: "Verfügbar<br/>", with: "")
        let date = DateFormatter.shortDate.date(from: "\(value) \(NSCalendar.current.component(.year, from: today))")
        
        // If given value is not a valid date, return value.
        guard let _date = date else
        {
            return value
        }

        // Calculate delta in days from now till availability date.
        let components = Calendar.current.dateComponents([.day], from: today, to: _date)
        let deltaToAvailbility = components.day ?? 0
        
        // macOS 10.15 version:
        // let deltaToAvailbility = Int(today.distance(to: _date) / 60 / 60 / 24)
        
        // Add special formatting for known values.
        if deltaToAvailbility == 0
        {
            return "Heute"
        }
            
        else if deltaToAvailbility == 1
        {
            return "Morgen"
        }
            
        else
        {
            return  "in \(deltaToAvailbility) Tagen"
        }
    }
}
