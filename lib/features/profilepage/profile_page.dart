import 'dart:convert';

import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = true;

  String _name = '';
  String _mobile = '';
  String _email = '';
  String _state = '';
  String _district = '';
  String _taluka = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // LOAD USER DATA FROM SECURE STORAGE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final userDataString = await _storage.read(key: 'user_data');

      debugPrint('PROFILE USER DATA: $userDataString');

      if (userDataString == null || userDataString.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> userData = jsonDecode(userDataString);

      debugPrint('PROFILE JSON: $userData');

      setState(() {
        _name = _getValue(userData, [
          'user_name',
          'userName',
          'name',
          'fld_user_name',
          'fld_name',
        ]);

        _mobile = _getValue(userData, [
          'mobile',
          'mobile_no',
          'mobileNo',
          'phone',
          'phone_no',
          'fld_mobile',
          'fld_mobile_no',
        ]);

        _email = _getValue(userData, [
          'email',
          'email_id',
          'user_email',
          'fld_email',
        ]);

        _state = _getValue(userData, [
          'States',
          'state_name',
          'stateName',
          'fld_state',
          'fld_state_name',
        ]);

        _district = _getValue(userData, [
          'Districts',
          'district_name',
          'districtName',
          'fld_district',
          'fld_district_name',
        ]);

        _taluka = _getValue(userData, [
          'Taluka',
          'taluka_name',
          'talukaName',
          'fld_taluka',
          'fld_taluka_name',
        ]);

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('PROFILE ERROR: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // VALUE READER
  // ============================================================

  String _getValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _getInitials() {
    if (_name.trim().isEmpty) {
      return 'U';
    }

    final words = _name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'My Profile',
        showBackButton: true,
        onBackTap: () {
          context.pop();
        },
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.darkPrimaryColor,
              ),
            )
          : RefreshIndicator(
              color: AppColors.darkPrimaryColor,
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildProfileHeader(),

                    SizedBox(height: 16.h),

                    _buildDetailsCard(),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Icon
          Container(
            width: 88.w,
            height: 88.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkPrimaryColor.withOpacity(0.10),
              border: Border.all(
                color: AppColors.darkPrimaryColor.withOpacity(0.20),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _getInitials(),
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkPrimaryColor,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          Text(
            _name.isEmpty ? 'User' : _name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF26332C),
            ),
          ),

          SizedBox(height: 5.h),

          if (_mobile.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 14.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 5.w),
                Text(
                  _mobile,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAILS CARD
  // ============================================================

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF26332C),
            ),
          ),

          SizedBox(height: 12.h),

          _profileItem(Icons.person_outline_rounded, 'Full Name', _name),

          _divider(),

          _profileItem(Icons.phone_outlined, 'Mobile Number', _mobile),

          _divider(),

          _profileItem(Icons.email_outlined, 'Email Address', _email),

          _divider(),

          _profileItem(Icons.map_outlined, 'State', _state),

          _divider(),

          _profileItem(Icons.location_city_outlined, 'District', _district),

          _divider(),

          _profileItem(Icons.place_outlined, 'Taluka', _taluka),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE ITEM
  // ============================================================

  Widget _profileItem(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.darkPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.darkPrimaryColor, size: 20.sp),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  value.isEmpty ? 'Not available' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF26332C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, thickness: 0.7, color: Colors.grey.shade200);
  }
}
