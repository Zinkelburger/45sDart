# Forty fives in Dart
I want to use flutter, so I rewrote my C++ code in Dart. Also I improved it so it is less bad.

I removed operator>, as it requires suitLed and trump to be set. Now you have to explicitly pass them as parameters to the function lessThan. This also lets me remove the global variables/singleton class.

The ace of hearts has Suit.ACE_OF_HEARTS and value 0xACE