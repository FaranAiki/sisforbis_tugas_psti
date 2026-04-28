import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalcTextField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CalcTextField({
    super.key,
    required this.controller,
    this.decoration = const InputDecoration(),
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.onChanged,
    this.validator,
  });

  @override
  State<CalcTextField> createState() => _CalcTextFieldState();
}

class _CalcTextFieldState extends State<CalcTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _evaluateExpression();
    }
  }

  void _evaluateExpression() {
    String input = widget.controller.text.trim();
    if (input.isEmpty) return;

    try {
      // Replace comma with dot for evaluation if needed
      input = input.replaceAll(',', '.');
      
      Parser p = Parser();
      Expression exp = p.parse(input);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // If it's a whole number, show it without decimals
      String result;
      if (eval == eval.toInt()) {
        result = eval.toInt().toString();
      } else {
        result = eval.toStringAsFixed(2);
        // Remove trailing zeros
        if (result.contains('.')) {
          result = result.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
        }
      }

      if (result != input) {
        setState(() {
          widget.controller.text = result;
          if (widget.onChanged != null) {
            widget.onChanged!(result);
          }
        });
      }
    } catch (e) {
      // If parsing fails, just keep the original text
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: widget.decoration.copyWith(
        suffixIcon: const Icon(Icons.calculate_outlined, size: 16),
      ),
      keyboardType: widget.keyboardType,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      validator: widget.validator,
      onFieldSubmitted: (_) => _evaluateExpression(),
    );
  }
}
