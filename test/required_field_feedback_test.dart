import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/core/utility/widgets/custom_textformfield.dart';
import 'package:solufine/core/utility/widgets/custom_dropdown.dart';

void main() {
  testWidgets(
    'required text field supports validation focus and a green valid border',
    (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();
      final key = GlobalKey<FormFieldState>();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => CustomTextFormField(
                controller: controller,
                fieldKey: key,
                focusNode: focus,
                hintText: 'Name',
                prefixIcon: Icons.person,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
                isValid: controller.text.trim().isNotEmpty,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
        ),
      );
      expect(key.currentState!.validate(), isFalse);
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      await tester.enterText(find.byType(TextFormField), 'Farmer');
      expect(key.currentState!.validate(), isTrue);
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(
        field.decoration!.enabledBorder!.borderSide.color,
        const Color(0xFF087C3A),
      );
    },
  );

  testWidgets(
    'selected dropdown supports a field key, focus and green border',
    (tester) async {
      final focus = FocusNode();
      final key = GlobalKey<FormFieldState>();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown<String>(
              fieldKey: key,
              focusNode: focus,
              isValid: true,
              hintText: 'State',
              prefixIcon: Icons.map,
              value: '1',
              items: const [DropdownMenuItem(value: '1', child: Text('State'))],
              onChanged: (_) {},
              validator: (value) => value == null ? 'Required' : null,
            ),
          ),
        ),
      );
      expect(key.currentState!.validate(), isTrue);
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      final decoration = tester.widget<InputDecorator>(
        find.byType(InputDecorator),
      );
      expect(
        decoration.decoration.enabledBorder!.borderSide.color,
        const Color(0xFF087C3A),
      );
    },
  );
}
