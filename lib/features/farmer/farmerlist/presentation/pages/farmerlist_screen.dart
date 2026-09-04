import 'dart:async';

import 'package:demo/features/farmer/farmerlist/presentation/bloc/farmerlist_bloc.dart';
import 'package:demo/features/farmer/farmerlist/presentation/bloc/farmerlist_event.dart';
import 'package:demo/features/farmer/farmerlist/presentation/bloc/farmerlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:demo/features/farmer/farmerlist/data/model/farmerlist_model.dart';
import 'package:demo/features/farmer/farmerlist/domain/repository/farmerlist_repo.dart';
import 'package:demo/features/farmer/farmerlist/presentation/widgets/search_widget.dart';

class FarmerlistScreen extends StatefulWidget {
  const FarmerlistScreen({super.key});

  @override
  State<FarmerlistScreen> createState() => _FarmerlistScreenState();
}

class _FarmerlistScreenState extends State<FarmerlistScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadFarmers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFarmers() {
    context.read<FarmerListBloc>().add(
      const FarmerListEvent(
        user_id: 4,
        currentLat: '19.96778917556256',
        currentLong: '73.77769130315075',
        limit: 20,
        searchKey: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer List')),

      body: BlocBuilder<FarmerListBloc, FarmerListState>(
        builder: (context, state) {
          // LOADING
          if (state.status == FarmerlistStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // FAILURE
          if (state.status == FarmerlistStatus.failure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Something went wrong'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadFarmers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // EMPTY
          if (state.farmerList.isEmpty) {
            return const Center(child: Text('NO RECORDS FOUND'));
          }

          // SUCCESS
          return RefreshIndicator(
            onRefresh: () async {
              _loadFarmers();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.farmerList.length,
              itemBuilder: (context, index) {
                final farmer = state.farmerList[index];

                print(
                  'Displaying Farmer: '
                  '${farmer.farmerName}',
                );

                return _FarmerListItem(farmer: farmer);
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _loadFarmers,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _FarmerListItem extends StatelessWidget {
  final FarmerlistModel farmer;

  const _FarmerListItem({required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            farmer.farmerName.isEmpty
                ? '?'
                : farmer.farmerName[0].toUpperCase(),
          ),
        ),

        title: Text(
          farmer.farmerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Text(
          '${farmer.farmerPhone}\n'
          '${farmer.farmerAddress}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        isThreeLine: true,

        trailing: farmer.statusOfFarmer == null
            ? null
            : Text(
                farmer.statusOfFarmer!,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
      ),
    );
  }
}
