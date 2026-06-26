import 'package:flutter/material.dart';
import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/leadManagement/quotationPage.dart';
import 'package:login2/screens/serviceman/leadDashboard.dart';
import 'package:login2/screens/serviceman/workList.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 242, 242, 243),
            ),
            child: Center(
              child: Image.asset(
                "assets/main/funriders.png",
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(
              Icons.dashboard,
              color: Color.fromARGB(255, 37, 118, 194),
            ),
            title: const Text(
              "Lead Dashboard",
              style: TextStyle(
                color: Color.fromARGB(255, 37, 118, 194),
                fontSize: 16,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeadDashboard()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.work,
              color: Color.fromARGB(255, 37, 118, 194),
            ),
            title: const Text(
              "All Works",
              style: TextStyle(
                color: Color.fromARGB(255, 39, 37, 194),
                fontSize: 16,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkListPage(pageTitle: "All Works",typeId:"5")),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.quora_outlined,
              color: Color.fromARGB(255, 37, 118, 194),
            ),
            title: const Text(
              "Quotations & Estimations",
              style: TextStyle(
                color: Color.fromARGB(255, 37, 118, 194),
                fontSize: 16,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuotationPage(status:"All")),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 37, 118, 194),
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Color.fromARGB(255, 37, 118, 194),
                fontSize: 16,
              ),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

