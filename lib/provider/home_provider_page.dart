import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listview_test/restful_client.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/subjects.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Provider<HomePageViewModel>(
        create: (context) {
          viewModel.getSectionList();
          return viewModel;
        },
        dispose: (context, value) => value.dispose,
        child: Consumer<HomePageViewModel>(
          builder: (context, provider, child) {
            return StreamBuilder<bool>(
                stream: provider.isLodaing,
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
                  return StreamBuilder<List<Section>?>(
                    stream: provider.sectionList,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return RefreshIndicator(
                          key: _refreshIndicatorKey,
                          onRefresh: () async {
                            await viewModel.getSectionList();
                          },
                          child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              cacheExtent: double.maxFinite,
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text("Section $index"),
                                    ),
                                    ContentListView(
                                      id: snapshot.data![index].id,
                                      maxItemCount:
                                          snapshot.data![index].maxItemCount,
                                    ),
                                  ],
                                );
                              }),
                        );
                      } else {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }
                    },
                  );
                });
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
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: maxItemCount < snapshot.data!.length
                ? maxItemCount
                : snapshot.data!.length,
            itemBuilder: (context, index) {
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
