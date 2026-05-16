/// Normalizes project-style year/month/day input (30-day months, 12-month years).
/// Constraints: years 0–10 before carry; months 0–12; days 0–30 before carry.
/// After carry, years are capped at 10 (overflow months/days are discarded).
class ProjectDurationYmd {
  const ProjectDurationYmd(this.years, this.months, this.days);

  final int years;
  final int months;
  final int days;

  /// Clamp inputs, then carry days→months (30 per month) and months→years (12 per year).
  static ProjectDurationYmd normalize(int y, int m, int d) {
    var yy = y.clamp(0, 10);
    var mm = m.clamp(0, 12);
    var dd = d.clamp(0, 30);

    mm += dd ~/ 30;
    dd %= 30;

    yy += mm ~/ 12;
    mm %= 12;

    if (yy > 10) {
      yy = 10;
    }

    return ProjectDurationYmd(yy, mm, dd);
  }

  bool get isPositive => years > 0 || months > 0 || days > 0;

  String formatVerbose() {
    final parts = <String>[];
    if (years > 0) parts.add('$years ${years == 1 ? 'year' : 'years'}');
    if (months > 0) parts.add('$months ${months == 1 ? 'month' : 'months'}');
    if (days > 0) parts.add('$days ${days == 1 ? 'day' : 'days'}');
    if (parts.isEmpty) return '0 days';
    return parts.join(', ');
  }

  /// Rough total for legacy APIs (30-day month).
  int get approximateTotalDays => years * 365 + months * 30 + days;
}
