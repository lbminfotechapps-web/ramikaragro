import 'dart:async';

import 'package:demo/features/collection/data/models/dealer_model.dart';
import 'package:demo/features/collection/domain/entities/dealer.dart';
import 'package:demo/features/collection/presentation/bloc/collection_bloc.dart';
import 'package:demo/features/collection/presentation/bloc/collection_event.dart';
import 'package:demo/features/collection/presentation/bloc/collection_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DealerSearchBottomSheet extends StatefulWidget {
  final String userId;

  const DealerSearchBottomSheet({
    super.key,
    required this.userId,
  });

  @override
  State<DealerSearchBottomSheet> createState() =>
      _DealerSearchBottomSheetState();
}

class _DealerSearchBottomSheetState
    extends State<DealerSearchBottomSheet> {
  final TextEditingController searchController =
      TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // Load dealers when bottom sheet opens.
    _searchDealer('');
  }

  // ============================================================
  // SEARCH DEALER
  // ============================================================

  void _searchDealer(String searchText) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () {
        if (!mounted) return;

        debugPrint('=========================================');
        debugPrint('COLLECTION BLOC: SEARCH DEALER');
        debugPrint('USER ID: ${widget.userId}');
        debugPrint('SEARCH TEXT: ${searchText.trim()}');
        debugPrint('=========================================');

        context.read<CollectionBloc>().add(
              SearchDealerEvent(
                userId: widget.userId,
                searchText: searchText.trim(),
              ),
            );
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // ====================================================
            // HANDLE
            // ====================================================

            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 4,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 14),

            // ====================================================
            // HEADER
            // ====================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF6EE),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFF166534),
                    ),
                  ),

                  const SizedBox(width: 11),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Dealer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Search and select a dealer',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ====================================================
            // SEARCH FIELD
            // ====================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: TextField(
                controller: searchController,

                onChanged: (value) {
                  setState(() {});

                  _searchDealer(value);
                },

                decoration: InputDecoration(
                  hintText: 'Search dealer...',

                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF166534),
                  ),

                  suffixIcon:
                      searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                searchController.clear();

                                setState(() {});

                                _searchDealer('');
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                              ),
                            )
                          : null,

                  filled: true,

                  fillColor: const Color(0xFFF5F7F6),

                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE1E7E3),
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF166534),
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ====================================================
            // DEALER LIST
            // ====================================================

            Expanded(
              child: BlocBuilder<
                  CollectionBloc,
                  CollectionState>(
                builder: (context, state) {
                  // ----------------------------------------------
                  // LOADING
                  // ----------------------------------------------

                  if (state.dealerLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF166534),
                      ),
                    );
                  }

                  // ----------------------------------------------
                  // ERROR
                  // ----------------------------------------------

                  if (state.dealerError != null &&
                      state.dealerError!.isNotEmpty) {
                    return _errorState(
                      state.dealerError!,
                    );
                  }

                  // ----------------------------------------------
                  // EMPTY
                  // ----------------------------------------------

                  if (state.dealers.isEmpty) {
                    return _emptyState();
                  }

                  // ----------------------------------------------
                  // LIST
                  // ----------------------------------------------

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      20,
                    ),
                    itemCount: state.dealers.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final dealer =
                          state.dealers[index];

                      return _dealerTile(dealer);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DEALER TILE
  // ============================================================

  Widget _dealerTile(DealerModel dealer) {
    return InkWell(
      onTap: () {
        // ======================================================
        // IMPORTANT
        //
        // BottomSheet expects Dealer
        // API gives DealerModel
        //
        // So convert DealerModel -> Dealer
        // ======================================================

        final Dealer selectedDealer = Dealer(
          id: dealer.id,
          name: dealer.name,
          mobile: dealer.mobile,
          address: dealer.address,
        );

        debugPrint(
          '=========================================',
        );
        debugPrint('DEALER SELECTED');
        debugPrint('ID: ${selectedDealer.id}');
        debugPrint('NAME: ${selectedDealer.name}');
        debugPrint('MOBILE: ${selectedDealer.mobile}');
        debugPrint('ADDRESS: ${selectedDealer.address}');
        debugPrint(
          '=========================================',
        );

        // ======================================================
        // RETURN Dealer
        // NOT DealerModel
        // ======================================================

        Navigator.of(context).pop<Dealer>(
          selectedDealer,
        );
      },

      borderRadius: BorderRadius.circular(15),

      child: Container(
        padding: const EdgeInsets.all(13),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: const Color(0xFFE3E9E5),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.03,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [
            // ==================================================
            // ICON
            // ==================================================

            Container(
              height: 44,
              width: 44,

              decoration: BoxDecoration(
                color: const Color(0xFFEAF6EE),
                borderRadius: BorderRadius.circular(13),
              ),

              child: const Icon(
                Icons.store_rounded,
                color: Color(0xFF166534),
              ),
            ),

            const SizedBox(width: 11),

            // ==================================================
            // DEALER DETAILS
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    dealer.name.isEmpty
                        ? 'Unnamed dealer'
                        : dealer.name,

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  if (dealer.mobile.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 13,
                          color: Colors.black45,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            dealer.mobile,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (dealer.address.isNotEmpty) ...[
                    const SizedBox(height: 3),

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Colors.black38,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            dealer.address,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              height: 62,
              width: 62,

              decoration: const BoxDecoration(
                color: Color(0xFFEAF6EE),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.store_mall_directory_outlined,
                size: 30,
                color: Color(0xFF166534),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'No dealers found',

              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Try another dealer name',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              height: 62,
              width: 62,

              decoration: const BoxDecoration(
                color: Color(0xFFFFF1F2),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.error_outline_rounded,
                size: 30,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load dealers',

              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              message,

              textAlign: TextAlign.center,

              maxLines: 3,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                fontSize: 11,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {
                _searchDealer(
                  searchController.text.trim(),
                );
              },

              icon: const Icon(
                Icons.refresh_rounded,
              ),

              label: const Text(
                'Retry',
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF166534),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}