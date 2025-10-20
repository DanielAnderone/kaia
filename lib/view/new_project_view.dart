import 'package:flutter/material.dart';

class ProjectManagementPage extends StatefulWidget {
  const ProjectManagementPage({super.key});

  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _roiController = TextEditingController();
  final TextEditingController _riskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<String, dynamic>> projects = [
    {
      "name": "Chick-fil-A Expansion",
      "cost": 50000,
      "roi": 15,
      "risk": 5,
      "status": "Active"
    },
    {
      "name": "Organic Feed Trial",
      "cost": 25000,
      "roi": 20,
      "risk": 10,
      "status": "Pending"
    },
    {
      "name": "Winter Broiler Cycle",
      "cost": 75000,
      "roi": 12,
      "risk": 3,
      "status": "Concluded"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        title: const Text(
          "Project Management",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111712)),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF169C1D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("New Project", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Form Section
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Create New Project",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Project Name",
                        hintText: "e.g. Spring Brood Launch",
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Total Investment Cost (\$)",
                        hintText: "50000",
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _roiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Expected ROI (%)",
                        hintText: "15",
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _riskController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Risk Level (%)",
                        hintText: "5",
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Project Description",
                        hintText: "Detailed description...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                            onPressed: () {},
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text("Save Project"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Project Table/List
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Project Name")),
                    DataColumn(label: Text("Total Cost")),
                    DataColumn(label: Text("Expected Return")),
                    DataColumn(label: Text("Risk %")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: projects.map((project) {
                    return DataRow(cells: [
                      DataCell(Text(project["name"])),
                      DataCell(Text("\$${project["cost"]}")),
                      DataCell(Text("${project["roi"]}%")),
                      DataCell(Text("${project["risk"]}%")),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: project["status"] == "Active"
                              ? Colors.green[100]
                              : project["status"] == "Pending"
                                  ? Colors.yellow[100]
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(project["status"]),
                      )),
                      DataCell(Row(
                        children: [
                          TextButton(onPressed: () {}, child: const Text("Edit")),
                          TextButton(onPressed: () {}, child: const Text("Action")),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
