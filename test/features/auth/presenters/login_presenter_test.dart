import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_demo/core/domain/model/user.dart';
import 'package:flutter_demo/features/auth/domain/model/log_in_failure.dart';
import 'package:flutter_demo/features/auth/login/login_initial_params.dart';
import 'package:flutter_demo/features/auth/login/login_presentation_model.dart';
import 'package:flutter_demo/features/auth/login/login_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks/mocks.dart';
import '../../../test_utils/test_utils.dart';
import '../mocks/auth_mock_definitions.dart';
import '../mocks/auth_mocks.dart';

void main() {
  late LoginPresentationModel model;
  late LoginPresenter presenter;
  late MockLoginNavigator navigator;

  test(
    'should show error when LogInUseCase fails with missingCredentials',
    () async {
      // GIVEN
      whenListen(
        Mocks.userStore,
        Stream.fromIterable([const User.anonymous()]),
      );

      when(
        () => AuthMocks.logInUseCase.execute(username: '', password: ''),
      ).thenAnswer((_) => failFuture(const LogInFailure.missingCredentials()));
      when(() => navigator.showError(any())).thenAnswer((_) => Future.value());

      // WHEN
      await presenter.onLogin();

      // THEN
      verify(() => navigator.showError(any()));
    },
  );

  test(
    'should show error when LogInUseCase fails with unknown failure',
    () async {
      // GIVEN
      whenListen(
        Mocks.userStore,
        Stream.fromIterable([const User.anonymous()]),
      );

      when(
        () =>
            AuthMocks.logInUseCase.execute(username: 'test', password: 'test'),
      ).thenAnswer((_) => failFuture(const LogInFailure.unknown()));
      when(() => navigator.showError(any())).thenAnswer((_) => Future.value());

      // WHEN
      await presenter.onLogin();

      // THEN
      verify(() => navigator.showError(any()));
    },
  );

  test(
    'should show success alert when LogInUseCase succeeds',
    () async {
      // GIVEN
      when(
        () => AuthMocks.logInUseCase.execute(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => successFuture(const User.anonymous()));
      when(
        () => navigator.showAlert(
          title: any(named: 'title'),
          message: any(named: 'message'),
        ),
      ).thenAnswer((_) => Future.value());

      // WHEN
      await presenter.onLogin();

      // THEN
      verify(
        () => navigator.showAlert(
          title: any(named: 'title'),
          message: any(named: 'message'),
        ),
      );
    },
  );

  setUp(() {
    model = LoginPresentationModel.initial(const LoginInitialParams());
    navigator = MockLoginNavigator();
    presenter = LoginPresenter(
      model,
      navigator,
      AuthMocks.logInUseCase,
    );
  });
}
