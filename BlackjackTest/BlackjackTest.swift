//
//  BlackjackTest.swift
//  BlackjackTest
//
//  Created by Mephrine on 2021/11/13.
//

import XCTest

class BlackjackTest: XCTestCase {
	let resultView = StubResultView()
	
	override func tearDownWithError() throws {
		StubInputView.Verify.clear()
		resultView.clear()
	}
	
	func test_shouldGet2CardsWhenTheDealerDealsCards() throws {
		let dealer = makeDealer()
		let blackjackCards = [try dealer.deal(), try dealer.deal()]
		XCTAssertEqual(blackjackCards.count, 2)
	}
	
	func test_shouldRemoveTheDrawnCardsWhenTheDealerDeals() throws {
		let dealer = makeDealer()
		let initialDeckCount = dealer.cardPack.cards.count
		
		let blackjackCards = [try dealer.deal(), try dealer.deal()]
		let result = Set(dealer.cardPack.cards + blackjackCards).count
		XCTAssertEqual(result, initialDeckCount)
	}
	
	func test_shouldOwnNameAnd2CardsWhenTheBlackjackGameStarts() throws {
		let blackjackCards = Deck(cards: [BlackjackCard(suit: .spades, rank: .ace), BlackjackCard(suit: .spades, rank: .eight)])
		let name = "ABC"
		let player = Player(name: name, bet: try PlayerBet(input: "1000"), deck: blackjackCards)
		
		XCTAssertEqual(player.name, name)
		XCTAssertEqual(player.deck, blackjackCards)
	}
	
	func test_shouldGetOneCardWhenAPlayerHits() throws {
		let blackjackCards = Deck(cards: [BlackjackCard(suit: .spades, rank: .ace), BlackjackCard(suit: .spades, rank: .eight)])
		let player = Player(name: "ABC", bet: try PlayerBet(input: "1000"), deck: blackjackCards)
		let drawnCard = BlackjackCard(suit: .spades, rank: .two)
		
		player.hit(drawnCard: drawnCard)
		let sumOfCardNumbers = player.deck.cards.count
		XCTAssertEqual(3, sumOfCardNumbers)
	}
	
	func test_shouldNotHitWhenSumOfCardnumbersIsEqualToOrGreaterThanTheBlackjackNumber() throws {
		let blackjackCards = Deck(cards: [BlackjackCard(suit: .spades, rank: .king), BlackjackCard(suit: .spades, rank: .eight)])
		let player = Player(name: "ABC", bet: try PlayerBet(input: "1000"), deck: blackjackCards)
		
		let firstDrawnCard = BlackjackCard(suit: .spades, rank: .three)
		player.hit(drawnCard: firstDrawnCard)
		
		let secondDrawnCard = BlackjackCard(suit: .spades, rank: .two)
		
		XCTAssertFalse(player.canHit())
	}
	
	func test_shouldGetTheSumOfCardNumbersWhenTheGameIsOver() throws {
		let blackjackCards = Deck(cards: [BlackjackCard(suit: .spades, rank: .ace), BlackjackCard(suit: .clubs, rank: .ace)])
		let player = Player(name: "ABC", bet: try PlayerBet(input: "1000"), deck: blackjackCards)
		
		let firstDrawnCard = BlackjackCard(suit: .diamonds, rank: .ace)
		player.hit(drawnCard: firstDrawnCard)
		
		let secondDrawnCard = BlackjackCard(suit: .diamonds, rank: .ace)
		player.hit(drawnCard: secondDrawnCard)
		
		let thirdDrawnCard = BlackjackCard(suit: .diamonds, rank: .seven)
		player.hit(drawnCard: thirdDrawnCard)
		
		let gameResult = player.cardResultScore
		XCTAssertEqual(21, gameResult.sumOfCardNumbers)
	}
	
