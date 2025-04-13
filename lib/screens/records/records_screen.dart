import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/blocs/record/record_bloc.dart';
import 'package:patient_management_app/blocs/record/record_event.dart';
import 'package:patient_management_app/blocs/record/record_state.dart';
import 'package:patient_management_app/screens/records/add_record_screen.dart';
import 'package:patient_management_app/screens/records/record_detail_screen.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecordBloc()..add(const RecordFetchAll()),
      child: const _RecordsScreenContent(),
    );
  }
}

class _RecordsScreenContent extends StatefulWidget {
  const _RecordsScreenContent();

  @override
  State<_RecordsScreenContent> createState() => _RecordsScreenContentState();
}

class _RecordsScreenContentState extends State<_RecordsScreenContent> {
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
      body: BlocConsumer<RecordBloc, RecordState>(
        listener: (context, state) {
          if (state.status == Status.failure && state.failure != null) {
            _showErrorSnackBar(state.failure!.message);
          }
        },
        builder: (context, state) {
          final isLoading = state.status == Status.loading;
          final records = state.records;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لم يتم العثور على سجلات طبية'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddRecordScreen(),
                        ),
                      ).then((_) {
                        if(context.mounted) context.read<RecordBloc>().add(const RecordFetchAll());
                      });
                    },
                    child: const Text('إضافة سجل جديد'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<RecordBloc>().add(const RecordFetchAll());
            },
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('معرّف المريض: ${record.patientId}'),
                    subtitle: Text(
                      'التاريخ: ${record.issuedDate} • الطبيب: ${record.doctorSpecialization}',
                    ),
                    trailing: Text('الأدوية: ${record.totalGivenMedicines}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecordDetailScreen(recordId: record.id!),
                        ),
                      ).then((_) {
                        if(context.mounted) context.read<RecordBloc>().add(const RecordFetchAll());
                      });
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRecordScreen(),
            ),
          ).then((_) {
            if(context.mounted)  context.read<RecordBloc>().add(const RecordFetchAll());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
