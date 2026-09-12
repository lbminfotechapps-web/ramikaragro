import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/utility/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:demo/core/di/top_ten_dealer_di.dart';
import 'package:go_router/go_router.dart';

import '../bloc/top_ten_dealer_bloc.dart';
import '../bloc/top_ten_dealer_event.dart';
import '../bloc/top_ten_dealer_state.dart';

import '../widgets/dealer_card.dart';
import '../widgets/dealer_filter.dart';
import '../widgets/monthly_visit_dialog.dart';
import '../widgets/top_ten_header.dart';

class TopTenDealerPage extends StatefulWidget {
  const TopTenDealerPage({super.key});

  @override
  State<TopTenDealerPage> createState() => _TopTenDealerPageState();
}

class _TopTenDealerPageState extends State<TopTenDealerPage> {
  late final TopTenDealerBloc bloc;

  @override
  void initState() {
    super.initState();

    bloc = sl<TopTenDealerBloc>();

    bloc.add(const GetTopTenDealerEvent(days: 30));
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<TopTenDealerBloc, TopTenDealerState>(
        listener: (context, state) {
          if (state.status == TopTenDealerStatus.failure) {
            _showMessage(state.errorMessage ?? 'Something went wrong');
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: CustomAppBar(
              title: 'Top 10 Dealers',
              showBackButton: true,
              onBackTap: () => context.go(AppRouter.home),
              actionIcon: Icons.refresh_rounded,
              onActionIconTap: () {
                bloc.add(GetTopTenDealerEvent(days: state.selectedDays));
              },
            ),

            //  _buildAppBar(
            //   state.selectedDays,
            // ),
            body: RefreshIndicator(
              color: const Color(0xFF2E7D32),
              onRefresh: () async {
                bloc.add(GetTopTenDealerEvent(days: state.selectedDays));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                children: [
                  TopTenHeader(
                    selectedDays: state.selectedDays,
                    count: state.dealers.length,
                  ),

                  const SizedBox(height: 18),

                  DealerFilter(
                    selectedDays: state.selectedDays,
                    onChanged: (days) {
                      bloc.add(GetTopTenDealerEvent(days: days));
                    },
                  ),

                  const SizedBox(height: 22),

                  _buildTableHeader(),

                  const SizedBox(height: 10),

                  _buildContent(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int selectedDays) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.green,
      surfaceTintColor: Colors.white,
      titleSpacing: 20,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 10 Dealers',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 2),
          Text(
            'Dealer visit performance',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),

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

      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              bloc.add(GetTopTenDealerEvent(days: selectedDays));
            },
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2E7D32)),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(TopTenDealerState state) {
    if (state.status == TopTenDealerStatus.loading) {
      return _buildLoading();
    }

    if (state.dealers.isEmpty) {
      return _buildNoRecords(state.selectedDays);
    }

    return Column(
      children: List.generate(state.dealers.length, (index) {
        final dealer = state.dealers[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DealerCard(
            dealer: dealer,
            index: index,
            onTap: () {
              showMonthlyVisitDialog(context, dealer);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          SizedBox(width: 34),

          Expanded(
            child: Text(
              'Dealer Name / Address',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17202A),
              ),
            ),
          ),

          SizedBox(
            width: 1,
            height: 25,
            child: ColoredBox(color: Color(0xFFD0D8D2)),
          ),

          SizedBox(width: 12),

          SizedBox(
            width: 62,
            child: Text(
              'Visits',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17202A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
  return const CustomLoader(
           
            );
  }

  Widget _buildNoRecords(int days) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 40,
              color: Color(0xFF9AA3AF),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'No Dealers Found',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 6),

          Text(
            'No dealer visits found for last $days days',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A94A6)),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
