import 'package:flutter/material.dart';
import 'package:kitokopay/src/screens/ui/loans.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({super.key});

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3C4B9D), // Top color (lighter blue)
              Color(0xFF151A37), // Bottom color (darker blue)
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo and separator line
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/Kitokopaylogo.png', // Your logo here
                      height: 80,
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                        color: Colors.white, thickness: 1), // Thin white line
                  ],
                ),
              ),
            ),

            // User Account section
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                "Account Details",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                // Handle navigation or action
              },
            ),

            // Loans section
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.white),
              title: const Text(
                "Loans",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                // Navigate to the LoansPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoansPage()),
                );
              },
            ),


            // Manage Cards section
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.white),
              title: const Text(
                "Manage Cards",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                // Handle navigation or action
              },
            ),

            // Get Support section
            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.white),
              title: const Text(
                "Get Support",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                // Handle navigation or action
              },
            ),

            // Account Settings section
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text(
                "Account Settings",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                // Handle navigation or action
              },
            ),

            const SizedBox(height: 10), // Spacer between sections

            // Second white line separator
            const Divider(color: Colors.white, thickness: 1),

            // About section
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text(
                "About",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                // Handle navigation or action
              },
            ),

            // Log Out section
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                "Log Out",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                // Handle navigation or action
              },
            ),
          ],
        ),
      ),
    );
  }
}
