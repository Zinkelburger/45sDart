// Copyright Andrew Bernal 2023
import 'card.dart';
import 'suit.dart';
import 'pair.dart';

// Player is designed to be overridden by Computer and Human
abstract class Player {
    // The player's hand of cards
    List<Card> hand = [];

    // Default constructor
    Player();

    // Constructor that takes a list of cards
    Player.fromCards(List<Card> cards) {
        hand = cards;
    }

    // Add the card to the player's hand
    void dealCard(Card c) {
        hand.add(c);
    }

    // The player must keep at least 1 card
    void discard();

    // Returns the player's bid as a pair of bidAmount and suit
    Pair<int, Suit> getBid(List<int> bidHistory);

    // The player is forced to bid
    Suit bagged();

    // Returns the card the player wants to play and removes it from their hand
    Card playCard(List<Card> cardsPlayedThisHand, Suit suitLed, Suit trump);

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
}
