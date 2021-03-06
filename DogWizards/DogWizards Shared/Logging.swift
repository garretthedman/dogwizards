//
//  Logging.swift
//  DogWizards
//
//  Created by Andrew Finke on 9/28/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Foundation

class Logging {

    // MARK: - Types -

    enum Event: String {
        case appOpened, startCardChange, startCardOptionsViewed, spellAdded, spellRemoved, spellFlipped, spellsStartedZag, spellsZagged, levelCompleted
    }

    // MARK: - Properties -

    private let writeQueue = DispatchQueue(label: "com.andrewfinke.write", qos: .background)

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    private let fileURL: URL = {
        guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory,
                                                                   in: .userDomainMask,
                                                                   appropriateFor: nil,
                                                                   create: false) else { fatalError() }
        let string = Logging.dateFormatter.string(from: Date()) + ".csv"
        let url =  documentDirectory.appendingPathComponent(string)
        print("Logging URL: \(url)")
        return url
    }()

    private var events = [(date: Date, type: Event, activeCards: String, description: String)]() {
        didSet {
            saveToDisk()
        }
    }

    static let shared = Logging()
    var activeLevel: LevelModel?

    // MARK: - Helpers -

    func log(event: Event, description: String = "") {
        let activeCards = activeCardsString()
        print("Event: \(event), activeCards: \(activeCards), description: \(description)")
        events.append((Date(), event, activeCards, description))
    }

    private func activeCardsString() -> String {
        var string = ""
        for card in activeLevel?.castModel.cards ?? [] {
            if let card = card {
                string += card.description
            } else {
                string += "Empty"
            }
            string += ","
        }
        return string
    }

    private func saveToDisk() {
        writeQueue.async {
            var string = "Date,Event,Cast,Description\n"
            for event in self.events {
                string += Logging.dateFormatter.string(from: event.date) + ","
                string += "\"" + event.type.rawValue + "\","
                string += "\"" + event.activeCards.description + "\","
                string += "\"" + event.description + "\"\n"
            }
            guard let data = string.data(using: .utf8) else { fatalError() }
            do {
                try data.write(to: self.fileURL)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
