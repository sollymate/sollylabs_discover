import 'package:sollylabs_discover/database/services/profile_service.dart';

import 'services/community_service.dart';
import 'services/network_service.dart';

class Database {
  final ProfileService profileService;
  // final ConnectionService connectionService;
  final CommunityService communityService;
  final NetworkService networkService; // ✅ Add NetworkService

  Database({
    required this.profileService,
    // required this.connectionService,
    required this.communityService,
    required this.networkService, // ✅ Initialize in constructor
  });
}
