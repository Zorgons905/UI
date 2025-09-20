import 'package:dokie/core/widgets/calendar.dart';
import 'package:dokie/core/widgets/interfaces.dart';
import 'package:dokie/features/2_group/data/models/task_group.dart';
import 'package:dokie/features/2a_task/data/models/task.dart';
import 'package:dokie/features/2a_task/presentation/add_task_page.dart';
import 'package:flutter/material.dart';

class DetailGroupPage extends StatefulWidget {
  final TaskGroup taskGroup;

  const DetailGroupPage({super.key, required this.taskGroup});

  @override
  _DetailGroupPageState createState() => _DetailGroupPageState();
}

class _DetailGroupPageState extends State<DetailGroupPage>
    with SingleTickerProviderStateMixin {
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  bool isLoading = true;
  String selectedSort = 'Date';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  DateTime? selectedDate; // Track selected date from calendar

  List<Map<String, String>> getGroupMembers() {
    return [
      {'name': 'You', 'avatar': 'Y', 'color': '0xFF7B6EF2'},
      {'name': 'John Doe', 'avatar': 'J', 'color': '0xFF4CAF50'},
      {'name': 'Sarah Wilson', 'avatar': 'S', 'color': '0xFFFF9800'},
      {'name': 'Mike Johnson', 'avatar': 'M', 'color': '0xFFE91E63'},
      {'name': 'Lisa Chen', 'avatar': 'L', 'color': '0xFF9C27B0'},
      {'name': 'David Smith', 'avatar': 'D', 'color': '0xFF2196F3'},
    ];
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> getStaticTasks() {
    return [
      Task(
        id: 1,
        taskName: 'Algoritma Genetika',
        taskDesc:
            'Tugas dikumpulkan di ethol format .pdf. Sertakan link google colabs.',
        taskAttachment: 'attachment_1.pdf',
        date: '2024-09-17',
        time: '15:00',
        progress: 80,
        taskGroupId: widget.taskGroup.id ?? 1,
      ),
      Task(
        id: 2,
        taskName: 'Perhitungan Xor',
        taskDesc:
            'Tugas dikumpulkan di ethol format .pdf. Sertakan link google colabs.',
        taskAttachment: 'attachment_2.pdf',
        date: '2024-09-17',
        time: '20:00',
        progress: 20,
        taskGroupId: widget.taskGroup.id ?? 1,
      ),
      Task(
        id: 3,
        taskName: 'PPT Perceptron',
        taskDesc:
            'Tugas dikumpulkan di ethol format .pdf. Sertakan link google colabs.',
        taskAttachment: 'presentation.ppt',
        date: '2024-09-18',
        time: '14:30',
        progress: 50,
        taskGroupId: widget.taskGroup.id ?? 1,
      ),
      Task(
        id: 4,
        taskName: 'Machine Learning Model',
        taskDesc: 'Implement and train a basic ML model with documentation.',
        date: '2024-09-19',
        time: '10:00',
        progress: 0,
        taskGroupId: widget.taskGroup.id ?? 1,
      ),
      Task(
        id: 5,
        taskName: 'Data Visualization',
        taskDesc:
            'Create interactive charts and graphs using matplotlib/plotly.',
        date: '2024-09-20',
        time: '16:00',
        progress: 100,
        taskGroupId: widget.taskGroup.id ?? 1,
      ),
    ];
  }

  Future<void> loadTasks() async {
    setState(() => isLoading = true);
    await Future.delayed(Duration(milliseconds: 800));

    try {
      final taskList = getStaticTasks();
      if (selectedSort == 'Date') {
        taskList.sort(
          (a, b) => DateTime.parse(
            a.date + ' ' + a.time,
          ).compareTo(DateTime.parse(b.date + ' ' + b.time)),
        );
      } else {
        taskList.sort((a, b) => a.taskName.compareTo(b.taskName));
      }

      setState(() {
        tasks = taskList;
        applyFilters(); // Apply both search and date filters
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading tasks: $e')));
    }
  }

  void applyFilters() {
    List<Task> result = tasks;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      result =
          result
              .where(
                (task) =>
                    task.taskName.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    (task.taskDesc?.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
    }

    // Apply date filter
    if (selectedDate != null) {
      String dateStr =
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
      result = result.where((task) => task.date == dateStr).toList();
    }

    setState(() {
      filteredTasks = result;
    });
  }

  void filterTasks(String query) {
    setState(() {
      searchQuery = query;
    });
    applyFilters();
  }

  void filterByDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    applyFilters();
  }

  void clearDateFilter() {
    setState(() {
      selectedDate = null;
    });
    applyFilters();
  }

  void changeSortOrder(String sortBy) {
    setState(() {
      selectedSort = sortBy;
      if (sortBy == 'Date') {
        filteredTasks.sort(
          (a, b) => DateTime.parse(
            a.date + ' ' + a.time,
          ).compareTo(DateTime.parse(b.date + ' ' + b.time)),
        );
      } else {
        filteredTasks.sort((a, b) => a.taskName.compareTo(b.taskName));
      }
    });
  }

  String formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  String checkDay(String date) {
    final today = DateTime.now();
    final taskDate = DateTime.parse(date);

    if (today.year == taskDate.year && today.month == taskDate.month) {
      if (today.day == taskDate.day) {
        return "Today";
      } else if ((today.day + 1) == taskDate.day) {
        return "Tomorrow";
      } else if ((today.day - 1) == taskDate.day) {
        return "Yesterday";
      }
    }
    return formatDate(date);
  }

  Color getProgressColor(int progress) {
    if (progress <= 20) {
      return Color(0xFFFF5454);
    } else if (progress <= 60) {
      return Color(0xFFF2B900);
    } else {
      return Color(0xFF38D300);
    }
  }

  void _showGroupDropdown(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.edit, color: Color(0xFF7B6EF2), size: 20),
            title: Text('Edit Group', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edit group functionality')),
              );
            });
          },
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.person, color: Color(0xFF7B6EF2), size: 20),
            title: Text('Add Members', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Add members functionality')),
              );
            });
          },
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.share, color: Color(0xFF7B6EF2), size: 20),
            title: Text('Share Group', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share group functionality')),
              );
            });
          },
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red, size: 20),
            title: Text(
              'Delete Group',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              _showDeleteConfirmation();
            });
          },
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Group'),
            content: Text('Are you sure you want to delete this group?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Group deleted')));
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showCalendarPopup() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by Date',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Calendar(
                    isHomePage: false,
                    onDateSelected: (date) {
                      filterByDate(date);
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 16),
                  if (selectedDate != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtered by: ${formatDate(selectedDate.toString().split(' ')[0])}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            clearDateFilter();
                            Navigator.pop(context);
                          },
                          child: Text('Clear Filter'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = getGroupMembers();

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Custom AppBar
          Container(
            padding: EdgeInsets.only(top: 30, left: 8, right: 8, bottom: 16),
            decoration: BoxDecoration(
              color: Color(0xFF7B6EF2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.taskGroup.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.taskGroup.description?.isNotEmpty == true)
                            Text(
                              widget.taskGroup.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            'Owner: ${members.first['name']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    _buildMembers(members),
                    SizedBox(width: 12),
                    GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        _showGroupDropdown(context, details.globalPosition);
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: buildTextFormField(
                        label: '',
                        controller: _searchController,
                        hintText: 'Search tasks...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        onChanged: () => filterTasks(_searchController.text),
                      ),
                    ),
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: _showCalendarPopup,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              selectedDate != null
                                  ? Colors.white24
                                  : Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              selectedDate != null
                                  ? Border.all(color: Colors.white, width: 1)
                                  : null,
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          color:
                              selectedDate != null
                                  ? Colors.white
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (selectedDate != null) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF7B6EF2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt,
                          size: 14,
                          color: Color(0xFF7B6EF2),
                        ),
                        SizedBox(width: 4),
                        Text(
                          formatDate(selectedDate.toString().split(' ')[0]),
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF7B6EF2),
                          ),
                        ),
                        SizedBox(width: 4),
                        GestureDetector(
                          onTap: clearDateFilter,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFF7B6EF2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Spacer(),
                Text(
                  'Sort by: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _buildSortButton('Name'),
                SizedBox(width: 8),
                _buildSortButton('Date'),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Tasks List
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7B6EF2),
                      ),
                    )
                    : filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      onRefresh: loadTasks,
                      color: Color(0xFF7B6EF2),
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskCard(filteredTasks[index]);
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          );
        },
        backgroundColor: Color(0xFF7B6EF2),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSortButton(String sortType) {
    bool isSelected = selectedSort == sortType;
    return GestureDetector(
      onTap: () => changeSortOrder(sortType),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF7B6EF2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFF7B6EF2) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          sortType,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on ${task.taskName}')),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.taskName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B6EF2),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "${checkDay(task.date)}, ${task.time}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (task.taskDesc != null) ...[
                  SizedBox(height: 4),
                  Text(
                    task.taskDesc!,
                    style: TextStyle(color: Colors.black87, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (task.taskAttachment != null) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Attachment',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: task.progress / 100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            getProgressColor(task.progress),
                          ),
                          backgroundColor: Colors.grey[300],
                          minHeight: 8,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${task.progress}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String emptyMessage;
    String emptySubtitle;
    IconData emptyIcon;

    if (searchQuery.isNotEmpty && selectedDate != null) {
      emptyMessage = 'No Tasks Found';
      emptySubtitle = 'No tasks match your search and date filter';
      emptyIcon = Icons.search_off;
    } else if (searchQuery.isNotEmpty) {
      emptyMessage = 'No Tasks Found';
      emptySubtitle = 'No tasks match your search';
      emptyIcon = Icons.search_off;
    } else if (selectedDate != null) {
      emptyMessage = 'No Tasks on This Date';
      emptySubtitle =
          'No tasks scheduled for ${formatDate(selectedDate.toString().split(' ')[0])}';
      emptyIcon = Icons.event_busy;
    } else {
      emptyMessage = 'No Tasks Found';
      emptySubtitle = 'Add your first task to get started';
      emptyIcon = Icons.assignment_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(emptyIcon, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            emptySubtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (searchQuery.isNotEmpty || selectedDate != null) {
                _searchController.clear();
                setState(() {
                  searchQuery = '';
                  selectedDate = null;
                });
                applyFilters();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskPage()),
                );
              }
            },
            icon: Icon(
              (searchQuery.isNotEmpty || selectedDate != null)
                  ? Icons.clear
                  : Icons.add,
              color: Colors.white,
            ),
            label: Text(
              (searchQuery.isNotEmpty || selectedDate != null)
                  ? 'Clear Filters'
                  : 'Add Task',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7B6EF2),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembers(List<Map<String, String>> members) {
    if (members.isEmpty) return SizedBox.shrink();

    final displayCount = members.length > 2 ? 2 : members.length;
    final totalWidth = 32 + (displayCount - 1) * 24;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 32,
          width: totalWidth.toDouble(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < displayCount; i++)
                Positioned(
                  left: i * 15.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(int.parse(members[i]['color']!)),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        members[i]['avatar']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              if (members.length > 2)
                Positioned(
                  left: displayCount * 15.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 113, 113, 113),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '+${members.length - displayCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
