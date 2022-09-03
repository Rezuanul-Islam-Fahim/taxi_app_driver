import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _loggedUser;

  User? get loggedUser => _loggedUser;

  void setUser(User user) {
    print(user.toMap());
    _loggedUser = user;
  }
}
