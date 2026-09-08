import 'package:flutter/material.dart';

import '../../domain/entities/assign_employee.dart';

class EmployeeOutputFilter extends StatelessWidget {
  final TextEditingController employeeController;

  final String employeeId;

  final String fromDate;

  final String toDate;

  final bool expanded;

  final List<AssignEmployee> employees;

  final bool employeeLoading;

  final VoidCallback onExpandChanged;

  final ValueChanged<String> onEmployeeChanged;

  final ValueChanged<AssignEmployee>
      onEmployeeSelected;

  final VoidCallback onFromDateTap;

  final VoidCallback onToDateTap;

  final VoidCallback onReset;

  final VoidCallback onSearch;

  const EmployeeOutputFilter({
    super.key,
    required this.employeeController,
    required this.employeeId,
    required this.fromDate,
    required this.toDate,
    required this.expanded,
    required this.employees,
    required this.employeeLoading,
    required this.onExpandChanged,
    required this.onEmployeeChanged,
    required this.onEmployeeSelected,
    required this.onFromDateTap,
    required this.onToDateTap,
    required this.onReset,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ======================================================
          // FILTER HEADER
          // ======================================================

          InkWell(
            borderRadius:
                BorderRadius.circular(16),
            onTap: onExpandChanged,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 13,
              ),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFEAF6EE),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.filter_alt_outlined,
                      color:
                          Color(0xFF287A4B),
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 11),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search & Filter',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(0xFF202923),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Employee name and date range',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Color(0xFF7A837E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    expanded
                        ? Icons
                            .keyboard_arrow_up_rounded
                        : Icons
                            .keyboard_arrow_down_rounded,
                    color:
                        const Color(0xFF59645E),
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // FILTER BODY
          // ======================================================

          if (expanded) ...[
            const Divider(height: 1),

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                14,
                14,
                14,
                14,
              ),
              child: Column(
                children: [
                  // ==================================================
                  // EMPLOYEE LABEL
                  // ==================================================

                  const _FieldLabel(
                    icon:
                        Icons.person_outline_rounded,
                    title: 'Employee',
                  ),

                  const SizedBox(height: 7),

                  // ==================================================
                  // EMPLOYEE TEXT FIELD
                  // ==================================================

                  TextField(
                    controller:
                        employeeController,

                    onChanged:
                        onEmployeeChanged,

                    decoration:
                        InputDecoration(
                      hintText:
                          'Search employee name',

                      hintStyle:
                          const TextStyle(
                        fontSize: 13,
                        color:
                            Color(0xFF9AA19D),
                      ),

                      prefixIcon:
                          const Icon(
                        Icons.search_rounded,
                        size: 20,
                      ),

                      suffixIcon:
                          employeeController
                                  .text
                                  .isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    employeeController
                                        .clear();

                                    onEmployeeChanged(
                                      '',
                                    );
                                  },
                                  icon:
                                      const Icon(
                                    Icons
                                        .close_rounded,
                                    size: 18,
                                  ),
                                )
                              : null,

                      filled: true,

                      fillColor:
                          const Color(0xFFF7F9F8),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                11),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  // ==================================================
                  // LOADING
                  // ==================================================

                  if (employeeLoading)
                    const Padding(
                      padding:
                          EdgeInsets.only(
                        top: 6,
                      ),
                      child: Align(
                        alignment:
                            Alignment.centerRight,
                        child: SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),

                  // ==================================================
                  // EMPLOYEE SUGGESTIONS
                  // ==================================================

                  if (employees.isNotEmpty)
                    Container(
                      margin:
                          const EdgeInsets.only(
                        top: 4,
                      ),

                      constraints:
                          const BoxConstraints(
                        maxHeight: 190,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                                10),
                        border: Border.all(
                          color:
                              const Color(
                                  0xFFE0E5E2),
                        ),
                      ),

                      child:
                          ListView.separated(
                        shrinkWrap: true,

                        itemCount:
                            employees.length,

                        separatorBuilder:
                            (_, __) =>
                                const Divider(
                          height: 1,
                        ),

                        itemBuilder:
                            (context, index) {
                          final employee =
                              employees[index];

                          return InkWell(
                            onTap: () {
                              onEmployeeSelected(
                                employee,
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 32,
                                    width: 32,
                                    decoration:
                                        const BoxDecoration(
                                      color: Color(
                                          0xFFEAF6EE),
                                      shape:
                                          BoxShape.circle,
                                    ),
                                    child:
                                        const Icon(
                                      Icons
                                          .person_outline,
                                      size: 17,
                                      color: Color(
                                          0xFF287A4B),
                                    ),
                                  ),

                                  const SizedBox(
                                      width: 9),

                                  Expanded(
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          employee
                                              .fldAdmName
                                              .toString(),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                13,
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 2),

                                        Text(
                                          'ID: ${employee.fldId}',
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                10,
                                            color: Color(
                                                0xFF7A837E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // DATES
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          title: 'From Date',
                          value: fromDate,
                          onTap:
                              onFromDateTap,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _DateField(
                          title: 'To Date',
                          value: toDate,
                          onTap:
                              onToDateTap,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // BUTTONS
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child:
                            OutlinedButton.icon(
                          onPressed: onReset,

                          icon: const Icon(
                            Icons
                                .restart_alt_rounded,
                            size: 18,
                          ),

                          label:
                              const Text('Reset'),

                          style:
                              OutlinedButton.styleFrom(
                            foregroundColor:
                                const Color(
                                    0xFF59645E),

                            side:
                                const BorderSide(
                              color: Color(
                                  0xFFD8DEDA),
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      11),
                            ),

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child:
                            ElevatedButton.icon(
                          onPressed: onSearch,

                          icon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                          ),

                          label:
                              const Text('Search'),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                                    0xFF287A4B),

                            foregroundColor:
                                Colors.white,

                            elevation: 0,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      11),
                            ),

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 13,
                            ),
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

// ================================================================
// FIELD LABEL
// ================================================================

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
          size: 17,
          color:
              const Color(0xFF287A4B),
        ),

        const SizedBox(width: 6),

        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF39423D),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// DATE FIELD
// ================================================================

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
    return InkWell(
      borderRadius:
          BorderRadius.circular(11),

      onTap: onTap,

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 10,
        ),

        decoration:
            BoxDecoration(
          color:
              const Color(0xFFF7F9F8),

          borderRadius:
              BorderRadius.circular(11),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 17,
              color:
                  Color(0xFF287A4B),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 9,
                      color:
                          Color(0xFF7A837E),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    value,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFF202923),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}