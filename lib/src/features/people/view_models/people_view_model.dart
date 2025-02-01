import 'package:flutter/material.dart';
import 'package:sollylabs_discover/src/features/network/services/network_service.dart';
import 'package:sollylabs_discover/src/features/people/models/people_profile.dart';
import 'package:sollylabs_discover/src/features/people/repositories/people_repository.dart';

class PeopleViewModel extends ChangeNotifier {
  final PeopleRepository _peopleRepository;
  final NetworkService _networkService;

  PeopleViewModel({
    required PeopleRepository peopleRepository,
    required NetworkService networkService,
  })  : _peopleRepository = peopleRepository,
        _networkService = networkService;

  List<PeopleProfile> _profiles = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _limit = 5;
  int _offset = 0;

  List<PeopleProfile> get profiles => _profiles;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> fetchProfiles({
    required String currentUserId,
    String? searchQuery,
    bool isLoadMore = false,
  }) async {
    if (isLoadMore && !_hasMore) return;

    if (!isLoadMore) _offset = 0;

    _isLoading = true;
    notifyListeners();

    try {
      final newProfiles = await _peopleRepository.getPeopleProfiles(
        currentUserId: currentUserId,
        searchQuery: searchQuery,
        limit: _limit,
        offset: _offset,
      );

      if (isLoadMore) {
        _profiles.addAll(newProfiles);
      } else {
        _profiles = newProfiles;
      }

      _offset += _limit;
      _hasMore = newProfiles.length == _limit;
    } catch (e) {
      debugPrint("Error fetching profiles: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Send Connection Request
  Future<void> sendConnectionRequest({
    required BuildContext context,
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      await _networkService.addConnection(currentUserId, targetUserId);

      // ✅ Refresh profiles to reflect connection change
      await fetchProfiles(currentUserId: currentUserId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection Added!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending request: $e')),
      );
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:sollylabs_discover/src/features/people/models/people_profile.dart';
// import 'package:sollylabs_discover/src/features/people/repositories/people_repository.dart';
//
// class PeopleViewModel extends ChangeNotifier {
//   final PeopleRepository _peopleRepository;
//
//   PeopleViewModel({required PeopleRepository peopleRepository}) : _peopleRepository = peopleRepository;
//
//   List<PeopleProfile> _profiles = [];
//   bool _isLoading = false;
//   bool _hasMore = true;
//   int _limit = 5;
//   int _offset = 0;
//
//   List<PeopleProfile> get profiles => _profiles;
//   bool get isLoading => _isLoading;
//   bool get hasMore => _hasMore;
//
//   Future<void> fetchProfiles({
//     required String currentUserId,
//     String? searchQuery,
//     bool isLoadMore = false,
//   }) async {
//     if (isLoadMore && !_hasMore) return;
//
//     if (!isLoadMore) _offset = 0;
//
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final newProfiles = await _peopleRepository.getPeopleProfiles(
//         currentUserId: currentUserId,
//         searchQuery: searchQuery,
//         limit: _limit,
//         offset: _offset,
//       );
//
//       if (isLoadMore) {
//         _profiles.addAll(newProfiles);
//       } else {
//         _profiles = newProfiles;
//       }
//
//       _offset += _limit;
//       _hasMore = newProfiles.length == _limit;
//     } catch (e) {
//       debugPrint("Error fetching profiles: $e");
//     }
//
//     _isLoading = false;
//     notifyListeners();
//   }
// }
