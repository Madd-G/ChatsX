import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'index.dart';
import 'widgets/widgets.dart';

class NotFoundPage extends GetView<NotfoundController> {
  const NotFoundPage({super.key});

  Widget _buildView() {
    return const HelloWordWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildView(),
    );
  }
}
