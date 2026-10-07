import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/auth/domain/usecases/login_usecase.dart';
import 'package:solufine/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:solufine/features/auth/presentation/pages/login_screen.dart';

class _UnusedLoginUsecase implements LoginUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'iPad login opens text input and transfers focus to password',
    (tester) async {
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bloc = AuthBloc(_UnusedLoginUsecase());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        ScreenUtilPlusInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp(
            home: BlocProvider.value(value: bloc, child: const LoginScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final username = find.byType(TextFormField).first;
      final password = find.byType(TextFormField).last;
      FocusNode focusOf(Finder field) => tester
          .widget<TextField>(
            find.descendant(of: field, matching: find.byType(TextField)),
          )
          .focusNode!;
      await tester.ensureVisible(username);
      await tester.tap(username);
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, isTrue);
      expect(focusOf(username).hasFocus, isTrue);

      await tester.enterText(username, 'employee');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(focusOf(password).hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.ensureVisible(password);
      await tester.tap(password);
      await tester.pumpAndSettle();
      await tester.enterText(password, 'password123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(focusOf(password).hasFocus, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
