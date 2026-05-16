class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String title; // e.g. "Senior Flutter Developer"
  final String bio;
  final double hourlyRate;
  final String website;
  final double rating;
  final int completedJobs;
  final int totalEarnings;
  final List<String> skills;
  final String location;
  final bool isFreelancer;
  final DateTime joinedDate;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.title,
    required this.bio,
    required this.hourlyRate,
    required this.website,
    required this.rating,
    required this.completedJobs,
    required this.totalEarnings,
    required this.skills,
    required this.location,
    required this.isFreelancer,
    required this.joinedDate,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? title,
    String? bio,
    double? hourlyRate,
    String? website,
    double? rating,
    int? completedJobs,
    int? totalEarnings,
    List<String>? skills,
    String? location,
    bool? isFreelancer,
    DateTime? joinedDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      isFreelancer: isFreelancer ?? this.isFreelancer,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  factory UserModel.dummy() {
    return UserModel(
      id: 'user_1',
      name: 'Sarah Chen',
      email: 'sarah.chen@email.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      title: 'Senior Flutter Developer',
      bio:
          'Experienced Flutter developer with 5+ years building cross-platform mobile apps. Specialized in clean architecture, state management, and pixel-perfect UI implementations.',
      hourlyRate: 75,
      website: 'https://sarahchen.dev',
      rating: 4.9,
      completedJobs: 47,
      totalEarnings: 28500,
      skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs', 'Clean Architecture'],
      location: 'San Francisco, CA',
      isFreelancer: true,
      joinedDate: DateTime.now().subtract(const Duration(days: 420)),
    );
  }
}
