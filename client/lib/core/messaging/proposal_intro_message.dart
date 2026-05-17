import 'dart:convert';

/// Rich proposal notification sent as a chat message (plain text + JSON footer).
class ProposalIntroMessage {
  ProposalIntroMessage._();

  static const marker = '[[PROLANCE_PROPOSAL_PAYLOAD]]';

  static Map<String, dynamic>? tryParsePayload(String body) {
    final i = body.indexOf(marker);
    if (i < 0) return null;
    final jsonPart = body.substring(i + marker.length).trim();
    try {
      final decoded = jsonDecode(jsonPart);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry('$k', v));
      }
    } catch (_) {}
    return null;
  }

  static String humanIntro(String body) {
    final i = body.indexOf(marker);
    if (i < 0) return body;
    return body.substring(0, i).trim();
  }

  static String compose({
    required String jobTitle,
    required String jobDescription,
    required String budgetLine,
    required String category,
    required String duration,
    required String skillsLine,
    required String pitch,
    required String profilePath,
    required String proposalId,
    required String jobId,
    required String freelancerId,
    required String freelancerName,
    required double bid,
  }) {
    final desc = jobDescription.length > 600
        ? '${jobDescription.substring(0, 600)}…'
        : jobDescription;
    final buf = StringBuffer()
      ..writeln('📋 $jobTitle')
      ..writeln()
      ..writeln('Category: $category')
      ..writeln('Budget: $budgetLine')
      ..writeln('Duration: $duration')
      ..writeln('Skills: $skillsLine')
      ..writeln()
      ..writeln('Details:')
      ..writeln(desc)
      ..writeln();
    if (pitch.trim().isNotEmpty) {
      buf
        ..writeln('My proposal:')
        ..writeln(pitch.trim())
        ..writeln();
    }
    buf
      ..writeln('—')
      ..writeln(
        'I submitted a proposal for this listing and believe I can deliver quality work on time.',
      )
      ..writeln()
      ..writeln('View my profile: $profilePath')
      ..writeln()
      ..writeln(
        'Use Accept or Decline below to respond to this proposal.',
      );

    final payload = <String, dynamic>{
      'v': 1,
      'proposalId': proposalId,
      'jobId': jobId,
      'freelancerId': freelancerId,
      'freelancerName': freelancerName,
      'bid': bid,
      'jobTitle': jobTitle,
    };

    return '${buf.toString().trim()}\n\n$marker\n${jsonEncode(payload)}';
  }
}
