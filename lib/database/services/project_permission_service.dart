import 'package:sollylabs_discover/database/models/project_permission.dart';
import 'package:sollylabs_discover/global/globals.dart';

class ProjectPermissionService {
  Future<List<ProjectPermission>> getProjectPermissions(String projectId) async {
    final response = await globals.supabaseClient.from('project_permissions').select().eq('project_id', projectId).order('created_at', ascending: false);
    List<ProjectPermission> projectPermissions = [];
    for (final projectPermission in response) {
      projectPermissions.add(ProjectPermission.fromJson(projectPermission));
    }
    return projectPermissions;
  }

  Future<ProjectPermission> getProjectPermission(String id) async {
    final response = await globals.supabaseClient.from('project_permissions').select().eq('id', id).single();
    return ProjectPermission.fromJson(response);
  }

  Future<ProjectPermission> createProjectPermission(ProjectPermission projectPermission) async {
    final response = await globals.supabaseClient.from('project_permissions').insert(projectPermission.toJson()).select();
    return ProjectPermission.fromJson(response[0]);
  }

  Future<ProjectPermission> updateProjectPermission(ProjectPermission projectPermission) async {
    final response = await globals.supabaseClient.from('project_permissions').update(projectPermission.toJson()).eq('id', projectPermission.id.uuid).select();
    return ProjectPermission.fromJson(response[0]);
  }

  Future<void> deleteProjectPermission(String id) async {
    await globals.supabaseClient.from('project_permissions').delete().eq('id', id);
  }

  Future<void> updateProjectPermissionRole(
    String projectPermissionId,
    String newRole,
  ) async {
    // Fetch the project permission
    final projectPermission = await getProjectPermission(projectPermissionId);

    // Fetch all project permissions with the 'owner' role for this project
    final allOwners = await getProjectPermissionsByRole(projectPermission.projectId.uuid, 'owner');

    // Prevent setting the last owner to another role
    if (allOwners.length == 1 && allOwners[0].id == projectPermission.id && newRole != 'owner') {
      throw Exception("Cannot remove the last owner of the project.");
    }

    // Update the project permission's role
    await globals.supabaseClient.from('project_permissions').update({'role': newRole}).eq('id', projectPermissionId).select();
  }

  Future<List<ProjectPermission>> getProjectPermissionsByRole(
    String projectId,
    String role,
  ) async {
    final response = await globals.supabaseClient.from('project_permissions').select().eq('project_id', projectId).eq('role', role);
    List<ProjectPermission> owners = [];
    for (final projectPermission in response) {
      owners.add(ProjectPermission.fromJson(projectPermission));
    }
    return owners;
  }
}
