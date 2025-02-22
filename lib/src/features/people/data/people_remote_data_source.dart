import 'package:sollylabs_discover/src/core/config/supabase_client.dart';
import 'package:sollylabs_discover/src/features/people/models/people_profile.dart';

class PeopleRemoteDataSource {
  /// Fetch profiles from `community` view
  Future<List<PeopleProfile>> getCommunityProfiles({
    required String currentUserId,
    String? searchQuery,
    int? limit,
    int offset = 0,
  }) async {
    var query = supabase.from('community').select('user_id, email, display_id, full_name, avatar_url, website, updated_at, is_connected, is_blocked, is_blocked_by').neq('user_id', currentUserId); // Exclude the current user

    // Apply search filter if provided
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('email.ilike.%$searchQuery%,display_id.ilike.%$searchQuery%,website.ilike.%$searchQuery%');
    }

    // Apply pagination if a limit is specified
    final response = limit != null ? await query.range(offset, offset + limit - 1) : await query;

    return response.map<PeopleProfile>((data) => PeopleProfile.fromJson(data)).toList();
  }
}
