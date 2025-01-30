import 'package:sollylabs_discover/database/services/connection_service.dart';
import 'package:sollylabs_discover/database/services/invitation_service.dart';
import 'package:sollylabs_discover/database/services/message_service.dart';
import 'package:sollylabs_discover/database/services/profile_service.dart';
import 'package:sollylabs_discover/database/services/project_permission_service.dart';
import 'package:sollylabs_discover/database/services/project_service.dart';

class Database {
  final ProjectService projectService;
  final ProjectPermissionService projectPermissionService;
  final ProfileService profileService;
  final InvitationService invitationService;
  final ConnectionService connectionService;
  final MessageService messageService;

  Database({
    required this.projectService,
    required this.projectPermissionService,
    required this.profileService, // Ensure ProfileService is included
    required this.invitationService,
    required this.connectionService,
    required this.messageService,
  });
}

// import 'package:sollylabs_discover/database/services/invitation_service.dart';
// import 'package:sollylabs_discover/database/services/profile_service.dart';
// import 'package:sollylabs_discover/database/services/project_permission_service.dart';
// import 'package:sollylabs_discover/database/services/project_service.dart';
//
// class Database {
//   final ProjectService projectService;
//   final ProjectPermissionService projectPermissionService;
//   final ProfileService profileService;
//   final InvitationService invitationService;
//
//   Database({
//     required this.projectService,
//     required this.projectPermissionService,
//     required this.profileService,
//     required this.invitationService,
//   });
// }
