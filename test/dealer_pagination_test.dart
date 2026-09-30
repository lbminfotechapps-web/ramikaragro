import 'dart:io';

import 'package:solufine/features/dealer/data/models/dealer_products.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/dealer/data/models/DealerListModel.dart';
import 'package:solufine/features/dealer/domain/repository/dealer_repo.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_bloc.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_event.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_state.dart';

class FakeRepository implements DealerListRepository {
  final offsets = <int>[];
  final requests = <Completer<List<DealerListModel>>>[];
  @override
  Future<List<DealerListModel>> getDealers(
    String user,
    String lat,
    String lng,
    String search,
    String type,
    int startLimit,
  ) {
    offsets.add(startLimit);
    final request = Completer<List<DealerListModel>>();
    requests.add(request);
    return request.future;
  }

  @override
  Future<List<DealerStockProductModel>> getDealerProduct(String dealerId) async => [];

  @override
  Future<Map<String, dynamic>> addDealerLocation(
    Map<String, dynamic> data,
  ) async => {};

  @override
  Future<Map<String, dynamic>> addDealerStock(Map<String, dynamic> jsonData, File? dealerImage, String? digitalSignature) {
    // TODO: implement addDealerStock
    throw UnimplementedError();
  }
}

DealerListEvent page(int offset, [String search = '']) => DealerListEvent(
  user_id: '1',
  latitude: '',
  longitude: '',
  searchText: search,
  type: 'Dealer',
  startLimit: offset,
);
List<DealerListModel> rows(int start, int count) => List.generate(
  count,
  (i) => DealerListModel(
    outletId: '${start + i}',
    outletName: 'Dealer ${start + i}',
    outletPerson: '',
    outletAddress: '',
  ),
);
Future<void> tick() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeRepository repo;
  late DealerListBloc bloc;
  setUp(() {
    repo = FakeRepository();
    bloc = DealerListBloc(repository: repo);
  });
  tearDown(() async {
    await bloc.close();
  });

  Future<void> firstPage() async {
    bloc.add(page(0));
    await tick();
    repo.requests.last.complete(rows(0, 20));
    await tick();
  }

  test(
    'appends pages, blocks duplicate requests, stops on short page',
    () async {
      await firstPage();
      bloc.add(page(20));
      bloc.add(page(20));
      await tick();
      expect(repo.offsets, [0, 20]);
      expect(bloc.state.isLoadingMore, isTrue);
      expect(bloc.state.dealerList.length, 20);
      repo.requests.last.complete(rows(20, 20));
      await tick();
      expect(bloc.state.dealerList.length, 40);
      expect(bloc.state.dealerList.last.outletId, '39');
      bloc.add(page(40));
      await tick();
      repo.requests.last.complete(rows(40, 3));
      await tick();
      expect(bloc.state.dealerList.length, 43);
      expect(bloc.state.hasMore, isFalse);
      bloc.add(page(60));
      await tick();
      expect(repo.offsets, [0, 20, 40]);
    },
  );

  test(
    'failed next page retains entries and retries the same offset',
    () async {
      await firstPage();
      bloc.add(page(20));
      await tick();
      repo.requests.last.completeError(Exception('offline'));
      await tick();
      expect(bloc.state.status, DealerListStatus.success);
      expect(bloc.state.dealerList.length, 20);
      expect(bloc.state.isLoadingMore, isFalse);
      expect(bloc.state.loadMoreError, isNotNull);
      bloc.add(page(20));
      await tick();
      expect(repo.offsets, [0, 20, 20]);
      repo.requests.last.complete([]);
      await tick();
      expect(bloc.state.loadMoreError, isNull);
      expect(bloc.state.hasMore, isFalse);
    },
  );

  test('new search ignores an older page still in flight', () async {
    await firstPage();
    bloc.add(page(20));
    await tick();
    final oldPage = repo.requests.last;
    bloc.add(page(0, 'new'));
    await tick();
    repo.requests.last.complete(rows(100, 2));
    await tick();
    oldPage.complete(rows(20, 20));
    await tick();
    expect(bloc.state.searchText, 'new');
    expect(bloc.state.dealerList.map((d) => d.outletId), ['100', '101']);
    expect(bloc.state.isLoadingMore, isFalse);
  });
}
