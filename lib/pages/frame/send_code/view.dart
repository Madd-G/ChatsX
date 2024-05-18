import 'package:chatsx/common/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:get/get.dart';
import 'index.dart';

class SendCodePage extends GetView<SendCodeController> {
  const SendCodePage({super.key});

  AppBar _buildAppBar() {
    return AppBar();
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 0.h, bottom: 30.h),
          child: Text(
            "ChatsX .",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 28.sp,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 0.h, bottom: 20.h),
          child: Text(
            "Enter the 6 digit codes we send to you",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.normal,
              fontSize: 16.sp,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildCodeBtn() {
    return GestureDetector(
        child: Container(
          width: 295.w,
          height: 44.h,
          margin: EdgeInsets.only(top: 60.h, bottom: 30.h),
          padding: EdgeInsets.all(0.h),
          decoration: BoxDecoration(
            color: AppColors.primaryElement,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Sign in",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryElementText,
                  fontWeight: FontWeight.normal,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          controller.submitOTP();
        });
  }

  Widget _buildCodeInput() {
    return Container(
      width: 295.w,
      margin: EdgeInsets.only(bottom: 20.h, top: 0.h),
      padding: EdgeInsets.all(0.h),
      child: Center(
        child: VerificationCode(
          itemSize: 44,
          textStyle:
              const TextStyle(fontSize: 20.0, color: AppColors.primaryText),
          keyboardType: TextInputType.number,
          underlineColor: AppColors.primaryElement,
          // If this is null it will use primaryColor: Colors.red from Theme
          length: 6,
          cursorColor: AppColors.primaryElement,
          // If this is null it will default to the ambient
          // clearAll is NOT required, you can delete it
          // takes any widget, so you can implement your design
          onCompleted: (String value) {
            controller.state.verifycode.value = value;
            // setState(() {
            //   _code = value;
            // });
          },
          onEditing: (bool value) {
            // setState(() {
            //   _onEditing = value;
            // });
            // if (!_onEditing) FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: CustomScrollView(slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: 15.w,
            horizontal: 15.w,
          ),
          sliver: SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(bottom: 0.h, top: 0.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLogo(),
                  _buildCodeInput(),
                  _buildCodeBtn(),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
