import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/utility/appdialog.dart';
import 'package:solufine/core/utility/fullimage.dart';
import 'package:solufine/core/utility/pdfviewerscreen.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/features/scheme/data/model/statedata.dart';
import 'package:solufine/features/scheme/domain/entity/scheme_entity.dart';
import 'package:solufine/features/scheme/presentation/bloc/scheme_bloc.dart';
import 'package:solufine/features/scheme/presentation/bloc/scheme_event.dart';
import 'package:solufine/features/scheme/presentation/bloc/scheme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';

class SchemeScreen extends StatefulWidget {
  const SchemeScreen({super.key});

  @override
  State<SchemeScreen> createState() => _SchemeScreenState();
}

class _SchemeScreenState extends State<SchemeScreen> {
  final List<String> months = List.generate(
    12,
    (i) => DateFormat.MMMM().format(DateTime(0, i + 1)),
  );

  late String selectedMonth;

  late List<String> years;

  late String selectedYear;

  Statedata? selectedState;

  List<Statedata> stateList = [];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    selectedMonth = months[now.month - 1];

    years = List.generate(7, (i) => (now.year - i).toString());

    selectedYear = now.year.toString();

    context.read<SchemeBloc>().add(LoadAssignedStatesEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,

      appBar: CustomAppBar(
        title: 'Schemes',
        showBackButton: true,
        onBackTap: () => Navigator.pop(context),
      ),

      body: BlocConsumer<SchemeBloc, SchemeState>(
        listener: (context, state) {
          if (state is SchemeStatesLoaded) {
            setState(() {
              stateList = state.states;

              selectedState = state.selectedState;
            });
          }

          if (state is SchemeError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is SchemeLoaded && state.schemes.isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Record Not Found")));
          }
        },

        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                SizedBox(height: 14.h),
                _buildFilter(state),

                Expanded(child: _buildSchemeList(state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilter(SchemeState state) {
    final bool stateLoading = state is SchemeStatesLoading;

    return Padding(
      padding: const EdgeInsets.all(12),

      child: _buildCard(
        child: Column(
          children: [
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

            stateLoading ? _buildStateLoading() : _buildStateDropdown(),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 45,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.onPrimaryColor,
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

  Widget _buildStateDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),

      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Icon(Icons.map, color: context.primaryColor, size: 18),

          const SizedBox(width: 8),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Statedata>(
                value: selectedState,
                dropdownColor: context.cardBackgroundColor,
                iconEnabledColor: context.primaryColor,
                style: TextStyle(color: context.primaryTextColor),

                isExpanded: true,

                hint: Text(
                  'Select State',
                  style: TextStyle(color: context.secondaryTextColor),
                ),

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

  Widget _buildStateLoading() {
    return Container(
      height: 50,

      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Icon(Icons.map, color: context.primaryColor, size: 18),

          SizedBox(width: 8),

          Expanded(
            child: Text(
              'Loading states...',
              style: TextStyle(color: context.secondaryTextColor),
            ),
          ),

          SizedBox(
            width: 18,
            height: 18,

            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownn({
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),

      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Icon(icon, color: context.primaryColor, size: 18),

          const SizedBox(width: 8),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                dropdownColor: context.cardBackgroundColor,
                iconEnabledColor: context.primaryColor,
                style: TextStyle(color: context.primaryTextColor),

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

  Widget _buildSchemeList(SchemeState state) {
    if (state is SchemeLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (state is SchemeError) {
      return Center(
        child: Text(
          state.message,
          style: TextStyle(color: context.appColors.error),
        ),
      );
    }

    if (state is SchemeLoaded) {
      if (state.schemes.isEmpty) {
        return Center(
          child: Text(
            'No Scheme Found',
            style: TextStyle(color: context.secondaryTextColor, fontSize: 15),
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

    return Center(
      child: Text(
        'No Scheme Found',
        style: TextStyle(color: context.secondaryTextColor, fontSize: 15),
      ),
    );
  }

  Widget _buildSchemeCard(SchemeEntity item) {
    final String image = item.fldImage ?? '';

    final String url = fileUrl(image);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.05),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
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
                        color: context.appColors.primaryContainer,

                        child: Center(
                          child: Icon(
                            Icons.picture_as_pdf,
                            size: 60,
                            color: context.appColors.error,
                          ),
                        ),
                      )
                    : Image.network(
                        url,

                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: context.secondaryTextColor,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  item.fldRemark ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: context.cardTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String fileUrl(String file) {
    final String value = file.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    return '${ApiClient.imageBaseUrl}Scheme/$value';
  }

  bool isPdf(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),

      child: child,
    );
  }
}
