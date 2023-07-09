import 'dart:math';
import 'card.dart';
import 'suit.dart';

class Deck {
  List<Card> pack = [];

  /// Initialize 52 cards. Does not shuffle them.
  Deck() {
    // Hearts = 2, Diamonds = 3, Clubs = 4, Spades = 5
    // there is no ++ for enum types, which is dumb
    for (int i = 2; i <= 5; i++) {
      for (int j = 1; j < 14; j++) {
        pack.add(Card(value: j, suit: Suit.values[i]));
      }
    }
    // Set the ace of hearts to its special suit
    pack[0].suit = Suit.ACE_OF_HEARTS;
    pack[0].value = 0xACE;
  }

  /// Does a Fisher-Yates shuffle
  void shuffle() {
    int seed = DateTime.now().millisecondsSinceEpoch;
    Random random = Random(seed);
    for (int i = pack.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      Card c = pack[j];
      pack[j] = pack[i];
      pack[i] = c;
    }
  }

  /// Shuffles the deck multiple times
  void shuffleTimes(int times) {
    for (int i = 0; i < times; i++) {
      shuffle();
    }
  }

  /// Removes and returns the last card in the deck
  Card popBack() {
    Card c = pack.last;
    pack.removeLast();
    return c;
  }

  /// Return the last card in the deck without removing it
  Card peekBack() {
    return pack.last;
  }

  /// Adds the card to the end of the deck
  void pushBack(Card c) {
    pack.add(c);
  }

  /// Clears the deck and reinitializes it with 52 cards
  void reset() {
    pack.clear();
    for (Suit i = Suit.HEARTS;
        i.index <= Suit.SPADES.index;
        i = Suit.values[(i.index + 1) % Suit.values.length]) {
      for (int j = 1; j < 14; j++) {
        pack.add(Card(value: j, suit: i));
      }
    }
    // Set the ace of hearts to its special suit
    pack[0].suit = Suit.ACE_OF_HEARTS;
    pack[0].value = 0xACE;
  }

  /// Removes the card from the deck. Error if the card is not in the deck
  void removeCard(Card c) {
    int? indexToRemove;
    for (int i = 0; i < pack.length; i++) {
      if (pack[i].suit == c.suit && pack[i].value == c.value) {
        indexToRemove = i;
        break;
      }
    }

    if (indexToRemove == null) {
      throw ArgumentError("Invalid Card passed to removeCard");
    } else {
      pack.removeAt(indexToRemove);
    }
  }

  /// Removes the card from the deck. Error if the card is not in the deck
  void removeCardByValueAndSuit(int value, Suit suit) {
    int? indexToRemove;
    for (int i = 0; i < pack.length; i++) {
      if (pack[i].suit == suit && pack[i].value == value) {
        indexToRemove = i;
        break;
      }
    }

    if (indexToRemove == null) {
      throw ArgumentError(
          "Invalid value, suit pair passed to removeCard: ${value.toString()}, $suit");
    } else {
      pack.removeAt(indexToRemove);
    }
  }

  /// Returns True if the card is in the deck, and false otherwise
  bool containsCard(int value, Suit suit) {
    for (int i = 0; i < pack.length; i++) {
      if (pack[i].suit == suit && pack[i].value == value) {
        return true;
      }
    }
    return false;
  }

  @override

  /// The Cards separated by spaces
  String toString() {
    String result = "";
    for (int i = 0; i < pack.length; i++) {
      result += pack[i].toString() + " ";
    }
    return result;
  }
}
