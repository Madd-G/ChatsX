import 'package:chatsx/common/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'index.dart';

class PhonePage extends GetView<PhoneController> {
  const PhonePage({super.key});

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
            "Sign in with phone number",
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

  Widget _buildPhoneBtn() {
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
          controller.handlePhone();
          //
        });
  }

  Widget _buildPhoneInput(BuildContext context) {
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
        child: Row(
          children: [
            GestureDetector(
              child: Container(
                width: 60.w,
                height: 25.h,
                decoration: BoxDecoration(
                    border: Border(
                  right: BorderSide(
                      width: 2.w, color: AppColors.primarySecondaryBackground),
                )),
                child: Text(
                  controller.state.chooseIndexFlag.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              onTap: () {
                chooseCountry();
              },
            ),
            SizedBox(
                width: 233.w,
                height: 44.h,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: controller.phoneEditingController,
                  onChanged: (value) {
                    controller.state.phoneNumber.value = value;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter your phone number",
                    contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    hintStyle: const TextStyle(
                      color: AppColors.primarySecondaryElementText,
                    ),
                    prefixIcon: GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin:
                            EdgeInsets.only(top: 12.h, left: 15.w, right: 5.w),
                        child: Text(
                          controller.state.chooseIndexDialCode.value,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.normal,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.normal,
                    fontSize: 14.sp,
                  ),
                  maxLines: 1,
                  autocorrect: false,
                  obscureText: false,
                ))
          ],
        ));
  }

  Future chooseCountry() {
    controller.state.chooseIndex.value = 0;
    return Get.bottomSheet(
      Obx(() => Container(
          height: 350.h,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                  width: 360.w,
                  height: 50.h,
                  padding: EdgeInsets.only(left: 15.w, right: 15.w),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            child: Text(
                              "Cancel",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontFamily: "Avenir",
                                fontWeight: FontWeight.normal,
                                fontSize: 15.sp,
                              ),
                            ),
                            onTap: () {
                              Get.back();
                            }),
                        GestureDetector(
                            child: Text(
                              "Confirm",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.thirdElement,
                                fontFamily: "Avenir",
                                fontWeight: FontWeight.normal,
                                fontSize: 15.sp,
                              ),
                            ),
                            onTap: () {
                              controller.saveAddress();
                            })
                      ])),
              SizedBox(
                width: 360.w,
                height: 300.h,
                child: CupertinoPicker.builder(
                  backgroundColor: Colors.white,
                  itemExtent: 50.h,
                  magnification: 1.1,
                  diameterRatio: 1.0,
                  selectionOverlay:
                      const CupertinoPickerDefaultSelectionOverlay(
                          background: Color.fromRGBO(200, 200, 200, 0.1)),
                  scrollController: controller.fixedExtentScrollController,
                  useMagnifier: true,
                  childCount: controller.state.countryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 27.h,
                      child: Text(
                        "${controller.state.countryList.elementAt(index).dialCode} ${controller.state.countryList.elementAt(index).flag} ${controller.state.countryList.elementAt(index).name}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontFamily: "Avenir",
                          fontWeight: FontWeight.normal,
                          fontSize: 20.sp,
                        ),
                      ),
                    );
                  },
                  onSelectedItemChanged: (value) {
                    debugPrint('$value');
                    controller.state.chooseIndex.value = value;
                  },
                ),
              ),
            ],
          ))),
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
      isDismissible: true,
      enableDrag: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: Obx(() {
        return CustomScrollView(slivers: [
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
                    _buildPhoneInput(context),
                    _buildPhoneBtn(),
                  ],
                ),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}
