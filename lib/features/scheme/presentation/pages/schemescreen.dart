import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/utility/appdialog.dart';
import 'package:demo/core/utility/fullimage.dart';
import 'package:demo/core/utility/pdfviewerscreen.dart';
import 'package:demo/features/scheme/data/model/statedata.dart';
import 'package:demo/features/scheme/domain/entity/scheme_entity.dart';
import 'package:demo/features/scheme/presentation/bloc/scheme_bloc.dart';
import 'package:demo/features/scheme/presentation/bloc/scheme_event.dart';
import 'package:demo/features/scheme/presentation/bloc/scheme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SchemeScreen extends StatefulWidget {
  const SchemeScreen({super.key});

  @override
  State<SchemeScreen> createState() => _SchemeScreenState();
}

class _SchemeScreenState extends State<SchemeScreen> {
  // ============================================================
  // MONTH
  // ============================================================

  final List<String> months = List.generate(
    12,
    (i) => DateFormat.MMMM().format(DateTime(0, i + 1)),
  );

  late String selectedMonth;

  // ============================================================
  // YEAR
  // ============================================================

  late List<String> years;

  late String selectedYear;

  // ============================================================
  // STATE
  // ============================================================

  Statedata? selectedState;

  List<Statedata> stateList = [];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    selectedMonth = months[now.month - 1];

    years = List.generate(7, (i) => (now.year - i).toString());

    selectedYear = now.year.toString();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: const Text(
          'Scheme',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: BlocConsumer<SchemeBloc, SchemeState>(
        listener: (context, state) {
          // ----------------------------------------------------
          // STATES LOADED
          // ----------------------------------------------------

          if (state is SchemeStatesLoaded) {
            setState(() {
              stateList = state.states;

              selectedState = state.selectedState;
            });
          }

          // ----------------------------------------------------
          // SCHEME ERROR
          // ----------------------------------------------------

          if (state is SchemeError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          // ----------------------------------------------------
          // NO RECORD
          // ----------------------------------------------------

          if (state is SchemeLoaded && state.schemes.isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Record Not Found")));
          }
        },

        builder: (context, state) {
          return Column(
            children: [
              // =================================================
              // FILTER
              // =================================================
              _buildFilter(state),

              // =================================================
              // LIST
              // =================================================
              Expanded(child: _buildSchemeList(state)),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilter(SchemeState state) {
    final bool stateLoading = state is SchemeStatesLoading;

    return Padding(
      padding: const EdgeInsets.all(12),

      child: _buildCard(
        child: Column(
          children: [
            // ==================================================
            // MONTH + YEAR
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: _buildDropdownn(
                    icon: Icons.calendar_month,
                    value: selectedMonth,
                    items: months,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        selectedMonth = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _buildDropdownn(
                    icon: Icons.date_range,
                    value: selectedYear,
                    items: years,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        selectedYear = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ==================================================
            // STATE
            // ==================================================
            stateLoading ? _buildStateLoading() : _buildStateDropdown(),

            const SizedBox(height: 12),

            // ==================================================
            // SEARCH BUTTON
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 45,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: _onSearch,

                child: const Text(
                  'Search',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearch() {
    final String? stateId = selectedState?.stateId;

    if (stateId == null || stateId.isEmpty) {
      AppDialog.show(
        context: context,
        message: 'Please select state',
        type: DialogType.error,
      );

      return;
    }

    // Month name -> month number
    final int month = months.indexOf(selectedMonth) + 1;

    print('Search Scheme:');

    print('Year: $selectedYear');

    print('Month: $month');

    print('State ID: $stateId');

    context.read<SchemeBloc>().add(
      GetSchemeEvent(
        year: selectedYear,
        month: month.toString(),
        stateId: stateId,
      ),
    );
  }

  // ============================================================
  // STATE DROPDOWN
  // ============================================================

  Widget _buildStateDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),

      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F9),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          const Icon(Icons.map, color: Colors.green, size: 18),

          const SizedBox(width: 8),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Statedata>(
                value: selectedState,

                isExpanded: true,

                hint: const Text('Select State'),

                items: stateList.map((Statedata state) {
                  return DropdownMenuItem<Statedata>(
                    value: state,

                    child: Text(state.stateName ?? ''),
                  );
                }).toList(),

                onChanged: (Statedata? value) {
                  setState(() {
                    selectedState = value;
                  });

                  print(
                    'Selected State: '
                    '${value?.stateName}',
                  );

                  print(
                    'Selected State ID: '
                    '${value?.stateId}',
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATE LOADING
  // ============================================================

  Widget _buildStateLoading() {
    return Container(
      height: 50,

      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F9),
        borderRadius: BorderRadius.circular(12),
      ),

      child: const Row(
        children: [
          Icon(Icons.map, color: Colors.green, size: 18),

          SizedBox(width: 8),

          Expanded(child: Text('Loading states...')),

          SizedBox(
            width: 18,
            height: 18,

            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MONTH / YEAR DROPDOWN
  // ============================================================

  Widget _buildDropdownn({
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),

      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F9),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 18),

          const SizedBox(width: 8),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,

                isExpanded: true,

                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,

                    child: Text(item),
                  );
                }).toList(),

                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCHEME LIST
  // ============================================================

  Widget _buildSchemeList(SchemeState state) {
    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (state is SchemeLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (state is SchemeError) {
      return Center(
        child: Text(state.message, style: const TextStyle(color: Colors.red)),
      );
    }

    // ----------------------------------------------------------
    // LOADED
    // ----------------------------------------------------------

    if (state is SchemeLoaded) {
      if (state.schemes.isEmpty) {
        return const Center(
          child: Text(
            'No Scheme Found',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),

        itemCount: state.schemes.length,

        itemBuilder: (context, index) {
          final SchemeEntity item = state.schemes[index];

          return _buildSchemeCard(item);
        },
      );
    }

    // ----------------------------------------------------------
    // INITIAL / OTHER
    // ----------------------------------------------------------

    return const Center(
      child: Text(
        'No Scheme Found',
        style: TextStyle(color: Colors.grey, fontSize: 15),
      ),
    );
  }

  // ============================================================
  // SCHEME CARD
  // ============================================================

  Widget _buildSchemeCard(SchemeEntity item) {
    final String image = item.fldImage ?? '';

    final String url = fileUrl(image);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ====================================================
          // IMAGE / PDF
          // ====================================================
          GestureDetector(
            onTap: () {
              if (image.isEmpty) {
                return;
              }

              if (isPdf(image)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PdfViewerScreen(pdfUrl: url),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullImageScreen(imageUrl: url),
                  ),
                );
              }
            },

            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),

              child: SizedBox(
                height: 180,

                width: double.infinity,

                child: isPdf(image)
                    ? Container(
                        color: Colors.red.shade50,

                        child: const Center(
                          child: Icon(
                            Icons.picture_as_pdf,
                            size: 60,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : Image.network(
                        url,

                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),

          // ====================================================
          // DETAILS
          // ====================================================
          Padding(
            padding: const EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  item.fldOutletName ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  item.fldRemark ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),

                // Optional dates
                if ((item.fldFromDate ?? '').isNotEmpty ||
                    (item.fldToDate ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),

                  Text(
                    '${item.fldFromDate ?? ''} - '
                    '${item.fldToDate ?? ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILE URL
  // ============================================================

  String fileUrl(String file) {
    return '${ApiClient.imageGalleryUrl}'
        'Scheme/'
        '$file';
  }

  // ============================================================
  // PDF CHECK
  // ============================================================

  bool isPdf(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),

      child: child,
    );
  }
}
