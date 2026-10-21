import 'package:solufine/features/schedule/domain/entities/schedule_farmer_entity.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:solufine/core/router/app_router.dart';

import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/plot_entities.dart';
import '../../data/models/plot_model.dart';
import '../bloc/plot_bloc.dart';

class PlotRegistrationPage extends StatefulWidget {
  final ScheduleFarmerEntity farmer;
  const PlotRegistrationPage({super.key, required this.farmer});

  @override
  State<PlotRegistrationPage> createState() => _PlotRegistrationPageState();
}

class _PlotRegistrationPageState extends State<PlotRegistrationPage> {
  String _empId = '';
  bool _loadingUser = true;
  bool _showDraftErrors = false;

  final Set<String> _expanded = {};
  final Map<String, TextEditingController> _names = {};

  @override
  void initState() {
    super.initState();
    context.read<PlotBloc>().add(
      SetRegistrationFarmer(
        FarmerOption(
          id: widget.farmer.farmerId,
          name: widget.farmer.farmerName,
          talukaName: widget.farmer.talukaName,
          plotStatus: widget.farmer.farmerPlotStatus,
        ),
      ),
    );
    _readUser();
  }

  Future<void> _readUser() async {
    try {
      final data = await SecureStorage.instance.getUserData();

      if (!mounted) return;

      setState(() {
        _empId = (data?['user_id'] ?? data?['userId'] ?? '').toString().trim();
        _loadingUser = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingUser = false;
      });

      _toast('Unable to read user: $e');
    }
  }

