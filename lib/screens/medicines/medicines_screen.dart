import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/blocs/medicine/medicine_bloc.dart';
import 'package:patient_management_app/blocs/medicine/medicine_event.dart';
import 'package:patient_management_app/blocs/medicine/medicine_state.dart';
import 'package:patient_management_app/screens/medicines/add_edit_medicine_screen.dart';
import 'package:patient_management_app/widgets/medicine_card.dart';

class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicineBloc()..add(const MedicineFetchAll()),
      child: const _MedicinesScreenContent(),
    );
  }
}

class _MedicinesScreenContent extends StatefulWidget {
  const _MedicinesScreenContent();

  @override
  State<_MedicinesScreenContent> createState() => _MedicinesScreenContentState();
}

class _MedicinesScreenContentState extends State<_MedicinesScreenContent> {
  String _searchQuery = '';

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MedicineBloc, MedicineState>(
        listener: (context, state) {
          if (state.status == Status.failure && state.failure != null) {
            _showErrorSnackBar(state.failure!.message);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'البحث عن الدواء',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    if (value.isEmpty) {
                      context.read<MedicineBloc>().add(const MedicineFetchAll());
                    } else {
                      context.read<MedicineBloc>().add(MedicineSearch(value));
                    }
                  },
                ),
              ),
              Expanded(
                child: state.status == Status.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.medicines.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty ? 'لم يتم العثور على أي أدوية' : 'لا توجد أدوية تطابق "$_searchQuery"',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context.read<MedicineBloc>().add(const MedicineFetchAll());
                            },
                            child: ListView.builder(
                              itemCount: state.medicines.length,
                              itemBuilder: (context, index) {
                                final medicine = state.medicines[index];
                                return MedicineCard(
                                  medicine: medicine,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddEditMedicineScreen(medicine: medicine),
                                      ),
                                    ).then((_) {
                                      if (context.mounted) context.read<MedicineBloc>().add(const MedicineFetchAll());
                                    });
                                  },
                                );
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
              builder: (context) => const AddEditMedicineScreen(),
            ),
          ).then((_) {
            if (context.mounted) context.read<MedicineBloc>().add(const MedicineFetchAll());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
