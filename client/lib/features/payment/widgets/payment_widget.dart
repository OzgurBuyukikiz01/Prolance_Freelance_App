import 'package:flutter/material.dart';

/// Mock card capture — no PSP; collects a display label only.
class PaymentWidget extends StatefulWidget {
  const PaymentWidget({
    super.key,
    required this.onTokenLabel,
  });

  final ValueChanged<String> onTokenLabel;

  @override
  State<PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  final _last4 = TextEditingController(text: '4242');

  @override
  void dispose() {
    _last4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mock payment method',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _last4,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: 'Card last 4',
            counterText: '',
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () =>
              widget.onTokenLabel('tok_mock_${_last4.text.trim()}'),
          child: const Text('Tokenize (mock)'),
        ),
      ],
    );
  }
}
