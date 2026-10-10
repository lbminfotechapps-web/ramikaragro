import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:solufine/core/location_tracking/app_database.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';

import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/features/ai/presentation/bloc/ai_bloc.dart';
import 'package:solufine/features/ai/presentation/bloc/ai_event.dart';
import 'package:solufine/features/ai/presentation/bloc/ai_state.dart';
import 'package:solufine/features/ai/presentation/database/ai_chat_database_operations.dart';

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';

import 'package:get_it/get_it.dart';

// Add your existing CustomAppBar and AppColors imports here.
// import 'package:solufine/.../custom_appbar.dart';
// import 'package:solufine/.../app_colors.dart';

// ============================================================
// OUTPUT TYPE
// ============================================================

enum ChatOutputType { graph, table }

// ============================================================
// CHAT MESSAGE UI MODEL
// ============================================================

class ChatMessage {
  final String text;
  final bool isUser;
  final ChatOutputType? outputType;

  // Complete API response restored from SQLite.
  final Map<String, dynamic>? responseData;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.outputType,
    this.responseData,
  });
}

// ============================================================
// AI CHATBOT SCREEN
// ============================================================

class AiChatbot extends StatefulWidget {
  const AiChatbot({super.key});

  @override
  State<AiChatbot> createState() => _AiChatbotState();
}

class _AiChatbotState extends State<AiChatbot> {
  late final AiChatDatabaseOperations _chatOperations;

  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _userId = 0;
  int? _currentSessionId;
  int? _pendingSessionId;

  ChatOutputType _selectedOutput = ChatOutputType.graph;
  ChatOutputType? _pendingOutputType;

  List<AiChatSession> _chatSessions = [];
  final List<ChatMessage> _messages = [];

  bool _isSending = false;
  bool _isLoadingHistory = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _chatOperations = GetIt.instance<AiChatDatabaseOperations>();

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final userData = await SecureStorage.instance.getUserData();

      _userId = int.tryParse((userData?['user_id'] ?? '').toString()) ?? 0;

      if (_userId <= 0) {
        debugPrint('AI CHAT: Invalid user ID');
        return;
      }

      final deletedCount = await _chatOperations.cleanupOldChatHistory();

      debugPrint('AI CHAT: Deleted $deletedCount expired chats');

      if (!mounted) return;

