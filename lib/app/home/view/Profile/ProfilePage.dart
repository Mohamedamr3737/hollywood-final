import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/profile_controller.dart';
import '../../../auth/controller/token_controller.dart';
import '../../../widgets/coustom_textfield.dart';
import '../../../widgets/coustom_button.dart';
import '../../../../general/consts/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController controller = Get.put(ProfileController());
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  
  bool _isEditing = false;
  late final Worker _profileWorker;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    controller.fetchProfile();
    
    // Listen to profile changes and update controllers
    _profileWorker = ever(controller.userData, (profile) {
      if (profile != null && profile.isNotEmpty) {
        _nameController.text = profile['name'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _emergencyContactController.text = profile['emergency_contact'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _profileWorker.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Header Section
              Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    // Background image with overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          image: DecorationImage(
                            image: const NetworkImage(
                              'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',
                            ),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              AppColors.primaryColor.withOpacity(0.8),
                              BlendMode.overlay,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // AppBar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        title: const Text(
                          "My Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        centerTitle: true,
                        actions: [
                          IconButton(
                            icon: Icon(
                              _isEditing ? Icons.close : Icons.edit,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Circular Icon and Title
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Obx(() {
                            final profile = controller.userData;
                            final initials = _getInitials(profile['name'] ?? 'User');
                            
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: profile['avatar'] != null && profile['avatar'].isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        profile['avatar'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildInitialsAvatar(initials);
                                        },
                                      ),
                                    )
                                  : _buildInitialsAvatar(initials),
                            );
                          }),
                          const SizedBox(height: 12),
                          Obx(() {
                            final name = controller.userData['name'] ?? 'User Name';
                            return Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D8F),
                      ),
                    );
                  }

                  if (controller.errorMessage.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to load profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.errorMessage.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => controller.fetchProfile(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D8F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Profile Form
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Title
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D8F).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF2E7D8F),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D8F),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Form Fields
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: "Name",
                                  hintText: "Full Name",
                                  border: OutlineInputBorder(),
                                ),
                                enabled: _isEditing,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  hintText: "Email Address",
                                  border: OutlineInputBorder(),
                                ),
                                enabled: _isEditing,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              TextField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: "Phone",
                                  hintText: "Phone Number",
                                  border: OutlineInputBorder(),
                                ),
                                enabled: _isEditing,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              TextField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  labelText: "Address",
                                  hintText: "Home Address",
                                  border: OutlineInputBorder(),
                                ),
                                enabled: _isEditing,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              TextField(
                                controller: _emergencyContactController,
                                decoration: InputDecoration(
                                  labelText: "Emergency Contact",
                                  hintText: "Emergency Contact",
                                  border: OutlineInputBorder(),
                                ),
                                enabled: _isEditing,
                              ),
                              
                              if (_isEditing) ...[
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _isEditing = false;
                                          });
                                          // Reset form
                                          controller.fetchProfile();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey,
                                          side: const BorderSide(color: Colors.grey),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _saveProfile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2E7D8F),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Save Changes'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Account Actions
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Title
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D8F).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.settings_outlined,
                                      color: Color(0xFF2E7D8F),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Account Settings',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D8F),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Action Items
                              _buildActionItem(
                                icon: Icons.lock_outline,
                                title: 'Change Password',
                                subtitle: 'Update your account password',
                                onTap: () {
                                  // Handle change password
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Change password feature coming soon!'),
                                    ),
                                  );
                                },
                              ),
                              
                              _buildActionItem(
                                icon: Icons.notifications_outlined,
                                title: 'Notification Settings',
                                subtitle: 'Manage your notification preferences',
                                onTap: () {
                                  // Handle notification settings
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Notification settings coming soon!'),
                                    ),
                                  );
                                },
                              ),
                              
                              _buildActionItem(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Privacy Settings',
                                subtitle: 'Control your privacy preferences',
                                onTap: () {
                                  // Handle privacy settings
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Privacy settings coming soon!'),
                                    ),
                                  );
                                },
                              ),
                              
                              _buildActionItem(
                                icon: Icons.logout,
                                title: 'Sign Out',
                                subtitle: 'Sign out of your account',
                                onTap: _signOut,
                                isDestructive: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D8F).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Color(0xFF2E7D8F),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : const Color(0xFF2E7D8F);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  void _saveProfile() async {
    final profileData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'emergency_contact': _emergencyContactController.text,
    };

    await controller.updateProfile(profileData, context);
    
    if (controller.errorMessage.isEmpty) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF2E7D8F),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage.value),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.signOut(context);
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
