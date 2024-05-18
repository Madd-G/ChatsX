import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../index.dart';

class HelloWordWidget extends GetView<NotfoundController> {
  const HelloWordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() => Text(controller.state.title)),
    );
  }
}
