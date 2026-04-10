import 'package:flutter/material.dart';
import 'package:absensi_raditya/models/profile_model.dart';
import 'package:absensi_raditya/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final Data userData;
  final VoidCallback onCameraTap;
  final VoidCallback onEditNameTap;

  const ProfileHeader({
    super.key,
    required this.userData,
    required this.onCameraTap,
    required this.onEditNameTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Lingkaran dekoratif kuning
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.3),
                  width: 8,
                ),
              ),
            ),
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 15),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage:
                    (userData.profilePhotoUrl != null &&
                        userData.profilePhotoUrl!.isNotEmpty)
                    ? NetworkImage(
                        "${userData.profilePhotoUrl}?t=${DateTime.now().millisecondsSinceEpoch}",
                      )
                    : null,
                child:
                    (userData.profilePhotoUrl == null ||
                        userData.profilePhotoUrl!.isEmpty)
                    ? Icon(Icons.person, size: 70, color: AppColors.primaryBlue)
                    : null,
              ),
            ),
            // Tombol kamera
            Positioned(
              bottom: 5,
              right: 5,
              child: GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userData.name?.toUpperCase() ?? "USER",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: appColors.text,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEditNameTap,
              child: const Icon(
                Icons.edit_attributes,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ),
          ],
        ),
        Text(
          userData.email ?? "-",
          style: TextStyle(
            color: appColors.subText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
