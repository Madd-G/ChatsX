import 'package:chatsx/common/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'controller.dart';
import 'package:photo_view/photo_view.dart';

class PhotoImgViewPage extends GetView<PhotoImgViewController> {
  const PhotoImgViewPage({super.key});

  AppBar _buildAppBar() {
    return AppBar(
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: AppColors.secondaryElement,
              height: 2.0,
            )),
        title: Text(
          "PhotoView",
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
      backgroundColor: Colors.white,
      body: PhotoView(
        imageProvider: NetworkImage(controller.state.url.value),
      ),
    );
  }
}
