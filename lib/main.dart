import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_management_app/config/router.dart';
import 'package:patient_management_app/screens/authentication/login_screen.dart';
import 'package:patient_management_app/utils/bloc_observer.dart';
import 'package:patient_management_app/utils/cache_manager.dart';
import 'package:patient_management_app/utils/shared_prefrences_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ShPH.init();
  AppBlocObserver();
  CacheManager();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
home: LoginScreen(),
      title: 'Patient Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, surface: Colors.white),
        textTheme: GoogleFonts.cairoTextTheme(),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
      // routerConfig: AppRouter.router,
    );
  }
}
