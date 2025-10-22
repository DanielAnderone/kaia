import 'package:flutter/material.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF386641);
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Perfil do Administrador'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // 📸 Foto do Admin
                Container(
                  width: 128,
                  height: 128,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'João Silva',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    'Editar Perfil',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 32),

                // 🧾 Campos do perfil
                _buildField('Nome Completo', 'João Silva', textColor, enabled: false),
                const SizedBox(height: 16),
                _buildField('Número de Telefone', '+258 84 123 4567', textColor, enabled: false),
                const SizedBox(height: 16),
                _buildField('Data de Nascimento', '12 de Maio de 1985', textColor, enabled: false),
                const SizedBox(height: 16),
                _buildField('Nuit', '123456789', textColor, enabled: false),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          'Guardar Alterações',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: primaryColor),
                        ),
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

  Widget _buildField(String label, String value, Color textColor,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: textColor),
        ),
      ],
    );
  }
}
