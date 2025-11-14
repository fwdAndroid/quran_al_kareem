import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';
import 'package:quran_al_kareem/screens/auth/login_screen.dart';
import 'package:quran_al_kareem/screens/drawer_pages/change_language.dart';
import 'package:quran_al_kareem/screens/other/edit_profile.dart';
import 'package:quran_al_kareem/screens/other/font_setting.dart';
import 'package:quran_al_kareem/screens/other/privacy_policy.dart';
import 'package:quran_al_kareem/screens/other/terms_of_service.dart';
import 'package:quran_al_kareem/screens/widget/arabic_text_widget.dart';
import 'package:quran_al_kareem/utils/colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart'; // 👈 Added for "Rate Us"

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _username;
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _username = data['name'] ?? 'User';
          _profileImageUrl = data['image'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _username = 'User';
          _profileImageUrl = null;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      //    backgroundColor: mainColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(color: mainColor.withOpacity(0.3)),
          Column(
            children: [
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GestureDetector(
                      onTap: () {
                        final user = _auth.currentUser;
                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          ).then((_) => _loadUserProfile());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in first'),
                            ),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : const AssetImage('assets/logo.png')
                                      as ImageProvider,
                          ),
                          const SizedBox(height: 10),
                          ArabicText(
                            _username ?? 'Guest',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildListTile(
                      context,
                      title:
                          languageProvider
                              .localizedStrings["Change Language"] ??
                          "Change Language",
                      icon: Icons.language,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChangeLangage()),
                      ),
                    ),
                    Divider(color: primaryText.withOpacity(.1)),

                    _buildListTile(
                      context,
                      title:
                          languageProvider.localizedStrings["Font Setting"] ??
                          "Font Setting",
                      icon: Icons.font_download_sharp,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FontSettingsScreen()),
                      ),
                    ),
                    Divider(color: primaryText.withOpacity(.1)),

                    _buildListTile(
                      context,
                      title: "Privacy Policy",
                      icon: Icons.privacy_tip_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    Divider(color: primaryText.withOpacity(.1)),

                    _buildListTile(
                      context,
                      title: "Terms & Services",
                      icon: Icons.article_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsAndServicesScreen(),
                        ),
                      ),
                    ),
                    Divider(color: primaryText.withOpacity(.1)),

                    _buildListTile(
                      context,
                      title:
                          languageProvider.localizedStrings["Invite Friends"] ??
                          "Invite Friends",
                      icon: Icons.share,
                      onTap: shareApp,
                    ),
                    Divider(color: primaryText.withOpacity(.1)),

                    // ✅ Rate Us Button (added above logout)
                    _buildListTile(
                      context,
                      title: "Rate Us",
                      icon: Icons.star_rate_rounded,
                      onTap: _launchRateUs,
                    ),
                    Divider(color: primaryText.withOpacity(.1)),

                    // 👇 Logout Button
                    _buildListTile(
                      context,
                      title: "Logout",
                      icon: Icons.logout,
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ListTile _buildListTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: ArabicText(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: iconColor),
      onTap: onTap,
    );
  }

  // ✅ Confirm Logout Dialog
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Confirm Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _auth.signOut();

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void shareApp() {
    const appLink =
        "https://play.google.com/store/apps/details?id=com.example.yourapp";
    Share.share("Hey, check out this amazing app: $appLink");
  }

  // ✅ Open Play Store link
  Future<void> _launchRateUs() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.example.yourapp'; // change to your app ID
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Play Store')),
      );
    }
  }
}
