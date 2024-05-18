import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'index.dart';
import 'widgets/widgets.dart';
import 'package:chatsx/common/values/values.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactPage extends GetView<ContactController> {
  const ContactPage({super.key});

  AppBar _buildAppBar() {
    return AppBar(
        // backgroundColor: Colors.transparent,
        // elevation: 0,
        title: Text(
      "Contact",
      style: TextStyle(
        color: AppColors.primaryText,
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: const ContactList(),
    );
  }
}
