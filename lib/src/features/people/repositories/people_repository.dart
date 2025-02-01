import 'package:sollylabs_discover/src/features/people/models/people_profile.dart';
import 'package:sollylabs_discover/src/features/people/services/people_service.dart';

class PeopleRepository {
  final PeopleService _peopleService;

  PeopleRepository({required PeopleService peopleService}) : _peopleService = peopleService;

  /// Fetch community profiles using `PeopleService`
  Future<List<PeopleProfile>> getPeopleProfiles({
    required String currentUserId,
    String? searchQuery,
    int? limit,
    int offset = 0,
  }) async {
    return await _peopleService.getCommunityProfiles(
      currentUserId: currentUserId,
      searchQuery: searchQuery,
      limit: limit,
      offset: offset,
    );
  }
}
