import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; // <-- Added
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
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // <-- Added

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

    // Guest Mode
    if (user == null) {
      setState(() {
        _username = "Guest";
        _profileImageUrl = null;
        _isLoading = false;
      });
      return;
    }

    // Logged-in user
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    setState(() {
      _username = data?['name'] ?? "User";
      _profileImageUrl = data?['image'];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isGuest = _auth.currentUser == null;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(color: mainColor.withOpacity(0.3)),
          Column(
            children: [
              const SizedBox(height: 40),

              // PROFILE SECTION
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GestureDetector(
                      onTap: isGuest
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              ).then((_) => _loadUserProfile());
                            },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : const AssetImage("assets/logo.png")
                                      as ImageProvider,
                          ),
                          const SizedBox(height: 10),
                          ArabicText(
                            _username ?? "Guest",
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

              // LIST ITEMS
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildTile(
                      title:
                          language.localizedStrings["Change Language"] ??
                          "Change Language",
                      icon: Icons.language,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChangeLangage()),
                      ),
                    ),
                    _divider(),
                    _buildTile(
                      title:
                          language.localizedStrings["Font Setting"] ??
                          "Font Setting",
                      icon: Icons.font_download,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FontSettingsScreen()),
                      ),
                    ),
                    _divider(),
                    _buildTile(
                      title: "Privacy Policy",
                      icon: Icons.privacy_tip,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    _divider(),
                    _buildTile(
                      title: "Terms & Services",
                      icon: Icons.article_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsAndServicesScreen(),
                        ),
                      ),
                    ),
                    _divider(),
                    _buildTile(
                      title:
                          language.localizedStrings["Invite Friends"] ??
                          "Invite Friends",
                      icon: Icons.share,
                      onTap: _shareApp,
                    ),
                    _divider(),
                    _buildTile(
                      title: "Rate Us",
                      icon: Icons.star_rate,
                      onTap: _rateUs,
                    ),
                    _divider(),

                    // LOGOUT & DELETE ACCOUNT — ONLY IF LOGGED IN
                    if (!isGuest)
                      _buildTile(
                        title: "Logout",
                        icon: Icons.logout,
                        onTap: _confirmLogout,
                      ),
                    if (!isGuest) _divider(),
                    if (!isGuest)
                      _buildTile(
                        title: "Delete Account",
                        icon: Icons.delete_forever,
                        onTap: _confirmDeleteAccount,
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

  Widget _divider() => Divider(color: primaryText.withOpacity(0.1));

  Widget _buildTile({
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
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: onTap,
    );
  }

  // LOGOUT WITH GOOGLE SIGN-OUT
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              // Google Sign-out
              try {
                if (await _googleSignIn.isSignedIn()) {
                  await _googleSignIn.signOut();
                }
              } catch (e) {
                debugPrint("Google sign out failed: $e");
              }

              // Firebase Auth sign-out
              await _auth.signOut();

              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // DELETE ACCOUNT
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _deleteAccount,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    Navigator.pop(context);
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Delete Firestore document
        await _firestore.collection('users').doc(user.uid).delete();
        // Delete Auth account
        await user.delete();

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete account: $e")));
      }
    }
  }

  // SHARE APP
  void _shareApp() {
    const link =
        "https://play.google.com/store/apps/details?id=com.islamproquran.app";
    Share.share("Check out this amazing Islamic app: $link");
  }

  // RATE US
  Future<void> _rateUs() async {
    const url =
        "https://play.google.com/store/apps/details?id=com.islamproquran.app";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
