abstract class JobListingKinds {
  JobListingKinds._();

  static const String jobOffer = 'job_offer';
  static const String freelancerSeeking = 'freelancer_seeking';
}

class JobModel {
  final String id;
  final String title;
  final String description;
  final String clientName;
  final String clientAvatar;
  final double budgetMin;
  final double budgetMax;
  final String budgetType; // "fixed" or "hourly"
  final String category;
  final List<String> skills;
  final String experienceLevel; // "Entry", "Intermediate", "Expert"
  final DateTime postedDate;
  final int proposalCount;
  final String duration; // "Less than 1 month", "1-3 months", "3-6 months", "More than 6 months"
  final bool isSaved;
  final String status; // "open", "in_progress", "completed", "cancelled"
  /// User-created posts from the app (excluded from home "Recommended", prioritized in "Recent").
  final bool isUserPosted;
  /// [JobListingKinds.jobOffer] or [JobListingKinds.freelancerSeeking].
  final String listingKind;

  const JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.clientName,
    required this.clientAvatar,
    required this.budgetMin,
    required this.budgetMax,
    required this.budgetType,
    required this.category,
    required this.skills,
    required this.experienceLevel,
    required this.postedDate,
    required this.proposalCount,
    required this.duration,
    required this.isSaved,
    required this.status,
    this.isUserPosted = false,
    this.listingKind = JobListingKinds.jobOffer,
  });

  JobModel copyWith({
    String? id,
    String? title,
    String? description,
    String? clientName,
    String? clientAvatar,
    double? budgetMin,
    double? budgetMax,
    String? budgetType,
    String? category,
    List<String>? skills,
    String? experienceLevel,
    DateTime? postedDate,
    int? proposalCount,
    String? duration,
    bool? isSaved,
    String? status,
    bool? isUserPosted,
    String? listingKind,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      clientName: clientName ?? this.clientName,
      clientAvatar: clientAvatar ?? this.clientAvatar,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      budgetType: budgetType ?? this.budgetType,
      category: category ?? this.category,
      skills: skills ?? this.skills,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      postedDate: postedDate ?? this.postedDate,
      proposalCount: proposalCount ?? this.proposalCount,
      duration: duration ?? this.duration,
      isSaved: isSaved ?? this.isSaved,
      status: status ?? this.status,
      isUserPosted: isUserPosted ?? this.isUserPosted,
      listingKind: listingKind ?? this.listingKind,
    );
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final kind = json['listingKind'] as String?;
    return JobModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      clientName: json['clientName'] as String,
      clientAvatar: json['clientAvatar'] as String,
      budgetMin: (json['budgetMin'] as num).toDouble(),
      budgetMax: (json['budgetMax'] as num).toDouble(),
      budgetType: json['budgetType'] as String,
      category: json['category'] as String,
      skills: (json['skills'] as List<dynamic>).map((e) => '$e').toList(),
      experienceLevel: json['experienceLevel'] as String,
      postedDate: DateTime.parse(json['postedDate'] as String),
      proposalCount: json['proposalCount'] as int,
      duration: json['duration'] as String,
      isSaved: json['isSaved'] as bool,
      status: json['status'] as String,
      isUserPosted: json['isUserPosted'] as bool? ?? false,
      listingKind: kind ?? JobListingKinds.jobOffer,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'clientName': clientName,
        'clientAvatar': clientAvatar,
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'budgetType': budgetType,
        'category': category,
        'skills': skills,
        'experienceLevel': experienceLevel,
        'postedDate': postedDate.toIso8601String(),
        'proposalCount': proposalCount,
        'duration': duration,
        'isSaved': isSaved,
        'status': status,
        'isUserPosted': isUserPosted,
        'listingKind': listingKind,
      };

  static List<JobModel> dummyList() {
    final now = DateTime.now();
    return [
      JobModel(
        id: 'job_1',
        title: 'Flutter App for E-commerce Startup',
        description:
            'We need a skilled Flutter developer to build a cross-platform e-commerce app with product catalog, cart, checkout, and user authentication. Must integrate with our existing REST API backend.',
        clientName: 'Marcus Thompson',
        clientAvatar: 'https://i.pravatar.cc/150?img=12',
        budgetMin: 2500,
        budgetMax: 5000,
        budgetType: 'fixed',
        category: 'Mobile Development',
        skills: ['Flutter', 'Dart', 'REST APIs', 'Firebase'],
        experienceLevel: 'Intermediate',
        postedDate: now.subtract(const Duration(hours: 3)),
        proposalCount: 12,
        duration: '1-3 months',
        isSaved: true,
        status: 'open',
        isUserPosted: false,
      ),
      JobModel(
        id: 'job_2',
        title: 'UI/UX Design for Fitness Tracking App',
        description:
            'Looking for a talented designer to create modern, engaging UI designs for our fitness tracking application. Need wireframes, high-fidelity mockups, and design system.',
        clientName: 'Elena Rodriguez',
        clientAvatar: 'https://i.pravatar.cc/150?img=5',
        budgetMin: 40,
        budgetMax: 75,
        budgetType: 'hourly',
        category: 'Design',
        skills: ['UI Design', 'Figma', 'UX Research', 'Prototyping'],
        experienceLevel: 'Expert',
        postedDate: now.subtract(const Duration(days: 1)),
        proposalCount: 23,
        duration: 'Less than 1 month',
        isSaved: false,
        status: 'open',
        isUserPosted: false,
      ),
      JobModel(
        id: 'job_3',
        title: 'WordPress Website with Custom Theme',
        description:
            'Need a WordPress developer to build a corporate website with custom theme, blog section, contact forms, and SEO optimization. Design files will be provided.',
        clientName: 'David Kim',
        clientAvatar: 'https://i.pravatar.cc/150?img=33',
        budgetMin: 800,
        budgetMax: 1500,
        budgetType: 'fixed',
        category: 'Web Development',
        skills: ['WordPress', 'PHP', 'CSS', 'JavaScript'],
        experienceLevel: 'Entry',
        postedDate: now.subtract(const Duration(days: 2)),
        proposalCount: 8,
        duration: 'Less than 1 month',
        isSaved: true,
        status: 'open',
        isUserPosted: false,
      ),
      JobModel(
        id: 'job_4',
        title: 'React Native Developer for Social App',
        description:
            'Seeking experienced React Native developer to join our team building a social networking app. Must have experience with real-time features, push notifications, and scalable architecture.',
        clientName: 'Amanda Foster',
        clientAvatar: 'https://i.pravatar.cc/150?img=9',
        budgetMin: 55,
        budgetMax: 90,
        budgetType: 'hourly',
        category: 'Mobile Development',
        skills: ['React Native', 'TypeScript', 'Firebase', 'WebSockets'],
        experienceLevel: 'Expert',
        postedDate: now.subtract(const Duration(days: 3)),
        proposalCount: 18,
        duration: '3-6 months',
        isSaved: false,
        status: 'open',
        isUserPosted: false,
      ),
      JobModel(
        id: 'job_5',
        title: 'Logo and Brand Identity Design',
        description:
            'Startup in fintech space needs a complete brand identity: logo, color palette, typography, and brand guidelines. Looking for creative, minimalist aesthetic.',
        clientName: 'James Wilson',
        clientAvatar: 'https://i.pravatar.cc/150?img=15',
        budgetMin: 500,
        budgetMax: 1200,
        budgetType: 'fixed',
        category: 'Branding',
        skills: ['Logo Design', 'Branding', 'Illustrator', 'Adobe Creative Suite'],
        experienceLevel: 'Intermediate',
        postedDate: now.subtract(const Duration(days: 4)),
        proposalCount: 31,
        duration: 'Less than 1 month',
        isSaved: true,
        status: 'open',
        isUserPosted: false,
      ),
      JobModel(
        id: 'job_6',
        title: 'Python Backend for Analytics Dashboard',
        description:
            'Need a Python developer to build a FastAPI backend for our analytics dashboard. Includes data processing, authentication, and integration with PostgreSQL and Redis.',
        clientName: 'Priya Sharma',
        clientAvatar: 'https://i.pravatar.cc/150?img=20',
        budgetMin: 3000,
        budgetMax: 6000,
        budgetType: 'fixed',
        category: 'Backend Development',
        skills: ['Python', 'FastAPI', 'PostgreSQL', 'Redis'],
        experienceLevel: 'Expert',
        postedDate: now.subtract(const Duration(days: 5)),
        proposalCount: 9,
        duration: '1-3 months',
        isSaved: false,
        status: 'open',
        isUserPosted: false,
      ),
      JobModel(
        id: 'job_7',
        title: 'Video Editing for YouTube Channel',
        description:
            'Looking for a video editor to create engaging content for our tech review YouTube channel. 2-3 videos per week, 8-12 min each. Need someone familiar with tech content style.',
        clientName: 'Chris Martinez',
        clientAvatar: 'https://i.pravatar.cc/150?img=11',
        budgetMin: 25,
        budgetMax: 45,
        budgetType: 'hourly',
        category: 'Video Editing',
        skills: ['Premiere Pro', 'After Effects', 'Color Grading', 'Motion Graphics'],
        experienceLevel: 'Intermediate',
        postedDate: now.subtract(const Duration(days: 6)),
        proposalCount: 27,
        duration: 'More than 6 months',
        isSaved: false,
        status: 'open',
        isUserPosted: false,
      ),
      JobModel(
        id: 'job_8',
        title: 'Shopify Store Setup and Customization',
        description:
            'Need help setting up a new Shopify store for handmade jewelry. Includes theme customization, product setup, payment integration, and basic SEO.',
        clientName: 'Rachel Green',
        clientAvatar: 'https://i.pravatar.cc/150?img=23',
        budgetMin: 600,
        budgetMax: 1000,
        budgetType: 'fixed',
        category: 'E-commerce',
        skills: ['Shopify', 'Liquid', 'E-commerce', 'SEO'],
        experienceLevel: 'Entry',
        postedDate: now.subtract(const Duration(days: 7)),
        proposalCount: 15,
        duration: 'Less than 1 month',
        isSaved: true,
        status: 'open',
        isUserPosted: false,
      ),
      JobModel(
        id: 'job_9',
        title: 'Technical Writer for API Documentation',
        description:
            'We need a technical writer to create comprehensive API documentation for our developer platform. Must understand REST APIs and be able to write clear, concise documentation with code examples.',
        clientName: 'Michael Chen',
        clientAvatar: 'https://i.pravatar.cc/150?img=68',
        budgetMin: 35,
        budgetMax: 60,
        budgetType: 'hourly',
        category: 'Technical Writing',
        skills: ['Technical Writing', 'API Documentation', 'Markdown', 'OpenAPI'],
        experienceLevel: 'Intermediate',
        postedDate: now.subtract(const Duration(days: 8)),
        proposalCount: 11,
        duration: '1-3 months',
        isSaved: false,
        status: 'open',
        isUserPosted: false,
      ),
      JobModel(
        id: 'job_10',
        title: 'Flutter Migration from React Native',
        description:
            'We have an existing React Native app that we want to migrate to Flutter. Need an experienced developer who has done similar migrations. App has ~20 screens with complex state management.',
        clientName: 'TechVentures Inc',
        clientAvatar: 'https://i.pravatar.cc/150?img=70',
        budgetMin: 8000,
        budgetMax: 15000,
        budgetType: 'fixed',
        category: 'Mobile Development',
        skills: ['Flutter', 'Dart', 'React Native', 'State Management'],
        experienceLevel: 'Expert',
        postedDate: now.subtract(const Duration(days: 10)),
        proposalCount: 6,
        duration: '3-6 months',
        isSaved: true,
        status: 'open',
        isUserPosted: false,
      ),
      JobModel(
        id: 'job_11',
        title: 'Mobile App Bug Fixes and Performance Optimization',
        description:
            'Our Flutter app has some performance issues and bugs that need to be fixed. Looking for someone who can dive in quickly and improve app stability and responsiveness.',
        clientName: 'Sarah Mitchell',
        clientAvatar: 'https://i.pravatar.cc/150?img=47',
        budgetMin: 500,
        budgetMax: 1200,
        budgetType: 'fixed',
        category: 'Mobile Development',
        skills: ['Flutter', 'Dart', 'Performance', 'Debugging'],
        experienceLevel: 'Intermediate',
        postedDate: now.subtract(const Duration(hours: 18)),
        proposalCount: 14,
        duration: 'Less than 1 month',
        isSaved: false,
        status: 'open',
        isUserPosted: false,
      ),
    ];
  }
}
