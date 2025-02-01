import 'package:sollylabs_discover/src/features/people/data/people_remote_data_source.dart';
import 'package:sollylabs_discover/src/features/people/models/people_profile.dart';

class PeopleService {
  final PeopleRemoteDataSource _remoteDataSource;

  PeopleService({required PeopleRemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  Future<List<PeopleProfile>> getCommunityProfiles({
    required String currentUserId,
    String? searchQuery,
    int? limit,
    int offset = 0,
  }) async {
    return await _remoteDataSource.getCommunityProfiles(
      currentUserId: currentUserId,
      searchQuery: searchQuery,
      limit: limit,
      offset: offset,
    );
  }
}

// import 'package:sollylabs_discover/src/core/config/supabase_client.dart';
// import 'package:sollylabs_discover/src/features/people/models/people_profile.dart';
//
// class PeopleService {
//   /// ✅ Fetch profiles from `community` view
//   Future<List<PeopleProfile>> getCommunityProfiles({
//     required String currentUserId,
//     String? searchQuery,
//     int? limit,
//     int offset = 0,
//   }) async {
//     var query = supabase.from('community').select('user_id, email, display_id, full_name, avatar_url, website, updated_at, is_connected, is_blocked, is_blocked_by').neq('user_id', currentUserId); // Exclude the current user
//
//     // Apply search if provided (Temporary: ilike-based, FTS will be added later)
//     if (searchQuery != null && searchQuery.isNotEmpty) {
//       query = query.or('email.ilike.%$searchQuery%,display_id.ilike.%$searchQuery%,website.ilike.%$searchQuery%');
//     }
//
//     // Apply pagination if a limit is specified
//     final response = limit != null ? await query.range(offset, offset + limit - 1) : await query;
//
//     return response.map<PeopleProfile>((data) => PeopleProfile.fromJson(data)).toList();
//   }
// }
