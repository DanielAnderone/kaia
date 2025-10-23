// lib/view/account_view.dart
import 'package:flutter/material.dart';
import '../../widgts/app_bottom.dart'; // menu inferior

class AccountView extends StatefulWidget {
  final String name;
  final String email;
  final String avatarUrl;

  const AccountView({
    super.key,
    this.name = 'Alex Johnson',
    this.email = 'alex.johnson@example.com',
    this.avatarUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBVEcSLW51nIIxWAj1GawkdnHeKrtUgql_j7zYJDGnr-2Tt_lVBvs4-y8PKDDWUtzMZ1OZih2yy8M-nwcnOKmnK4CMCub1I60NBsBagyFBcB4E9v7Z1qg4s5YIx05kCajRhXAgNfLweJasmmQLNWWxH_9LSfPco39ZZgfocq36jI0VJ1PlCZ68fXX6WDRV5Rd6tWlBIc3vh3gSlHZkhSvzCVXCH8jrJnRoojQvYCTiBgjeHz2fICIcRY07QZT8h8OxzzBRTmkMFnnUc',
  });

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  static const Color primary = Color(0xFF169C1D);
  static const Color bgLight = Color(0xFFF6F8F6);
  static const Color bgDark = Color(0xFF112112);

  bool syncOn = true;

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? bgDark : bgLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Conta',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context, isDark),
            const SizedBox(height: 16),
            _sectionLabel('Segurança', isDark),
            const SizedBox(height: 8),
            _tile(isDark, Icons.lock, 'Alterar palavra-passe', () => _notImpl(context)),
            const SizedBox(height: 16),
            _sectionLabel('Dados e Pagamento', isDark),
            const SizedBox(height: 8),
            _tile(isDark, Icons.credit_card, 'Métodos de pagamento', () => _notImpl(context)),
            _switchTile(isDark, Icons.cloud_sync, 'Sincronização de dados', syncOn, (v) {
              setState(() => syncOn = v);
            }),
            const SizedBox(height: 16),
            _sectionLabel('Ações da conta', isDark),
            const SizedBox(height: 8),
            _button('Terminar sessão', () => _notImpl(context), filled: false),
            const SizedBox(height: 10),
            _dangerButton('Eliminar conta', () => _notImpl(context)),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
    );
  }

  Widget _header(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundImage: NetworkImage(widget.avatarUrl),
            backgroundColor: const Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 10),
          Text(
            widget.name,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.email,
            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black54),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () => _notImpl(context),
              child: const Text('Editar perfil'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _tile(bool isDark, IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F5EA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primary),
        ),
        title: Text(
          label,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey[400] : Colors.black45),
        onTap: onTap,
      ),
    );
  }

  Widget _switchTile(
    bool isDark,
    IconData icon,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F5EA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primary),
        ),
        title: Text(
          label,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: primary,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFC7CCD1),
        ),
      ),
    );
  }

  Widget _button(String text, VoidCallback onPressed, {bool filled = true}) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: filled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: onPressed,
              child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primary),
                foregroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onPressed,
              child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
    );
  }

  Widget _dangerButton(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _notImpl(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Ação não implementada')));
  }
}
