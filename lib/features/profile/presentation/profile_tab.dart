import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        const Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              SizedBox(height: 16),
              Text(
                'John Doe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'john.doe@example.com',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Divider(),
        _ProfileMenuItem(
          icon: Icons.edit,
          title: 'Edit Profile',
          onTap: () {},
        ),
        _ProfileMenuItem(
          icon: Icons.lock,
          title: 'Change Password',
          onTap: () {},
        ),
        _ProfileMenuItem(
          icon: Icons.notifications,
          title: 'Notifications',
          onTap: () {},
        ),
        _ProfileMenuItem(
          icon: Icons.privacy_tip,
          title: 'Privacy',
          onTap: () {},
        ),
        const Divider(),
        _ProfileMenuItem(
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () {},
        ),
        _ProfileMenuItem(
          icon: Icons.info,
          title: 'About',
          onTap: () {},
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
