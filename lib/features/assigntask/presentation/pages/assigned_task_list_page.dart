import '../widgets/task_image_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_theme_context.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/assigned_task.dart';
import '../bloc/assigned_task_bloc.dart';

// ========================================================
// THEME
// ========================================================

const Color kTaskOverdue = Color(0xFFDC2626);
const Color kTaskOverdueBg = Color(0xFFFFF8F8);
const Color kTaskOverdueBorder = Color(0xFFF1B8B8);

const Color kTaskPending = Color(0xFFD97706);

// ========================================================
// ASSIGNED TASK LIST PAGE
// ========================================================

class AssignedTaskListPage extends StatefulWidget {
  const AssignedTaskListPage({
    super.key,
    this.imageBaseUrl = ApiClient.baseUrlForAssignTask,
    this.employees = const [],
  });

  final String imageBaseUrl;
  final List<AssignedTaskEmployee> employees;

  @override
  State<AssignedTaskListPage> createState() => _AssignedTaskListPageState();
}

class _AssignedTaskListPageState extends State<AssignedTaskListPage> {
  final TextEditingController _searchController = TextEditingController();

  AssignedTaskFilter _draft = const AssignedTaskFilter();

  String _selectedSummary = 'Total';
  bool _showFilters = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    context.read<AssignedTaskBloc>().add(const LoadAssignedTasks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ========================================================
  // TASK STATUS
  // ========================================================

  bool _isOverdue(AssignedTask task) {
    // Display overdue only when fld_overdue_status is 1.
    return task.isOverdue;
  }

  bool _isPending(AssignedTask task) {
    return task.status.trim() == '0';
  }

  bool _isCompleted(AssignedTask task) {
    return task.status.trim() == '1';
  }

  // ========================================================
  // LOAD TASKS
  // ========================================================

  void _loadTasks() {
    FocusManager.instance.primaryFocus?.unfocus();

    context.read<AssignedTaskBloc>().add(LoadAssignedTasks(filter: _draft));
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _draft = const AssignedTaskFilter();
      _searchQuery = '';
    });

