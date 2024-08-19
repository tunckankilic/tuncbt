import 'package:get/get.dart';
import 'package:tuncbt/screens/bindings.dart';
import 'package:tuncbt/screens/screens.dart';

class AppRoutes {
  static final routes = [
    //Auth Pages
    GetPage(
      name: Login.routeName,
      page: () => Login(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: SignUp.routeName,
      page: () => SignUp(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: ForgetPasswordScreen.routeName,
      page: () => ForgetPasswordScreen(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: '/all-workers',
      page: () => AllWorkersScreen(),
      binding: AllWorkersBindings(),
    ),

    // Diğer sayfalar için de benzer şekilde tanımlayın
  ];
}
