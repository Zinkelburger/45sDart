import 'deck.dart';
import 'player.dart';
import 'card.dart';
import 'suit.dart';
import 'pair.dart';

class X45s {
  List<Player> players = [];
  Deck deck = Deck();
  List<int> playerScores = [0, 0];
  List<int> playerScoresThisHand = [0, 0];

  /// bidHistory is bidAmount, playerNumber
  List<Pair<int, int>> bidHistory = [];
  int playerDealing = 0;
  int? bidAmount;
  int? bidder;
  Suit trump = Suit.INVALID;
  Suit suitLed = Suit.INVALID;

  X45s(Player p1, Player p2, Player p3, Player p4) {
    players.addAll([p1, p2, p3, p4]);
    playerDealing = 0;
  }

  /// when all 4 players are the same, sometimes you just want one function
  /// can be called like X45s.withFunction(() => Player());
  X45s.withOneFunction(Player Function(int playerNumber) createPlayer) {
    for (int i = 1; i <= 4; i++) {
      players.add(createPlayer(i));
    }
    playerDealing = 0;
  }

  X45s.withDifferentFunctions(
      Player Function(int playerNumber) cp1,
      Player Function(int playerNumber) cp2,
      Player Function(int playerNumber) cp3,
      Player Function(int playerNumber) cp4) {
    players.addAll([cp1(1), cp2(2), cp3(3), cp4(4)]);
    playerDealing = 0;
  }

  /// Shuffles the deck 10 times
  void shuffle() {
    deck.shuffleTimes(10);
  }

  /// Deals each player until their hand is 5 cards
  void dealPlayers() {
    for (final player in players) {
      while (player.getSize() < 5) {
        final card = deck.popBack();
        player.dealCard(card);
      }
    }
  }

  /// Deals the kiddie to the bidder
  void dealKiddie() {
    if (bidder! < 0 || bidder! > 3 || bidder == null) {
      throw ArgumentError(
          'Invalid winner of bid. Needs to be player 0, 1, 2, or 3');
    }
    // deal 3 cards to the player who won the kiddie
    for (int i = 0; i < 3; i++) {
      players[bidder!].dealCard(deck.popBack());
    }
  }

  /// Returns the best card
  Card evaluateTrick(Card card1, Card card2, Card card3, Card card4) {
    final cards = [card1, card2, card3, card4];
    return cards.reduce((value, element) =>
        value.lessThan(element, suitLed, trump) ? element : value);
  }

  /// Returns the best card from the list
  Card evaluateTrickList(List<Card> cards) {
    return cards.reduce((value, element) =>
        value.lessThan(element, suitLed, trump) ? element : value);
  }

  /// Increments the team's score by 5 (team is either 0 or 1)
  void updateScores(int team) {
    if (team != 0 && team != 1) {
      throw ArgumentError(
          'Invalid player $team in updateScores. Must be 0 or 1');
    }
    playerScoresThisHand[team] += 5;
  }

  /// Returns the score of team 0 or 1
  int getTeamScore(int team) {
    if (team != 0 && team != 1) {
      throw ArgumentError(
          'Invalid player $team in updateScores. Must be 0 or 1');
    }
    return playerScores[team];
  }

  /// Returns whether either team has more than 120 points
  bool hasWon() => playerScores[0] >= 120 || playerScores[1] >= 120;

  /// Returns the amount bid
  int? getBidAmount() => bidAmount;

  /// One full turn of the game. Returns the bidder and whether they won
  Future<Pair<int, bool>> dealBidAndFullFiveTricks() async {
    shuffle();
    dealPlayers();

    await getBidder();
    dealKiddie();

    await havePlayersDiscard();

    dealPlayers();

    // (Card, player)
    Pair<Card, int> highCard = Pair(Card(), -1000);

    int trickWinner = bidder!;
    // all 5 tricks
    for (int i = 0; i < 5; i++) {
      final winnerAndCard = await havePlayersPlayCardsAndEvaluate(trickWinner);
      trickWinner = winnerAndCard.second;

      // // update the score
      updateScores(trickWinner % 2);

      // check for the high card
      if (i == 0 ||
          highCard.first.lessThan(winnerAndCard.first, suitLed, trump)) {
        highCard = winnerAndCard;
      }
    }

    updateScores(highCard.second % 2);

    return Pair(bidder!, determineIfWonBidAndDeduct());
  }

  /// gets the bids of all 4 players. If no one bid, then bag the dealer
  /// Postcondition: playerDealing++, bidAmount, trump, and bidder are set.
  Future<void> getBidder() async {
    bidHistory.clear();
    Pair<int, Suit> currentBid;
    var maxBid = Pair<int, Suit>(0, Suit.INVALID);
    int? firstPlayer;

    // get the bids for the players besides the dealer
    for (int i = playerDealing + 1; i < playerDealing + 4; i++) {
      currentBid = await players[i % 4].getBid(bidHistory);
      if (currentBid.first != 0) {
        bidHistory.add(Pair(currentBid.first, i));
        if (currentBid.first > maxBid.first) {
          maxBid = currentBid;
          firstPlayer = i;
        }
      }
    }

    // check if you have to bag the dealer
    if (maxBid.first <= 0) {
      maxBid = Pair(15, await players[playerDealing].bagged());
      firstPlayer = playerDealing;
    } else {
      // otherwise the dealer can choose to bid
      currentBid = await players[playerDealing].getBid(bidHistory);
      if (currentBid.first != 0) {
        bidHistory.add(Pair(currentBid.first, playerDealing));
        if (currentBid.first > maxBid.first) {
          maxBid = currentBid;
          firstPlayer = playerDealing;
        }
      }
    }

    playerDealing++;
    playerDealing %= 4;

    bidAmount = maxBid.first;
    trump = maxBid.second;
    bidder = firstPlayer;
  }