    _loadTasks();
  }

  Future<void> _refresh() async {
    final bloc = context.read<AssignedTaskBloc>();

    final completed = bloc.stream
        .skipWhile((state) => !state.loading)
        .firstWhere((state) => !state.loading);

    bloc.add(LoadAssignedTasks(filter: _draft));

    await completed;
  }

  Future<void> _pickDate(bool from) async {
    final current = from ? _draft.fromDate : _draft.toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    final other = from ? _draft.toDate : _draft.fromDate;
    if (other != null &&
        (from ? picked.isAfter(other) : picked.isBefore(other))) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid date range')));
      return;
    }
    setState(() {
      _draft = from
          ? _draft.copyWith(fromDate: picked)
          : _draft.copyWith(toDate: picked);
    });
  }

  Widget _dateFilter(bool from) {
    final date = from ? _draft.fromDate : _draft.toDate;
    final label = from ? 'From Date' : 'To Date';
    return Expanded(
      child: TextFormField(
        key: ValueKey('$label:$date'),
        initialValue: date == null ? '' : DateFormat('dd-MM-yyyy').format(date),
        readOnly: true,
        onTap: () => _pickDate(from),
        style: TextStyle(fontSize: 12, color: context.primaryTextColor),
        decoration: _inputDecoration(label, Icons.calendar_month_outlined)
            .copyWith(
              suffixIcon: date == null
                  ? null
                  : IconButton(
                      tooltip: 'Clear date',
                      icon: const Icon(Icons.close, size: 17),
                      onPressed: () => setState(() {
                        _draft = from
                            ? _draft.copyWith(clearDate: true)
                            : _draft.copyWith(clearToDate: true);
                      }),
                    ),
            ),
      ),
    );
  }
  // ========================================================
  // INPUT DECORATION
  // ========================================================

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 12),
      prefixIcon: Icon(icon, color: context.primaryColor, size: 18),
      isDense: true,
      filled: true,
      fillColor: context.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: context.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: context.primaryColor),
      ),
    );
  }

  // ========================================================
  // FILTER PANEL
  // ========================================================

  Widget _filterPanel() {
    final validEmployee = widget.employees.any(
      (employee) => employee.id == _draft.employeeId,
    );

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // PRIORITY FILTER
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('priority_${_draft.priority}'),
                  initialValue: _draft.priority,
                  isExpanded: true,
                  decoration: _inputDecoration('Priority', Icons.flag_outlined),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All')),
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _draft = _draft.copyWith(priority: value ?? '');
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              // STATUS FILTER
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('status_${_draft.status}'),
                  initialValue: _draft.status,
                  isExpanded: true,
                  decoration: _inputDecoration(
                    'Status',
                    Icons.task_alt_outlined,
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All')),
                    DropdownMenuItem(value: '0', child: Text('Pending')),
                    DropdownMenuItem(value: '1', child: Text('Completed')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _draft = _draft.copyWith(status: value ?? '');
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              _dateFilter(true),
              const SizedBox(width: 8),
              _dateFilter(false),
            ],
          ),
          const SizedBox(height: 9),
          // EMPLOYEE FILTER
          DropdownButtonFormField<String>(
            key: ValueKey('employee_${_draft.employeeId}'),
            initialValue: validEmployee ? _draft.employeeId : '',
            isExpanded: true,
            decoration: _inputDecoration('Employee', Icons.person_outline),
            items: [
              const DropdownMenuItem(value: '', child: Text('All Employees')),
              ...widget.employees
                  .where((e) => e.id.isNotEmpty)
                  .map(
                    (employee) => DropdownMenuItem<String>(
                      value: employee.id,
                      child: Text(
                        employee.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
            ],
            onChanged: (value) {
              setState(() {
                _draft = _draft.copyWith(employeeId: value ?? '');
              });
            },
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              TextButton.icon(
                onPressed: _clearFilters,
                icon: Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Clear'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  _loadTasks();

                  setState(() {
                    _showFilters = false;
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.cardBackgroundColor,
                ),
                icon: Icon(Icons.check, size: 18),
                label: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================================
  // DASHBOARD SUMMARY
  // ========================================================

  Widget _summary({
    required int total,
    required int pending,
    required int completed,
    required int overdue,
  }) {
    Widget item(String title, int count, IconData icon, Color color) {
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _selectedSummary = title),
          borderRadius: BorderRadius.circular(11),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: _selectedSummary == title ? color : context.borderColor,
                width: _selectedSummary == title ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 19),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.secondaryTextColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        item('Total', total, Icons.assignment_outlined, context.primaryColor),
        const SizedBox(width: 6),
        item('Pending', pending, Icons.pending_actions_rounded, kTaskPending),
        const SizedBox(width: 6),
        item('Overdue', overdue, Icons.warning_amber_rounded, kTaskOverdue),
        const SizedBox(width: 6),
        item('Done', completed, Icons.task_alt_rounded, context.primaryColor),
      ],
    );
  }

  // ========================================================
  // BUILD PAGE
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,

      // appBar: AppBar(
      //   backgroundColor: context.primaryColor,
      //   foregroundColor: context.cardBackgroundColor,
      //   elevation: 0,
      //   title: const Text(
      //     'Assigned Tasks List',
      //     style: TextStyle(
      //       fontSize: 18,
      //       fontWeight: FontWeight.w800,
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //       tooltip: 'Filters',
      //       onPressed: () {
      //         setState(() {
      //           _showFilters = !_showFilters;
      //         });
      //       },
      //       icon: Icon(
      //         Icons.tune_rounded,
      //       ),
      //     ),
      //     IconButton(
      //       tooltip: 'Refresh',
      //       onPressed: _loadTasks,
      //       icon: Icon(
      //         Icons.refresh_rounded,
      //       ),
      //     ),
      //   ],
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
          onPressed: () => context.go(AppRouter.home),
        ),

        action: Row(
          children: [
            IconButton(
              tooltip: 'Show / Hide Filters',
              icon: Icon(Icons.tune_rounded, color: context.onPrimaryColor),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),

            IconButton(
              tooltip: 'Refresh',
              onPressed: _loadTasks,
              icon: Icon(Icons.refresh_rounded),
            ),
          ],
        ),

        title: 'Assigned Tasks List',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
      ),

      body: BlocBuilder<AssignedTaskBloc, AssignedTaskState>(
        builder: (context, state) {
          final query = _searchQuery.trim().toLowerCase();

          // Keep your existing search logic.
          final summaryTasks = state.tasks.where((task) {
            if (query.isEmpty) return true;

            return task.title.toLowerCase().contains(query) ||
                task.description.toLowerCase().contains(query) ||
                task.assigneeName.toLowerCase().contains(query);
          }).toList();

          // ============================================
          // OVERDUE TASKS FIRST
          // ============================================

          final tasks = summaryTasks.where((task) {
            switch (_selectedSummary) {
              case 'Pending':
                return _isPending(task);
              case 'Done':
                return _isCompleted(task);
              case 'Overdue':
                return _isOverdue(task);
              default:
                return true;
            }
          }).toList();

          tasks.sort((a, b) {
            final aOverdue = _isOverdue(a);
            final bOverdue = _isOverdue(b);

            if (aOverdue != bOverdue) {
              return aOverdue ? -1 : 1;
            }

            // Preserve descending task-date order.
            final aDate = a.taskDate;
            final bDate = b.taskDate;

            if (aDate == null && bDate == null) {
              return 0;
            }

            if (aDate == null) return 1;
            if (bDate == null) return -1;

            return bDate.compareTo(aDate);
          });

          // ============================================
          // SUMMARY COUNTS
          // ============================================

          final totalCount = summaryTasks.length;

          final pendingCount = summaryTasks.where(_isPending).length;

          final completedCount = summaryTasks.where(_isCompleted).length;

          final overdueCount = summaryTasks.where(_isOverdue).length;

          return RefreshIndicator(
            color: context.primaryColor,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
              children: [
                // =====================================
                // SUMMARY
                // =====================================

                _summary(
                  total: totalCount,
                  pending: pendingCount,
                  completed: completedCount,
                  overdue: overdueCount,
                ),

                const SizedBox(height: 10),

                // =====================================
                // OPTIONAL SEARCH FIELD
                // =====================================

                // TextField(
                //   controller: _searchController,
                //   onChanged: (value) {
                //     setState(() => _searchQuery = value);
                //   },
                //   decoration: _inputDecoration(
                //     'Search task or employee',
                //     Icons.search_rounded,
                //   ),
                // ),

                // =====================================
                // FILTERS
                // =====================================
                if (_showFilters) ...[
                  const SizedBox(height: 9),
                  _filterPanel(),
                ],

                const SizedBox(height: 15),

                // =====================================
                // TASK LIST HEADING
                // =====================================
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedSummary == 'Total'
                            ? 'Task List'
                            : _selectedSummary == 'Done'
                            ? 'Completed Tasks'
                            : '$_selectedSummary Tasks',
                        style: TextStyle(
                          color: context.primaryTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${tasks.length} Tasks',
                      style: TextStyle(
                        color: context.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // =====================================
                // LOADING
                // =====================================
                if (state.loading)
                  Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: context.primaryColor,
                      ),
                    ),
                  ),

                // =====================================
                // ERROR
                // =====================================
                if (!state.loading && state.errorMessage.isNotEmpty)
                  _MessageCard(
                    message: state.errorMessage,
                    icon: Icons.error_outline,
                    action: _loadTasks,
                  ),

                // =====================================
                // EMPTY
                // =====================================
                if (!state.loading &&
                    state.errorMessage.isEmpty &&
                    tasks.isEmpty)
                  const _MessageCard(
                    message: 'No assigned tasks found',
                    icon: Icons.assignment_outlined,
                  ),

                // =====================================
                // TASK CARDS
                // =====================================
                if (!state.loading && state.errorMessage.isEmpty)
                  ...tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _AssignedTaskCard(
                        task: task,
                        imageBaseUrl: widget.imageBaseUrl,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ========================================================
// EMPTY / ERROR CARD
// ========================================================

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.icon, this.action});

  final String message;
  final IconData icon;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: context.primaryColor),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.secondaryTextColor, fontSize: 12),
          ),
          if (action != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: action, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

// ========================================================
// COMPACT ASSIGNED TASK CARD
// NO EXPANSION ICON
// ========================================================

class _AssignedTaskCard extends StatelessWidget {
  const _AssignedTaskCard({required this.task, required this.imageBaseUrl});

  final AssignedTask task;
  final String imageBaseUrl;

  Future<void> _viewCompletionDetails(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: dialogContext.cardBackgroundColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 480,
            maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
                color: dialogContext.primaryColor.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: dialogContext.primaryColor.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.task_alt_rounded,
                        color: dialogContext.primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Completion Details',
                            style: TextStyle(
                              color: dialogContext.primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (task.completedDate.trim().isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              task.completedDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: dialogContext.secondaryTextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: dialogContext.secondaryTextColor,
                        size: 21,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: dialogContext.primaryTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (task.remark.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: dialogContext.appTheme.inputBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: dialogContext.borderColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COMPLETION REMARK',
                                style: TextStyle(
                                  color: dialogContext.secondaryTextColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.7,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                task.remark.trim(),
                                style: TextStyle(
                                  color: dialogContext.primaryTextColor,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 16,
                            color: dialogContext.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Task Photos',
                            style: TextStyle(
                              color: dialogContext.primaryTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Tap to enlarge',
                            style: TextStyle(
                              color: dialogContext.secondaryTextColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      TaskImageRow(
                        taskImageUrl: _imageUrl(task.image),
                        completedImageUrl: _imageUrl(task.completedImage),
                      ),
                      if ((_imageUrl(task.image)?.trim().isEmpty ?? true) &&
                          (_imageUrl(task.completedImage)?.trim().isEmpty ??
                              true))
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'No photos attached.',
                            style: TextStyle(
                              color: dialogContext.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
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

  bool get _isOverdue => task.isOverdue;

  bool get _isPending => task.status.trim() == '0';

  bool get _isCompleted => task.status.trim() == '1';

  // ========================================================
  // STATUS LABEL
  // ========================================================

  String get _statusText {
    if (_isPending) return 'Pending';

    if (_isCompleted) return 'Completed';

    return task.statusText;
  }

  // ========================================================
  // PRIORITY COLOR
  // ========================================================

  Color _priorityColor(BuildContext context) {
    switch (task.priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFD34832);

      case 'medium':
        return const Color(0xFFB5740A);

      case 'urgent':
        return const Color(0xFFDC2626);

      default:
        return context.primaryColor;
    }
  }

  Color _statusColor(BuildContext context) {
    if (_isCompleted) return context.primaryColor;
    if (_isPending) return kTaskPending;

    return context.secondaryTextColor;
  }

  IconData get _statusIcon {
    if (_isCompleted) {
      return Icons.check_circle_rounded;
    }

    if (_isPending) {
      return Icons.pending_actions_rounded;
    }

    return Icons.info_outline;
  }

  // ========================================================
  // DATE FORMAT
  // ========================================================

  String _formatDate(DateTime? value) {
    if (value == null) return '-';

    return DateFormat('dd MMM, hh:mm a').format(value);
  }

  // ========================================================
  // IMAGE URL
  // ========================================================

  String? _imageUrl(String filename) {
    final value = filename.trim();

    if (value.isEmpty || value.toLowerCase() == 'null') {
      return null;
    }

    final parsed = Uri.tryParse(value);

    if (parsed != null &&
        (parsed.scheme == 'https' || parsed.scheme == 'http') &&
        parsed.hasAuthority) {
      return value;
    }

    // Filename from API, e.g. TASK_IMAGE_123.png
    if (value.contains('/') || value.contains('\\')) {
      return null;
    }

    final base = imageBaseUrl.endsWith('/') ? imageBaseUrl : '$imageBaseUrl/';

    return Uri.parse(base).resolve(Uri.encodeComponent(value)).toString();
  }

  // ========================================================
  // BADGE
  // ========================================================

  Widget _badge({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // DATE CELL
  // ========================================================

  Widget _dateCell(
    BuildContext context,
    String label,
    DateTime? value, {
    bool warning = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFEDED) : context.backgroundColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 15,
            color: warning ? kTaskOverdue : context.primaryColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: warning ? kTaskOverdue : context.secondaryTextColor,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(value),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: warning ? kTaskOverdue : context.primaryTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // MAIN CARD
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isOverdue ? kTaskOverdueBg : context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isCompleted
              ? Colors.green
              : (_isOverdue ? kTaskOverdueBorder : context.borderColor),
          width: _isCompleted ? 2 : (_isOverdue ? 1.2 : 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // OVERDUE HEADER
          // ============================================

          if (_isOverdue)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEAEA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: kTaskOverdue,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'OVERDUE TASK',
                    style: TextStyle(
                      color: kTaskOverdue,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====================================
                // TASK TITLE + PRIORITY
                // ====================================

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _isOverdue
                            ? const Color(0xFFFFE4E4)
                            : context.primaryColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        _isOverdue
                            ? Icons.warning_amber_rounded
                            : Icons.assignment_outlined,
                        size: 19,
                        color: _isOverdue ? kTaskOverdue : context.primaryColor,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title.isEmpty
                                ? 'Task : Untitled Task'
                                : 'Task : ${task.title}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.primaryTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 13,
                                color: context.secondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Assigned by : ${task.assigneeName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.secondaryTextColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 7),

                    _badge(
                      text: task.priority,
                      color: _priorityColor(context),
                      icon: Icons.flag_outlined,
                    ),
                  ],
                ),

                // ====================================
                // DESCRIPTION
                // ====================================
                if (task.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Text(
                    'Description : ${task.description}',
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // ====================================
                // ASSIGNED DATE / DUE DATE
                // ====================================
                Row(
                  children: [
                    Expanded(
                      child: _dateCell(context, 'Assigned', task.taskDate),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _dateCell(
                        context,
                        'Due Date',
                        task.dueDate,
                        warning: _isOverdue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ====================================
                // TWO INDEPENDENT STATUS BADGES
                // ====================================
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          // Actual task status.
                          _badge(
                            text: _statusText,
                            color: _statusColor(context),
                            icon: _statusIcon,
                          ),

                          // Backend overdue flag.
                          if (_isOverdue)
                            _badge(
                              text: 'Overdue',
                              color: kTaskOverdue,
                              icon: Icons.warning_amber_rounded,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _viewCompletionDetails(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.primaryColor,
                        side: BorderSide(color: context.primaryColor),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      icon: const Icon(Icons.visibility_outlined, size: 15),
                      label: const Text('View', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