	func test_shouldGetGameResultWhenTheGameIsOver() throws {
		let blackjackCards = Deck(cards: [BlackjackCard(suit: .spades, rank: .ace), BlackjackCard(suit: .clubs, rank: .ace)])
		let player = Player(name: "ABC", bet: try PlayerBet(input: "1000"), deck: blackjackCards)
		let gameResult = player.cardResultScore
		let expect = CardResultScore(name: "ABC", deck: blackjackCards, sumOfCardNumbers: 12)
		
		XCTAssertEqual(expect, gameResult)
	}
	
	func test_shouldHaveEachPlayers2CardsWhenGameStart() throws {
		let dealear = makeDealer()
		let inputView = StubInputView(playerNames: "abc,def", betAmounts: ["10000", "20000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealear, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		
		blackjackGame.players.forEach { player in
			XCTAssertEqual(player.deck.cards.count, 2)
		}
	}
	
	func test_shouldGet1CardWhenPlayerAcceptsThe1Hit() throws {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "abc,def", betAmounts: ["10000", "20000"], answerTheHit: "y")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		
		blackjackGame.players.forEach { player in
			XCTAssertEqual(player.deck.cards.count, 3)
		}
	}
	
	func test_shouldThrowABustErrorWhenPlayerAcceptsThe7Hit() throws {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "abc,def", betAmounts: ["10000", "20000"], answerTheHit: "y","y","y","y","y","y","y")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		
		XCTAssertEqual(StubResultView.Verify.printOutError, true)
		XCTAssertEqual(resultView.error, .bust)
	}
	