  @override
  void dispose() {
    for (final controller in _names.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toast(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  TextEditingController _nameController(PlotEntry plot) {
    return _names.putIfAbsent(
      plot.localId,
      () => TextEditingController(text: plot.plotName),
    );
  }

  Future<void> _selectDate(PlotEntry plot) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: plot.sowingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (!mounted || selected == null) return;

    context.read<PlotBloc>().add(UpdatePlotDateEvent(plot.localId, selected));
  }

  void _addPlot() {
    final bloc = context.read<PlotBloc>();

    if (bloc.state.plots.isEmpty) return;
    final plot = bloc.state.plots.last;
    final name = _nameController(plot).text.trim();
    setState(() => _showDraftErrors = true);
    String? error;
    if (name.isEmpty) {
      error = 'Please enter the plot name.';
    } else if (plot.farmer == null) {
      error = 'Please select a farmer.';
    } else if (plot.crop == null) {
      error = 'Please select a crop.';
    } else if (plot.crop!.id.trim().isEmpty) {
      error = 'Crop ID is missing from the Crop API.';
    } else if (plot.sowingDate == null) {
      error = 'Please select the sowing date.';
    }
    if (error != null) {
      _toast(error);
      return;
    }
    setState(() => _showDraftErrors = false);
    FocusScope.of(context).unfocus();
    bloc.add(AddPlotEvent(plotName: name));
  }

  void _removePlot(PlotEntry plot) {
    context.read<PlotBloc>().add(RemovePlotEvent(plot.localId));

    _expanded.remove(plot.localId);
  }

  // Submit ALL completed plots, including the current plot.
  // Only a completely blank trailing draft is excluded.
  void _submit() {
    if (_loadingUser) return;
    if (_empId.isEmpty || _empId == '0') {
      _toast('Please log in again');
      return;
    }

    final bloc = context.read<PlotBloc>();
    if (bloc.state.submitStatus == PlotSubmitStatus.submitting ||
        bloc.state.submitStatus == PlotSubmitStatus.success)
      return;

    final entries = bloc.state.plots;
    final plots = entries.where((p) => !p.isBlank).toList();

    if (plots.isEmpty) {
      _toast('Please complete at least one plot');
      return;
    }

    // Include pending text in the current TextField even if a BLoC
    // update has not finished processing yet.
    if (entries.isNotEmpty && !entries.last.isBlank) {
      final last = entries.last;
      final actualName = _nameController(last).text.trim();
      if (actualName != last.plotName.trim()) {
        bloc.add(UpdatePlotNameEvent(last.localId, actualName));
        _toast('Plot name updated. Tap Submit All again.');
        return;
      }
    }

    for (var i = 0; i < plots.length; i++) {
      final plot = plots[i];
      if (!plot.isComplete) {
        setState(() => _showDraftErrors = true);
        if (plot.crop != null && plot.crop!.id.trim().isEmpty) {
          _toast(
            'Crop ID is missing for ${plot.crop!.name}. Ask backend to return fld_crop_id.',
          );
        } else {
          _toast('Complete all fields for Plot ${i + 1} before submitting.');
        }
        return;
      }
    }

    final payload = PlotModel.toJson(
      PlotSubmission(empId: _empId, plots: plots),
    );
    debugPrint('========== FINAL /addPlot POST JSON ==========');
    debugPrint(const JsonEncoder.withIndent('  ').convert(payload));
    FocusScope.of(context).unfocus();
    bloc.add(SubmitPlotsEvent(_empId));
  }

  List<PlotEntry> _listedPlots(PlotState state) =>
      state.submitStatus == PlotSubmitStatus.success
      ? state.plots.where((plot) => !plot.isBlank).toList()
      : state.plots
            .take(state.plots.isEmpty ? 0 : state.plots.length - 1)
            .toList();

  InputDecoration _fieldDecoration(String label, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      isDense: true,
      filled: true,
      fillColor: colors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
    );
  }

  Widget _pickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback? onTap,
    String? errorText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: value.isEmpty,
        decoration: _fieldDecoration(label, icon).copyWith(
          enabled: onTap != null,
          errorText: errorText,
          suffixIcon: const Icon(Icons.expand_more_rounded, size: 20),
        ),
        child: Text(
          value.isEmpty ? ' ' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  bool _hasDraftValues(PlotEntry plot) =>
      plot.plotName.trim().isNotEmpty ||
      plot.farmer != null ||
      plot.crop != null ||
      plot.sowingDate != null;

  Widget _summaryDetail(IconData icon, String text) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: colors.primary),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _plotSummary(
    PlotEntry plot,
    PlotState state, {
    bool showFarmer = true,
  }) {
    final colors = Theme.of(context).colorScheme;
    final locked =
        state.submitStatus == PlotSubmitStatus.submitting ||
        state.submitStatus == PlotSubmitStatus.success;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.landscape_rounded, size: 21, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plot.plotName.trim().isEmpty
                        ? 'Unnamed plot'
                        : plot.plotName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove plot',
                  onPressed: locked ? null : () => _removePlot(plot),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: locked ? colors.onSurfaceVariant : colors.error,
                  ),
                ),
              ],
            ),
            if (showFarmer) ...[
              _summaryDetail(
                Icons.person_outline_rounded,
                plot.farmer?.name ?? 'Farmer not selected',
              ),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _summaryDetail(
                  Icons.spa_outlined,
                  plot.crop?.name ?? 'Crop not selected',
                ),
                _summaryDetail(
                  Icons.calendar_today_outlined,
                  plot.sowingDate == null
                      ? 'Date not selected'
                      : PlotModel.formatDate(plot.sowingDate!),
                ),
              ],
            ),
            if (plot.crop != null && plot.crop!.id.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Crop ID unavailable from server',
                  style: TextStyle(fontSize: 11, color: colors.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _addedPlots(PlotState state) {
    final plots = _listedPlots(state);
    if (plots.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Added plots',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${plots.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...plots.map((plot) => _plotSummary(plot, state)),
      ],
    );
  }

  bool _isComplete(PlotEntry plot) =>
      plot.plotName.trim().isNotEmpty &&
      plot.farmer?.id.isNotEmpty == true &&
      plot.crop?.id.isNotEmpty == true &&
      plot.sowingDate != null;

  Widget _plotCard(PlotEntry plot, int index, PlotState state) {
    final colors = Theme.of(context).colorScheme;
    final expanded =
        _expanded.contains(plot.localId) ||
        !_expanded.contains('closed_${plot.localId}');
    final submitting =
        state.submitStatus == PlotSubmitStatus.submitting ||
        state.submitStatus == PlotSubmitStatus.success;
    final complete = _isComplete(plot);
    final cropField = DropdownButtonFormField<String>(
      key: ValueKey('${plot.localId}_${plot.crop?.id ?? ""}'),
      initialValue: plot.crop?.name,
      isExpanded: true,
      decoration: _fieldDecoration('Crop', Icons.spa_outlined).copyWith(
        errorText: _showDraftErrors && plot.crop == null
            ? 'Select a crop'
            : null,
      ),
      items: state.crops
          .map(
            (crop) => DropdownMenuItem(
              value: crop.name,
              child: Text(
                crop.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: submitting || state.loadingCrops
          ? null
          : (name) {
              if (name == null) return;
              context.read<PlotBloc>().add(
                UpdatePlotCropEvent(
                  plot.localId,
                  state.crops.firstWhere((crop) => crop.name == name),
                ),
              );
            },
    );
    final dateField = _pickerField(
      label: 'Sowing date',
      errorText: _showDraftErrors && plot.sowingDate == null
          ? 'Select sowing date'
          : null,
      value: plot.sowingDate == null
          ? ''
          : PlotModel.formatDate(plot.sowingDate!),
      icon: Icons.calendar_today_outlined,
      onTap: submitting ? null : () => _selectDate(plot),
    );
    return Card(
      key: ValueKey(plot.localId),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: complete
              ? colors.primary.withValues(alpha: .35)
              : colors.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(
              plot.plotName.trim().isEmpty
                  ? 'Plot ${index + 1}'
                  : plot.plotName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              complete ? 'Ready to register' : 'Complete plot details',
              style: TextStyle(
                fontSize: 12,
                color: complete ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                ),
              ],
            ),
            onTap: () => setState(() {
              if (expanded) {
                _expanded.remove(plot.localId);
                _expanded.add('closed_${plot.localId}');
              } else {
                _expanded.add(plot.localId);
                _expanded.remove('closed_${plot.localId}');
              }
            }),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController(plot),
                    enabled: !submitting,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration:
                        _fieldDecoration(
                          'Plot name',
                          Icons.landscape_outlined,
                        ).copyWith(
                          errorText:
                              _showDraftErrors &&
                                  _nameController(plot).text.trim().isEmpty
                              ? 'Enter plot name'
                              : null,
                        ),
                    onChanged: (value) => context.read<PlotBloc>().add(
                      UpdatePlotNameEvent(plot.localId, value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: _fieldDecoration(
                      'Farmer',
                      Icons.person_outline_rounded,
                    ),
                    child: Text(
                      widget.farmer.farmerName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 330 ||
                          MediaQuery.textScalerOf(context).scale(14) > 19) {
                        return Column(
                          children: [
                            cropField,
                            const SizedBox(height: 12),
                            dateField,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: cropField),
                          const SizedBox(width: 10),
                          Expanded(child: dateField),
                        ],
                      );
                    },
                  ),
                  if (state.loadingCrops)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  if (state.cropError.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: submitting
                            ? null
                            : () => context.read<PlotBloc>().add(
                                const LoadPlotCrops(),
                              ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry loading crops'),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _overview(PlotState state) {
    final colors = Theme.of(context).colorScheme;
    final completed = state.plots.where((plot) => plot.isComplete).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primaryContainer, colors.surfaceContainerLow],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.landscape_rounded, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your plots',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$completed added',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete the form, add it to the list, then submit all plots.',
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: state.plots.isEmpty ? 0 : completed / (completed + 1),
              backgroundColor: colors.surface,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSubmissionSuccess(PlotState state) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: Icon(
            Icons.check_circle_rounded,
            color: Theme.of(dialogContext).colorScheme.primary,
            size: 44,
          ),
          title: const Text('Plots submitted'),
          content: Text(
            state.message.trim().isEmpty
                ? 'Your plots have been registered successfully.'
                : state.message,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (context.canPop()) {
      context.pop(true);
    } else {
      context.go(AppRouter.schedule);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlotBloc, PlotState>(
      listenWhen: (old, current) => old.submitStatus != current.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == PlotSubmitStatus.success) {
          _showSubmissionSuccess(state);
        } else if (state.submitStatus == PlotSubmitStatus.failure) {
          _toast(state.message);
        }
      },
      builder: (context, state) {
        final submitting = state.submitStatus == PlotSubmitStatus.submitting;
        final locked =
            submitting || state.submitStatus == PlotSubmitStatus.success;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,

          // appBar: AppBar(
          //   title: const Text('Plot registration'),
          //   centerTitle: false,
          //   backgroundColor: Theme.of(context).colorScheme.surface,
          // ),
          appBar: CustomAppBar(
            backgroundColor: context.primaryColor,

            titleStyle: AppTextStyles.appBarTitle.copyWith(
              color: context.onPrimaryColor,
            ),

            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: context.onPrimaryColor,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRouter.home);
                }
              },
            ),

            title: 'Plot registration',

            showBackButton: true,
          ),

          body: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              _overview(state),
              if (state.plots.isNotEmpty &&
                  state.submitStatus != PlotSubmitStatus.success)
                _plotCard(state.plots.last, state.plots.length - 1, state),
              OutlinedButton.icon(
                onPressed: locked ? null : _addPlot,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Another Plot'),
              ),
              const SizedBox(height: 10),
              _addedPlots(state),
            ],
          ),
          bottomNavigationBar: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 6,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed:
                            submitting ||
                                _loadingUser ||
                                state.submitStatus == PlotSubmitStatus.success
                            ? null
                            : _submit,
                        icon: submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          submitting ? 'Submitting...' : 'Submit All',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
