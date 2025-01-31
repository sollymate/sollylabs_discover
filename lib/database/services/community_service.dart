import 'package:sollylabs_discover/database/models/community_profile.dart';
import 'package:sollylabs_discover/global/globals.dart';

class CommunityService {
  /// ✅ Fetch profiles from `community` view
  Future<List<CommunityProfile>> getCommunityProfiles({
    required String currentUserId,
    String? searchQuery,
    int? limit,
    int offset = 0,
  }) async {
    var query = globals.supabaseClient.from('community').select('user_id, email, display_id, full_name, avatar_url, website, updated_at, is_connected, is_blocked, is_blocked_by').neq('user_id', currentUserId); // Exclude the current user

    // Apply search if provided (Temporary: ilike-based, FTS will be added later)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('email.ilike.%$searchQuery%,display_id.ilike.%$searchQuery%,website.ilike.%$searchQuery%');
    }

    // Apply pagination if a limit is specified
    final response = limit != null ? await query.range(offset, offset + limit - 1) : await query;

    return response.map<CommunityProfile>((data) => CommunityProfile.fromJson(data)).toList();
  }
}
