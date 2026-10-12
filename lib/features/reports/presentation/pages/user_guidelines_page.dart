import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/organization_di.dart';

import '../bloc/organization_bloc.dart';
import '../bloc/organization_event.dart';
import '../bloc/organization_state.dart';

import '../widgets/organization_webview.dart';

class UserGuidelinesPage extends StatelessWidget {
  const UserGuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OrganizationDI.createBloc()..add(GetOrganizationDetailsEvent()),
      child: Scaffold(
        appBar: CustomAppBar(
          backgroundColor: context.primaryColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 19,
              color: context.onPrimaryColor,
            ),
            onPressed: () {
              context.go(AppRouter.home);
            },
          ),
          title: 'User Guide',
          titleStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: context.onPrimaryColor,
          ),
        ),

        backgroundColor: context.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),

              Expanded(
                child: BlocBuilder<OrganizationBloc, OrganizationState>(
                  builder: (context, state) {
                    if (state is OrganizationLoading) {
                      return _buildLoading(context);
                    }

                    if (state is OrganizationError) {
                      return _buildError(context, state.message);
                    }

                    if (state is OrganizationLoaded) {
                      return _buildContent(
                        context,
                        state.organization.organizationUserGuideLine,
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
      decoration: BoxDecoration(
        color: context.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: context.onPrimaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.onPrimaryColor.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: context.onPrimaryColor,
              size: 32,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Application Guidelines',
            style: TextStyle(
              color: context.onPrimaryColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Everything you need to know',
            style: TextStyle(
              color: context.onPrimaryColor.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(BuildContext context, String html) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.appColors.shadow.withValues(alpha: 0.06),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildSectionHeader(context),

            Expanded(child: OrganizationWebView(html: html)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(
            color: context.primaryColor.withValues(alpha: 0.08),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(21),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: context.primaryColor,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Loading Guidelines...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Please wait a moment',
            style: TextStyle(fontSize: 12, color: context.secondaryTextColor),
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
                color: context.appColors.error.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 44,
                color: context.appColors.error,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'Unable to Load Guidelines',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: context.primaryTextColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Something went wrong while loading '
              'the user guidelines.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: context.secondaryTextColor,
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: context.appColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: context.appColors.error.withValues(alpha: 0.10),
                ),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: context.appColors.error,
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
                label: Text(
                  'Try Again',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.onPrimaryColor,
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
