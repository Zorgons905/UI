import 'package:dokie/core/widgets/interfaces.dart';
import 'package:dokie/features/2_group/data/models/task_group.dart';
import 'package:dokie/features/2_group/presentation/detail_group_page.dart';
import 'package:dokie/features/2_group/presentation/add_group_page.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<TaskGroup> taskGroups = [];
  List<TaskGroup> filteredTaskGroups = [];
  bool isLoading = true;
  String selectedSort = 'Date';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadTaskGroups();
  }

  List<TaskGroup> getStaticTaskGroups() {
    return [
      TaskGroup(
        id: 1,
        name: 'Mobile App Development',
        description: 'Complete mobile application development project',
        createdAt: '2024-01-15T10:30:00Z',
        notStartedCount: 3,
        ongoingCount: 5,
        completedCount: 12,
      ),
      TaskGroup(
        id: 2,
        name: 'Website Redesign',
        description: 'Redesign company website with modern UI/UX',
        createdAt: '2024-01-10T14:20:00Z',
        notStartedCount: 7,
        ongoingCount: 2,
        completedCount: 8,
      ),
      TaskGroup(
        id: 3,
        name: 'Marketing Campaign',
        description: 'Q1 2024 marketing campaign planning and execution',
        createdAt: '2024-01-08T09:15:00Z',
        notStartedCount: 1,
        ongoingCount: 3,
        completedCount: 15,
      ),
      TaskGroup(
        id: 4,
        name: 'Database Migration',
        description: 'Migrate legacy database to new infrastructure',
        createdAt: '2024-01-05T16:45:00Z',
        notStartedCount: 5,
        ongoingCount: 1,
        completedCount: 2,
      ),
      TaskGroup(
        id: 5,
        name: 'UI/UX Research',
        description: 'User experience research and interface improvements',
        createdAt: '2024-01-03T11:30:00Z',
        notStartedCount: 0,
        ongoingCount: 0,
        completedCount: 10,
      ),
      TaskGroup(
        id: 6,
        name: 'Security Audit',
        description: 'Comprehensive security assessment and improvements',
        createdAt: '2024-01-01T08:00:00Z',
        notStartedCount: 8,
        ongoingCount: 4,
        completedCount: 1,
      ),
    ];
  }

  Future<void> loadTaskGroups() async {
    setState(() => isLoading = true);

    await Future.delayed(Duration(milliseconds: 1000));

    try {
      final groups = getStaticTaskGroups();

      if (selectedSort == 'Date') {
        groups.sort(
          (a, b) => DateTime.parse(
            b.createdAt,
          ).compareTo(DateTime.parse(a.createdAt)),
        );
      } else {
        groups.sort((a, b) => a.name.compareTo(b.name));
      }

      setState(() {
        taskGroups = groups;
        filteredTaskGroups = groups;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading task groups: $e')));
    }
  }

  void filterTaskGroups(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredTaskGroups = taskGroups;
      } else {
        filteredTaskGroups =
            taskGroups
                .where(
                  (group) =>
                      group.name.toLowerCase().contains(query.toLowerCase()) ||
                      (group.description?.toLowerCase().contains(
                            query.toLowerCase(),
                          ) ??
                          false),
                )
                .toList();
      }
    });
  }

  void changeSortOrder(String sortBy) {
    setState(() {
      selectedSort = sortBy;
      if (sortBy == 'Date') {
        filteredTaskGroups.sort(
          (a, b) => DateTime.parse(
            b.createdAt,
          ).compareTo(DateTime.parse(a.createdAt)),
        );
      } else {
        filteredTaskGroups.sort((a, b) => a.name.compareTo(b.name));
      }
    });
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Color getProgressColor(int notStarted, int ongoing, int completed) {
    final total = notStarted + ongoing + completed;
    if (total == 0) return Colors.grey;

    final completedRatio = completed / total;
    if (completedRatio >= 0.7) return Colors.green;
    if (completedRatio >= 0.3) return Colors.orange;
    return Colors.red;
  }

  double getProgressValue(int notStarted, int ongoing, int completed) {
    final total = notStarted + ongoing + completed;
    if (total == 0) return 0;
    return (ongoing * 0.5 + completed) / total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox(height: 60),
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFA),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Task Group',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: buildTextField(
              controller: filterTaskGroups,
              hintText: 'Search',
              prefixIcon: Icon(Icons.search, color: Color(0xFF8c8c8c)),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Sort by :',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12),

                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: buildButton(
                          text: 'Name',
                          onPressed: () => changeSortOrder('Name'),
                          backgroundColor:
                              selectedSort == 'Name'
                                  ? Color(0xFF7B6EF2)
                                  : Colors.white,
                          textColor:
                              selectedSort == 'Name'
                                  ? Colors.white
                                  : Color(0xFF7B6EF2),
                          isFilled: selectedSort == 'Name',
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: buildButton(
                          text: 'Date',
                          onPressed: () => changeSortOrder('Date'),
                          backgroundColor:
                              selectedSort == 'Date'
                                  ? Color(0xFF7B6EF2)
                                  : Colors.white,
                          textColor:
                              selectedSort == 'Date'
                                  ? Colors.white
                                  : Color(0xFF7B6EF2),
                          isFilled: selectedSort == 'Date',
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredTaskGroups.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      onRefresh: loadTaskGroups,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTaskGroups.length,
                        itemBuilder: (context, index) {
                          return _buildTaskGroupCard(filteredTaskGroups[index]);
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
            MaterialPageRoute(builder: (context) => AddGroupPage()),
          );
        },
        backgroundColor: Color(0xFF7B6EF2),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskGroupCard(TaskGroup taskGroup) {
    final progressValue = getProgressValue(
      taskGroup.notStartedCount,
      taskGroup.ongoingCount,
      taskGroup.completedCount,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailGroupPage(taskGroup: taskGroup),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 30.0,
                lineWidth: 10.0,
                percent: progressValue,
                center: Text(
                  '${(progressValue * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                progressColor: Color(0xFF7B6EF2),
                backgroundColor: Color(0xFFD9D9D9),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskGroup.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Created by User',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),

                    Divider(
                      color: Color(0xFFD9D9D9),
                      thickness: 2,
                      indent: 0,
                      endIndent: 8,
                    ),

                    SizedBox(height: 8),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      children: [
                        _buildStatusIndicator(
                          '${taskGroup.notStartedCount} Not Started',
                          Colors.red,
                        ),
                        SizedBox(width: 12),
                        _buildStatusIndicator(
                          '${taskGroup.ongoingCount} On Going',
                          Colors.orange,
                        ),
                        SizedBox(height: 4),
                        _buildStatusIndicator(
                          '${taskGroup.completedCount} Completed',
                          Colors.green,
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Updated: ${formatDate(taskGroup.createdAt)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No Task Groups Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'No task groups match your search'
                : 'Create your first task group to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (searchQuery.isNotEmpty) {
                filterTaskGroups('');
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddGroupPage()),
                );
              }
            },
            icon: Icon(
              searchQuery.isNotEmpty ? Icons.clear : Icons.add,
              color: Colors.white,
            ),
            label: Text(
              searchQuery.isNotEmpty ? 'Clear Search' : 'Create Task Group',
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
}
