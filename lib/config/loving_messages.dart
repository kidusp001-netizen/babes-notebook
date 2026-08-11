/// Daily loving notes shown on the Profile screen — from Kidus to Babe.
class LovingMessages {
  LovingMessages._();

  static const signature = 'With all my love, Kidus ♡';

  static const _messages = [
    'You are my babe in every season. I\'m so proud of the woman you are.',
    'Every letter you write here matters — to God, and to me.',
    'Your heart is beautiful, Babe. Never stop pouring it out.',
    'I built this for you because you deserve something as lovely as you are.',
    'Thank you for letting me love you. You make every ordinary day sacred.',
    'When you write to Him, I see grace in you. Keep going, my love.',
    'You don\'t have to be perfect — just be you. That\'s more than enough.',
    'I fall in love with you a little more every day. Always your Kidus.',
    'Your prayers, your gratitude, your tears — all of it is holy ground.',
    'Rest in knowing you are deeply loved, today and always.',
    'The world is brighter because you\'re in it. Never forget that.',
    'I\'m cheering for you always — in every page you write.',
  ];

  static String forToday() {
    final index = DateTime.now().difference(DateTime(2020, 1, 1)).inDays;
    return _messages[index % _messages.length];
  }
}
