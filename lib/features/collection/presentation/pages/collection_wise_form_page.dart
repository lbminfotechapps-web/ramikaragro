
import 'dart:io';

import 'package:demo/core/di/collection_di.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/features/collection/domain/entities/dealer.dart';
import 'package:demo/features/collection/presentation/bloc/collection_bloc.dart';
import 'package:demo/features/collection/presentation/bloc/collection_event.dart';
import 'package:demo/features/collection/presentation/bloc/collection_state.dart';
import 'package:demo/features/collection/presentation/pages/dealer_search_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CollectionWiseFormPage extends StatefulWidget {
  const CollectionWiseFormPage({
    super.key,
  });

  @override
  State<CollectionWiseFormPage> createState() =>
      _CollectionWiseFormPageState();
}

class _CollectionWiseFormPageState
    extends State<CollectionWiseFormPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController rtgsController =
      TextEditingController();

  final TextEditingController neftController =
      TextEditingController();

  final TextEditingController chequeNumberController =
      TextEditingController();

  final TextEditingController chequeDateController =
      TextEditingController();

  final TextEditingController bankNameController =
      TextEditingController();

  final TextEditingController depositBankNameController =
      TextEditingController();

  final TextEditingController depositBranchController =
      TextEditingController();

  final TextEditingController remarkController =
      TextEditingController();

  final TextEditingController upiController =
      TextEditingController();

  final TextEditingController upiTransactionController =
      TextEditingController();

  // ============================================================
  // IMAGE
  // ============================================================

  final ImagePicker imagePicker = ImagePicker();

  List<File> selectedImages = [];

  // ============================================================
  // BLOC
  // ============================================================

  late CollectionBloc bloc;

  // ============================================================
  // DATA
  // ============================================================

  String? paymentMode;

  String dealerId = '';
  String dealerName = '';
  String userId = '';

  // ============================================================
  // PAYMENT MODES
  // ============================================================

  final List<String> paymentModes = [
    'Cash',
    'Cheque',
    'RTGS',
    'NEFT',
    'UPI',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    bloc = sl<CollectionBloc>();

    _loadUser();
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> _loadUser() async {
    try {
      final userData =
          await SecureStorage.instance.getUserData();

      if (!mounted) return;

      final loadedUserId =
          userData?['user_id']?.toString() ?? '';

      setState(() {
        userId = loadedUserId;
      });

      debugPrint(
        '=========================================',
      );
      debugPrint('COLLECTION USER');
      debugPrint('USER ID = $userId');
      debugPrint(
        '=========================================',
      );
    } catch (e) {
      debugPrint(
        'Error loading user: $e',
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    amountController.dispose();
    rtgsController.dispose();
    neftController.dispose();
    chequeNumberController.dispose();
    chequeDateController.dispose();
    bankNameController.dispose();
    depositBankNameController.dispose();
    depositBranchController.dispose();
    remarkController.dispose();
    upiController.dispose();
    upiTransactionController.dispose();

    bloc.close();

    super.dispose();
  }

  // ============================================================
  // PAYMENT MODE CHANGE
  // ============================================================

  void _onPaymentModeChanged(
    String? mode,
  ) {
    if (mode == null) return;

    _clearPaymentFields();

    setState(() {
      paymentMode = mode;
    });
  }

  // ============================================================
  // CLEAR PAYMENT FIELDS
  // ============================================================

  void _clearPaymentFields() {
    rtgsController.clear();
    neftController.clear();
    chequeNumberController.clear();
    chequeDateController.clear();
    bankNameController.clear();
    depositBankNameController.clear();
    depositBranchController.clear();
    upiController.clear();
    upiTransactionController.clear();
  }

  // ============================================================
  // CHEQUE DATE
  // ============================================================

  Future<void> _selectChequeDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (
        context,
        child,
      ) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(
              primary: Color(0xFF166534),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) {
      return;
    }

    final day = pickedDate.day
        .toString()
        .padLeft(2, '0');

    final month = pickedDate.month
        .toString()
        .padLeft(2, '0');

    chequeDateController.text =
        '$day-$month-${pickedDate.year}';

    setState(() {});
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Future<void> _pickImages() async {
    try {
      final files =
          await imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (files.isEmpty) {
        return;
      }

      setState(() {
        selectedImages = files
            .map(
              (e) => File(e.path),
            )
            .toList();
      });

      debugPrint(
        'Selected images = ${selectedImages.length}',
      );
    } catch (e) {
      debugPrint(
        'Image picker error: $e',
      );

      _showMessage(
        'Unable to select images',
      );
    }
  }

  // ============================================================
  // REMOVE IMAGE
  // ============================================================

  void _removeImage(
    int index,
  ) {
    if (index < 0 ||
        index >= selectedImages.length) {
      return;
    }

    setState(() {
      selectedImages.removeAt(index);
    });
  }

  // ============================================================
  // SELECT DEALER
  // ============================================================

  Future<void> _selectDealer() async {
    if (userId.trim().isEmpty) {
      _showMessage(
        'User information not available',
      );

      return;
    }

    debugPrint(
      '=========================================',
    );
    debugPrint(
      'OPEN DEALER SEARCH',
    );
    debugPrint(
      'USER ID = $userId',
    );
    debugPrint(
      '=========================================',
    );

    final Dealer? selectedDealer =
        await showModalBottomSheet<Dealer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: DealerSearchBottomSheet(
            userId: userId,
          ),
        );
      },
    );

    if (!mounted ||
        selectedDealer == null) {
      return;
    }

    setState(() {
      dealerId = selectedDealer.id;
      dealerName = selectedDealer.name;
    });

    debugPrint(
      '=========================================',
    );
    debugPrint(
      'DEALER SELECTED',
    );
    debugPrint(
      'DEALER ID = $dealerId',
    );
    debugPrint(
      'DEALER NAME = $dealerName',
    );
    debugPrint(
      '=========================================',
    );
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validateForm() {
    // ----------------------------------------------------------
    // DEALER
    // ----------------------------------------------------------

    if (dealerId.trim().isEmpty) {
      _showMessage(
        'Please select dealer',
      );

      return false;
    }

    // ----------------------------------------------------------
    // PAYMENT MODE
    // ----------------------------------------------------------

    if (paymentMode == null ||
        paymentMode!.trim().isEmpty) {
      _showMessage(
        'Please select payment mode',
      );

      return false;
    }

    // ----------------------------------------------------------
    // AMOUNT
    // ----------------------------------------------------------

    if (amountController.text
        .trim()
        .isEmpty) {
      _showMessage(
        'Please enter amount',
      );

      return false;
    }

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      _showMessage(
        'Please enter valid amount',
      );

      return false;
    }

    // ----------------------------------------------------------
    // CHEQUE
    // ----------------------------------------------------------

    if (paymentMode == 'Cheque') {
      if (chequeNumberController.text
          .trim()
          .isEmpty) {
        _showMessage(
          'Please enter cheque number',
        );

        return false;
      }

      if (chequeDateController.text
          .trim()
          .isEmpty) {
        _showMessage(
          'Please select cheque date',
        );

        return false;
      }

      if (bankNameController.text
          .trim()
          .isEmpty) {
        _showMessage(
          'Please enter bank name',
        );

        return false;
      }

      if (depositBankNameController.text
          .trim()
          .isEmpty) {
        _showMessage(
          'Please enter deposit bank name',
        );

        return false;
      }

      if (depositBranchController.text
          .trim()
          .isEmpty) {
        _showMessage(
          'Please enter deposit branch',
        );

        return false;
      }
    }

    // ----------------------------------------------------------
    // RTGS
    // ----------------------------------------------------------

    if (paymentMode == 'RTGS' &&
        rtgsController.text
            .trim()
            .isEmpty) {
      _showMessage(
        'Please enter RTGS number',
      );

      return false;
    }

    // ----------------------------------------------------------
    // NEFT
    // ----------------------------------------------------------

    if (paymentMode == 'NEFT' &&
        neftController.text
            .trim()
            .isEmpty) {
      _showMessage(
        'Please enter NEFT number',
      );

      return false;
    }

    // ----------------------------------------------------------
    // UPI
    // ----------------------------------------------------------

    if (paymentMode == 'UPI') {
      if (upiController.text
          .trim()
          .isEmpty) {
        _showMessage(
          'Please enter UPI ID',
        );

        return false;
      }

      if (upiTransactionController.text
          .trim()
          .isEmpty) {
        _showMessage(
          'Please enter UPI transaction number',
        );

        return false;
      }
    }

    // ----------------------------------------------------------
    // USER
    // ----------------------------------------------------------

    if (userId.trim().isEmpty) {
      _showMessage(
        'User information not available',
      );

      return false;
    }

    return true;
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    // Prevent duplicate API calls
    if (bloc.state.status ==
        CollectionStatus.loading) {
      return;
    }

    if (!_validateForm()) {
      return;
    }

    debugPrint(
      '=========================================',
    );
    debugPrint(
      'SUBMIT COLLECTION',
    );
    debugPrint(
      '=========================================',
    );

    debugPrint(
      'Dealer ID: $dealerId',
    );

    debugPrint(
      'Dealer Name: $dealerName',
    );

    debugPrint(
      'Payment Mode: $paymentMode',
    );

    debugPrint(
      'Amount: ${amountController.text.trim()}',
    );

    debugPrint(
      'User ID: $userId',
    );

    debugPrint(
      'Images: ${selectedImages.length}',
    );

    debugPrint(
      '=========================================',
    );

    bloc.add(
      SubmitPaymentEvent(
        dealerId: dealerId,

        paymentMode: paymentMode!,

        amount:
            amountController.text.trim(),

        rtgsNo:
            rtgsController.text.trim(),

        neftNo:
            neftController.text.trim(),

        chequeDate:
            chequeDateController.text.trim(),

        chequeNumber:
            chequeNumberController.text.trim(),

        bankName:
            bankNameController.text.trim(),

        depositBankName:
            depositBankNameController.text
                .trim(),

        depositBranchName:
            depositBranchController.text
                .trim(),

        remark:
            remarkController.text.trim(),

        transaction:
            upiTransactionController.text
                .trim(),

        userId: userId,

        images: selectedImages,
      ),
    );
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  Future<void> _showSuccessDialog(
    String message,
  ) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),

          contentPadding:
              const EdgeInsets.fromLTRB(
            24,
            28,
            24,
            20,
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              // ==================================================
              // SUCCESS ICON
              // ==================================================

              Container(
                height: 76,
                width: 76,
                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xFFE8F7ED),
                  shape:
                      BoxShape.circle,
                ),
                child:
                    const Icon(
                  Icons
                      .check_circle_rounded,
                  color:
                      Color(0xFF166534),
                  size: 54,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                'Collection Submitted!',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF17201B),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              // ==================================================
              // MESSAGE
              // ==================================================

              Text(
                message,
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color:
                      Color(0xFF66736B),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // OK BUTTON
              // ==================================================

              SizedBox(
                width:
                    double.infinity,
                height: 48,
                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF166534,
                    ),

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),

                  child:
                      const Text(
                    'OK',
                    style:
                        TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // ==========================================================
    // AFTER OK -> GO BACK TO COLLECTION LIST
    // ==========================================================

    if (!mounted) return;

    if (context.canPop()) {
      context.pop();
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,

        margin:
            const EdgeInsets.all(16),

        duration:
            const Duration(
          seconds: 2,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),

        content: Text(
          message,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocProvider.value(
      value: bloc,

      child: BlocListener<
          CollectionBloc,
          CollectionState>(
        listener: (
          context,
          state,
        ) {
          // ======================================================
          // SUCCESS
          // ======================================================

          if (state.status ==
              CollectionStatus.success) {
            _showSuccessDialog(
              state.message ??
                  'Collection submitted successfully.',
            );

            return;
          }

          // ======================================================
          // FAILURE
          // ======================================================

          if (state.status ==
              CollectionStatus.failure) {
            _showMessage(
              state.message ??
                  'Payment submission failed',
            );
          }
        },

        child: Scaffold(
          backgroundColor:
              const Color(0xFFF6F8F7),

              // ====================================================================
        // APP BAR
        // ====================================================================
        appBar: AppBar(
          backgroundColor: const Color(0xFF287A4B),

          foregroundColor: Colors.white,

          elevation: 0,

          automaticallyImplyLeading: false,

          leading: IconButton(
            onPressed: () {
              context.go(AppRouter.home);
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 25),
          ),

          title: const Text(
            'Add Collection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

         
        ),

          body: CustomScrollView(
            slivers: [
              // ==================================================
              // HEADER
              // ==================================================

              _buildHeader(),

              // ==================================================
              // BODY
              // ==================================================

              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(
                  14,
                  12,
                  14,
                  24,
                ),

                sliver: SliverList(
                  delegate:
                      SliverChildListDelegate(
                    [
                      // DEALER
                      _buildDealerCard(),

                      const SizedBox(
                        height: 12,
                      ),

                      // PAYMENT
                      _buildPaymentCard(),

                      const SizedBox(
                        height: 12,
                      ),

                      // REMARK
                      _buildRemarkCard(),

                      const SizedBox(
                        height: 12,
                      ),

                      // IMAGES
                      _buildImageCard(),

                      const SizedBox(
                        height: 18,
                      ),

                      // SUBMIT
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 120,

      pinned: true,

      elevation: 0,

      backgroundColor:
          const Color(0xFF166534),

  
      flexibleSpace:
          FlexibleSpaceBar(
        background:
            Container(
          decoration:
              const BoxDecoration(
            gradient:
                LinearGradient(
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
              colors: [
                Color(0xFF14532D),
                Color(0xFF166534),
                Color(0xFF22C55E),
              ],
            ),
          ),

          child: SafeArea(
            child:
                Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                18,
                70,
                18,
                14,
              ),

              child:
                  Align(
                alignment:
                    Alignment.bottomLeft,

                child:
                    Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,

                      child:
                          const Icon(
                        Icons
                            .account_balance_wallet_rounded,
                        color:
                            Colors.white,
                        size: 25,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    const Expanded(
                      child:
                          Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .end,

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            'Record Collection',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  20,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),

                  
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DEALER CARD
  // ============================================================

  Widget _buildDealerCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionHeader(
            icon:
                Icons.storefront_rounded,
            title:
                'Dealer',
            subtitle:
                'Select dealer for this collection',
          ),

          const SizedBox(
            height: 12,
          ),

          InkWell(
            onTap:
                _selectDealer,

            borderRadius:
                BorderRadius.circular(
              14,
            ),

            child:
                Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                13,
              ),

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF5F7F6,
                ),

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),

                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFE2E8E5,
                  ),
                ),
              ),

              child:
                  Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFE7F5EC,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons.store_rounded,
                      color:
                          Color(0xFF166534),
                      size: 21,
                    ),
                  ),

                  const SizedBox(
                    width: 11,
                  ),

                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          dealerName.isEmpty
                              ? 'Select dealer'
                              : dealerName,

                          maxLines: 1,

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style:
                              TextStyle(
                            fontSize: 14,

                            fontWeight:
                                FontWeight
                                    .w700,

                            color:
                                dealerName
                                        .isEmpty
                                    ? Colors
                                        .black54
                                    : const Color(
                                        0xFF17201B,
                                      ),
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          dealerName.isEmpty
                              ? 'Tap to search dealer'
                              : 'Dealer ID: $dealerId',

                          style:
                              const TextStyle(
                            fontSize: 11,
                            color:
                                Colors
                                    .black45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: 34,
                    width: 34,

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFE7F5EC,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons.search_rounded,
                      color:
                          Color(0xFF166534),
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT CARD
  // ============================================================

  Widget _buildPaymentCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionHeader(
            icon:
                Icons.payments_rounded,
            title:
                'Payment Details',
            subtitle:
                'Select method and enter amount',
          ),

          const SizedBox(
            height: 12,
          ),

          _buildAmountField(),

          const SizedBox(
            height: 12,
          ),

          _buildPaymentDropdown(),

          if (paymentMode != null) ...[
            const SizedBox(
              height: 12,
            ),

            AnimatedSwitcher(
              duration:
                  const Duration(
                milliseconds: 200,
              ),

              child:
                  _buildConditionalFields(),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  Widget _buildAmountField() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 3,
      ),

      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFFF0FDF4),
            Color(0xFFE7F8ED),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        border:
            Border.all(
          color:
              const Color(0xFFBBE8C9),
        ),
      ),

      child:
          Row(
        children: [
          Container(
            height: 40,
            width: 40,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF166534,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child:
                const Icon(
              Icons.currency_rupee_rounded,
              color:
                  Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child:
                TextField(
              controller:
                  amountController,

              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),

              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF17201B),
              ),

              decoration:
                  const InputDecoration(
                border:
                    InputBorder.none,

                labelText:
                    'Collection Amount *',

                hintText:
                    '0.00',

                labelStyle:
                    TextStyle(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT DROPDOWN
  // ============================================================

  Widget _buildPaymentDropdown() {
    return DropdownButtonFormField<String>(
      value:
          paymentMode,

      isExpanded:
          true,

      decoration:
          InputDecoration(
        labelText:
            'Payment Method *',

        hintText:
            'Select payment method',

        prefixIcon:
            const Icon(
          Icons
              .account_balance_wallet_rounded,
          size: 20,
          color:
              Color(0xFF166534),
        ),

        filled:
            true,

        fillColor:
            const Color(0xFFF6F8F7),

        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 12,
          vertical: 13,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),

          borderSide:
              const BorderSide(
            color:
                Color(0xFFE1E7E3),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),

          borderSide:
              const BorderSide(
            color:
                Color(0xFF166534),
            width: 1.4,
          ),
        ),
      ),

      icon:
          const Icon(
        Icons
            .keyboard_arrow_down_rounded,
        color:
            Color(0xFF166534),
      ),

      items:
          paymentModes.map(
        (mode) {
          return DropdownMenuItem<String>(
            value:
                mode,

            child:
                Row(
              children: [
                Icon(
                  _paymentIcon(
                    mode,
                  ),

                  size:
                      19,

                  color:
                      const Color(
                    0xFF166534,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Text(
                  mode,

                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight
                            .w600,
                    color:
                        Color(
                      0xFF17201B,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),

      onChanged:
          _onPaymentModeChanged,
    );
  }

  // ============================================================
  // PAYMENT ICON
  // ============================================================

  IconData _paymentIcon(
    String mode,
  ) {
    switch (mode) {
      case 'Cash':
        return Icons
            .payments_outlined;

      case 'Cheque':
        return Icons
            .receipt_long_outlined;

      case 'RTGS':
        return Icons
            .account_balance_outlined;

      case 'NEFT':
        return Icons
            .swap_horiz_rounded;

      case 'UPI':
        return Icons
            .qr_code_2_rounded;

      default:
        return Icons
            .payment_rounded;
    }
  }

  // ============================================================
  // CONDITIONAL FIELDS
  // ============================================================

  Widget _buildConditionalFields() {
    switch (paymentMode) {
      case 'Cheque':
        return _buildChequeFields();

      case 'RTGS':
        return _buildSingleField(
          key:
              const ValueKey(
            'rtgs',
          ),

          controller:
              rtgsController,

          label:
              'RTGS Number',

          hint:
              'Enter RTGS transaction number',

          icon:
              Icons.account_balance_rounded,
        );

      case 'NEFT':
        return _buildSingleField(
          key:
              const ValueKey(
            'neft',
          ),

          controller:
              neftController,

          label:
              'NEFT Number',

          hint:
              'Enter NEFT transaction number',

          icon:
              Icons.swap_horiz_rounded,
        );

      case 'UPI':
        return _buildUpiFields();

      case 'Cash':
        return _buildCashInfo();

      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // CASH
  // ============================================================

  Widget _buildCashInfo() {
    return Container(
      key:
          const ValueKey(
        'cash',
      ),

      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        12,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF0FDF4,
        ),

        borderRadius:
            BorderRadius.circular(
          12,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFBBE8C9,
          ),
        ),
      ),

      child:
          const Row(
        children: [
          Icon(
            Icons
                .check_circle_outline_rounded,
            color:
                Color(0xFF166534),
            size: 20,
          ),

          SizedBox(
            width: 8,
          ),

          Expanded(
            child:
                Text(
              'Cash payment selected. No transaction details required.',
              style:
                  TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color:
                    Color(0xFF166534),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHEQUE
  // ============================================================

  Widget _buildChequeFields() {
    return Container(
      key:
          const ValueKey(
        'cheque',
      ),

      padding:
          const EdgeInsets.all(
        12,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFFFFBEB,
        ),

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFF5D98B,
          ),
        ),
      ),

      child:
          Column(
        children: [
          _buildInput(
            controller:
                chequeNumberController,

            label:
                'Cheque Number *',

            hint:
                'Enter cheque number',

            icon:
                Icons.receipt_long_rounded,
          ),

          const SizedBox(
            height: 10,
          ),

          _buildDateInput(),

          const SizedBox(
            height: 10,
          ),

          _buildInput(
            controller:
                bankNameController,

            label:
                'Bank Name *',

            hint:
                'Enter bank name',

            icon:
                Icons.account_balance_rounded,
          ),

          const SizedBox(
            height: 10,
          ),

          _buildInput(
            controller:
                depositBankNameController,

            label:
                'Deposit Bank Name *',

            hint:
                'Enter deposit bank',

            icon:
                Icons
                    .account_balance_wallet_rounded,
          ),

          const SizedBox(
            height: 10,
          ),

          _buildInput(
            controller:
                depositBranchController,

            label:
                'Deposit Branch *',

            hint:
                'Enter deposit branch',

            icon:
                Icons.location_city_rounded,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UPI
  // ============================================================

  Widget _buildUpiFields() {
    return Container(
      key:
          const ValueKey(
        'upi',
      ),

      padding:
          const EdgeInsets.all(
        12,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF5F3FF,
        ),

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFDCD2FF,
          ),
        ),
      ),

      child:
          Column(
        children: [
          _buildInput(
            controller:
                upiController,

            label:
                'UPI ID *',

            hint:
                'example@upi',

            icon:
                Icons.qr_code_rounded,

            keyboardType:
                TextInputType
                    .emailAddress,
          ),

          const SizedBox(
            height: 10,
          ),

          _buildInput(
            controller:
                upiTransactionController,

            label:
                'Transaction Number *',

            hint:
                'Enter UPI transaction number',

            icon:
                Icons
                    .confirmation_number_rounded,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SINGLE FIELD
  // ============================================================

  Widget _buildSingleField({
    required Key key,
    required TextEditingController
        controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      key:
          key,

      padding:
          const EdgeInsets.all(
        12,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF5F7F6,
        ),

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFE3E8E5,
          ),
        ),
      ),

      child:
          _buildInput(
        controller:
            controller,

        label:
            label,

        hint:
            hint,

        icon:
            icon,
      ),
    );
  }

  // ============================================================
  // DATE INPUT
  // ============================================================

  Widget _buildDateInput() {
    return InkWell(
      onTap:
          _selectChequeDate,

      borderRadius:
          BorderRadius.circular(
        13,
      ),

      child:
          IgnorePointer(
        child:
            _buildInput(
          controller:
              chequeDateController,

          label:
              'Cheque Date *',

          hint:
              'Select cheque date',

          icon:
              Icons.calendar_month_rounded,
        ),
      ),
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  Widget _buildInput({
    required TextEditingController
        controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller:
          controller,

      keyboardType:
          keyboardType,

      style:
          const TextStyle(
        fontSize: 13,
        fontWeight:
            FontWeight.w600,
      ),

      decoration:
          InputDecoration(
        labelText:
            label,

        hintText:
            hint,

        prefixIcon:
            Icon(
          icon,

          size: 19,

          color:
              const Color(
            0xFF607068,
          ),
        ),

        filled:
            true,

        fillColor:
            Colors.white,

        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 12,
          vertical: 13,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            13,
          ),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            13,
          ),

          borderSide:
              const BorderSide(
            color:
                Color(0xFFE1E7E3),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            13,
          ),

          borderSide:
              const BorderSide(
            color:
                Color(0xFF166534),
            width: 1.3,
          ),
        ),

        labelStyle:
            const TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }

  // ============================================================
  // REMARK CARD
  // ============================================================

  Widget _buildRemarkCard() {
    return _buildCard(
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionHeader(
            icon:
                Icons.notes_rounded,

            title:
                'Remark',

            subtitle:
                'Add additional information',
          ),

          const SizedBox(
            height: 12,
          ),

          TextField(
            controller:
                remarkController,

            maxLines:
                3,

            style:
                const TextStyle(
              fontSize: 13,
            ),

            decoration:
                InputDecoration(
              hintText:
                  'Write a remark...',

              filled:
                  true,

              fillColor:
                  const Color(
                0xFFF6F8F7,
              ),

              prefixIcon:
                  const Padding(
                padding:
                    EdgeInsets.only(
                  bottom: 35,
                ),

                child:
                    Icon(
                  Icons
                      .edit_note_rounded,
                  size: 21,
                ),
              ),

              contentPadding:
                  const EdgeInsets.all(
                13,
              ),

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),

                borderSide:
                    BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE CARD
  // ============================================================

  Widget _buildImageCard() {
    return _buildCard(
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionHeader(
            icon:
                Icons.photo_library_rounded,

            title:
                'Payment Proof',

            subtitle:
                'Attach payment related images',
          ),

          const SizedBox(
            height: 12,
          ),

          InkWell(
            onTap:
                _pickImages,

            borderRadius:
                BorderRadius.circular(
              14,
            ),

            child:
                Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 16,
              ),

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF5F7F6,
                ),

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),

                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFD9E1DC,
                  ),
                ),
              ),

              child:
                  Column(
                children: [
                  Container(
                    height: 42,
                    width: 42,

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFE7F5EC,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        13,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons
                          .add_photo_alternate_rounded,

                      color:
                          Color(
                        0xFF166534,
                      ),

                      size: 22,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Add payment images',
                    style:
                        TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    selectedImages.isEmpty
                        ? 'Tap to select photos'
                        : '${selectedImages.length} image(s) selected',

                    style:
                        const TextStyle(
                      fontSize: 11,
                      color:
                          Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // SELECTED IMAGES
          // ======================================================

          if (selectedImages
              .isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),

            GridView.builder(
              shrinkWrap:
                  true,

              physics:
                  const NeverScrollableScrollPhysics(),

              itemCount:
                  selectedImages.length,

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    3,

                crossAxisSpacing:
                    7,

                mainAxisSpacing:
                    7,
              ),

              itemBuilder:
                  (context, index) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child:
                          ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),

                        child:
                            Image.file(
                          selectedImages[
                              index],

                          fit:
                              BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 5,
                      right: 5,

                      child:
                          GestureDetector(
                        onTap:
                            () =>
                                _removeImage(
                          index,
                        ),

                        child:
                            Container(
                          height: 25,
                          width: 25,

                          decoration:
                              const BoxDecoration(
                            color:
                                Colors
                                    .black54,

                            shape:
                                BoxShape
                                    .circle,
                          ),

                          child:
                              const Icon(
                            Icons
                                .close_rounded,

                            color:
                                Colors
                                    .white,

                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton() {
    return BlocBuilder<
        CollectionBloc,
        CollectionState>(
      builder: (
        context,
        state,
      ) {
        final bool loading =
            state.status ==
                CollectionStatus.loading;

        return Container(
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              16,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF166534,
                ).withValues(
                  alpha: 0.20,
                ),

                blurRadius:
                    15,

                offset:
                    const Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),

          child:
              SizedBox(
            width:
                double.infinity,

            height:
                52,

            child:
                ElevatedButton(
              onPressed:
                  loading
                      ? null
                      : _submit,

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    const Color(
                  0xFF166534,
                ),

                foregroundColor:
                    Colors.white,

                disabledBackgroundColor:
                    const Color(
                  0xFF86A891,
                ),

                elevation:
                    0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),

              child:
                  loading
                      ? const SizedBox(
                          height:
                              21,

                          width:
                              21,

                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.4,

                            color:
                                Colors
                                    .white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [
                            Icon(
                              Icons
                                  .check_circle_outline_rounded,
                              size:
                                  20,
                            ),

                            SizedBox(
                              width:
                                  8,
                            ),

                            Text(
                              'Submit Collection',
                              style:
                                  TextStyle(
                                fontSize:
                                    14,

                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // COMMON CARD
  // ============================================================

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        14,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(
          color:
              const Color(
            0xFFE8ECE9,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.025,
            ),

            blurRadius:
                12,

            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child:
          child,
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height:
              38,

          width:
              38,

          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFEAF6EE,
            ),

            borderRadius:
                BorderRadius.circular(
              11,
            ),
          ),

          child:
              Icon(
            icon,

            color:
                const Color(
              0xFF166534,
            ),

            size:
                20,
          ),
        ),

        const SizedBox(
          width:
              10,
        ),

        Expanded(
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              Text(
                title,

                style:
                    const TextStyle(
                  fontSize:
                      15,

                  fontWeight:
                      FontWeight
                          .w800,

                  color:
                      Color(
                    0xFF17201B,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    2,
              ),

              Text(
                subtitle,

                maxLines:
                    1,

                overflow:
                    TextOverflow
                        .ellipsis,

                style:
                    const TextStyle(
                  fontSize:
                      10.5,

                  color:
                      Color(
                    0xFF7A867F,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