	func test_shouldGetGameResultsWhenGameIsOver() throws {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "abc,def,ghi", betAmounts: ["10000", "20000", "20000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		
		let expectNames = ["딜러", "abc", "def", "ghi"]
		
		XCTAssertTrue(resultView.gameResults.count == 4)
		XCTAssertEqual(resultView.gameResults.map { $0.name }, expectNames)
	}
	
	func test_shouldTheDealWithANextPlayerWhenAPlayerDoNotHit() {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "abc,def", betAmounts: ["10000", "20000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		
		let expectMoveOnToTheNextPlayerCoount = 1
		let expectAnswerTheHitIndex = 1
		
		XCTAssertEqual(StubInputView.Verify.moveOnToTheNextPlayerCount, expectMoveOnToTheNextPlayerCoount)
		XCTAssertEqual(inputView.answerTheHitIndex, expectAnswerTheHitIndex)
	}
	
	func test_shouldHitAgainWhenAPlayerHit() {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "abc,def", betAmounts: ["10000", "20000"], answerTheHit: "y","n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		
		let expectMoveOnToTheNextPlayerCoount = 1
		let expectAnswerTheHitIndex = 2
		
		XCTAssertEqual(StubInputView.Verify.moveOnToTheNextPlayerCount, expectMoveOnToTheNextPlayerCoount)
		XCTAssertEqual(inputView.answerTheHitIndex, expectAnswerTheHitIndex)
	}
	
	func test_shouldThrowEmptyErrorWhenInputNameIsEmpty() throws {
		try testExpectInputError(expect: .input(.empty), playerName: nil, answerTheHit: "n")
		try testExpectInputError(expect: .input(.empty), playerName: "", answerTheHit: "n")
		try testExpectInputError(expect: .input(.empty), playerName: "a,b", answerTheHit: nil)
		try testExpectInputError(expect: .input(.empty), playerName: "a,b", answerTheHit: "")
	}
	
	func test_shouldThrowDuplicateErrorWhenInputNameIsDuplicated() throws {
		try testExpectInputError(expect: .input(.duplicatedName), playerName: "abc,def,abc", answerTheHit: "n")
		try testExpectInputError(expect: .input(.duplicatedName), playerName: "abc,dabc,def,abc", answerTheHit: "n")
	}
	
	func test_shouldThrowAnOutOfRangesForNumberOfParticipantsErrorWhenInputNameIsNotContainedInNumberOfParticipantsRange() throws {
		try testExpectInputError(expect: .input(.outOfRangesForNumberOfParticipants), playerName: "abc,def,123,456,789,1011,1111", answerTheHit: "n")
		try testExpectInputError(expect: .input(.outOfRangesForNumberOfParticipants), playerName: "abc,def,123,456,789,1011", answerTheHit: "n")
	}
	
	func test_shouldThrowAnOutOfRangesInNameErrorWhenInputNameIsNotContainedInNumberOfPlayers() throws {
		try testExpectInputError(expect: .input(.outOfRangeInName), playerName: "abcdefghijasdfkjwbefjkbwa, abcd", answerTheHit: "n")
		try testExpectInputError(expect: .input(.outOfRangeInName), playerName: "12345678910, abcde", answerTheHit: "n")
	}
	
	func test_shouldThrowAnOutOfRangesInYesOrNoErrorWhenInputIsOtherThanYesOrNo() throws {
		try testExpectInputError(expect: .input(.outOfRangeInYesOrNo), playerName: "abcde, abcd", answerTheHit: "a")
		try testExpectInputError(expect: .input(.outOfRangeInYesOrNo), playerName: "12345678, abcde", answerTheHit: "1")
	}
	
	func test_shouldOutputGameStatusBeforePlayWhenAfterTheDeals() {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "ab,cd,ef", betAmounts: ["10000", "20000", "10000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		XCTAssertEqual(StubResultView.Verify.printOutGameStatusBeforePlay, true)
	}
	
	func test_shouldOutputAllCardsWhenPlayerHits() {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "ab,cd,ef", betAmounts: ["10000", "20000", "10000"], answerTheHit: "y", "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		XCTAssertEqual(StubResultView.Verify.printOutDeckOfPlayer, true)
		XCTAssertEqual(resultView.hitCount[1...3], [1, 1, 1])
	}
	
	func test_shouldOutputGameResultWhenGameIsOver() {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "ab,cd,ef", betAmounts: ["10000", "20000", "10000"], answerTheHit: "y", "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		XCTAssertEqual(StubResultView.Verify.printOutGameResult, true)
	}
	
	func test_shouldOutputEmptyErrorMessageWhenThrowsEmptyError() {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: nil, betAmounts: ["10000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		
		blackjackGame.start()
		XCTAssertEqual(StubResultView.Verify.printOutError, true)
		XCTAssertEqual(resultView.error, .input(.empty))
	}
	
	func test_shouldTheDealerTakeCardsWhenGameStart() {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "ab, bc", betAmounts: ["10000", "20000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		
		blackjackGame.start()
		XCTAssertFalse(dealer.cardPack.cards.isEmpty)
	}
	
	func test_shouldTakeOneMoreCardWhenTheScoreOfDealerIs16OrLess() {
		let blackjackCards = (2...9).map { BlackjackCard(suit: .clubs, rank: BlackjackCard.Rank(rawValue: $0)!) }
		let cardPack: CardDrawable = CardPack(cards: blackjackCards)
		let dealer = Dealer(cardPack: cardPack)
		let inputView = StubInputView(playerNames: "ab, bc", betAmounts: ["10000", "20000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		
		blackjackGame.start()
		XCTAssertTrue(dealer.deck.cards.count == 3)
	}
	
	func test_shouldNotHitsWhenTheScoreOfDealerIs17OrMore() {
		let blackjackCards = BlackjackCard.Suit.allCases
			.flatMap { suit in
				[BlackjackCard.Rank.king, BlackjackCard.Rank.queen, BlackjackCard.Rank.jack].map { rank in
					(suit: suit, rank: rank)
				}
			}.map {
				BlackjackCard(suit: $0.suit, rank: $0.rank)
			}
		let cardPack: CardDrawable = CardPack(cards: blackjackCards)
		let dealer = Dealer(cardPack: cardPack)
		let inputView = StubInputView(playerNames: "ab, bc", betAmounts: ["10000", "20000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		
		blackjackGame.start()
		XCTAssertEqual(dealer.deck.cards.count, 2)
	}
	
	func test_shouldOutputTheDealerHitWhenTheScoreOfDealerIs16OrLess() {
		let blackjackCards = (2...9).map { BlackjackCard(suit: .clubs, rank: BlackjackCard.Rank(rawValue: $0)!) }
		let cardPack: CardDrawable = CardPack(cards: blackjackCards)
		let dealer = Dealer(cardPack: cardPack)
		let inputView = StubInputView(playerNames: "ab, bc", betAmounts: ["10000", "20000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		
		blackjackGame.start()
		XCTAssertEqual(StubResultView.Verify.printOutTheDealerHit, true)
	}
	
	func test_shouldLoseWhenTheDealerIsBust() {
		let blackjackCards = BlackjackCard.Suit.allCases
			.flatMap { suit in
				(7...8).map { rank in
					(suit: suit, rank: rank)
				}
			}.map {
				BlackjackCard(suit: $0.suit, rank: BlackjackCard.Rank(rawValue: $0.rank)!)
			}
		let cardPack: CardDrawable = CardPack(cards: blackjackCards)
		let dealer = Dealer(cardPack: cardPack)
		let inputView = StubInputView(playerNames: "ab, bc", betAmounts: ["10000", "20000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		
		blackjackGame.start()
		XCTAssertEqual(resultView.playResult!.dealerResult.losingCount, 2)
		resultView.playResult!.playerResults.forEach { playerResults in
			XCTAssertEqual(playerResults.winning, .win)
		}
	}
	
	func test_shouldOutputWinningResultWhenTheGameIsOver() {
		let blackjackCards = BlackjackCard.Suit.allCases
			.flatMap { suit in
				(2...9).map { rank in
					(suit: suit, rank: rank)
				}
			}.map {
				BlackjackCard(suit: $0.suit, rank: BlackjackCard.Rank(rawValue: $0.rank)!)
			}
		let cardPack: CardDrawable = CardPack(cards: blackjackCards)
		let dealer = Dealer(cardPack: cardPack)
		let inputView = StubInputView(playerNames: "ab, bc", betAmounts: ["10000", "20000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		
		blackjackGame.start()
		
		XCTAssertTrue(StubResultView.Verify.printOutWinningResult)
	}
	
	func test_shouldOutputGameResultIncludeTheDealerWhenTheGameIsOver() {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "ab,cd,ef", betAmounts: ["10000", "20000", "10000"], answerTheHit: "y", "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		XCTAssertTrue(resultView.gameResults.first { $0.name == "딜러" } != nil)
		XCTAssertEqual(resultView.gameResults.count, 4)
	}
	
	func test_shouldOutputGameStatusIncludingTheDealerBeforePlayWhenAfterTheDeals() {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "ab,cd,ef", betAmounts: ["10000", "20000", "10000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		XCTAssertTrue(resultView.players.first { $0.name == "딜러" } != nil)
		XCTAssertEqual(resultView.players.count, 4)
	}
	
	func test_shouldHaveBetAmountOfEachPlayerWhenTheBlackjackGameStarts() {
		let dealer = makeDealer()
		let inputView = StubInputView(playerNames: "ab,cd", betAmounts: ["10000", "20000"], answerTheHit: "n")
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		XCTAssertEqual(blackjackGame.players[0].bet.amount, 10000)
		XCTAssertEqual(blackjackGame.players[1].bet.amount, 20000)
	}
	
	private func testExpectInputError(expect expectedError: BlackjackError, playerName: String?, answerTheHit: String? ...)  throws {
		let dealer = makeDealer()
		let betAmountsSize = playerName?.components(separatedBy: ",").count ?? 0
		let betAmountsRange = betAmountsSize > 0 ? (0...betAmountsSize - 1) : (0...0)
		let betAmounts = betAmountsRange.map { _ in "10000" }
		
		let inputView = StubInputView(playerNames: playerName, betAmounts: betAmounts, answerTheHit: answerTheHit)
		let blackjackGame = BlackjackGame(dealer: dealer, inputable: inputView, presentable: resultView)
		blackjackGame.start()
		
		XCTAssertEqual(StubResultView.Verify.printOutError, true)
		XCTAssertEqual(resultView.error, expectedError)
		
		resultView.clear()
	}
	
	private func makeDealer(by cardPack: CardPack = BlackjackCard.arrangeCards()) -> Dealer{
		Dealer(cardPack: cardPack)
	}
}
