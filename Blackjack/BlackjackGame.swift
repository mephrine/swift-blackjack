//
//  BlackjackGame.swift
//  Blackjack
//
//  Created by Mephrine on 2021/11/14.
//

import Foundation

final class BlackjackGame {
	private let dealer: Dealer
	private let inputView: Inputable
	private let resultView: Presentable
	var players: [Player] = [Player]()
	
	init(dealer: Dealer, inputable: Inputable, presentable: Presentable) {
		self.dealer = dealer
		self.inputView = inputable
		self.resultView = presentable
	}
	
	func start() {
		do {
			try dealTheCards()
			try playGame()
			gameIsOver()
		} catch (let error) {
			printOutErrorOnResultView(error: error)
		}
	}
	
	private func dealTheCards() throws {
		let players = try inputView.askPlayerNames()
		try startGame(by: players.names)
		printOutGameStatusBeforePlay()
	}
	
	private func startGame(by names: [String]) throws {
		try names.forEach { name in
			let playerBet = try inputView.askBetAmount(ofPlayer: name)
			joinTheGame(by: name, playerBet: playerBet)
		}
	}
	
	private func joinTheGame(by playerName: String, playerBet: PlayerBet) {
		if let firstCard = try? dealer.deal(),
			 let secondCard = try? dealer.deal() {
			let deck = Deck(cards: [firstCard, secondCard])
			let player = Player(name: playerName, bet: playerBet, deck: deck)
			players.append(player)
		}
	}
	
	private func printOutGameStatusBeforePlay() {
		let outputPlayers: [Player] = [self.dealer] + self.players
		resultView.printOutGameStatusBeforePlay(by: outputPlayers)
	}
	
	private func playGame() throws {
		try playPlayers()
		try playDealer()
	}
	
	private func playPlayers() throws {
		for var player in players {
			do {
				try askThePlayerWhetherToHit(player: &player)
			} catch (let error) {
				if isBustError(on: error) == false { throw error }
			}
		}
	}
	
	private func askThePlayerWhetherToHit(player: inout Player) throws {
		guard try inputView.askThePlayerWhetherToHit(name: player.name) else { return }
		if player.canHit() == false { throw BlackjackError.bust }
		
		player.hit(drawnCard: try dealer.deal())
		resultView.printOutDeck(of: player)
		try askThePlayerWhetherToHit(player: &player)
	}
	
	private func isBustError(on thrownError: Error) -> Bool {
		if let error = thrownError as? BlackjackError, error == .bust {
			printOutErrorOnResultView(error: error)
			return true
		}
		return false
	}
	
	private func printOutErrorOnResultView(error: Error) {
		if let inputError = error as? BlackjackError.InputError {
			resultView.printOut(error: .input(inputError))
		}
		
		if let blackjackError = error as? BlackjackError {
			resultView.printOut(error: blackjackError)
		}
	}
	
	private func playDealer() throws {
		if dealer.canHit() == false { return }
		dealer.hit(drawnCard: try dealer.deal())
		resultView.printOutTheDealerHit()
	}
	
	private func gameIsOver() {
		self.printOutGameResult()
		self.printOutWinningResult()
	}
	
	private func printOutGameResult() {
		let cardResultScores = [dealer.cardResultScore] + players.map { $0.cardResultScore }
		resultView.printOutGameResult(by: cardResultScores)
	}
	
	private func printOutWinningResult() {
		let winningResult = PlayResultDecider.decideWinning(of: dealer, players: players)
		resultView.printOutWinningResult(by: winningResult)
	}
}
