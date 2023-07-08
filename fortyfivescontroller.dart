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
  List<int> bidHistory = [];
  int playerDealing = 0;
  int? bidAmount;
  int? bidder;
  Suit trump = Suit.INVALID;
  Suit suitLed = Suit.INVALID;

  X45s(Player p1, Player p2, Player p3, Player p4) {
    players.addAll([p1, p2, p3, p4]);
    playerDealing = 0;
  }

  // when all 4 players are the same, sometimes you just want one function
  // can be called like X45s.withFunction(() => Player());
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

  void shuffle() {
    deck.shuffleTimes(10);
  }

  void dealPlayers() {
    for (final player in players) {
      while (player.getSize() < 5) {
        final card = deck.popBack();
        player.dealCard(card);
      }
    }
  }

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

  Card evaluateTrick(Card card1, Card card2, Card card3, Card card4) {
    final cards = [card1, card2, card3, card4];
    return cards.reduce((value, element) =>
        value.lessThan(element, suitLed, trump) ? value : element);
  }

  Card evaluateTrickList(List<Card> cards) {
    return cards.reduce((value, element) =>
        value.lessThan(element, suitLed, trump) ? value : element);
  }

  void updateScores(int player) {
    if (player != 0 && player != 1) {
      throw ArgumentError(
          'Invalid player $player in updateScores. Must be 0 or 1');
    }
    playerScores[player] += 5;
  }

  int getTeamScore(int player) {
    if (player != 0 && player != 1) {
      throw ArgumentError(
          'Invalid player $player in updateScores. Must be 0 or 1');
    }
    return playerScores[player];
  }

  bool hasWon() => playerScores[0] >= 120 || playerScores[1] >= 120;

  int? getBidAmount() => bidAmount;

  Pair<int, bool> dealBidAndFullFiveTricks() {
    dealPlayers();

    getBidder();
    dealKiddie();

    havePlayersDiscard();

    dealPlayers();

    // (Card, player)
    Pair<Card, int> highCard = Pair(Card(), -1000);

    int trickWinner = bidder!;
    // all 5 tricks
    for (int i = 0; i < 5; i++) {
      final winnerAndCard = havePlayersPlayCardsAndEvaluate(trickWinner);
      trickWinner = winnerAndCard.second;

      // sometimes set the high card to the winning card
      if (i == 0 ||
          highCard.first.lessThan(winnerAndCard.first, suitLed, trump)) {
        highCard = winnerAndCard;
      }
    }

    updateScores(highCard.second % 2);

    return Pair(bidder!, determineIfWonBidAndDeduct());
  }

  // gets the bids of all 4 players. If none bid, then bag the dealer
  // postcondition: playerDealing++, bidAmount, trump, and bidder are set.
  void getBidder() {
    bidHistory.clear();
    Pair<int, Suit> currentBid;
    var maxBid = Pair<int, Suit>(0, Suit.INVALID);
    int? firstPlayer;

    for (int i = playerDealing; i < playerDealing + 3; i++) {
      currentBid = players[i % 4].getBid(bidHistory);
      if (currentBid.first != 0) {
        bidHistory.add(currentBid.first);
        if (currentBid.first > maxBid.first) {
          maxBid = currentBid;
          firstPlayer = i;
        }
      }
    }

    // bags the dealer in this case
    if (maxBid.first <= 0) {
      currentBid = Pair(15, players[playerDealing].bagged());
      firstPlayer = playerDealing;
    }

    playerDealing++;
    playerDealing %= 4;

    bidAmount = maxBid.first;
    trump = maxBid.second;
    bidder = firstPlayer;
  }

  Suit getTrump() => trump;

  bool determineIfWonBidAndDeduct() {
    if (bidder == null) {
      throw ArgumentError("bidder should not be null");
    } else if (bidAmount == null) {
      throw ArgumentError("bidAmount should not be null");
    }

    // if the player lost the bid, then deduct the bid from their hand
    if (playerScoresThisHand[bidder! % 2] < bidAmount!) {
      playerScores[bidder!] -= bidAmount!;
      return false;
    }
    return true;
  }

  void reset() {
    for (final player in players) {
      player.resetHand();
    }
    deck.reset();
  }

  List<Card> havePlayersPlayCards(int playerLeading) {
    final cardsPlayed =
        List<Card>.filled(4, Card(value: -1000, suit: Suit.INVALID));

    // get the first card, where suitLed is not initialized
    cardsPlayed[playerLeading % 4] =
        players[playerLeading % 4].playCard(cardsPlayed, Suit.INVALID, trump);

    suitLed = cardsPlayed[playerLeading % 4].suit;

    // there is the case where the card's suit is the Ace of Hearts
    // when suitLed is set to trump
    if (suitLed == Suit.ACE_OF_HEARTS) {
      suitLed = trump;
    }
    for (int i = ++playerLeading % 4; i < (4 + playerLeading) % 4; i++) {
      cardsPlayed[i % 4] = players[i % 4].playCard(cardsPlayed, suitLed, trump);
    }
    return cardsPlayed;
  }

  // returns WinningCard, WinningPlayer
  Pair<Card, int> havePlayersPlayCardsAndEvaluate(int playerLeading) {
    final cardsPlayed =
        List<Card>.filled(4, Card(value: -1000, suit: Suit.INVALID));

    // get the first card, where suitLed is not initialized
    cardsPlayed[playerLeading % 4] =
        players[playerLeading % 4].playCard(cardsPlayed, Suit.INVALID, trump);

    suitLed = cardsPlayed[playerLeading % 4].suit;

    // there is the case where the card's suit is the Ace of Hearts
    // when suitLed is set to trump
    if (suitLed == Suit.ACE_OF_HEARTS) {
      suitLed = trump;
    }
    for (int i = ++playerLeading % 4; i < (4 + playerLeading) % 4; i++) {
      cardsPlayed[i % 4] = players[i % 4].playCard(cardsPlayed, suitLed, trump);
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
