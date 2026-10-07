import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:solufine/core/di/notification_di.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import '../../data/datasource/monthly_collection_remote_datasource.dart';


import '../bloc/dealer_bloc.dart';
import '../bloc/dealer_event.dart';
import '../bloc/dealer_state.dart';


import '../bloc/collection_type_bloc.dart';
import '../bloc/collection_type_event.dart';
import '../bloc/collection_type_state.dart';


import '../../domain/entities/collection_type_entity.dart';

class AssignSelfCollectionTargetPage extends StatefulWidget {
  const AssignSelfCollectionTargetPage({super.key});

  @override
  State<AssignSelfCollectionTargetPage> createState() =>
      _AssignSelfCollectionTargetPageState();
}

class _AssignSelfCollectionTargetPageState
    extends State<AssignSelfCollectionTargetPage> {


  late final DealerBloc _dealerBloc;
  late final CollectionTypeBloc _collectionTypeBloc;

 

  final Map<String, Map<String, String>> _targetValues = {};
  late final List<DateTime> _availableMonths;
  late String _selectedMonth;
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _monthValue(DateTime month) =>
      '${month.month.toString().padLeft(2, '0')}-${month.year}';


  int userId = 0;

  bool _isUserLoaded = false;
  bool _isSubmitting = false;



  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _availableMonths = [
      for (var month = now.month; month <= 12; month++)
        DateTime(now.year, month),
    ];
    _selectedMonth = _monthValue(_availableMonths.first);

    _dealerBloc = sl<DealerBloc>();

    _collectionTypeBloc = sl<CollectionTypeBloc>();


    _collectionTypeBloc.add(const GetCollectionTypeEvent());



    _loadUser();
  }

 

  Future<void> _loadUser() async {
    try {
      final userData = await SecureStorage.instance.getUserData();

      final int loadedUserId =
          int.tryParse(userData?['user_id']?.toString() ?? '') ?? 0;

      if (!mounted) {
        return;
      }

      setState(() {
        userId = loadedUserId;

        _isUserLoaded = true;
      });

      if (userId > 0) {
        _fetchDealerList();
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUserLoaded = true;
      });

      debugPrint('LOAD USER ERROR: $e');
    }
  }

  

  void _fetchDealerList() {
    if (userId <= 0) {
      return;
    }

    _dealerBloc.add(GetDealerListEvent(userId: userId));
  }


  Future<void> _refreshDealerList() async {
    if (userId <= 0) {
      return;
    }

    _dealerBloc.add(RefreshDealerListEvent(userId: userId));
  }



  Future<void> _refreshCollectionTypes() async {
    _collectionTypeBloc.add(const RefreshCollectionTypeEvent());
  }



  String _getTargetValue({
    required String dealerId,
    required String collectionTypeId,
  }) {
    return _targetValues[dealerId]?[collectionTypeId] ?? '';
  }



  void _setTargetValue({
    required String dealerId,
    required String collectionTypeId,
    required String value,
  }) {
    _targetValues.putIfAbsent(dealerId, () => <String, String>{});

    _targetValues[dealerId]![collectionTypeId] = value;
  }



  Future<void> _submitTargets() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    if (userId <= 0) {
      _showSubmitMessage('Please sign in before submitting targets.');
      return;
    }

    final collectionTypes = _collectionTypeBloc.state.collectionTypes;


    if (collectionTypes.isEmpty) {
      _showSubmitMessage('Collection types not available.');

      return;
    }

    final List<Map<String, dynamic>> targets = [];



    for (final dealer in _dealerBloc.state.dealers) {


      for (final collectionType in collectionTypes) {
        final String value = _getTargetValue(
          dealerId: dealer.outletId,
          collectionTypeId: collectionType.collectionTypeId,
        ).trim();

        // Skip empty value
        if (value.isEmpty) {
          continue;
        }

        final double? amount = double.tryParse(value);


        if (amount == null || !amount.isFinite) {
          _showSubmitMessage(
            'Enter valid ${collectionType.collectionType} '
            'target for ${dealer.outletName}.',
          );

          return;
        }


        targets.add({
          'fld_outlet_id': dealer.outletId,

          // Important
          'fld_collection_type_id': collectionType.collectionTypeId,

          'target': amount,
        });
      }
    }


    if (targets.isEmpty) {
      _showSubmitMessage('Enter targets for at least one dealer.');

      return;
    }



    setState(() => _isSubmitting = true);
    try {
      final message = await sl<MonthlyCollectionRemoteDataSource>().submit(
        userId: userId,
        monthYear: _selectedMonth,
        targets: targets,
      );
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
      if (!mounted) return;
      if (confirmed == true) context.go(AppRouter.home);
    } catch (e) {
      if (!mounted) return;
      _showSubmitMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

void _showSubmitMessage(String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
}



  @override
  void dispose() {
    _dealerBloc.close();

    _collectionTypeBloc.close();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [

        BlocProvider<DealerBloc>.value(value: _dealerBloc),

    
        BlocProvider<CollectionTypeBloc>.value(value: _collectionTypeBloc),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),

        appBar: AppBar(
          title: const Text(
            'Add Collectionwise Target',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          centerTitle: false,
          backgroundColor: const Color(0xFFF4F7F5),
          foregroundColor: const Color(0xFF183D30),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),

        bottomNavigationBar:
            BlocBuilder<CollectionTypeBloc, CollectionTypeState>(
              builder: (context, collectionState) {
                return BlocBuilder<DealerBloc, DealerState>(
                  builder: (context, dealerState) {
                    if (!_isUserLoaded ||
                        userId <= 0 ||
                        dealerState.status != DealerStatus.success ||
                        dealerState.dealers.isEmpty ||
                        collectionState.status !=
                            CollectionTypeStatus.success ||
                        collectionState.collectionTypes.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFE3EBE5)),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: FilledButton.icon(
                          onPressed: _isSubmitting ? null : _submitTargets,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline_rounded),
                          label: Text(
                            _isSubmitting ? 'Submitting…' : 'Submit Targets',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1E6046),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),


        body: !_isUserLoaded
            ? const Center(child: CircularProgressIndicator())
            : userId <= 0
            ? const Center(
                child: Text(
                  'User not found',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              )
            : BlocBuilder<CollectionTypeBloc, CollectionTypeState>(
                builder: (context, collectionState) {
        

                  if (collectionState.status == CollectionTypeStatus.loading ||
                      collectionState.status == CollectionTypeStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }

             

                  if (collectionState.status == CollectionTypeStatus.failure) {
                    return _ErrorView(
                      message: collectionState.message,
                      onRetry: () {
                        _collectionTypeBloc.add(const GetCollectionTypeEvent());
                      },
                    );
                  }


                  if (collectionState.collectionTypes.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshCollectionTypes,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 250),
                          Center(
                            child: Text(
                              'No collection type found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

  

                  return BlocBuilder<DealerBloc, DealerState>(
                    builder: (context, dealerState) {
    

                      if (dealerState.status == DealerStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }


                      if (dealerState.status == DealerStatus.failure) {
                        return _ErrorView(
                          message: dealerState.message,
                          onRetry: _fetchDealerList,
                        );
                      }

      

                      if (dealerState.dealers.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _refreshDealerList,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 250),
                              Center(
                                child: Text(
                                  'No dealer found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                    

                      return SafeArea(
                        top: false,
                        child: Column(
                          children: [
 
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF164C38),
                                    Color(0xFF287356),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.trending_up_rounded,
                                        color: Color(0xFFBCE8CA),
                                        size: 24,
                                      ),

                                      const SizedBox(width: 8),

                                      const Expanded(
                                        child: Text(
                                          'SELF COLLECTION',
                                          style: TextStyle(
                                            color: Color(0xFFBCE8CA),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.3,
                                          ),
                                        ),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF398363),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          '${dealerState.dealers.length} dealers',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                            

                                  const Text(
                                    'Plan your collection',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                    

                                  const Text(
                                    'Enter collection targets for each dealer below.',
                                    style: TextStyle(
                                      color: Color(0xFFD2E8DC),
                                      fontSize: 11,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                         
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedMonth,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Target month',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: _availableMonths.map((month) {
                                  return DropdownMenuItem<String>(
                                    value: _monthValue(month),
                                    child: Text(
                                      '${_monthNames[month.month - 1]} ${month.year}',
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _selectedMonth = value);
                                },
                              ),
                            ),

                          
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  var columnWidth = 140.0;
                                  for (final type
                                      in collectionState.collectionTypes) {
                                    final painter = TextPainter(
                                      text: TextSpan(
                                        text: '${type.collectionType} Target',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      textDirection: Directionality.of(context),
                                      textScaler: MediaQuery.textScalerOf(
                                        context,
                                      ),
                                      maxLines: 1,
                                    )..layout();
                                    final width = painter.width + 24;
                                    if (width > columnWidth) { columnWidth = width; }
                                    painter.dispose();
                                  }
                                  final minimumWidth =
                                      60 +
                                      columnWidth *
                                          (collectionState
                                                  .collectionTypes
                                                  .length +
                                              4 / 3);
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: minimumWidth > constraints.maxWidth
                                          ? minimumWidth
                                          : constraints.maxWidth,
                                      height: constraints.maxHeight,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: _DealerTargetRow(
                                              dealer: 'Dealer',
                                              collectionTypes: collectionState
                                                  .collectionTypes,
                                              isHeader: true,
                                            ),
                                          ),

                                         
                                          Expanded(
                                            child: RefreshIndicator(
                                              onRefresh: _refreshDealerList,
                                              child: ListView.builder(
                                                physics:
                                                    const AlwaysScrollableScrollPhysics(),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      16,
                                                      8,
                                                      16,
                                                      24,
                                                    ),
                                                keyboardDismissBehavior:
                                                    ScrollViewKeyboardDismissBehavior
                                                        .onDrag,
                                                itemCount:
                                                    dealerState.dealers.length,
                                                itemBuilder: (context, index) {
                                                  final dealer = dealerState
                                                      .dealers[index];

                                                  return _DealerTargetRow(
                                                    key: ValueKey(
                                                      dealer.outletId,
                                                    ),

                                                    dealer: dealer.outletName+"\n(${dealer.outletMobile})",

                                                  
                                                    collectionTypes:
                                                        collectionState
                                                            .collectionTypes,

                                                    getTargetValue:
                                                        (collectionTypeId) {
                                                          return _getTargetValue(
                                                            dealerId:
                                                                dealer.outletId,
                                                            collectionTypeId:
                                                                collectionTypeId,
                                                          );
                                                        },

                                                    onTargetChanged:
                                                        (
                                                          collectionTypeId,
                                                          value,
                                                        ) {
                                                          _setTargetValue(
                                                            dealerId:
                                                                dealer.outletId,
                                                            collectionTypeId:
                                                                collectionTypeId,
                                                            value: value,
                                                          );
                                                        },
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}



class _DealerTargetRow extends StatelessWidget {
  final String dealer;


  final List<CollectionTypeEntity> collectionTypes;

  final bool isHeader;

  final String Function(String collectionTypeId)? getTargetValue;

  final void Function(String collectionTypeId, String value)? onTargetChanged;

  const _DealerTargetRow({
    super.key,
    required this.dealer,
    required this.collectionTypes,
    this.isHeader = false,
    this.getTargetValue,
    this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isHeader ? 0 : 10),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isHeader ? 10 : 18,
      ),
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFE8EFEA) : Colors.white,
        borderRadius: BorderRadius.circular(isHeader ? 12 : 18),
        border: isHeader ? null : Border.all(color: const Color(0xFFE3EBE5)),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: isHeader ? 11 : 14,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          color: isHeader ? const Color(0xFF5A7163) : const Color(0xFF203C2D),
        ),
        child: Row(
          children: [
        
            Expanded(
              flex: 4,
              child: Text(
                dealer,
                maxLines: isHeader ? 1 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 4),

        
            ...collectionTypes.map((collectionType) {
              return Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: isHeader
      
                      ? Text(
                          '${collectionType.collectionType} Target',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        )
                      
                      : _targetField(
                          getTargetValue?.call(
                                collectionType.collectionTypeId,
                              ) ??
                              '',
                          '${collectionType.collectionType} Target',
                          (value) {
                            onTargetChanged?.call(
                              collectionType.collectionTypeId,
                              value,
                            );
                          },
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }



  Widget _targetField(
    String value,
    String label,
    ValueChanged<String>? onChanged,
  ) {
    return Semantics(
      label: '$dealer, $label',
      child: TextFormField(
        initialValue: value,

        onChanged: onChanged,

        keyboardType: const TextInputType.numberWithOptions(decimal: true),

        textInputAction: TextInputAction.next,

        textAlign: TextAlign.center,

        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF183D30),
        ),

   
        inputFormatters: [
          TextInputFormatter.withFunction((oldValue, newValue) {
            final RegExp regex = RegExp(r'^\d*\.?\d*$');

            return regex.hasMatch(newValue.text) ? newValue : oldValue;
          }),
        ],

        decoration: InputDecoration(
          hintText: '0.00',

          hintStyle: const TextStyle(
            color: Color(0xFF94A39A),
            fontWeight: FontWeight.w400,
          ),

          filled: true,

          fillColor: const Color(0xFFF6F9F7),

          isDense: true,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 14,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDE7E0)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF287356), width: 1.5),
          ),
        ),
      ),
    );
  }
}


class _ErrorView extends StatelessWidget {
  final String message;

  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
