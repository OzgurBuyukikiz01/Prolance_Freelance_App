class Conversation {
  final String id;
  final String userName;
  final String userAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const Conversation({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });

  static List<Conversation> dummyList() {
    final now = DateTime.now();
    return [
      Conversation(
        id: 'conv_1',
        userName: 'Marcus Thompson',
        userAvatar: 'https://i.pravatar.cc/150?img=12',
        lastMessage: 'Sounds great! I\'ll send over the contract by tomorrow.',
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
        unreadCount: 0,
        isOnline: true,
      ),
      Conversation(
        id: 'conv_2',
        userName: 'Elena Rodriguez',
        userAvatar: 'https://i.pravatar.cc/150?img=5',
        lastMessage: 'Can we schedule a call to discuss the design revisions?',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        unreadCount: 2,
        isOnline: true,
      ),
      Conversation(
        id: 'conv_3',
        userName: 'David Kim',
        userAvatar: 'https://i.pravatar.cc/150?img=33',
        lastMessage: 'The website is live. Thanks for your hard work!',
        lastMessageTime: now.subtract(const Duration(hours: 8)),
        unreadCount: 0,
        isOnline: false,
      ),
      Conversation(
        id: 'conv_4',
        userName: 'Amanda Foster',
        userAvatar: 'https://i.pravatar.cc/150?img=9',
        lastMessage: 'I\'ve pushed the latest changes to the staging branch.',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unreadCount: 1,
        isOnline: true,
      ),
      Conversation(
        id: 'conv_5',
        userName: 'James Wilson',
        userAvatar: 'https://i.pravatar.cc/150?img=15',
        lastMessage: 'Love the logo concepts! Let\'s go with option 2.',
        lastMessageTime: now.subtract(const Duration(days: 1, hours: 5)),
        unreadCount: 0,
        isOnline: false,
      ),
      Conversation(
        id: 'conv_6',
        userName: 'Priya Sharma',
        userAvatar: 'https://i.pravatar.cc/150?img=20',
        lastMessage: 'When can you start on the backend project?',
        lastMessageTime: now.subtract(const Duration(days: 2)),
        unreadCount: 0,
        isOnline: false,
      ),
      Conversation(
        id: 'conv_7',
        userName: 'Chris Martinez',
        userAvatar: 'https://i.pravatar.cc/150?img=11',
        lastMessage: 'Here\'s the first draft. Let me know your feedback.',
        lastMessageTime: now.subtract(const Duration(days: 3)),
        unreadCount: 3,
        isOnline: true,
      ),
      Conversation(
        id: 'conv_8',
        userName: 'Rachel Green',
        userAvatar: 'https://i.pravatar.cc/150?img=23',
        lastMessage: 'Perfect, the store looks amazing. Payment sent!',
        lastMessageTime: now.subtract(const Duration(days: 4)),
        unreadCount: 0,
        isOnline: false,
      ),
      Conversation(
        id: 'conv_9',
        userName: 'Michael Chen',
        userAvatar: 'https://i.pravatar.cc/150?img=68',
        lastMessage: 'I\'ve completed the API docs for the auth endpoints.',
        lastMessageTime: now.subtract(const Duration(days: 5)),
        unreadCount: 0,
        isOnline: false,
      ),
    ];
  }
}

class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  const Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });

  static List<Message> dummyList() {
    final now = DateTime.now();
    return [
      Message(
        id: 'msg_1',
        senderId: 'user_other',
        text: 'Hi! I saw your proposal for the Flutter project. Are you available for a quick call?',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
        isMe: false,
      ),
      Message(
        id: 'msg_2',
        senderId: 'user_me',
        text: 'Hello! Yes, I\'m available. When works best for you?',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 25)),
        isMe: true,
      ),
      Message(
        id: 'msg_3',
        senderId: 'user_other',
        text: 'How about tomorrow at 3 PM your time?',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 20)),
        isMe: false,
      ),
      Message(
        id: 'msg_4',
        senderId: 'user_me',
        text: 'That works perfectly. I\'ll send you a calendar invite.',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
        isMe: true,
      ),
      Message(
        id: 'msg_5',
        senderId: 'user_other',
        text: 'Sounds great! I\'ll send over the contract by tomorrow.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isMe: false,
      ),
    ];
  }
}
