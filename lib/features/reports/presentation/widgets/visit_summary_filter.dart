import 'package:flutter/material.dart';

class VisitSummaryFilter extends StatelessWidget {
  final TextEditingController employeeController;

  final String fromDate;
  final String toDate;
  final String selectedStatus;

  final bool expanded;

  final VoidCallback onExpandChanged;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;

  final ValueChanged<String> onStatusChanged;

  final VoidCallback onReset;
  final VoidCallback onSearch;

  const VisitSummaryFilter({
    super.key,
    required this.employeeController,
    required this.fromDate,
    required this.toDate,
    required this.selectedStatus,
    required this.expanded,
    required this.onExpandChanged,
    required this.onFromDateTap,
    required this.onToDateTap,
    required this.onStatusChanged,
    required this.onReset,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ============================================================
          // FILTER HEADER
          // ============================================================
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onExpandChanged,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF6EE),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.filter_alt_outlined,
                      color: Color(0xFF287A4B),
                      size: 19,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search & Filter',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF202923),
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Select date and visit status',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF7A837E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF59645E),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // ============================================================
          // EXPANDED FILTER
          // ============================================================
          if (expanded) ...[
            const Divider(
              height: 1,
              thickness: .7,
              color: Color(0xFFE8ECE9),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                11,
                12,
                11,
              ),
              child: Column(
                children: [
                  // ======================================================
                  // EMPLOYEE
                  // ======================================================
                  const _FieldLabel(
                    icon: Icons.person_outline_rounded,
                    title: 'Employee',
                  ),

                  const SizedBox(height: 5),

                  TextField(
                    controller: employeeController,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF303934),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Employee name',
                      hintStyle: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF9AA19D),
                      ),

                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 19,
                        color: Color(0xFF68736D),
                      ),

                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 42,
                      ),

                      isDense: true,

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 11,
                      ),

                      filled: true,
                      fillColor: const Color(0xFFF7F9F8),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF287A4B),
                          width: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 11),

                  // ======================================================
                  // DATE
                  // ======================================================
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          title: 'From Date',
                          value: fromDate,
                          onTap: onFromDateTap,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: _DateField(
                          title: 'To Date',
                          value: toDate,
                          onTap: onToDateTap,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 11),

                  // ======================================================
                  // STATUS
                  // ======================================================
                  const _FieldLabel(
                    icon: Icons.assessment_outlined,
                    title: 'Status',
                  ),

                  const SizedBox(height: 5),

                  DropdownButtonFormField<String>(
                    value: selectedStatus,

                    isDense: true,

                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF303934),
                    ),

                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF7F9F8),

                      isDense: true,

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 11,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF287A4B),
                          width: 1,
                        ),
                      ),
                    ),

                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: Color(0xFF59645E),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: 'All Status',
                        child: Text('All Status'),
                      ),
                      DropdownMenuItem(
                        value: 'Present',
                        child: Text('Present'),
                      ),
                      DropdownMenuItem(
                        value: 'Absent',
                        child: Text('Absent'),
                      ),
                    ],

                    onChanged: (value) {
                      if (value != null) {
                        onStatusChanged(value);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // ======================================================
                  // BUTTONS
                  // ======================================================
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReset,

                          icon: const Icon(
                            Icons.restart_alt_rounded,
                            size: 17,
                          ),

                          label: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                const Color(0xFF59645E),

                            side: const BorderSide(
                              color: Color(0xFFD8DEDA),
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),

                            minimumSize: const Size(
                              0,
                              40,
                            ),

                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onSearch,

                          icon: const Icon(
                            Icons.search_rounded,
                            size: 17,
                          ),

                          label: const Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF287A4B),

                            foregroundColor: Colors.white,

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),

                            minimumSize: const Size(
                              0,
                              40,
                            ),

                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ========================================================================
// FIELD LABEL
// ========================================================================

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FieldLabel({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: const Color(0xFF287A4B),
        ),

        const SizedBox(width: 5),

        Text(
          title,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4E5953),
          ),
        ),
      ],
    );
  }
}

// ========================================================================
// DATE FIELD
// ========================================================================

class _DateField extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4E5953),
          ),
        ),

        const SizedBox(height: 5),

        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),

          child: Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 11,
            ),

            decoration: BoxDecoration(
              color: const Color(0xFFF7F9F8),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 17,
                  color: Color(0xFF287A4B),
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    value.isEmpty
                        ? 'Select date'
                        : value,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 11.5,

                      color: value.isEmpty
                          ? const Color(0xFF9AA19D)
                          : const Color(0xFF303934),

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}