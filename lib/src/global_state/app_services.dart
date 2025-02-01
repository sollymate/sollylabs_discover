import 'package:sollylabs_discover/src/features/network/services/network_service.dart';
import 'package:sollylabs_discover/src/features/people/services/people_service.dart';
import 'package:sollylabs_discover/src/features/profile/services/user_service.dart';

class AppServices {
  final UserService userService;
  final PeopleService peopleService;
  final NetworkService networkService; // ✅ Add NetworkService

  AppServices({
    required this.userService,
    required this.peopleService,
    required this.networkService, // ✅ Initialize in constructor
  });
}
