import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:listview_test/restful_client.dart';

class HomeFuturePage extends StatefulWidget {
  const HomeFuturePage({super.key, required this.title});

  final String title;

  @override
  State<HomeFuturePage> createState() => _HomeFuturePageState();
}

class _HomeFuturePageState extends State<HomeFuturePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Section>>(
        future: RestfulClient.getSectionSetting(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('錯誤'));
          } else {
            List<Section> sections = snapshot.data!;
            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                setState(() {});

                await RestfulClient.getSectionSetting();
              },
              child: ListView.builder(
                // key: const PageStorageKey<String>("my_list"),
                itemCount: sections.length,
                cacheExtent: double.maxFinite, // 設定緩存範圍
                itemBuilder: (context, index) {
                  Section section = sections[index];
                  switch (index) {
                    case 0:
                      return HorizontalListSection(section: section);
                    case 1:
                      return GridViewSection(section: section);
                    case 2:
                      return ListViewSection(section: section);
                    case 3:
                      return GridViewSection(section: section);
                    case 4:
                      return HorizontalListSection(section: section);

                    default:
                      return Container();
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class HorizontalListSection extends StatelessWidget {
  final Section section;

  const HorizontalListSection({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text("Section ${section.id}"),
          FutureBuilder<List<Item>>(
              future: RestfulClient.getItemList(section.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: CupertinoActivityIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text("Error: ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("沒有任何item"),
                  );
                } else {
                  List<Item> items = snapshot.data!;
                  return SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // Horizontal scrolling
                      itemCount: section.maxItemCount < items.length
                          ? section.maxItemCount
                          : items.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: items[index].height,
                          margin: const EdgeInsets.all(4.0),
                          color: items[index].color,
                          child: Center(
                            child: Text(
                              "$index",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}

class GridViewSection extends StatelessWidget {
  final Section section;

  const GridViewSection({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text("Section ${section.id}"),
          FutureBuilder<List<Item>>(
              future: RestfulClient.getItemList(section.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: CupertinoActivityIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text("Error: ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("沒有任何item"),
                  );
                } else {
                  List<Item> items = snapshot.data!;
                  return MasonryGridView.count(
                    shrinkWrap: true,
                    itemCount: section.maxItemCount < items.length
                        ? section.maxItemCount
                        : items.length,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        alignment: Alignment.center,
                        height: items[index].height,
                        color: items[index].color,
                        child: Text(
                          "$index",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  );
                }
              }),
        ],
      ),
    );
  }
}

class ListViewSection extends StatelessWidget {
  final Section section;

  const ListViewSection({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('Section ${section.id}'),
          FutureBuilder<List<Item>>(
            future: RestfulClient.getItemList(section.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CupertinoActivityIndicator(),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('沒有任何item'),
                );
              } else {
                List<Item> items = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: section.maxItemCount < items.length
                      ? section.maxItemCount
                      : items.length,
                  itemBuilder: (context, index) {
                    Item item = items[index];
                    return Container(
                      alignment: Alignment.center,
                      color: item.color,
                      height: item.height,
                      child: Text(
                        "$index",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
