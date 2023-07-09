// Copyright Andrew Bernal 2023
import 'card.dart';
import 'suit.dart';
import 'pair.dart';

// Player is designed to be overridden
abstract class Player {
  // The player's hand of cards
  List<Card> hand = [];
  // the player's number
  final int playerNumber;

  // Default constructor
  Player({required this.playerNumber});

  // Constructor that takes a list of cards and a player number
  Player.fromCards({required List<Card> cards, required this.playerNumber}) {
    hand = cards;
  }

  // Add the card to the player's hand
  void dealCard(Card c) {
    hand.add(c);
  }

  // The player must keep at least 1 card
  Future<void> discard(int playerLeading, int bidAmount, Suit trump);

  // Returns the player's bid as a pair of bidAmount and suit
  Future<Pair<int, Suit>> getBid(List<Pair<int, int>> bidHistory);

  // The player is forced to bid
  Future<Suit> bagged();

  // Returns the card the player wants to play and removes it from their hand
  Future<Card> playCard(List<Card> cardsPlayedThisHand, Suit suitLed,
      Suit trump, List<Card> legalCards);

  // Returns the size of the player's hand
  int getSize() {
    return hand.length;
  }

  // Resets the player's hand
  void resetHand() {
    hand.clear();
  }

  // Prints the player's hand to the console
  void printHand() {
    for (var c in hand) {
      print(c);
    }
    print('\n');
  }

  // Returns a string representation of the player's hand
  String handToString() {
    var out = '';
    for (var c in hand) {
      out += '$c ';
    }
    out += '\n';
    return out;
  }

  // returns all of the cards you can legally play
  List<Card> getLegalMoves(Card cardLed, Suit trump) {
    // if you are the first player, you can play whatever you want
    if (cardLed.suit == Suit.INVALID) {
      return hand;
    }

    final Suit suitLed;
    if (cardLed.suit == Suit.ACE_OF_HEARTS) {
      suitLed = trump;
    } else {
      suitLed = cardLed.suit;
    }

    List<Card> legalCards = [];

    // you can always play trump if you want.
    for (Card card in hand) {
      if (card.suit == trump || card.suit == Suit.ACE_OF_HEARTS) {
        legalCards.add(card);
      }
    }

    // reneging is rare so I try to check it less often by putting conditions
    if (legalCards.isNotEmpty && legalCards.length <= 3) {
      List<Card> renegableCards = [
        Card(value: 5, suit: trump),
        Card(value: 11, suit: trump),
        Card(value: 0xACE, suit: Suit.ACE_OF_HEARTS)
      ];
      // if the 5 is led, then you can't renege
      if (cardLed == Card(value: 5, suit: trump)) {
        renegableCards.clear();
        // if the jack is led, then the ace of hearts can't be reneged
      } else if (cardLed == Card(value: 11, suit: trump)) {
        renegableCards.remove(Card(value: 0xACE, suit: Suit.ACE_OF_HEARTS));
      }

      // # of trump == the number of renegableCards, then you can reneg the cards
      if (legalCards.every((element) => renegableCards.contains(element))) {
        return hand;
      }
    }
    // must follow suit led if you have it
    // Don't have to compute it again if suitLed is trump
    if (suitLed != trump) {
      for (Card card in hand) {
        if (card.suit == cardLed.suit) {
          legalCards.add(card);
        }
      }
    }

    // if you can't follow suit, you can play whatever you want
    if (legalCards.isEmpty) {
      return hand;
    }

    return legalCards;
  }
}
