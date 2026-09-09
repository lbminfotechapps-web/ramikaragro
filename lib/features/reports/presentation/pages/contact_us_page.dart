import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/organization_di.dart';

import '../bloc/organization_bloc.dart';
import '../bloc/organization_event.dart';
import '../bloc/organization_state.dart';

import '../widgets/organization_webview.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  static const Color primaryGreen = Color(0xFF0F723A);
  static const Color darkGreen = Color(0xFF084D28);
  static const Color backgroundColor = Color(0xFFF4F8F5);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OrganizationDI.createBloc()..add(GetOrganizationDetailsEvent()),
      child: Scaffold(
        appBar: CustomAppBar(
          backgroundColor: primaryGreen,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 19,
              color: AppColors.backgroundColor,
            ),
            onPressed: () {
              context.go(AppRouter.home);
            },
          ),

          title: 'Contact Us',
          titleStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.backgroundColor,
          ),
        ),

        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),

              Expanded(
                child: BlocBuilder<OrganizationBloc, OrganizationState>(
                  builder: (context, state) {
                    if (state is OrganizationLoading) {
                      return _buildLoading();
                    }

                    if (state is OrganizationError) {
                      return _buildError(context, state.message);
                    }

                    if (state is OrganizationLoaded) {
                      return _buildContent(
                        state.organization.organizationContactUs,
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 25),
      decoration: const BoxDecoration(
        color: primaryGreen,
        // gradient: LinearGradient(
        //   colors: [
        //     primaryGreen,
        //     darkGreen,
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // _buildBackButton(context),
              const SizedBox(width: 44),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Get In Touch',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'We are here to help you',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 19,
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(String html) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildSectionHeader(),

            Expanded(child: OrganizationWebView(html: html)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.06),
        border: Border(
          bottom: BorderSide(color: primaryGreen.withOpacity(0.08)),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(21),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: primaryGreen,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Loading Contact Information...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Please wait a moment',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.contact_support_outlined,
                size: 44,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Unable to Load Contact Us',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF252525),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Something went wrong while loading '
              'the contact information.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.red.withOpacity(0.10)),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: Colors.redAccent,
                ),
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<OrganizationBloc>().add(
                    GetOrganizationDetailsEvent(),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
