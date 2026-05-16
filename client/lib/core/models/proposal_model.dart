class ProposalModel {
  final String id;
  final String freelancerName;
  final String freelancerAvatar;
  final String freelancerTitle;
  final double bidAmount;
  final String coverLetter;
  final int deliveryDays;
  final double freelancerRating;
  final DateTime submittedDate;

  const ProposalModel({
    required this.id,
    required this.freelancerName,
    required this.freelancerAvatar,
    required this.freelancerTitle,
    required this.bidAmount,
    required this.coverLetter,
    required this.deliveryDays,
    required this.freelancerRating,
    required this.submittedDate,
  });

  static List<ProposalModel> dummyList() {
    final now = DateTime.now();
    return [
      ProposalModel(
        id: 'prop_1',
        freelancerName: 'Sarah Chen',
        freelancerAvatar: 'https://i.pravatar.cc/150?img=1',
        freelancerTitle: 'Senior Flutter Developer',
        bidAmount: 3500,
        coverLetter:
            'I have 5+ years of experience building Flutter apps for e-commerce. I\'ve completed similar projects with seamless API integration and clean architecture. I\'d love to discuss your requirements in detail.',
        deliveryDays: 45,
        freelancerRating: 4.9,
        submittedDate: now.subtract(const Duration(hours: 2)),
      ),
      ProposalModel(
        id: 'prop_2',
        freelancerName: 'Alex Rivera',
        freelancerAvatar: 'https://i.pravatar.cc/150?img=3',
        freelancerTitle: 'Flutter & Firebase Developer',
        bidAmount: 2800,
        coverLetter:
            'I specialize in Flutter e-commerce apps with Firebase backend. I can deliver a polished app within 6 weeks. Happy to provide portfolio and references.',
        deliveryDays: 42,
        freelancerRating: 4.7,
        submittedDate: now.subtract(const Duration(hours: 5)),
      ),
      ProposalModel(
        id: 'prop_3',
        freelancerName: 'Priya Patel',
        freelancerAvatar: 'https://i.pravatar.cc/150?img=20',
        freelancerTitle: 'Full-Stack Mobile Developer',
        bidAmount: 4200,
        coverLetter:
            'I\'ve built 15+ e-commerce apps on Flutter. I use clean architecture and ensure maintainable code. I can start immediately and deliver in 2 months.',
        deliveryDays: 60,
        freelancerRating: 5.0,
        submittedDate: now.subtract(const Duration(days: 1)),
      ),
      ProposalModel(
        id: 'prop_4',
        freelancerName: 'Marcus Johnson',
        freelancerAvatar: 'https://i.pravatar.cc/150?img=11',
        freelancerTitle: 'Flutter Developer',
        bidAmount: 2200,
        coverLetter:
            'I\'m an intermediate Flutter developer looking to grow my portfolio. I can deliver a solid e-commerce app at a competitive rate. Let\'s connect!',
        deliveryDays: 55,
        freelancerRating: 4.5,
        submittedDate: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      ProposalModel(
        id: 'prop_5',
        freelancerName: 'Yuki Tanaka',
        freelancerAvatar: 'https://i.pravatar.cc/150?img=25',
        freelancerTitle: 'Cross-Platform App Developer',
        bidAmount: 3800,
        coverLetter:
            'I have extensive experience with REST APIs and state management in Flutter. I\'ll ensure your app has excellent performance and a smooth user experience.',
        deliveryDays: 50,
        freelancerRating: 4.8,
        submittedDate: now.subtract(const Duration(days: 2)),
      ),
      ProposalModel(
        id: 'prop_6',
        freelancerName: 'Omar Hassan',
        freelancerAvatar: 'https://i.pravatar.cc/150?img=52',
        freelancerTitle: 'Flutter & Dart Expert',
        bidAmount: 4500,
        coverLetter:
            'I\'ve been working with Flutter since its early days. I can implement advanced features like offline support and push notifications. Ready to start ASAP.',
        deliveryDays: 40,
        freelancerRating: 4.9,
        submittedDate: now.subtract(const Duration(days: 2, hours: 8)),
      ),
    ];
  }
}
