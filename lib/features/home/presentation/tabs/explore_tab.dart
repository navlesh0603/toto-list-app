import 'package:flutter/material.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Explore',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _ExploreCard(
          title: 'Trending Topics',
          subtitle: 'See what\'s popular today',
          icon: Icons.trending_up,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ExploreCard(
          title: 'Discover New',
          subtitle: 'Find something interesting',
          icon: Icons.stars,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ExploreCard(
          title: 'Categories',
          subtitle: 'Browse by category',
          icon: Icons.category,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ExploreCard(
          title: 'Recommended',
          subtitle: 'Based on your interests',
          icon: Icons.recommend,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
