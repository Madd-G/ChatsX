import 'package:chatsx/common/routes/names.dart';
import 'package:chatsx/common/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'index.dart';

class EmailLoginPage extends GetView<EmailLoginController> {
  const EmailLoginPage({super.key});

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
          margin: EdgeInsets.only(top: 0.h, bottom: 30.h),
          child: Text(
            "Sign in with Email",
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

  Widget _buildLoginBtn() {
    return GestureDetector(
        child: Container(
          width: 295.w,
          height: 44.h,
          margin: EdgeInsets.only(top: 60.h, bottom: 30.h),
          padding: EdgeInsets.all(10.h),
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
          controller.handleEmailLogin();
        });
  }

  Widget _buildEmailInput() {
    return Container(
        width: 295.w,
        height: 44.h,
        margin: EdgeInsets.only(bottom: 20.h, top: 0.h),
        padding: EdgeInsets.all(0.h),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
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
        child: TextField(
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: "Enter your email address",
            contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            hintStyle: TextStyle(
              color: AppColors.primarySecondaryElementText,
            ),
          ),
          style: TextStyle(
            color: AppColors.primaryText,
            fontFamily: "Avenir",
            fontWeight: FontWeight.normal,
            fontSize: 14.sp,
          ),
          onChanged: (value) {
            controller.state.email.value = value;
          },
          maxLines: 1,
          autocorrect: false,
          // 自动纠正
          obscureText: false,
        ));
  }

  Widget _buildPasswordInput() {
    return Container(
        width: 295.w,
        height: 44.h,
        margin: EdgeInsets.only(bottom: 20.h, top: 0.h),
        padding: EdgeInsets.all(0.h),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
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
        child: TextField(
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: "Enter your password",
            contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            hintStyle: TextStyle(
              color: AppColors.primarySecondaryElementText,
            ),
          ),
          style: TextStyle(
            color: AppColors.primaryText,
            fontFamily: "Avenir",
            fontWeight: FontWeight.normal,
            fontSize: 14.sp,
          ),
          onChanged: (value) {
            controller.state.password.value = value;
          },
          maxLines: 1,
          autocorrect: false,
          obscureText: true,
        ));
  }

  Widget _forgotPassword() {
    return SizedBox(
      width: 260.w,
      height: 44.h,
      child: GestureDetector(
          child: Text(
            "Forgot password?",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.primaryText,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryText,
              fontWeight: FontWeight.normal,
              fontSize: 12.sp,
            ),
          ),
          onTap: () {
            Get.toNamed(AppRoutes.Forgot);
          }),
    );
  }

  Widget _bottomRegister() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Don't have an account?",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.normal,
            fontSize: 12.sp,
          ),
        ),
        GestureDetector(
            child: Text(
              "Register here",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryElement,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primaryElement,
                fontSize: 12.sp,
              ),
            ),
            onTap: () {
              Get.toNamed(AppRoutes.Register);
            }),
      ],
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
                  _buildEmailInput(),
                  _buildPasswordInput(),
                  _forgotPassword(),
                  _buildLoginBtn(),
                  _bottomRegister()
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