      await _loadChatHistory();
    } catch (e, stackTrace) {
      debugPrint('AI CHAT INITIALIZATION ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // LOAD CHAT HISTORY FROM SQLITE
  // ============================================================

  Future<void> _loadChatHistory() async {
    if (_userId <= 0 || !mounted) return;

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final sessions = await _chatOperations.getChatSessions(_userId);

      if (!mounted) return;

      setState(() {
        _chatSessions = sessions;
      });
    } catch (e) {
      debugPrint('LOAD CHAT HISTORY ERROR: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  // ============================================================
  // SEND MESSAGE + DISPATCH API EVENT
  // ============================================================

  Future<void> _sendMessage() async {
    final question = _messageController.text.trim();

    if (question.isEmpty || _isSending || _userId <= 0) {
      return;
    }

    final selectedType = _selectedOutput;

    // Capture before creating a new session.
    final isPreviousChat = _currentSessionId != null;

    setState(() {
      _isSending = true;
    });

    try {
      // Create session for the first question.
      if (_currentSessionId == null) {
        _currentSessionId = await _chatOperations.createChatSession(
          userId: _userId,
          title: question.length > 40
              ? '${question.substring(0, 40)}...'
              : question,
        );
      }

      final sessionId = _currentSessionId!;

      // Save user's question in local SQLite.
      await _chatOperations.insertChatMessage(
        sessionId: sessionId,
        message: question,
        isUser: true,
        outputType: selectedType.name,
      );

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(text: question, isUser: true, outputType: selectedType),
        );

        _pendingSessionId = sessionId;
        _pendingOutputType = selectedType;
      });

      _messageController.clear();
      _scrollToBottom();

      await _loadChatHistory();

      if (!mounted) return;

      // Pass selected Graph/Table value to API.
      context.read<AiBloc>().add(
        AskQueryEvent(
          logUserId: _userId.toString(),
          question: question,
          format: selectedType.name,
          usePrevious: isPreviousChat ? '1' : '0',
        ),
      );

      debugPrint('========== AI QUERY ==========');
      debugPrint('Question: $question');
      debugPrint('Format: ${selectedType.name}');
      debugPrint('Use Previous: ${isPreviousChat ? '1' : '0'}');
      debugPrint('Session ID: $sessionId');
    } catch (e, stackTrace) {
      debugPrint('SEND MESSAGE ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isSending = false;
        _pendingSessionId = null;
        _pendingOutputType = null;
      });

      _showError('Unable to send message: $e');
    }
  }

  // ============================================================
  // HANDLE REAL API RESPONSE
  // ============================================================

  Future<void> _handleAiState(AiState state) async {
    if (!_isSending || _pendingSessionId == null) {
      return;
    }

    if (state.aiStatus != AiStatus.success &&
        state.aiStatus != AiStatus.failure) {
      return;
    }

    final sessionId = _pendingSessionId!;
    final selectedType = _pendingOutputType ?? ChatOutputType.graph;

    try {
      if (state.aiStatus == AiStatus.failure) {
        _showError(state.errorMessage ?? 'AI request failed');
        return;
      }

      final response = state.aiResponse;

      if (response == null) {
        _showError('Empty AI response');
        return;
      }
      final responseMap = <String, dynamic>{
        'status': response.status,
        'message': response.message,
        'format': response.format,
        'result': {
          'labels': response.result.labels,
          'values': response.result.values,
          'columns': response.result.columns
              .map((column) => {'key': column.key, 'label': column.label})
              .toList(),
          'rows': response.result.rows,
          'total_rows': response.result.totalRows,
        },
      };
      final responseJson = jsonEncode(responseMap);

      final responseText = response.message.isNotEmpty
          ? response.message
          : response.result.rows.isNotEmpty
          ? 'Here is your result'
          : 'No Record Found';

      // Save real AI response in SQLite.
      await _chatOperations.insertChatMessage(
        sessionId: sessionId,
        message: responseText,
        isUser: false,
        outputType: selectedType.name,
        responseData: responseJson,
      );

      if (!mounted) return;

      if (_currentSessionId == sessionId) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: responseText,
              isUser: false,
              outputType: selectedType,
              responseData: responseMap,
            ),
          );
        });

        _scrollToBottom();
      }

      await _loadChatHistory();

      debugPrint('AI RESPONSE SAVED');
      debugPrint('Format Selected: ${selectedType.name}');
      debugPrint('Rows: ${response.result.totalRows}');
    } catch (e, stackTrace) {
      debugPrint('HANDLE AI RESPONSE ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      _showError('Failed to save AI response: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _pendingSessionId = null;
          _pendingOutputType = null;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // RESTORE SELECTED CHAT FROM SQLITE
  // ============================================================

  Future<void> _openHistory(AiChatSession session) async {
    if (_isSending) return;

    Navigator.pop(context);

    try {
      final savedMessages = await _chatOperations.getChatMessages(
        sessionId: session.id,
        userId: _userId,
      );

      if (!mounted) return;

      setState(() {
        _currentSessionId = session.id;

        _messages.clear();

        for (final saved in savedMessages) {
          Map<String, dynamic>? responseMap;

          if (saved.responseData.isNotEmpty) {
            try {
              final decoded = jsonDecode(saved.responseData);

              if (decoded is Map) {
                responseMap = Map<String, dynamic>.from(decoded);
              }
            } catch (e) {
              debugPrint('RESTORE RESPONSE JSON ERROR: $e');
            }
          }

          _messages.add(
            ChatMessage(
              text: saved.message,
              isUser: saved.isUser,
              outputType: _parseOutputType(saved.outputType),
              responseData: responseMap,
            ),
          );
        }

        _selectedOutput = ChatOutputType.graph;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('OPEN HISTORY ERROR: $e');
      _showError('Unable to load chat');
    }
  }

  ChatOutputType? _parseOutputType(String value) {
    switch (value.toLowerCase()) {
      case 'graph':
        return ChatOutputType.graph;
      case 'table':
        return ChatOutputType.table;
      default:
        return null;
    }
  }

  // ============================================================
  // DELETE CHAT
  // ============================================================

  Future<void> _deleteHistory(AiChatSession session) async {
    if (_isSending) return;

    try {
      await _chatOperations.deleteChatSession(
        sessionId: session.id,
        userId: _userId,
      );

      if (!mounted) return;

      if (_currentSessionId == session.id) {
        _resetChat();
      }

      await _loadChatHistory();
    } catch (e) {
      debugPrint('DELETE CHAT ERROR: $e');
      _showError('Unable to delete chat');
    }
  }

  // ============================================================
  // RESET / NEW CHAT
  // ============================================================

  void _resetChat() {
    if (_isSending) return;

    setState(() {
      _currentSessionId = null;
      _messages.clear();
      _messageController.clear();
      _selectedOutput = ChatOutputType.graph;
    });

    context.read<AiBloc>().add(const ResetAiEvent());
  }

  // ============================================================
  // SCROLL TO BOTTOM
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocListener<AiBloc, AiState>(
      listenWhen: (previous, current) {
        return current.aiStatus == AiStatus.success ||
            current.aiStatus == AiStatus.failure;
      },
      listener: (context, state) {
        _handleAiState(state);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: context.appBackground,

        appBar: CustomAppBar(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.appBorder),
            ),
            child: IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: context.appPrimary,
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
          action: IconButton(
            tooltip: 'New Chat',
            icon: Icon(Icons.edit_square, color: context.appPrimary),
            onPressed: _isSending ? null : _resetChat,
          ),
          title: 'AI Assistant',
          showBackButton: false,
        ),

        drawer: _buildHistoryDrawer(),

        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? _buildWelcomeScreen()
                    : _buildChatMessages(),
              ),
              _buildBottomInput(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHAT HISTORY DRAWER
  // ============================================================

  Widget _buildHistoryDrawer() {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.82,
      backgroundColor: context.appCard,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    Icons.forum_outlined,
                    color: context.appPrimary,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Chat History',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSending
                      ? null
                      : () {
                          Navigator.pop(context);
                          _resetChat();
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: context.appPrimary,
                  ),
                  icon: Icon(Icons.add),
                  label: Text('New Chat'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : _chatSessions.isEmpty
                  ? const Center(child: Text('No chat history yet'))
                  : ListView.builder(
                      itemCount: _chatSessions.length,
                      itemBuilder: (context, index) {
                        final session = _chatSessions[index];

                        return ListTile(
                          selected: _currentSessionId == session.id,
                          selectedTileColor: Color.alphaBlend(context.appPrimary.withValues(alpha: 0.12), context.appCard),
                          title: Text(
                            session.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: Icon(Icons.chat_bubble_outline),
                          onTap: _isSending
                              ? null
                              : () => _openHistory(session),
                          trailing: IconButton(
                            onPressed: _isSending
                                ? null
                                : () => _deleteHistory(session),
                            icon: Icon(
                              Icons.delete_outline,
                              color: context.appError,
                            ),
                          ),
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
  // WELCOME SCREEN
  // ============================================================

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color.alphaBlend(context.appPrimary.withValues(alpha: 0.12), context.appCard),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 36,
                color: context.appPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'How can I help you?',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask about sales, dealers, customers and orders.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.appSubText),
            ),
            const SizedBox(height: 24),
            _suggestionChip('Total Sales'),
            _suggestionChip('Customer Wise Sales'),
            _suggestionChip('State Wise Orders'),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _messageController.text = title;
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.appBorder),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 18,
                color: context.appPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title)),
              Icon(Icons.arrow_outward, size: 17),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHAT MESSAGES
  // ============================================================

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.appPrimary,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'AI is analyzing your question...',
                  style: TextStyle(fontSize: 13, color: context.appSubText),
                ),
              ],
            ),
          );
        }

        final message = _messages[index];

        return Align(
          alignment: message.isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: message.isUser ? null : double.infinity,
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.sizeOf(context).width *
                  (message.isUser ? 0.85 : 0.96),
            ),
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: message.isUser ? Color.alphaBlend(context.appPrimary.withValues(alpha: 0.12), context.appCard) : context.appCard,
              borderRadius: BorderRadius.circular(16),
              border: message.isUser
                  ? null
                  : Border.all(color: context.appBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!message.isUser) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: context.appPrimary,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        message.outputType == ChatOutputType.graph
                            ? 'Graph Response'
                            : message.outputType == ChatOutputType.table
                            ? 'Table Response'
                            : 'AI Response',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.appPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                Text(
                  message.text,
                  style: TextStyle(fontSize: 14, height: 1.5, color: context.appOnCard),
                ),

                // Graph or table based on the
                // selected output type saved
                // with this individual response.
                if (!message.isUser && message.responseData != null) ...[
                  const SizedBox(height: 12),
                  _buildResponseResult(message),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DYNAMIC RESPONSE RENDERER
  // ============================================================

  Widget _buildResponseResult(ChatMessage message) {
    final data = message.responseData;

    if (data == null) {
      return const SizedBox.shrink();
    }

    final rawResult = data['result'];

    if (rawResult is! Map) {
      return const SizedBox.shrink();
    }

    final result = Map<String, dynamic>.from(rawResult);

    if (message.outputType == ChatOutputType.graph) {
      final rawLabels = result['labels'] as List? ?? [];
      final rawValues = result['values'] as List? ?? [];

      if (rawLabels.isEmpty || rawValues.isEmpty) {
        return const SizedBox.shrink();
      }

      final count = math.min(rawLabels.length, rawValues.length);

      // Adapt graph data to the existing
      // _buildDynamicGraph(columns, rows) method.
      final rows = <Map<String, dynamic>>[];

      for (var i = 0; i < count; i++) {
        final label = rawLabels[i]?.toString();

        rows.add({
          'Category': label == null || label.isEmpty ? 'Item ${i + 1}' : label,
          'Value': _toDouble(rawValues[i]),
        });
      }

      const columns = <Map<String, dynamic>>[
        {'key': 'Category', 'label': 'Category'},
        {'key': 'Value', 'label': 'Value'},
      ];

      return _buildDynamicGraph(columns: columns, rows: rows);
    }

    // ============================================================
    // TABLE FORMAT
    // ============================================================

    final columns = (result['columns'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final rows = (result['rows'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    if (columns.isEmpty || rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildDynamicTable(
      columns: columns,
      rows: rows,
      totalRows: _toInt(result['total_rows']),
    );
  }

  // ============================================================
  // DYNAMIC TABLE
  // ============================================================

  Widget _buildDynamicTable({
    required List<Map<String, dynamic>> columns,
    required List<Map<String, dynamic>> rows,
    required int totalRows,
  }) {
    // Limit rendering for very large API responses.
    const maxVisibleRows = 200;
    final visibleRows = rows.take(maxVisibleRows).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 17,
              color: context.appPrimary,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Total Records: ${totalRows > 0 ? totalRows : rows.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Color.alphaBlend(context.appPrimary.withValues(alpha: 0.12), context.appCard)),
              columnSpacing: 24,
              horizontalMargin: 12,
              headingRowHeight: 45,
              dataRowMinHeight: 45,
              dataRowMaxHeight: 65,
              columns: columns.map((column) {
                return DataColumn(
                  label: Text(
                    column['label']?.toString() ??
                        column['key']?.toString() ??
                        '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
              rows: visibleRows.map((row) {
                return DataRow(
                  cells: columns.map((column) {
                    final key = column['key']?.toString() ?? '';

                    return DataCell(
                      Text(
                        _formatCellValue(row[key]),
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
        if (rows.length > maxVisibleRows)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Showing first $maxVisibleRows of '
              '${rows.length} returned records.',
              style: TextStyle(fontSize: 11, color: context.appSubText),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // DYNAMIC GRAPH
  // ============================================================

  Widget _buildDynamicGraph({
    required List<Map<String, dynamic>> columns,
    required List<Map<String, dynamic>> rows,
  }) {
    if (columns.length < 2) {
      return _graphFallback(columns, rows);
    }

    // First available text column is the X-axis label.
    // If all columns are numeric, use the first
    // column as the X-axis category.
    final firstRow = rows.first;

    String categoryKey = columns.first['key']?.toString() ?? '';

    for (final column in columns) {
      final key = column['key']?.toString() ?? '';

      if (_toDouble(firstRow[key]) == null) {
        categoryKey = key;
        break;
      }
    }

    // Detect numeric Y-axis columns dynamically.
    final numericColumns = columns.where((column) {
      final key = column['key']?.toString() ?? '';

      if (key == categoryKey) return false;

      return rows.any((row) => _toDouble(row[key]) != null);
    }).toList();

    if (numericColumns.isEmpty) {
      return _graphFallback(columns, rows);
    }

    // This bar chart supports non-negative numeric values.
    // Fall back to table if negatives are present.
    for (final row in rows) {
      for (final column in numericColumns) {
        final key = column['key']?.toString() ?? '';
        final value = _toDouble(row[key]);

        if (value != null && value < 0) {
          return _graphFallback(columns, rows);
        }
      }
    }

    const maxGraphRows = 30;
    final graphRows = rows.take(maxGraphRows).toList();

    final colors = <Color>[
      const Color(0xFF16A34A),
      const Color(0xFF2563EB),
      const Color(0xFFF59E0B),
      const Color(0xFF9333EA),
      const Color(0xFFEA580C),
    ];

    double maximumValue = 0;

    final groups = <BarChartGroupData>[];

    for (var i = 0; i < graphRows.length; i++) {
      final row = graphRows[i];

      final rods = <BarChartRodData>[];

      for (var j = 0; j < numericColumns.length; j++) {
        final key = numericColumns[j]['key']?.toString() ?? '';

        final value = _toDouble(row[key]) ?? 0;

        maximumValue = math.max(maximumValue, value);

        rods.add(
          BarChartRodData(
            toY: value,
            width: 14,
            color: colors[j % colors.length],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        );
      }

      groups.add(BarChartGroupData(x: i, barRods: rods, barsSpace: 4));
    }

    final double groupWidth = math.max(
      90.0,
      numericColumns.length * 24.0 + 32.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Visualization',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),

        // Legend: one item per numeric column.
        Wrap(
          spacing: 12,
          runSpacing: 7,
          children: [
            for (var j = 0; j < numericColumns.length; j++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[j % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    numericColumns[j]['label']?.toString() ?? '',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(height: 18),

        // Horizontal scrolling for large datasets.
        SizedBox(
          height: 310,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(
                MediaQuery.sizeOf(context).width - 85,
                graphRows.length * groupWidth + 65,
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maximumValue <= 0 ? 1 : maximumValue * 1.20,
                  barGroups: groups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maximumValue > 0
                        ? maximumValue * 1.20 / 4
                        : 0.25,
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _compactNumber(value),
                            style: TextStyle(
                              fontSize: 10,
                              color: context.appSubText,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 55,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();

                          if (index < 0 || index >= graphRows.length) {
                            return const SizedBox.shrink();
                          }

                          final label =
                              graphRows[index][categoryKey]?.toString() ?? '';

                          return SideTitleWidget(
                            meta: meta,
                            child: SizedBox(
                              width: groupWidth - 5,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: Text(
                                  label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: context.appOnCard,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Text(
          'Tap a bar to inspect its value. '
          'Swipe horizontally to see more records.',
          style: TextStyle(fontSize: 11, color: context.appSubText),
        ),
        if (rows.length > maxGraphRows)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'Showing first $maxGraphRows of '
              '${rows.length} returned records.',
              style: TextStyle(fontSize: 11, color: context.appSubText),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // GRAPH FALLBACK
  // ============================================================

  Widget _graphFallback(
    List<Map<String, dynamic>> columns,
    List<Map<String, dynamic>> rows,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This result cannot be plotted as a '
          'non-negative numeric bar graph. '
          'Showing table instead.',
          style: TextStyle(fontSize: 12, color: context.appWarning),
        ),
        const SizedBox(height: 10),
        _buildDynamicTable(
          columns: columns,
          rows: rows,
          totalRows: rows.length,
        ),
      ],
    );
  }

  // ============================================================
  // DATA HELPERS
  // ============================================================

  double? _toDouble(dynamic value) {
    if (value == null || value is bool) return null;

    if (value is num) return value.toDouble();

    if (value is String) {
      final cleaned = value
          .replaceAll(',', '')
          .replaceAll('₹', '')
          .replaceAll('%', '')
          .replaceAll('\$', '')
          .trim();

      return double.tryParse(cleaned);
    }

    return null;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatCellValue(dynamic value) {
    if (value == null) return '-';
    return value.toString();
  }

  String _compactNumber(double value) {
    final absolute = value.abs();

    if (absolute >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}Cr';
    }
    if (absolute >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    }
    if (absolute >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);
  }

  // ============================================================
  // BOTTOM MESSAGE INPUT
  // ============================================================

  Widget _buildBottomInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border(top: BorderSide(color: context.appBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _outputRadio(
                ChatOutputType.graph,
                'Graph',
                Icons.bar_chart_rounded,
              ),
              const SizedBox(width: 8),
              _outputRadio(
                ChatOutputType.table,
                'Table',
                Icons.table_chart_outlined,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _isSending ? null : _resetChat,
                icon: Icon(Icons.refresh, size: 17),
                label: Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.appInputBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.appBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: context.appText),
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Ask anything...',
                      hintStyle: TextStyle(color: context.appSubText),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Voice Input',
                  icon: Icon(
                    Icons.mic_none_rounded,
                    color: context.appSubText,
                  ),
                  onPressed: () {
                    // Speech-to-text integration pending.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voice input will be added next.'),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6, bottom: 5),
                  child: Material(
                    color: _isSending ? context.appSubText : context.appPrimary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isSending ? null : _sendMessage,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: context.appCard,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRAPH / TABLE RADIO BUTTON
  // ============================================================

  Widget _outputRadio(ChatOutputType type, String title, IconData icon) {
    final selected = _selectedOutput == type;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _isSending
          ? null
          : () {
              setState(() {
                _selectedOutput = type;
              });
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<ChatOutputType>(
            value: type,
            groupValue: _selectedOutput,
            activeColor: context.appPrimary,
            visualDensity: VisualDensity.compact,
            onChanged: _isSending
                ? null
                : (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedOutput = value;
                    });
                  },
          ),
          Icon(
            icon,
            size: 17,
            color: selected ? context.appPrimary : context.appSubText,
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? context.appPrimary : context.appSubText,
            ),
          ),
        ],
      ),
    );
  }
}
