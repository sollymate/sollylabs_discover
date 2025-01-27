import 'package:sollylabs_discover/database/models/project.dart';
import 'package:sollylabs_discover/global/globals.dart';

class ProjectService {
  Future<List<Project>> getProjects() async {
    final response = await globals.supabaseClient.from('project_list').select().order('created_at', ascending: false);
    List<Project> projects = [];
    for (final project in response) {
      projects.add(Project.fromJson(project));
    }
    return projects;
  }

  Future<Project> getProject(String id) async {
    final response = await globals.supabaseClient.from('project_list').select().eq('id', id).single();
    return Project.fromJson(response);
  }

  Future<Project> createProject(Project project) async {
    final user = globals.supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final projectData = project.toJson();
    projectData['created_by'] = user.id;
    projectData['owner_id'] = user.id; // Set owner_id to current user's ID
    projectData.remove('id'); // Remove the ID from the JSON

    final response = await globals.supabaseClient.from('project_list').insert(projectData).select();

    return Project.fromJson(response[0]);
  }

  Future<Project> updateProject(Project project) async {
    final response = await globals.supabaseClient.from('project_list').update(project.toJson()).eq('id', project.id.uuid).select();
    return Project.fromJson(response[0]);
  }

  Future<void> deleteProject(String id) async {
    await globals.supabaseClient.from('project_list').delete().eq('id', id);
  }
}
