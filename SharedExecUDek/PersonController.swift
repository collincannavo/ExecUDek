//
//  PersonController.swift
//  ExecUDek
//
//  Created by Thomas Ganley on 7/26/17.
//  Copyright © 2017 Collin Cannavo. All rights reserved.
//

import Foundation
import CloudKit


public class PersonController {
    
    public static let shared = PersonController()
    
    public var currentPerson: Person?
    
    public func addPersonalCard(_ card: Card, to person: Person) {
        person.personalCards.append(card)
    }
    
    public func addCard(_ card: Card, to person: Person) {
        person.cards.append(card)
    }
    
    public func addCardReference(_ reference : CKReference, to person: Person) {
        person.receivedCards.append(reference)
    }
    
    public func deleteCard(_ card: Card, from person: Person) {
        if let index = person.cards.index(where: { $0 == card }) {
            person.cards.remove(at: index)
        }
        
        if let index = person.personalCards.index(where: { $0 == card }) {
            person.personalCards.remove(at: index)
        }
    }
}
