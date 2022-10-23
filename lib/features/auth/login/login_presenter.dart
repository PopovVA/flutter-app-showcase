import 'package:bloc/bloc.dart';
import 'package:flutter_demo/core/utils/bloc_extensions.dart';
import 'package:flutter_demo/core/utils/either_extensions.dart';
import 'package:flutter_demo/features/auth/domain/use_cases/log_in_use_case.dart';
import 'package:flutter_demo/features/auth/login/login_navigator.dart';
import 'package:flutter_demo/features/auth/login/login_presentation_model.dart';
import 'package:flutter_demo/localization/app_localizations_utils.dart';

class LoginPresenter extends Cubit<LoginViewModel> {
  LoginPresenter(
    LoginPresentationModel super.model,
    this.navigator,
    this.logInUseCase,
  );

  final LoginNavigator navigator;
  final LogInUseCase logInUseCase;

  // ignore: unused_element
  LoginPresentationModel get _model => state as LoginPresentationModel;

  void onChangeUsername(String username) => emit(_model.copyWith(username: username));
  void onChangePassword(String password) => emit(_model.copyWith(password: password));

  Future<void> onLogin() => logInUseCase
      .execute(username: _model.username, password: _model.password)
      .observeStatusChanges(
        (result) => emit(_model.copyWith(logInResult: result)),
      )
      .asyncFold(
        (fail) => navigator.showError(fail.displayableFailure()),
        (success) => navigator.showAlert(
          title: appLocalizations.okAction,
          message: appLocalizations.successfulAuthorization,
        ),
      );
}
