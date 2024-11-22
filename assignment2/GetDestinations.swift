//
//  GetDestinations.swift
//  assignment2
//
//  Created by Default User on 11/19/24.
//

import SwiftUI

public struct DestinationStructure: Codable, Hashable {
    
    public var ID: String
    public var Stop1: String
    public var Stop2: String
    public var Final: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Stop1)
    }
    
}

class GetDestinations: ObservableObject {
    @Published var destinations = [DestinationStructure]()
    init() {
        let url = URL(string: "https://vutran.dev.fast.sheridanc.on.ca/iOSClassA3/sqlToJson.php")!
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            do {
                if let d = data {
                    let decodedData = try JSONDecoder().decode([DestinationStructure].self, from: d)
                    DispatchQueue.main.async {
                        print(decodedData)
                        self.destinations = decodedData
                    }
                } else {
                    print("No data")
                }
            } catch {
                print("Error: \(error)")
            }
        }.resume()
    }
}
