//
//  PersonController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import CloudKit

class PersonController {
    
    static let shared = PersonController()
    
    var currentPerson: Person?
    
    func addPersonalCard(_ card: Card, to person: Person) {
        person.personalCards.append(card)
    }
    
    func addCard(_ card: Card, to person: Person) {
        person.cards.append(card)
    }
    
    func addCardReference(_ reference : CKReference, to person: Person) {
        person.receivedCards.append(reference)
    }
    
    func deleteCard(_ card: Card, from person: Person) {
        if let index = person.cards.index(where: { $0 == card }) {
            person.cards.remove(at: index)
        }
        
        if let index = person.personalCards.index(where: { $0 == card }) {
            person.personalCards.remove(at: index)
        }
    }
}
