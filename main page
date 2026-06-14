# Todo-app main page
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pp/task.dart';
import 'package:pp/login.dart';

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final name = prefs.getString('name') ?? '';
  final email = prefs.getString('email') ?? '';
  final isDarkMode = prefs.getBool('darkMode') ?? false;
  isDarkModeNotifier.value = isDarkMode;

  runApp(MyApp(isLoggedIn: isLoggedIn, name: name, email: email));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String name;
  final String email;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFEAE6EC),
            primaryColor: const Color(0xFF0665B3),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0665B3),
              foregroundColor: Colors.white,
            ),
            textTheme: GoogleFonts.firaSansTextTheme(),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: const Color(0xFF90CAF9),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1A237E),
              foregroundColor: Colors.white,
            ),
            drawerTheme: const DrawerThemeData(
              backgroundColor: Color(0xFF1E1E1E),
            ),
            textTheme: GoogleFonts.firaSansTextTheme(
              ThemeData.dark().textTheme,
            ),
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: isLoggedIn
              ? TodoPage(userName: name, userEmail: email)
              : const LoginPage(),
        );
      },
    );
  }
}

class TodoPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const TodoPage({super.key, required this.userName, required this.userEmail});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> filteredTasks = [];

  final TextEditingController searchController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();

  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    userNameController.text = widget.userName;
    userEmailController.text = widget.userEmail;
    loadTasks();
  }

  @override
  void dispose() {
    searchController.dispose();
    userNameController.dispose();
    userEmailController.dispose();
    super.dispose();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final count = prefs.getInt('${email}_taskCount') ?? 0;

    List<Map<String, dynamic>> loaded = [];
    for (int i = 0; i < count; i++) {
      final title = prefs.getString('${email}_title_$i');
      if (title == null) continue;
      final completed = prefs.getBool('${email}_completed_$i') ?? false;
      loaded.add({
        "titleController": TextEditingController(text: title),
        "completed": completed,
        "taskIndex": i,
      });
    }

    if (!mounted) return;
    setState(() {
      tasks = loaded;
      filteredTasks = List.from(tasks);
    });
  }

  Future<void> saveTaskList() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    await prefs.setInt('${email}_taskCount', tasks.length);
  }

  Future<void> deleteTaskData(int taskIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    await prefs.remove('${email}_title_$taskIndex');
    await prefs.remove('${email}_description_$taskIndex');
    await prefs.remove('${email}_date_$taskIndex');
    await prefs.remove('${email}_completed_$taskIndex');
  }

  void deleteTask(int index) {
    final taskToRemove = filteredTasks[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Delete Task",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 158, 31, 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                final taskIndex = taskToRemove["taskIndex"] as int;
                await deleteTaskData(taskIndex);
                setState(() {
                  tasks.remove(taskToRemove);
                  filterTasks(searchController.text);
                });
                await saveTaskList();
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void toggleTask(int index) async {
    setState(() {
      filteredTasks[index]["completed"] = !filteredTasks[index]["completed"];
    });

    final isCompleted = filteredTasks[index]["completed"] as bool;
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final taskIndex = filteredTasks[index]["taskIndex"] as int;
    await prefs.setBool('${email}_completed_$taskIndex', isCompleted);

    if (isCompleted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Task completed!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void filterTasks(String query) {
    setState(() {
      filteredTasks = tasks.where((task) {
        return (task["titleController"] as TextEditingController).text
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget buildTaskCard(Map<String, dynamic> task, int index) {
    final isDark = isDarkModeNotifier.value;
    final cardColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFE6DDD8);
    final borderColor = isDark ? Colors.white24 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => toggleTask(index),
            child: Container(
              height: 60,
              width: 40,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: task["completed"] == true
                  ? Icon(
                      Icons.check,
                      size: 24,
                      color: isDark ? Colors.white : Colors.black,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Taskpage(
                      titleController:
                          task["titleController"] as TextEditingController,
                      taskIndex: task["taskIndex"] as int,
                    ),
                  ),
                );
                setState(() {});
              },
              child: Container(
                height: 60,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        (task["titleController"] as TextEditingController).text,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => deleteTask(index),
                      child: const Icon(
                        Icons.delete,
                        color: Color.fromARGB(255, 158, 31, 22),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkModeNotifier.value;
    final appBarColor = isDark
        ? const Color(0xFF1A237E)
        : const Color(0xFF0665B3);
    final fabColor = isDark ? const Color(0xFF0665B3) : const Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 240,
                    child: TextField(
                      controller: userNameController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onSubmitted: (_) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          'name',
                          userNameController.text.trim(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 240,
                    child: TextField(
                      controller: userEmailController,
                      textAlign: TextAlign.center,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            ValueListenableBuilder<bool>(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDarkValue, child) {
                return ListTile(
                  leading: Icon(
                    isDarkValue ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkValue ? Colors.amber : Colors.blueGrey,
                  ),
                  title: Text(
                    isDarkValue ? "Dark Mode" : "Light Mode",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: Switch(
                    value: isDarkValue,
                    activeColor: Colors.amber,
                    onChanged: (value) async {
                      isDarkModeNotifier.value = value;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('darkMode', value);
                      setState(() {});
                    },
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leadingWidth: 80,
        flexibleSpace: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: appBarColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1),
            ),
          ),
        ),
        title: isSearching
            ? Container(
                height: 45,
                margin: const EdgeInsets.only(right: 10),
                child: TextField(
                  controller: searchController,
                  onChanged: filterTasks,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search task...",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF0C0C46),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              )
            : const Text(
                "To Do App",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(
                isSearching ? Icons.close : Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    searchController.clear();
                    filteredTasks = List.from(tasks);
                  }
                });
              },
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: filteredTasks.isEmpty
                  ? const Center(
                      child: Text(
                        "No Tasks Found",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) =>
                          buildTaskCard(filteredTasks[index], index),
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: fabColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final titleController = TextEditingController();

          final prefs = await SharedPreferences.getInstance();
          final email = prefs.getString('email') ?? '';
          final nextIndex = (prefs.getInt('${email}_totalCreated') ?? 0);

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Taskpage(
                titleController: titleController,
                taskIndex: nextIndex,
              ),
            ),
          );

          if (result == true && titleController.text.trim().isNotEmpty) {
            await prefs.setInt('${email}_totalCreated', nextIndex + 1);
            setState(() {
              tasks.add({
                "titleController": titleController,
                "completed": false,
                "taskIndex": nextIndex,
              });
              filteredTasks = List.from(tasks);
            });
            await saveTaskList();
          }
        },
      ),
    );
  }
}

