import 'package:flutter/foundation.dart';

/// When opening the Jobs tab from Home "See All", apply a preset list filter.
enum JobsSeeAllMode {
  recommended,
  recent,
}

/// Controls bottom-tab index and one-shot Jobs list mode from Home.
class MainNavController extends ChangeNotifier {
  int _tabIndex = 0;

  /// When non-null, [JobsScreen] applies this filter until cleared or tab leaves Jobs.
  JobsSeeAllMode? _jobsSeeAllMode;

  int get tabIndex => _tabIndex;

  JobsSeeAllMode? get jobsSeeAllMode => _jobsSeeAllMode;

  void selectTab(int index) {
    _tabIndex = index;
    if (index != 1) {
      _jobsSeeAllMode = null;
    }
    notifyListeners();
  }

  /// Opens Jobs tab from Home with a preset row ("Recommended" / "Recent").
  void openJobsFromHome(JobsSeeAllMode mode) {
    _jobsSeeAllMode = mode;
    _tabIndex = 1;
    notifyListeners();
  }

  void clearJobsSeeAllMode() {
    _jobsSeeAllMode = null;
    notifyListeners();
  }
}
