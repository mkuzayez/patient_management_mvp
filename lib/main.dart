import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/patient/patient_bloc.dart';
import 'package:patient_management_app/blocs/medicine/medicine_bloc.dart';
import 'package:patient_management_app/blocs/record/record_bloc.dart';
import 'package:patient_management_app/config/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PatientBloc>(
          create: (context) => PatientBloc(),
        ),
        BlocProvider<MedicineBloc>(
          create: (context) => MedicineBloc(),
        ),
        BlocProvider<RecordBloc>(
          create: (context) => RecordBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Patient Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
