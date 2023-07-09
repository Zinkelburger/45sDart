import 'dart:math';
import 'card.dart';
import 'suit.dart';

class Deck {
  List<Card> pack = [];

  Deck() {
    // Initialize 52 cards, Hearts = 1, Diamonds = 2, Clubs = 3, Spades = 4
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

  void shuffle() {
    // Fisher-Yates shuffle
    int seed = DateTime.now().millisecondsSinceEpoch;
    Random random = Random(seed);
    for (int i = pack.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      Card c = pack[j];
      pack[j] = pack[i];
      pack[i] = c;
    }
  }

  void shuffleTimes(int times) {
    // Shuffle the deck multiple times
    for (int i = 0; i < times; i++) {
      shuffle();
    }
  }

  Card popBack() {
    // Remove and return the last card in the deck
    Card c = pack.last;
    pack.removeLast();
    return c;
  }

  Card peekBack() {
    // Return the last card in the deck without removing it
    return pack.last;
  }

  void pushBack(Card c) {
    // Add a card to the end of the deck
    pack.add(c);
  }

  void reset() {
    // Clear the deck and reinitialize it with 52 cards
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

  void removeCard(Card c) {
    // Linear search the deck until you find the card, then remove it
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

  void removeCardByValueAndSuit(int value, Suit suit) {
    // Linear search the deck until you find the card, then remove it
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

  bool containsCard(int value, Suit suit) {
    // Linear search the deck until you find the card
    for (int i = 0; i < pack.length; i++) {
      if (pack[i].suit == suit && pack[i].value == value) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() {
    // Return a string representation of the deck
    String result = "";
    for (int i = 0; i < pack.length; i++) {
      result += pack[i].toString() + " ";
    }
    return result;
  }
}
