import 'dart:math';

import 'package:flutter/material.dart';

class Section {
  final int id;
  final int maxItemCount;

  Section({
    required this.id,
    required this.maxItemCount,
  });
}

class Item {
  final double height;
  final Color color;

  Item({
    required this.color,
    required this.height,
  });
}

class RestfulClient {
  static Future<List<Section>> getSectionSetting() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      Section(
        id: 0,
        maxItemCount: 10,
      ),
      Section(
        id: 1,
        maxItemCount: 3,
      ),
      Section(
        id: 2,
        maxItemCount: 10,
      ),
      Section(
        id: 3,
        maxItemCount: 99,
      ),
      Section(
        id: 4,
        maxItemCount: 10,
      ),
    ];
  }

  static Future<List<Item>> getItemList(int id) async {
    // await Future.delayed(const Duration(seconds: 2));

    // switch (id) {
    //   case 0:
    //     return generateRandomItems(5);
    //   case 1:
    //     return generateRandomItems(30);
    //   case 2:
    //     return generateRandomItems(1);
    //   case 3:
    //     return generateRandomItems(99);
    //   case 4:
    //     return generateRandomItems(10);
    // }
    switch (id) {
      case 0:
        await Future.delayed(const Duration(seconds: 2));
        return generateRandomItems(5);
      case 1:
        await Future.delayed(const Duration(seconds: 6));
        return generateRandomItems(30);
      case 2:
        await Future.delayed(const Duration(seconds: 4));
        return generateRandomItems(1);
      case 3:
        await Future.delayed(const Duration(seconds: 8));
        return generateRandomItems(99);
      case 4:
        await Future.delayed(const Duration(seconds: 10));
        return generateRandomItems(10);
    } // 模擬 api 回應時間不同，分區域顯示
    return generateRandomItems(5);
  }
}

List<Item> generateRandomItems(int count) {
  final random = Random();
  return List<Item>.generate(count, (index) {
    return Item(
      height: 20 + random.nextDouble() * 40,
      color: Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ),
    );
  });
}
