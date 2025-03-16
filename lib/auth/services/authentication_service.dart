
import 'package:auth0_flutter/auth0_flutter.dart';

abstract class AuthenticationService<T> {
  Auth0 auth0 = Auth0(
    'dev-dq35jgmk2wftplfm.us.auth0.com', //auth0 domain
    'Dpv1brt1vS9MaJmHW1buVmuzXYr2Cjhs',
  );

  Future<T> signIn();

  Future<void> signOut();
}