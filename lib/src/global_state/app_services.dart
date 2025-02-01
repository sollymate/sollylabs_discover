import 'package:sollylabs_discover/src/features/network/services/network_service.dart';
import 'package:sollylabs_discover/src/features/people/data/people_remote_data_source.dart';
import 'package:sollylabs_discover/src/features/people/repositories/people_repository.dart';
import 'package:sollylabs_discover/src/features/people/services/people_service.dart';
import 'package:sollylabs_discover/src/features/profile/services/user_service.dart';

class AppServices {
  final UserService userService;
  final PeopleService peopleService;
  final PeopleRepository peopleRepository;

  final NetworkService networkService;

  AppServices({
    required this.userService,
    required this.peopleService,
    required this.peopleRepository,
    required this.networkService,
  });

  /// Factory constructor for easy initialization
  factory AppServices.create() {
    final peopleRemoteDataSource = PeopleRemoteDataSource();
    final peopleService = PeopleService(remoteDataSource: peopleRemoteDataSource);
    final peopleRepository = PeopleRepository(peopleService: peopleService);

    return AppServices(
      userService: UserService(),
      peopleService: peopleService,
      peopleRepository: peopleRepository,
      networkService: NetworkService(),
    );
  }
}
