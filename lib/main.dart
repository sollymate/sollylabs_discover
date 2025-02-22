import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/src/core/authentication/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/core/config/supabase_setup.dart';
import 'src/core/navigation/app_router.dart';
import 'src/features/network/services/network_service.dart';
import 'src/features/people/data/people_remote_data_source.dart';
import 'src/features/people/repositories/people_repository.dart';
import 'src/features/people/services/people_service.dart';
import 'src/features/people/view_models/people_view_model.dart';
import 'src/features/profile/services/user_service.dart';
import 'src/global_state/app_services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path-based URLs for web (remove the #)
  usePathUrlStrategy();

  await SupabaseSetup.initialize();

  final peopleRemoteDataSource = PeopleRemoteDataSource();

  // Initialize Services
  final peopleService = PeopleService(remoteDataSource: peopleRemoteDataSource);
  final userService = UserService();
  final networkService = NetworkService();

  // Initialize Repository
  final peopleRepository = PeopleRepository(peopleService: peopleService);

  // Initialize AppServices
  final appServices = AppServices(userService: userService, peopleService: peopleService, peopleRepository: peopleRepository, networkService: networkService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService(Supabase.instance.client)),

        Provider<AppServices>(create: (_) => appServices),
        Provider<UserService>(create: (context) => context.read<AppServices>().userService),
        Provider<PeopleService>(create: (context) => context.read<AppServices>().peopleService),
        Provider<NetworkService>(create: (context) => context.read<AppServices>().networkService),
        Provider<PeopleRepository>(create: (context) => context.read<AppServices>().peopleRepository),
        ChangeNotifierProvider(create: (context) => PeopleViewModel(peopleRepository: context.read<AppServices>().peopleRepository, networkService: context.read<AppServices>().networkService)),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router, // ✅ Using GoRouter instead of routes
      title: 'Solly Labs',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
    // return MaterialApp(
    //   navigatorKey: navigatorKey,
    //   title: 'Solly Labs',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   routes: {
    //     '/': (context) => const AuthGate(),
    //     '/account': (context) => const UserPage(),
    //     '/update-password': (context) => const UpdatePasswordAfterResetPage(),
    //     '/dashboard': (context) => const DashboardPage(),
    //     '/update-password-in-app': (context) => const UpdatePasswordPage(),
    //     '/community': (context) => const PeoplePage(),
    //     '/network': (context) => const NetworkPage(),
    //   },
    //   initialRoute: '/',
    // );
  }
}

// await Supabase.initialize(
//   url: 'https://xxrsdsxpunwytsfizujp.supabase.co',
//   anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4cnNkc3hwdW53eXRzZml6dWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc0NTQ5NjgsImV4cCI6MjA1MzAzMDk2OH0.39sq7-uHSVPcKN6fzGzLOPt4pUXi3bnn-F-eT6UFLfw',
// ).then((_) {
//   // Handle redirect here after initialization
//   Supabase.instance.client.auth.onAuthStateChange.listen((data) {
//     final AuthChangeEvent event = data.event;
//     final Session? session = data.session;
//
//     if (kDebugMode) {
//       print("Auth Change Event: $event");
//       print('Session: ${session?.toJson()}');
//     }
//
//     if (event == AuthChangeEvent.signedIn) {
//       // Navigate to account page only if there is a session
//       if (session != null) {
//         if (kDebugMode) {
//           print("Navigating to /account");
//         }
//         navigatorKey.currentState?.pushReplacementNamed('/account');
//       }
//     }
//     // else if (event == AuthChangeEvent.passwordRecovery) {
//     //   // Navigate to update password page
//     //   if (kDebugMode) {
//     //     print("Navigating to /update-password");
//     //   }
//     //   navigatorKey.currentState?.pushReplacementNamed('/update-password');
//     // }
//   });
// });

// Initialize Remote Data Sources
