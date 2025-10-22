import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/project.dart';
import '../viewmodel/project_viewmodel.dart';

class AdminProjectManagementView extends StatefulWidget {
  const AdminProjectManagementView({super.key});

  @override
  State<AdminProjectManagementView> createState() =>
      _AdminProjectManagementViewState();
}

class _AdminProjectManagementViewState
    extends State<AdminProjectManagementView> {
  final ProjectViewModel _viewModel = ProjectViewModel();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _projectBudgetController = TextEditingController();
  final TextEditingController _roiController = TextEditingController();
  final TextEditingController _totalBudgetController = TextEditingController();

  String? _selectedRisk;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  XFile? _selectedImage;

  bool _isSaving = false;

  final List<String> _riskOptions = ['Baixo', 'Médio', 'Alto'];
  final List<String> _statusOptions = [
    'Planejado',
    'Em andamento',
    'Concluído',
    'Pausado'
  ];

  @override
  void initState() {
    super.initState();
    // carrega projetos simulados na inicialização
    _viewModel.fetchProjects().then((_) => setState(() {}));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  Future<void> _pickDate(bool start) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
      start ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date != null) {
      setState(() => start ? _startDate = date : _endDate = date);
    }
  }

  void _addProject() async {
    // manter validações exatamente como você pediu
    if (_nameController.text.trim().isEmpty ||
        _selectedRisk == null ||
        _selectedStatus == null ||
        _startDate == null ||
        _endDate == null ||
        _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente.')),
      );
      return;
    }

    final totalBudget =
        double.tryParse(_totalBudgetController.text.replaceAll(',', '.')) ?? -1;
    final projectBudget =
        double.tryParse(_projectBudgetController.text.replaceAll(',', '.')) ?? -1;
    final roi = double.tryParse(_roiController.text.replaceAll(',', '.')) ?? -1;

    if (totalBudget < 0 || projectBudget < 0 || roi < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valores numéricos devem ser positivos.')),
      );
      return;
    }

    final project = Project(
      id: null,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      totalBudget: totalBudget,
      projectBudget: projectBudget,
      roi: roi,
      riskLevel: _selectedRisk!,
      status: _selectedStatus!,
      startDate: _startDate,
      endDate: _endDate,
      imagePath: _selectedImage?.path,
    );

    setState(() => _isSaving = true);

    // usa ViewModel que chama o Service (simulação)
    final created = await _viewModel.addProject(project, imageFile: _selectedImage);

    setState(() {
      _isSaving = false;
      if (created != null) _clearFields();
    });

    if (created != null) {
      // força rebuild para exibir novo item imediatamente
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projeto salvo com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar projeto.')),
      );
    }
  }

  void _clearFields() {
    _nameController.clear();
    _descriptionController.clear();
    _projectBudgetController.clear();
    _roiController.clear();
    _totalBudgetController.clear();
    _selectedImage = null;
    _selectedRisk = null;
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
  }

  void _deleteProject(Project project) async {
    if (project.id == null) return;
    await _viewModel.deleteProject(project.id!);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Projeto removido.')),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Em andamento':
        return const Color(0xFF169C1D);
      case 'Concluído':
        return Colors.grey;
      case 'Pausado':
        return Colors.orange;
      default:
        return Colors.yellow.shade800;
    }
  }

  Widget _buildImagePreviewSmall() {
    if (_selectedImage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: kIsWeb
            ? Image.network(_selectedImage!.path, width: 60, height: 60, fit: BoxFit.cover)
            : Image.file(File(_selectedImage!.path), width: 60, height: 60, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildProjectCard(Project p) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // imagem centralizada (se existir)
            if (p.imagePath != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(p.imagePath!, height: 160, width: double.infinity, fit: BoxFit.cover)
                      : Image.file(File(p.imagePath!), height: 160, width: double.infinity, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Icon(Icons.image_outlined, size: 56, color: Colors.grey)),
              ),
            const SizedBox(height: 12),

            // cabeçalho nome + badge status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111712))),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(p.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(p.status, style: TextStyle(color: _statusColor(p.status), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(p.description, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 12),

            // grid info
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 6,
              children: [
                _smallInfo("Budget & ROI", "${p.projectBudget.toStringAsFixed(2)} MT / ${p.roi.toStringAsFixed(1)}%"),
                _smallInfo("Risco", p.riskLevel, valueColor: (p.riskLevel == 'Baixo') ? Colors.green : (p.riskLevel == 'Médio') ? Colors.orange : Colors.red),
                _smallInfo("Duração", "${_formatDate(p.startDate)} • ${_formatDate(p.endDate)}", valueColor: Colors.black87),
                _smallInfo("Total", "${p.totalBudget.toStringAsFixed(2)} MT"),
              ],
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteProject(p),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallInfo(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? const Color(0xFF111712))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = _viewModel.projects;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Gestão de Projetos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF169C1D),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- FORMULÁRIO (mantido)
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Novo Projeto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome do Projeto')),
                  const SizedBox(height: 12),
                  TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Descrição')),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: TextField(controller: _projectBudgetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Orçamento (MT)'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: _roiController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ROI (%)'))),
                  ]),
                  const SizedBox(height: 12),
                  TextField(controller: _totalBudgetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Orçamento Total (MT)')),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: DropdownButtonFormField<String>(value: _selectedRisk, items: _riskOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(), onChanged: (v) => setState(() => _selectedRisk = v), decoration: const InputDecoration(labelText: 'Risco'))),
                    const SizedBox(width: 12),
                    Expanded(child: DropdownButtonFormField<String>(value: _selectedStatus, items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _selectedStatus = v), decoration: const InputDecoration(labelText: 'Status'))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: ElevatedButton(onPressed: () => _pickDate(true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF169C1D)), child: Text(_startDate == null ? 'Data Início' : 'Início: ${_formatDate(_startDate)}', style: const TextStyle(color: Colors.white)))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(onPressed: () => _pickDate(false), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF169C1D)), child: Text(_endDate == null ? 'Data Fim' : 'Fim: ${_formatDate(_endDate)}', style: const TextStyle(color: Colors.white)))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    ElevatedButton(onPressed: _pickImage, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade700), child: const Text('Selecionar Imagem', style: TextStyle(color: Colors.white))),
                    _buildImagePreviewSmall(),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _addProject,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF169C1D), padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Salvar Projeto', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 24),

            // --- LISTA DE CARDS BONITOS (estilo HTML)
            projects.isEmpty
                ? const Text('Nenhum projeto cadastrado.', style: TextStyle(color: Colors.black54))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return _buildProjectCard(projects[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
