# Integration / E2E

Flutter treats the `integration_test/` directory as **device integration tests** (`flutter drive`).

For CI-friendly smoke coverage, see:

- [`test/widget_test.dart`](../test/widget_test.dart)
- [`test/smoke/app_smoke_test.dart`](../test/smoke/app_smoke_test.dart)

To run on a simulator later:

```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/legacy_placeholder.dart
```

(Generate `test_driver/` when you add full E2E.)
