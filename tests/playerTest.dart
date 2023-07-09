import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import '../card.dart';
import '../player.dart';
import '../suit.dart';

class FakePlayer extends Fake implements Player {
  @override
  List<Card> hand = [];

  @override
  final int playerNumber;

  FakePlayer({required this.playerNumber});

  @override
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
    if (suitLed == trump && legalCards.isNotEmpty && legalCards.length <= 3) {
      print("here1");
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

      for (final element in legalCards) {
        final result = renegableCards.contains(element);
        print('Element: $element, Result: $result');
      }

      // # of trump == the number of renegableCards, then you can reneg the cards
      if (legalCards.every((element) => renegableCards.contains(element))) {
        print("Inside the important thing");
        print("Hand inside: $hand");
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

void main() {
  test('Reneg ace of hearts', () {
    // spades is led. Test that ace of hearts is not forced
    final player = FakePlayer(playerNumber: 1);
    player.hand = [
      Card(value: 0xACE, suit: Suit.ACE_OF_HEARTS),
      Card(value: 3, suit: Suit.CLUBS),
      Card(value: 4, suit: Suit.HEARTS),
    ];
    final cardLed = Card(value: 2, suit: Suit.SPADES);
    final trump = Suit.SPADES;

    expect(player.getLegalMoves(cardLed, trump), equals(player.hand));
  });
}
