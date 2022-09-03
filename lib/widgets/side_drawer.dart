import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/completed_trip_screen.dart';

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
            context: context,
            title: 'Completed Trips',
            icon: Icons.navigation_rounded,
            onTap: () => Navigator.of(context).pushNamed(
              CompletedTripsScreen.route,
            ),
          ),
          _buildButtonTile(
            context: context,
            title: 'Cash Earned',
            icon: Icons.attach_money_rounded,
            onTap: () {},
          ),
          _buildButtonTile(
            context: context,
            title: 'Logout',
            icon: Icons.exit_to_app,
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButtonTile({
    BuildContext? context,
    String? title,
    IconData? icon,
    Function()? onTap,
  }) {
    return ListTile(
      title: Text(title!),
      leading: Icon(icon),
      onTap: () {
        Navigator.pop(context!);
        onTap!();
      },
    );
  }
}
