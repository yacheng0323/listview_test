import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listview_test/restful_client.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class HomeProviderPage extends StatefulWidget {
  const HomeProviderPage({super.key, required this.title});

  final String title;

  @override
  State<HomeProviderPage> createState() => _HomeProviderPageState();
}

class _HomeProviderPageState extends State<HomeProviderPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  late final HomePageViewModel viewModel;

  @override
  void initState() {
    viewModel = HomePageViewModel();
    super.initState();
    viewModel.getSectionList();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Provider<HomePageViewModel>(
        create: (context) => viewModel,
        dispose: (context, value) => value.dispose(),
        child: Consumer<HomePageViewModel>(
          builder: (context, provider, child) {
            return StreamBuilder<bool>(
              stream: provider.isLodaing,
              builder: (context, loadingSnapshot) {
                if (loadingSnapshot.data == true) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
                return StreamBuilder<List<Section>?>(
                  stream: provider.sectionList,
                  builder: (context, sectionSnapshot) {
                    if (sectionSnapshot.hasData) {
                      final sections = sectionSnapshot.data!;
                      return RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: () async {
                          await viewModel.getSectionList();
                        },
                        child: CustomScrollView(
                          scrollDirection: Axis.vertical,
                          slivers: sections.map((section) {
                            return StreamBuilder<List<Item>?>(
                                stream: viewModel.getItemList(id: section.id),
                                builder: (context, itemSnapshot) {
                                  if (itemSnapshot.hasData) {
                                    final items = itemSnapshot.data!;

                                    return SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                      print("this is ${section.id} - $index");
                                      final item = items[index];
                                      return Container(
                                        height: item.height,
                                        margin: items.last == item
                                            ? const EdgeInsets.fromLTRB(
                                                4, 4, 4, 24)
                                            : const EdgeInsets.all(4.0),
                                        color: item.color,
                                        child: Center(
                                          child: Text(
                                            "${section.id} - $index",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        ),
                                      );
                                    },
                                            childCount: section.maxItemCount <
                                                    items.length
                                                ? section.maxItemCount
                                                : items.length));
                                  } else if (itemSnapshot.hasError) {
                                    return SliverToBoxAdapter(
                                      child: Center(
                                          child: Text(
                                              'Error: ${itemSnapshot.error}')),
                                    );
                                  } else {
                                    return const SliverToBoxAdapter(
                                      child: Center(
                                        child: CupertinoActivityIndicator(),
                                      ),
                                    );
                                  }
                                });
                          }).toList(),
                        ),
                      );
                    } else {
                      return const Center(
                        child: CupertinoActivityIndicator(),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ContentListView extends StatelessWidget {
  final int id;
  final int maxItemCount;

  const ContentListView({
    super.key,
    required this.id,
    required this.maxItemCount,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomePageViewModel>(context, listen: false);
    return StreamBuilder<List<Item>?>(
      stream: viewModel.getItemList(id: id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemExtent: 50,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: maxItemCount < snapshot.data!.length
                ? maxItemCount
                : snapshot.data!.length,
            itemBuilder: (context, index) {
              print("this is $index");

              final item = snapshot.data![index];
              return Container(
                height: item.height,
                margin: const EdgeInsets.all(4.0),
                color: item.color,
                child: Center(
                  child: Text(
                    "$index",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
      },
    );
  }
}

class HomePageViewModel {
  final _isLoading = BehaviorSubject<bool>.seeded(false);

  ValueStream<bool> get isLodaing => _isLoading.stream;

  final _sectionList = BehaviorSubject<List<Section>?>.seeded(null);

  ValueStream<List<Section>?> get sectionList => _sectionList.stream;

  void dispose() {
    _isLoading.close();
    _sectionList.close();
  }

  Future<void> getSectionList() async {
    _isLoading.add(true);
    try {
      List<Section> sectionList = await RestfulClient.getSectionSetting();

      _sectionList.add(sectionList);
      _isLoading.add(false);
    } catch (error) {
      _sectionList.addError(error);
      _isLoading.add(false);
    }
  }

  Stream<List<Item>?> getItemList({required int id}) {
    final itemList = BehaviorSubject<List<Item>?>();
    RestfulClient.getItemList(id).then((items) {
      itemList.add(items);
    }).catchError((error) {
      itemList.addError(error);
    });
    return itemList.stream;
  }
}
