import 'dart:math';

import 'deck.dart';
import 'player.dart';
import 'card.dart';
import 'suit.dart';
import 'pair.dart';

class X45s {
  final List<Player> players = [];
  final Deck deck = Deck();
  final List<int> playerScores = [0, 0];
  int playerDealing = 0;
  bool initalizedPlayersWithNew = false;

  X45s(Player p1, Player p2, Player p3, Player p4) {
    players.addAll([p1, p2, p3, p4]);
    playerDealing = 0;
  }

  X45s.withFunctions(
      Player Function() cp1,
      Player Function() cp2,
      Player Function() cp3,
      Player Function() cp4) {
    initalizedPlayersWithNew = true;
    players.addAll([cp1(), cp2(), cp3(), cp4()]);
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

  void dealKiddie(int winner) {
    if (winner < 0 || winner > 3) {
      throw ArgumentError(
          'Invalid winner of bid. Needs to be player 0, 1, 2, or 3');
    }
    for (int i = 0; i < 3; i++) {
      players[winner].dealCard(deck.popBack());
    }
  }

  Card evaluateTrick(Card card1, Card card2, Card card3, Card card4) {
    final cards = [card1, card2, card3, card4];
    return cards.reduce((value, element) => max(value, element));
  }

  Card evaluateTrickList(List<Card> cards) {
    return cards.reduce((value, element) => max(value, element));
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

  bool hasWon() => playerScores[0] >=120 || playerScores[1] >=120;

  int getBidAmount() => bidAmount;

  Pair<int, bool> dealBidAndFullFiveTricks() {
    dealPlayers();

    final bidder = getBidder();
    setBid(bidAmount, bidder);

    final gameState = GameState.instance;
    gameState.setTrump(getBidSuit());

    dealKiddie(bidder);
    havePlayersDiscard();

    dealPlayers();

    var firstPlayer = bidder + 1;
    Pair<Card, int> highCard;

    for (int i = 0; i < 5; i++) {
      final winnerAndCard = havePlayersPlayCardsAndEvaluate(firstPlayer);
      firstPlayer = winnerAndCard.second;

      if (winnerAndCard.first > highCard.first || i == 0) {
        highCard = winnerAndCard;
      }
    }

    updateScores(highCard.second % 2);

    return Pair(bidder, determineIfWonBidAndDeduct());
  }

  void setBid(int bid, int bidderNum) {
    bidAmount = bid;
    bidder = bidderNum;
    bidderInitialScore = playerScores[bidder];
  }

  int getBidder() {
    bidHistory.clear();
    Pair<int, Suit> currentBid;
    var maxBid = Pair<int, Suit>(-2147483648, Suit.ACE_OF_HEARTS);
    var firstPlayer = -1;

    for (int i = playerDealing + 1; i < playerDealing + 4; i++) {
      currentBid = players[i % 4].getBid(bidHistory);
      if (currentBid.first != 0) {
        bidHistory.add(currentBid.first);
        if (currentBid.first > maxBid.first) {
          maxBid = currentBid;
          firstPlayer = i;
        }
      }
    }

    if (maxBid.first <= 0) {
      currentBid.second = players[playerDealing].bagged();
      firstPlayer = playerDealing;
    } else {
      currentBid = players[playerDealing].getBid(bidHistory);
      if (currentBid.first != 0) {
        bidHistory.add(currentBid.first);
        if (currentBid.first > maxBid.first) {
          maxBid = currentBid;
          firstPlayer = playerDealing;
        }
      }
    }

    playerDealing++;
    playerDealing %= 4;

    bidAmount = maxBid.first;
    bidSuit = maxBid.second;

    return firstPlayer;
  }

  Suit getBidSuit() => bidSuit;

  bool determineIfWonBidAndDeduct() {
    if (playerScores[bidder] - bidAmount < bidderInitialScore) {
      playerScores[bidder] = bidderInitialScore - bidAmount;
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
    final cardsPlayed = List<Card>.filled(4, Card(Suit.aceOfHearts, 0));
    cardsPlayed[playerLeading % 4] = players[playerLeading % 4].playCard(cardsPlayed);

    final gameState = GameState.instance;
    gameState.setSuitLed(cardsPlayed[playerLeading % 4].suit);
    if (gameState.getSuitLed() == Suit.aceOfHearts) {
      gameState.setSuitLed(gameState.getTrump());
    }
    for (int cardNum = ++playerLeading; cardNum < 4 + playerLeading; cardNum++) {
      cardsPlayed[playerLeading % 4] =
          players[cardNum % 4].playCard(cardsPlayed);
    }
    return cardsPlayed;
  }

  Pair<Card, int> havePlayersPlayCardsAndEvaluate(int playerLeading) 
    final cardsPlayed = List<Card>.filled(4, Card(value: -1000, suit: Suit.INVALID));

    cardsPlayed[playerLeading % 4] = players[playerLeading % 4].playCard(cardsPlayed);

    final gameState = GameState.instance;
    gameState.setSuitLed(cardsPlayed[playerLeading % 4].suit);

    if (gameState.getSuitLed() == Suit.ACE_OF_HEARTS) {
      gameState.setSuitLed(gameState.getTrump());
    }

    for (int cardNum = ++playerLeading; cardNum < 4 + playerLeading; cardNum++) {
      cardsPlayed[playerLeading % 4] = players[cardNum % 4].playCard(cardsPlayed);
    }

    final winningCard = evaluateTrickList(cardsPlayed);
    int winningPlayer;
    if (winningCard == cardsPlayed[0]) {
      winningPlayer = 0;
    } else if (winningCard == cardsPlayed[1]) {
      winningPlayer = 1;
    } else if (winningCard == cardsPlayed[2]) {
      winningPlayer = 2;
    } else {
      winningPlayer = 3;
    }
      return Pair(winningCard, winningPlayer);
  }
}