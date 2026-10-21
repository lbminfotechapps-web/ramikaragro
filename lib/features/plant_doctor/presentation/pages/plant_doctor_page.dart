import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/plant_analysis_type.dart';
import '../../domain/entities/plant_product_entity.dart';
import '../bloc/plant_doctor_bloc.dart';
import '../bloc/plant_doctor_event.dart';
import '../bloc/plant_doctor_state.dart';

class PlantDoctorPage extends StatelessWidget {
  const PlantDoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlantDoctorView();
  }
}

class _PlantDoctorView extends StatelessWidget {
  const _PlantDoctorView();

  static const Color skyBlue = Color(0xFF11B7EA);
  static const Color headerBg = Color(0xFFE6F1E1);
  static const Color titleGreen = Color(0xFF2F6F1E);
  static const Color lightGreyBg = Color(0xFFE9ECEB);
  static const Color activeGreen = Color(0xFF51B64D);
  static const Color inactiveText = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyBg,

      // =========================================================
      // APP BAR
      // =========================================================
     
        appBar: CustomAppBar(
        backgroundColor: context.primaryColor,
        titleStyle: AppTextStyles.appBarTitle.copyWith(
          color: context.onPrimaryColor,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: context.onPrimaryColor,
          ),
          onPressed: () => context.go(AppRouter.home),
        ),
        title: 'Plant AI Doctor',
        showBackButton: true,
      
      ),


      body: BlocConsumer<PlantDoctorBloc, PlantDoctorState>(
        listener: (context, state) {
          if (state.status == PlantDoctorStatus.failure &&
              state.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(state.errorMessage),
                ),
              );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // =================================================
              // MAIN BODY
              // =================================================
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        0,
                        0,
                        150.h,
                      ),
                      child: Column(
                        children: [
                          _buildMainArea(context, state),

                          if (state.result.isNotEmpty) ...[
                            SizedBox(height: 14.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: _buildResultCard(state),
                            ),
                          ],

                          if (state.products.isNotEmpty) ...[
                            SizedBox(height: 14.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              child: _buildProductsCard(state.products),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // =================================================
              // RIGHT FLOATING BUTTONS
              // =================================================
              Positioned(
                right: 16.w,
                bottom: 160.h,
                child: _buildFloatingButtons(context, state),
              ),

              // =================================================
              // BOTTOM TYPE SELECTOR
              // =================================================
              Positioned(
                left: 14.w,
                right: 14.w,
                bottom: 20.h,
                child: _buildBottomSelector(context, state),
              ),

              // =================================================
              // LOADING OVERLAY
              // =================================================
              if (state.status == PlantDoctorStatus.loading)
                _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  // =============================================================
  // MAIN AREA
  // =============================================================
  Widget _buildMainArea(
    BuildContext context,
    PlantDoctorState state,
  ) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 520.h,
      ),
      color: lightGreyBg,
      child: state.imagePath.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: EdgeInsets.all(14.w),
              child: Container(
                height: 420.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        File(state.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 12.w,
                      right: 12.w,
                      bottom: 12.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.45),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.eco_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Selected mode: ${state.selectedType.title}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 520.h,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.75),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_florist_rounded,
                  size: 44.sp,
                  color: activeGreen,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Upload Plant Image',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: titleGreen,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Pick image from gallery or camera to analyze plant growth, disease or deficiency.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black54,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // FLOATING BUTTONS
  // =============================================================
  Widget _buildFloatingButtons(
    BuildContext context,
    PlantDoctorState state,
  ) {
    return Column(
      children: [
        _circleActionButton(
          icon: Icons.attachment_rounded,
          color: const Color(0xFF43B649),
          onTap: () {
            context.read<PlantDoctorBloc>().add(
                  const PickPlantFromGalleryEvent(),
                );
          },
        ),
        SizedBox(height: 16.h),
        _circleActionButton(
          icon: Icons.camera_alt_rounded,
          color: const Color(0xFF8BCB45),
          onTap: () {
            context.read<PlantDoctorBloc>().add(
                  const CapturePlantImageEvent(),
                );
          },
        ),
        SizedBox(height: 16.h),
        _circleActionButton(
          icon: Icons.share_rounded,
          color: const Color(0xFF17A6F4),
          onTap: () async {
            if (state.result.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No result available to share'),
                ),
              );
              return;
            }

            await SharePlus.instance.share(
              ShareParams(
                text:
                    'Plant Doctor Result\n\nType: ${state.selectedType.title}\n\n${state.result}',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _circleActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      elevation: 8,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 58.w,
          height: 58.w,
          child: Icon(
            icon,
            color: Colors.white,
            size: 28.sp,
          ),
        ),
      ),
    );
  }

  // =============================================================
  // BOTTOM SELECTOR
  // =============================================================
  Widget _buildBottomSelector(
    BuildContext context,
    PlantDoctorState state,
  ) {
    return Container(
      height: 64.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.96),
        borderRadius: BorderRadius.circular(36.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: PlantAnalysisType.values.map((type) {
          final bool isSelected = state.selectedType == type;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<PlantDoctorBloc>().add(
                      SelectPlantTypeEvent(type),
                    );
              },
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected ? activeGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(36.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  type.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : inactiveText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // =============================================================
  // RESULT CARD
  // =============================================================
  Widget _buildResultCard(
    PlantDoctorState state,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Result',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: titleGreen,
            ),
          ),
          SizedBox(height: 10.h),
          MarkdownBody(
            data: state.result,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // PRODUCTS
  // =============================================================
  Widget _buildProductsCard(
    List<PlantProductEntity> products,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Products',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: titleGreen,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final item = products[index];

              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBF7),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8E1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F1E2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 18.sp,
                        color: activeGreen,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.micronutrientName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =============================================================
  // LOADING
  // =============================================================
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(.16),
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 22.w,
          vertical: 18.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 12.h),
            Text(
              'Analyzing plant...',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // COMMON
  // =============================================================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}