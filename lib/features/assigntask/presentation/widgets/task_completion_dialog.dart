
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:solufine/core/utility/image_compression.dart';

import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';

class TaskCompletionDialog extends StatefulWidget {
  final TaskEntity task;

  const TaskCompletionDialog({
    super.key,
    required this.task,
  });

  @override
  State<TaskCompletionDialog> createState() =>
      _TaskCompletionDialogState();
}

class _TaskCompletionDialogState
    extends State<TaskCompletionDialog> {
  static const green = Color(0xFF16803D);
  static const ink = Color(0xFF172B3A);
  static const muted = Color(0xFF64748B);
  static const border = Color(0xFFE2EAE5);
  static const canvas = Color(0xFFF5F7F6);

  final _formKey = GlobalKey<FormState>();
  final _remark = TextEditingController();
  final _picker = ImagePicker();

  File? _photo;
  bool _compressing = false;
  bool _submitted = false;

  @override
  void dispose() {
    _remark.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_submitted || _compressing) return;

    setState(() => _compressing = true);

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (picked == null) return;

      final compressed =
          await ImageCompression.compressImage(
        File(picked.path),
        maxWidth: 450,
        maxHeight: 450,
        quality: 45,
      );

      if (compressed == null ||
          !await compressed.exists()) {
        throw Exception('Could not compress image');
      }

      if (!mounted) return;

      setState(() => _photo = compressed);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo error: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _compressing = false);
      }
    }
  }

  void _submit() {
    final state = context.read<TaskBloc>().state;

    if (_submitted || _compressing ||
        state.completing || state.saving) {
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitted = true);

    context.read<TaskBloc>().add(
      SubmitTaskCompletion(
        taskId: widget.task.id,
        remark: _remark.text.trim(),
        imagePath: _photo?.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (previous, current) =>
          previous.completionCounter !=
              current.completionCounter ||
          previous.completionFailureCounter !=
              current.completionFailureCounter,
      listener: (context, state) {
        if (!_submitted) return;

        if (state.error) {
          setState(() => _submitted = false);
          return;
        }

        Navigator.of(context).pop(true);
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F6EC),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.task_alt_rounded,
                          color: green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete Task',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: ink,
                              ),
                            ),
                            Text(
                              'Remark & completion proof',
                              style: TextStyle(
                                fontSize: 11,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _submitted
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // TASK DETAILS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: canvas,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task : ${widget.task.title}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                         // '#${widget.task.id}  •  '
                          'Emp Name : ${widget.task.employeeName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // REMARK
                  const Text(
                    'Completion remark *',
                    style: TextStyle(
                      color: ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _remark,
                    enabled: !_submitted,
                    minLines: 2,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'What work was completed?',
                      isDense: true,
                      filled: true,
                      fillColor: canvas,
                      contentPadding: const EdgeInsets.all(11),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: border),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter completion remark'
                            : null,
                  ),

                  const SizedBox(height: 2),

                  // ATTACHMENT
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Completion attachment',
                          style: TextStyle(
                            color: ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        _photo == null ? 'Optional' : 'Ready',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _compressing || _submitted
                              ? null
                              : () => _pickImage(
                                    ImageSource.camera,
                                  ),
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                          ),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _compressing || _submitted
                              ? null
                              : () => _pickImage(
                                    ImageSource.gallery,
                                  ),
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 18,
                          ),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
                  ),

                  if (_compressing)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  if (_photo != null) ...[
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),
                          child: Image.file(
                            _photo!,
                            width: double.infinity,
                            height: 135,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton.filledTonal(
                            onPressed: _submitted
                                ? null
                                : () => setState(
                                      () => _photo = null,
                                    ),
                            icon: const Icon(
                              Icons.close,
                              size: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // SUBMIT
                  BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      final busy = _submitted ||
                          _compressing ||
                          state.completing;

                      return SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton.icon(
                          onPressed: busy ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(11),
                            ),
                          ),
                          icon: busy
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_circle_outline,
                                ),
                          label: Text(
                            busy
                                ? 'Submitting...'
                                : 'Submit Completion',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
