import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import '../../../../core/di/organization_di.dart';

import '../bloc/organization_bloc.dart';
import '../bloc/organization_event.dart';
import '../bloc/organization_state.dart';

import '../widgets/organization_webview.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OrganizationDI.createBloc()..add(GetOrganizationDetailsEvent()),

      child: Scaffold(
        backgroundColor: context.backgroundColor,

        // ================================================================
        // APP BAR
        // ================================================================
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

          title: 'Contact Us',

          titleStyle: TextStyle(
            fontSize: 22,

            fontWeight: FontWeight.w600,

            color: context.onPrimaryColor,
          ),
        ),

        // ================================================================
        // BODY
        // ================================================================
        body: SafeArea(
          child: Column(
            children: [
              // ------------------------------------------------------------
              // HEADER
              // ------------------------------------------------------------
              _buildHeader(context),

              // ------------------------------------------------------------
              // CONTENT
              // ------------------------------------------------------------
              Expanded(
                child: BlocBuilder<OrganizationBloc, OrganizationState>(
                  builder: (context, state) {
                    // ------------------------------------------------------
                    // LOADING
                    // ------------------------------------------------------

                    if (state is OrganizationLoading) {
                      return _buildLoading(context);
                    }

                    // ------------------------------------------------------
                    // ERROR
                    // ------------------------------------------------------

                    if (state is OrganizationError) {
                      return _buildError(context, state.message);
                    }

                    // ------------------------------------------------------
                    // SUCCESS
                    // ------------------------------------------------------

                    if (state is OrganizationLoaded) {
                      return _buildContent(
                        context,
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

  // ===========================================================================
  // HEADER
  // ===========================================================================

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
          const SizedBox(height: 6),

          // ---------------------------------------------------------------
          // ICON
          // ---------------------------------------------------------------
          Container(
            width: 60,

            height: 60,

            decoration: BoxDecoration(
              color: context.onPrimaryColor.withOpacity(0.15),

              shape: BoxShape.circle,

              border: Border.all(
                color: context.onPrimaryColor.withOpacity(0.25),

                width: 1.5,
              ),
            ),

            child: Icon(
              Icons.support_agent_rounded,

              color: context.onPrimaryColor,

              size: 32,
            ),
          ),

          const SizedBox(height: 12),

          // ---------------------------------------------------------------
          // TITLE
          // ---------------------------------------------------------------
          Text(
            'Get In Touch',

            style: TextStyle(
              color: context.onPrimaryColor,

              fontSize: 17,

              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'We are here to help you',

            style: TextStyle(
              color: context.onPrimaryColor.withOpacity(0.75),

              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CONTENT
  // ===========================================================================

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
              color: Theme.of(context).shadowColor.withOpacity(0.06),

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

  // ===========================================================================
  // SECTION HEADER
  // ===========================================================================

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.06),

        border: Border(
          bottom: BorderSide(color: context.primaryColor.withOpacity(0.08)),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 34,

            height: 34,

            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.10),

              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(
              Icons.contact_phone_rounded,

              color: context.primaryColor,

              size: 19,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Contact Information',

                  style: TextStyle(
                    color: context.cardTextColor,

                    fontSize: 14,

                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'Tap phone, email or website to open',

                  style: TextStyle(
                    color: context.secondaryTextColor,

                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // LOADING
  // ===========================================================================

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            width: 76,

            height: 76,

            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.08),

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
            'Loading Contact Information...',

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

  // ===========================================================================
  // ERROR
  // ===========================================================================

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
                color: context.appColors.error.withOpacity(0.07),

                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.contact_support_outlined,

                size: 44,

                color: context.appColors.error,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'Unable to Load Contact Us',

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
              'the contact information.',

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
                color: context.appColors.error.withOpacity(0.05),

                borderRadius: BorderRadius.circular(13),

                border: Border.all(
                  color: context.appColors.error.withOpacity(0.10),
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

                icon: Icon(Icons.refresh_rounded, size: 20),

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
