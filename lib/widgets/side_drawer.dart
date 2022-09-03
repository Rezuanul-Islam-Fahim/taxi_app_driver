import 'package:flutter/material.dart';

class CustomSideDrawer extends StatelessWidget {
  const CustomSideDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.black45,
              ),
            ),
            accountName: const Text('Fahim'),
            accountEmail: const Text('rifahim98@gmail.com'),
          ),
          const SizedBox(height: 10),
          _buildButtonTile(
            title: 'Completed Trips',
            icon: Icons.navigation_rounded,
            onTap: () {},
          ),
          _buildButtonTile(
            title: 'Cash Earned',
            icon: Icons.attach_money_rounded,
            onTap: () {},
          ),
          _buildButtonTile(
            title: 'Logout',
            icon: Icons.exit_to_app,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildButtonTile({
    String? title,
    IconData? icon,
    Function()? onTap,
  }) {
    return ListTile(
      title: Text(title!),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}