//
//  CardModel.swift
//  appleInvitesClone
//
//  Created by Justin Hold on 3/10/25.
//

import Foundation
import SwiftUI

struct Card: Identifiable, Hashable {
	
	var id: String = UUID().uuidString
	var image: String
	
}

let cards: [Card] = [
	
	.init(image: "collectiveVision"),
	.init(image: "death"),
	.init(image: "heptagram"),
	.init(image: "lateralus"),
	.init(image: "theGreatTurn")
]
