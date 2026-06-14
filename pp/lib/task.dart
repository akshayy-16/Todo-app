
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Taskpage extends StatefulWidget {
  final TextEditingController titleController;
  final int taskIndex;

  const Taskpage({
    super.key,
    required this.titleController,
    required this.taskIndex,
  });

  @override
  State<Taskpage> createState() => _TaskpageState();
}

class _TaskpageState extends State<Taskpage> {
  final TextEditingController descriptionController = TextEditingController();

  // Instance variable — no longer global
  final ValueNotifier<DateTime?> selectedDate = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    loadTaskData();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    selectedDate.dispose();
    super.dispose();
  }

  Future<void> loadTaskData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    final title = prefs.getString('${email}_title_${widget.taskIndex}');
    if (title != null) widget.titleController.text = title;

    descriptionController.text =
        prefs.getString('${email}_description_${widget.taskIndex}') ?? '';

    final savedDate = prefs.getString('${email}_date_${widget.taskIndex}');
    selectedDate.value = savedDate != null
        ? DateTime.tryParse(savedDate)
        : null;

    if (!mounted) return;
    setState(() {});
  }

  Future<void> saveTaskData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    await prefs.setString(
      '${email}_title_${widget.taskIndex}',
      widget.titleController.text,
    );
    await prefs.setString(
      '${email}_description_${widget.taskIndex}',
      descriptionController.text,
    );

    if (selectedDate.value != null) {
      await prefs.setString(
        '${email}_date_${widget.taskIndex}',
        selectedDate.value!.toIso8601String(),
      );
    } else {
      await prefs.remove('${email}_date_${widget.taskIndex}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final appBarColor = isDark
        ? const Color(0xFF1A237E)
        : const Color(0xFF0665B3);
    final fieldFillColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFE8DFDB);
    final labelColor = isDark ? Colors.white70 : Colors.black87;
    final borderColor = isDark ? Colors.white38 : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          "Task",
          style: GoogleFonts.firaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
        child: Column(
          children: [
            TextField(
              controller: widget.titleController,
              maxLines: 2,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Enter Title",
                labelText: "Title",
                hintStyle: GoogleFonts.firaSans(
                  fontSize: 18,
                  color: labelColor,
                ),
                labelStyle: GoogleFonts.firaSans(
                  fontSize: 18,
                  color: labelColor,
                ),
                floatingLabelStyle: GoogleFonts.firaSans(
                  fontSize: 18,
                  color: labelColor,
                  backgroundColor: fieldFillColor,
                ),
                filled: true,
                fillColor: fieldFillColor,
                contentPadding: const EdgeInsets.all(15),
                alignLabelWithHint: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: descriptionController,
              maxLines: 10,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Enter Description",
                labelText: "Description",
                hintStyle: GoogleFonts.firaSans(
                  fontSize: 18,
                  color: labelColor,
                ),
                labelStyle: GoogleFonts.firaSans(
                  fontSize: 18,
                  color: labelColor,
                ),
                floatingLabelStyle: GoogleFonts.firaSans(
                  fontSize: 18,
                  color: labelColor,
                  backgroundColor: fieldFillColor,
                ),
                alignLabelWithHint: true,
                filled: true,
                fillColor: fieldFillColor,
                contentPadding: const EdgeInsets.all(18),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<DateTime?>(
                    valueListenable: selectedDate,
                    builder: (context, value, child) {
                      return OutlinedButton.icon(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: value ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            selectedDate.value = pickedDate;
                          }
                        },
                        icon: Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: isDark
                              ? Colors.amber
                              : const Color(0xFF0665B3),
                        ),
                        label: Text(
                          value == null
                              ? "Select Date"
                              : "${value.day.toString().padLeft(2, '0')}/"
                                    "${value.month.toString().padLeft(2, '0')}/"
                                    "${value.year}",
                          style: GoogleFonts.firaSans(
                            color: isDark
                                ? Colors.amber
                                : const Color(0xFF0665B3),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark
                                ? Colors.amber
                                : const Color(0xFF0665B3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                ValueListenableBuilder<DateTime?>(
                  valueListenable: selectedDate,
                  builder: (context, value, child) {
                    if (value == null) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: "Clear date",
                      onPressed: () => selectedDate.value = null,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? const Color(0xFF1565C0) : Colors.black,
        child: const Icon(Icons.save, color: Colors.white),
        onPressed: () async {
          if (widget.titleController.text.trim().isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Enter title")));
            return;
          }
          await saveTaskData();
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          Navigator.pop(context, true);
        },
      ),
    );
  }
}