// Copyright Andrew Bernal 2023
import 'package:flutter/material.dart';

enum Suit {
  INVALID,
  ACE_OF_HEARTS,
  HEARTS,
  DIAMONDS,
  CLUBS,
  SPADES,
}

/// Useful function for Flutter. Outputs the emoji for a Suit
TextSpan suitToEmoji(Suit suit) {
  switch (suit) {
    case Suit.ACE_OF_HEARTS:
    case Suit.HEARTS:
      return const TextSpan(text: '♥', style: TextStyle(color: Colors.red));
    case Suit.DIAMONDS:
      return const TextSpan(text: '♦', style: TextStyle(color: Colors.red));
    case Suit.CLUBS:
      return const TextSpan(text: '♣️');
    case Suit.SPADES:
      return const TextSpan(text: '♠️');
    default:
      return const TextSpan(text: '');
  }
}