  /// Returns the trump (as a Suit)
  Suit getTrump() => trump;

  /// Returns whether or not the player won their bid
  /// Calculates the updated scores with this information
  bool determineIfWonBidAndDeduct() {
    if (bidder == null) {
      throw ArgumentError("bidder should not be null");
    } else if (bidAmount == null) {
      throw ArgumentError("bidAmount should not be null");
    }

    // if the player lost the bid, then deduct the bid from their hand
    if (playerScoresThisHand[bidder! % 2] < bidAmount!) {
      // deduct the bid from the loser's hand
      playerScores[bidder!] -= bidAmount!;
      // give the opposing team their points
      playerScores[bidder! + 1 % 2] = playerScoresThisHand[bidder! + 1 % 2];
      return false;
    }
    // give the winning team their points
    playerScores[bidder! + 1 % 2] = playerScoresThisHand[bidder! + 1 % 2];
    // give the opposing team their points
    playerScores[bidder! + 1 % 2] = playerScoresThisHand[bidder! + 1 % 2];

    return true;
  }

  /// Resets the players, deck, and other member variables
  void reset() {
    for (final player in players) {
      player.resetHand();
    }
    deck.reset();
    playerScoresThisHand = [0, 0];
    bidAmount = null;
    bidder = null;
    trump = Suit.INVALID;
    suitLed = Suit.INVALID;
  }

  /// Has all the players play their cards and returns the list of the cards
  Future<List<Card>> havePlayersPlayCards() async {
    int playerLeading = bidder!;

    final cardsPlayed =
        List<Card>.filled(4, Card(value: -1000, suit: Suit.INVALID));

    // get the first card, where suitLed is not initialized
    cardsPlayed[playerLeading % 4] = await players[playerLeading % 4].playCard(
        cardsPlayed,
        Suit.INVALID,
        trump,
        players[playerLeading % 4].getLegalMoves(Card(), trump));

    players[playerLeading % 4].hand.remove(cardsPlayed[playerLeading % 4]);

    suitLed = cardsPlayed[playerLeading % 4].suit;

    // there is the case where the card's suit is the Ace of Hearts
    // when suitLed is set to trump
    if (suitLed == Suit.ACE_OF_HEARTS) {
      suitLed = trump;
    }
    for (int i = 1; i < 4; i++) {
      cardsPlayed[(playerLeading + i) % 4] =
          await players[(playerLeading + i) % 4].playCard(
              cardsPlayed,
              suitLed,
              trump,
              players[(playerLeading + i) % 4]
                  .getLegalMoves(cardsPlayed[playerLeading % 4], trump));
      players[(playerLeading + i) % 4]
          .hand
          .remove(cardsPlayed[(playerLeading + i) % 4]);
    }
    return cardsPlayed;
  }

  /// returns WinningCard, WinningPlayer
  Future<Pair<Card, int>> havePlayersPlayCardsAndEvaluate(
      int playerLeading) async {
    final cardsPlayed =
        List<Card>.filled(4, Card(value: -1000, suit: Suit.INVALID));

    // get the first card, where suitLed is not initialized
    cardsPlayed[playerLeading % 4] = await players[playerLeading % 4].playCard(
        cardsPlayed,
        Suit.INVALID,
        trump,
        players[playerLeading % 4].getLegalMoves(Card(), trump));

    players[playerLeading % 4].hand.remove(cardsPlayed[playerLeading % 4]);

    suitLed = cardsPlayed[playerLeading % 4].suit;

    // there is the case where the card's suit is the Ace of Hearts
    // when suitLed is set to trump
    if (suitLed == Suit.ACE_OF_HEARTS) {
      suitLed = trump;
    }
    for (int i = 1; i < 4; i++) {
      cardsPlayed[(playerLeading + i) % 4] =
          await players[(playerLeading + i) % 4].playCard(
              cardsPlayed,
              suitLed,
              trump,
              players[(playerLeading + i) % 4]
                  .getLegalMoves(cardsPlayed[playerLeading % 4], trump));
      players[(playerLeading + i) % 4]
          .hand
          .remove(cardsPlayed[(playerLeading + i) % 4]);
    }

    final winningCard = evaluateTrickList(cardsPlayed);
    int winningPlayer;
    if (winningCard == cardsPlayed[0]) {
      winningPlayer = 0;
    } else if (winningCard == cardsPlayed[1]) {
      winningPlayer = 1;
    } else if (winningCard == cardsPlayed[2]) {
      winningPlayer = 2;
    } else if (winningCard == cardsPlayed[3]) {
      winningPlayer = 3;
    } else {
      throw UnsupportedError(
          "cardsPlayed should be in the range 0 to 3 inclusive");
    }
    return Pair(winningCard, winningPlayer);
  }

  /// Calls the discard method for each of the players
  Future<void> havePlayersDiscard() async {
    if (bidAmount == null ||
        bidder == null ||
        trump == Suit.INVALID ||
        trump == Suit.ACE_OF_HEARTS) {
      throw ArgumentError("Variables are null that shouldn't be");
    }
    for (var e in players) {
      await e.discard(bidder!, bidAmount!, trump);
    }
  }
}
