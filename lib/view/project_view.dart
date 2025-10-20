// lib/view/projects_view.dart
import 'package:flutter/material.dart';

class ProjectsView extends StatelessWidget {
  const ProjectsView({super.key});

  // Paleta do HTML
  static const Color primary = Color(0xFF169C1D);
  static const Color bgLight = Color(0xFFF6F8F6);
  static const Color bgDark = Color(0xFF112112);

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              color: isDark ? bgDark : bgLight,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const _Avatar(
                    url:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuA3447MeD5msMbR_Bt3JCxz0LmKOi0JIWZwYFr1zKUCDnq1i6l8lvDtkFpwKZHa22Sfsu3JSC9RKA0vDh3z3ECVQHnoOBZiBcvnLwgTmwV2ZJJvKF7Pz5uhcSS93Qxfv7KnFEv6v0AeakP0kC-oq7T3yUhbuN86ktiuKGqn7iDDJ6ilbwanQRYrcksxy7-_KsqMlsv2xWGszKhqBXCBd6M8Gl0fNhTyP3CSnmyRdHsb0w8cZAqNtnTSk94BYoBSkN2AxxHMZbT_QXYa',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hello, Alex!',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications,
                        color: isDark ? Colors.white : Colors.black87),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  _StatCard(title: 'Total Invested', value: '\$25,000'),
                  SizedBox(width: 12),
                  _StatCard(title: 'Accumulated Profit', value: '\$5,000'),
                  SizedBox(width: 12),
                  _StatCard(title: 'Average Return', value: '20%'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section header
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Active Projects',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.15,
                  ),
                ),
              ),
            ),

            // Carousel
            SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _ProjectCard(
                    title: 'Hen Haven Farm',
                    cost: 10000,
                    expectedReturnPct: 25,
                    statusText: 'Active',
                    statusColor: primary,
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuACgrnBHW9MfWFTbMPdtLMGX8ZnXVB7YjYsJQjUM72b_YflyZDYCkjHTZ4x9zMewBPde1gSxIb9P93BiIF9bkz87z3Ab5N_jmbaZcx3lQBvXm_y-Qc6oFWVqPAu0lz_qlkqXqjWgrmxEemwFQDkASiLQMYOcrlhTrtU8L2cAkKRlWoOCEFxIlM3t1kvOkrOTsDChJE5ch1aRixzuqofMa7mbNmpqafZVNggE7oPba4kgRjCu8vQU9vWeo0_CwEUM0TABQLdsXtGTaN3',
                  ),
                  SizedBox(width: 12),
                  _ProjectCard(
                    title: 'Sunrise Poultry',
                    cost: 15000,
                    expectedReturnPct: 18,
                    statusText: 'Funded',
                    statusColor: Color(0xFFF59E0B), // amarelo
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAuOqE5s1bfq_t3Q-_yz6DV6XBZHdKauMZkg-mrwSLcXh7LRmOY65D8YJ1T73b3eHGwBqJY0phYExUmGBjLxYbWAC-N2NpU8K-TqBA5AIZx5o3wxBx6lk4b91ZDxZApuXIQ7nknCbkXG-tg4JJXmiF1en5GCNhRV0axciL4ZiHtADemkF6Ai_vnbf6DqkTwzdH-cK4oM5FZxBlbarFsbLtYDfoZ_Zj22A42_e7wIqoyNccMNtCZd1ZNZR6M-Z94e0TaDvoCX3rGBpe5',
                  ),
                  SizedBox(width: 12),
                  _ProjectCard(
                    title: 'Golden Egg Farms',
                    cost: 20000,
                    expectedReturnPct: 22,
                    statusText: 'Active',
                    statusColor: primary,
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCqysmCTOmz2y2jA9TxyCNnAbtgjNIKHoHLWiloBj7uoqWH49jUN0np6_BcuSN2ZDdNFySDVH6b-Mu3AyiLLzDJxKykuQGMqXOauMR0u0Bp6-Y0U1hkkeDd2vcj0iLnjmyRYSJpI_aCu2yWf-jS-l75vUUVUKvMUzw86OQB7dhQP945c_ubwpeLpIEyAnKpfiU_Pzu91Gpdclgda7M7BZKoXxbLIa-6Jd8Qqy-dYqwRloQyg9LC1B5hUusnnM6BaxJ_3d1wIL4y-8To',
                  ),
                ],
              ),
            ),

            const Spacer(), // reserva espaço para o bottom nav
          ],
        ),
      ),

      // Bottom nav
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
            ),
          ),
        ),
        child: Row(
          children: const [
            _NavItem(label: 'Dashboard', icon: Icons.space_dashboard, selected: true),
            _NavItem(label: 'Projects', icon: Icons.business_center),
            _NavItem(label: 'Portfolio', icon: Icons.pie_chart),
            _NavItem(label: 'Profile', icon: Icons.person),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  const _Avatar({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(url, width: 40, height: 40, fit: BoxFit.cover),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3748) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String title;
  final int cost;
  final int expectedReturnPct;
  final String statusText;
  final Color statusColor;
  final String imageUrl;

  const _ProjectCard({
    required this.title,
    required this.cost,
    required this.expectedReturnPct,
    required this.statusText,
    required this.statusColor,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      width: 288,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 6),
                  Text(
                    'Cost: \$${_fmt(cost)}  Expected Return: $expectedReturnPct% \nStatus: ',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProjectsView.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      b.write(s[i]);
      if (idx > 1 && idx % 3 == 1) b.write(',');
    }
    return b.toString();
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  const _NavItem({
    required this.label,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? ProjectsView.primary : Colors.grey[500];
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(9999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
