import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../screens/completed_trip_screen.dart';
import '../models/user_model.dart' as user;

class CustomSideDrawer extends StatelessWidget {
  const CustomSideDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user.User? loggedUser = Provider.of<UserProvider>(
      context,
      listen: false,
    ).loggedUser;

    return Drawer(
      child: Column(
        children: [
          loggedUser != null
              ? UserAccountsDrawerHeader(
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
                  accountName: Text(loggedUser.username!),
                  accountEmail: Text(loggedUser.email!),
                )
              : Container(
                  height: 200,
                  color: Theme.of(context).primaryColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
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
