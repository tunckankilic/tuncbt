import 'package:get/get.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/view/screens/users/users_repository.dart';

class UserController extends GetxController {
  final UserRepository _userRepository;
  final RxList<UserModel> users = <UserModel>[].obs;
  final Rx<UserModel> currentUser = UserModel.empty().obs;

  UserController(this._userRepository);

  @override
  void onInit() {
    super.onInit();
    getAllUsers();
  }

  void getAllUsers() {
    _userRepository.getAllUsers().listen(
      (usersList) {
        users.assignAll(usersList);
      },
      onError: (error) {
        print('Error fetching users: $error');
      },
    );
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _userRepository.updateUser(user);
      int index = users.indexWhere((element) => element.id == user.id);
      if (index != -1) {
        users[index] = user;
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }
}
