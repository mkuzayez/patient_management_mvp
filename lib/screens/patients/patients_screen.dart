import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/blocs/patient/patient_bloc.dart';
import 'package:patient_management_app/blocs/patient/patient_event.dart';
import 'package:patient_management_app/blocs/patient/patient_state.dart';
import 'package:patient_management_app/screens/patients/add_edit_patient_screen.dart';
import 'package:patient_management_app/screens/patients/patient_detail_screen.dart';
import 'package:patient_management_app/widgets/patient_card.dart';
import 'package:throttling/throttling.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientBloc()..add(const PatientFetchAll()),
      child: const _PatientsScreenContent(),
    );
  }
}

class _PatientsScreenContent extends StatefulWidget {
  const _PatientsScreenContent();

  @override
  State<_PatientsScreenContent> createState() => _PatientsScreenContentState();
}

class _PatientsScreenContentState extends State<_PatientsScreenContent> {
  String _searchQuery = '';
  late Debouncing _debouncer;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncing(duration: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _debouncer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state.status == Status.failure && state.failure != null) {
            _showErrorSnackBar("خطأ بتحميل المرضى، يرجى المحاولة مجددًا");
            log(state.failure!.message);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'البحث عن مريض',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });

                    _debouncer.debounce(() {
                      if (value.isEmpty) {
                        context.read<PatientBloc>().add(const PatientFetchAll());
                      } else {
                        context.read<PatientBloc>().add(PatientSearch(value));
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<PatientBloc>().add(const PatientFetchAll());
                  },
                  child: Builder(
                    builder: (context) {
                      switch (state.status) {
                        case Status.loading:
                          return const Center(child: CircularProgressIndicator());

                        case Status.failure:
                          return SizedBox(
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Center(
                                  child: Text(
                                    "خطأ بالإتصال",
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Center(
                                  child: TextButton(
                                      onPressed: () {
                                        context.read<PatientBloc>().add(const PatientFetchAll());
                                      },
                                      child: const Text("المحاولة مجددًا")),
                                )
                              ],
                            ),
                          );

                        case Status.success:
                          if (state.patients.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: MediaQuery.sizeOf(context).height * 0.5,
                                  child: Center(
                                    child: Text(
                                      _searchQuery.isEmpty ? 'لا يوجد مرضى' : 'لا يوجد مرضى يطابقون "$_searchQuery"',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return ListView.builder(
                            itemCount: state.patients.length,
                            itemBuilder: (context, index) {
                              final patient = state.patients[index];
                              return PatientCard(
                                patient: patient,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PatientDetailScreen(patientId: patient.id!),
                                    ),
                                  ).then((_) {
                                    if (context.mounted) {
                                      context.read<PatientBloc>().add(const PatientFetchAll());
                                    }
                                  });
                                },
                              );
                            },
                          );

                        case Status.initial:
                          return const SizedBox(); // empty state or placeholder
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditPatientScreen(),
            ),
          ).then((_) {
            if (context.mounted) {
              context.read<PatientBloc>().add(const PatientFetchAll());
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
