import 'package:sollylabs_discover/database/services/connection_service.dart';
import 'package:sollylabs_discover/database/services/invitation_service.dart';
import 'package:sollylabs_discover/database/services/message_service.dart';
import 'package:sollylabs_discover/database/services/profile_service.dart';
import 'package:sollylabs_discover/database/services/project_permission_service.dart';
import 'package:sollylabs_discover/database/services/project_service.dart';

import 'services/community_service.dart';
import 'services/network_service.dart';

class Database {
  final ProjectService projectService;
  final ProjectPermissionService projectPermissionService;
  final ProfileService profileService;
  final InvitationService invitationService;
  final ConnectionService connectionService;
  final MessageService messageService;
  final CommunityService communityService;
  final NetworkService networkService; // ✅ Add NetworkService

  Database({
    required this.projectService,
    required this.projectPermissionService,
    required this.profileService,
    required this.invitationService,
    required this.connectionService,
    required this.messageService,
    required this.communityService,
    required this.networkService, // ✅ Initialize in constructor
  });
}
