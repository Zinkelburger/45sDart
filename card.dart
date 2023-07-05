import 'suit.dart';

class Card {
  int value;
  Suit suit;

  Card({this.value = -1000, this.suit = Suit.INVALID});

  @override
  String toString() {
    String result = "";
    if (value == 13) {
      result += "King";
    } else if (value == 12) {
      result += "Queen";
    } else if (value == 11) {
      result += "Jack";
    } else if (suit == Suit.ACE_OF_HEARTS) {
      result += "Ace of Hearts, ";
      return result;
    } else if (value == 1) {
      result += "Ace";
    } else {
      result += value.toString();
    }
    result += " of";
    switch (suit) {
      case Suit.HEARTS:
        result += " Hearts, ";
        break;
      case Suit.DIAMONDS:
        result += " Diamonds, ";
        break;
      case Suit.CLUBS:
        result += " Clubs, ";
        break;
      case Suit.SPADES:
        result += " Spades, ";
        break;
      default:
        throw ("Card has an invalid suit!");
    }
    return result;
  }

  bool lessThan(Card other, Suit suitLed, Suit trump) {
    if (trump != Suit.CLUBS && trump != Suit.SPADES && trump != Suit.HEARTS && trump != Suit.DIAMONDS) {
      throw ArgumentError("trump is not valid!");
    }
    List<int> hearts = [5, 11, 0xACE, 13, 12, 10, 9, 8, 7, 6, 4, 3, 2, -10];
    List<int> diamonds = [5, 11, 0xACE, 1, 13, 12, 10, 9, 8, 7, 6, 4, 3, 2];
    List<int> clubsAndSpades = [5, 11, 0xACE, 1, 13, 12, 2, 3, 4, 6, 7, 8, 9, 10];

    List<int> order;

    // if both are offsuite, evaluateOffSuite
    if (suit != trump && suit != Suit.ACE_OF_HEARTS &&
        other.suit != trump && other.suit != Suit.ACE_OF_HEARTS) {
        bool r;
        try {
            r = evaluateOffSuit(other, suitLed);
            return r;
        } on Exception catch (e) {
            // could be a bug, fix if it is a bug
            if (e.toString() == "Exception: Neither card is of the current suit") {
                return false;
            }
        }
        throw UnsupportedError("Should not have gotten to this point");
    }

    if (trump == Suit.HEARTS) {
      order = hearts;
    } else if (trump == Suit.DIAMONDS) {
      order = diamonds;
    } else {
      order = clubsAndSpades;
    }

    if ((suit == trump || suit == Suit.ACE_OF_HEARTS) &&
        (other.suit == trump || other.suit == Suit.ACE_OF_HEARTS)) {
      for (int i = 0; i < order.length; i++) {
        if (other.value == order[i]) {
          return true;
        } else if (value == order[i]) {
          return false;
        }
      }
    } else if ((other.suit == trump || other.suit == Suit.ACE_OF_HEARTS) &&
               (suit != trump && suit != Suit.ACE_OF_HEARTS)) {
      return true;
    } else if ((other.suit != trump && other.suit != Suit.ACE_OF_HEARTS) &&
               (suit == trump || suit == Suit.ACE_OF_HEARTS)) {
      return false;
    }
    throw UnsupportedError("How the hell did you get here");
  }

    bool evaluateOffSuit(Card other, Suit inpSuit) {
        if (inpSuit != Suit.CLUBS && inpSuit != Suit.SPADES && inpSuit != Suit.HEARTS && inpSuit != Suit.DIAMONDS) {
            throw ArgumentError("suitLed is not valid!");
        }

        if (other.suit != inpSuit && suit != inpSuit) {
            throw Exception("Neither card is of the current suit");
        }

        List<int> heartsAndDiamonds = [13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
        List<int> clubsAndSpades = [13, 12, 11, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        List<int> order;
        if (inpSuit == Suit.HEARTS || inpSuit == Suit.DIAMONDS) {
            order = heartsAndDiamonds;
        } else {
            order = clubsAndSpades;
        }

        if (other.suit == inpSuit && suit == inpSuit) {
            for (int i = 0; i < order.length; i++) {
                if (value == order[i]) {
                    return true;
                } else if (other.value == order[i]) {
                    return false;
                }
            }
        } else if (suit == inpSuit && other.suit != inpSuit) {
            return true;
        } else if (suit != inpSuit && other.suit == inpSuit) {
            return false;
        }
        throw UnsupportedError("How the hell did you get here");
    }
}
