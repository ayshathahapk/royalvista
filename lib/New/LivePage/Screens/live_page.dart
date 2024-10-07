import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:auto_scroll_text/auto_scroll_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:royalvista/Core/app_export.dart';
import '../../../Core/CommenWidgets/custom_image_view.dart';
import '../../../Models/spread_document_model.dart';
import '../../NewsScreen/Controller/news_controller.dart';
import '../Controller/live_controller.dart';
import 'dart:math' as Math;

import '../Repository/live_repository.dart';
import 'commodity_list.dart';
import 'live_rate_widget.dart';

final rateBidValue = StateProvider(
  (ref) {
    return 0.0;
  },
);

class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});

  @override
  ConsumerState createState() => _LivePageState();
}

class _LivePageState extends ConsumerState<LivePage> {
  late Timer _timer;
  String formattedTime = DateFormat('h:mm:ss a').format(DateTime.now());
  final formattedTimeProvider = StateProvider(
    (ref) => DateFormat('h:mm a').format(DateTime.now()),
  );
  final bdTimeProvider = StateProvider(
    (ref) => "",
  );
  final uaeTimeProvider = StateProvider(
    (ref) => "",
  );
  final usTimeProvider = StateProvider(
    (ref) => "",
  );
  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        _updateTime(timer);
        convertTimes(timer);
      },
    );
  }

  final goldAskPrice = StateProvider.autoDispose<double>(
    (ref) => 0,
  );
  final silverAskPrice = StateProvider.autoDispose<double>(
    (ref) => 0,
  );
  void _updateTime(Timer timer) {
    ref.read(formattedTimeProvider.notifier).update(
          (state) => DateFormat('h:mm a').format(DateTime.now()),
        );
  }

  double getUnitMultiplier(String weight) {
    switch (weight) {
      case "GM":
        return 1;
      case "KG":
        return 1000;
      case "TTB":
        return 116.6400;
      case "TOLA":
        return 11.664;
      case "OZ":
        return 31.1034768;
      default:
        return 1;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  DateTime convertToTimeZone(DateTime dateTime, String timeZone) {
    final location = tz.getLocation(timeZone);
    final tz.TZDateTime tzDateTime = tz.TZDateTime.from(dateTime, location);
    return tzDateTime;
  }

  String ukTimeString = "";
  String bdTimeString = "";
  String inTimeString = "";
  String uaeTimeString = "";
  void convertTimes(Timer timer) {
    // Example timezones
    const String ukTimeZone = 'America/New_York';
    const String bdTimeZone = 'Asia/Dhaka';
    const String currentTimeZone = 'Asia/Kolkata';
    const String uaeTimeZone = 'Asia/Dubai';

    // Current time in your local timezone
    DateTime now = DateTime.now();

    // Convert to UK and Bangladesh time
    DateTime ukTime = convertToTimeZone(now, ukTimeZone);
    DateTime bdTime = convertToTimeZone(now, bdTimeZone);
    DateTime localTime = convertToTimeZone(now, currentTimeZone);
    DateTime uaeTime = convertToTimeZone(now, uaeTimeZone);
    // Format the time as needed
    ukTimeString = DateFormat('h:mm:ss a\nEEEE').format(ukTime);
    bdTimeString = DateFormat('h:mm:ss a\nEEEE').format(bdTime);
    inTimeString = DateFormat('h:mm:ss a\nEEEE').format(localTime);
    uaeTimeString = DateFormat('h:mm:ss a\nEEEE').format(uaeTime);
    ref.read(bdTimeProvider.notifier).update(
          (state) => bdTimeString,
        );
    ref.read(usTimeProvider.notifier).update(
          (state) => ukTimeString,
        );
    ref.read(uaeTimeProvider.notifier).update(
          (state) => uaeTimeString,
        );
  }

  final bannerBool = StateProvider.autoDispose(
    (ref) => false,
  );
  @override
  Widget build(BuildContext context) {
    final liveRateData = ref.watch(liveRateProvider);
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.0.h, right: 8.0.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    // width: SizeUtils.width / 3,
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          color: appTheme.mainBlue,
                        ),
                        Text(
                          DateFormat("MMM dd yyyy").format(DateTime.now()),
                          style: CustomPoppinsTextStyles.bodyText,
                        ),
                        Text(
                            DateFormat("EEEE")
                                .format(DateTime.now())
                                .toUpperCase(),
                            style: CustomPoppinsTextStyles.bodyText)
                      ],
                    ),
                  ),
                  SizedBox(
                    // width: SizeUtils.width / 3,
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.time,
                          color: appTheme.mainBlue,
                        ),
                        Consumer(
                          builder: (context, ref, child) => Text(
                            ref.watch(formattedTimeProvider),
                            style: CustomPoppinsTextStyles.bodyText,
                          ),
                        ),
                        space()
                      ],
                    ),
                  )
                ],
              ),
              space(),
              space(),
              space(),
              Container(
                height: 55.h,
                decoration: BoxDecoration(
                  color: appTheme.mainBlue,
                  borderRadius: BorderRadius.circular(15.v),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    space(w: 50.h),
                    const Spacer(),
                    Text(
                      "BUY\$",
                      style: CustomPoppinsTextStyles.bodyText1White2,
                    ),
                    const Spacer(),
                    Text(
                      "SELL\$",
                      style: CustomPoppinsTextStyles.bodyText1White2,
                    ),
                    space(w: 50.h)
                  ],
                ),
              ),
              space(),
              Consumer(
                builder: (context, ref1, child) {
                  return ref1.watch(spotRateProvider).when(
                    data: (spotRate) {
                      if (spotRate != null) {
                        if (liveRateData != null &&
                            liveRateData.gold != null &&
                            liveRateData.silver != null) {
                          final spreadNow = spotRate.info;
                          WidgetsBinding.instance.addPostFrameCallback(
                            (timeStamp) {
                              ref1.read(bannerBool.notifier).update(
                                (state) {
                                  return liveRateData.gold!.marketStatus !=
                                          "TRADEABLE"
                                      ? true
                                      : false;
                                },
                              );
                              ref1.read(rateBidValue.notifier).update(
                                (state) {
                                  return liveRateData.gold!.bid +
                                      (spreadNow.goldBidSpread);
                                },
                              );
                              ref1.read(goldAskPrice.notifier).update(
                                (state) {
                                  final res = (liveRateData.gold!.bid +
                                      (spreadNow.goldAskSpread));
                                  return res;
                                },
                              );
                              ref1.read(silverAskPrice.notifier).update(
                                (state) {
                                  final res = (liveRateData.gold!.bid +
                                      (spreadNow.goldAskSpread) +
                                      (spreadNow.goldBidSpread) +
                                      0.5);
                                  return res;
                                },
                              );
                            },
                          );
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(10.v)),
                                width: SizeUtils.width,
                                height: SizeUtils.height * 0.1,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: "Gold",
                                          style: CustomPoppinsTextStyles
                                              .bodyTextGold),
                                      TextSpan(
                                          text: "OZ",
                                          style: GoogleFonts.poppins(
                                              // fontFamily: marine,
                                              color: appTheme.gold,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.fSize))
                                    ])),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ValueDisplayWidget(
                                          value: (liveRateData.gold!.bid +
                                              (spreadNow.goldBidSpread)),
                                          // value: ref1.watch(goldAskPrice),
                                          // value: (liveRateData.gold.bid +
                                          //     (spreadNow?.editedBidSpreadValue ??
                                          //         0))
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_down_fill,
                                              color: appTheme.red700,
                                              size: 20.v,
                                            ),
                                            Text(
                                              "${liveRateData.gold!.low + (spreadNow.goldLowMargin)}",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ValueDisplayWidget2(
                                          value: (((liveRateData.gold!.bid +
                                                      spreadNow.goldBidSpread) +
                                                  spreadNow.goldAskSpread) +
                                              0.05),
                                          // value: ref1.watch(silverAskPrice),
                                          // value: (liveRateData.gold.bid +
                                          //     (spreadNow?.editedBidSpreadValue ??
                                          //         0) +
                                          //     (spreadNow?.editedAskSpreadValue ??
                                          //         0) +
                                          //     0.5)
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_up_fill,
                                              color: appTheme.mainGreen,
                                              size: 20.v,
                                            ),
                                            Text(
                                              "${liveRateData.gold?.high ?? 0 + (spreadNow.goldHighMargin)}",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              space(),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(10.v)),
                                width: SizeUtils.width,
                                height: SizeUtils.height * 0.1,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: "Silver",
                                          style: CustomPoppinsTextStyles
                                              .bodyTextGold),
                                      TextSpan(
                                          text: "OZ",
                                          style: GoogleFonts.poppins(
                                              // fontFamily: marine,
                                              color: appTheme.gold,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.fSize))
                                    ])),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ValueDisplayWidgetSilver1(
                                            // value: 0,
                                            value: (liveRateData.silver?.bid ??
                                                0 +
                                                    (spreadNow
                                                            .silverBidSpread ??
                                                        0))),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_down_fill,
                                              color: appTheme.red700,
                                              size: 20.v,
                                            ),
                                            Text(
                                              "${liveRateData.silver?.low ?? 0 + (spreadNow.silverLowMargin)}",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ValueDisplayWidgetSilver2(
                                            // value: 0,
                                            value: (((liveRateData.silver!.bid +
                                                        spreadNow
                                                            .silverBidSpread) +
                                                    spreadNow.silverAskSpread) +
                                                0.05)),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_up_fill,
                                              color: appTheme.mainGreen,
                                              size: 20.v,
                                            ),
                                            Text(
                                              "${liveRateData.silver?.high ?? 0 + (spreadNow.silverHighMargin)}",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              space(),
                            ],
                          );
                        } else {
                          print("Live rate is Null");
                          return Column(
                            children: [
                              Card(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: SizeUtils.width,
                                  height: SizeUtils.height * 0.1,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Gold",
                                            style: CustomPoppinsTextStyles
                                                .bodyTextGold),
                                        TextSpan(
                                            text: "OZ",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.fSize))
                                      ])),
                                      Column(
                                        children: [
                                          const ValueDisplayWidget(value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const ValueDisplayWidget2(value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              space(),
                              Card(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: SizeUtils.width,
                                  height: SizeUtils.height * 0.1,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Silver",
                                            style: CustomPoppinsTextStyles
                                                .bodyTextGold),
                                        TextSpan(
                                            text: "OZ",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.fSize))
                                      ])),
                                      Column(
                                        children: [
                                          const ValueDisplayWidgetSilver1(
                                              value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const ValueDisplayWidgetSilver2(
                                              value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              space(),
                            ],
                          );
                        }
                      } else {
                        print("Spot rate is Null");
                        return Column(
                          children: [
                            Card(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: SizeUtils.width,
                                height: SizeUtils.height * 0.1,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: "Gold",
                                          style: CustomPoppinsTextStyles
                                              .bodyTextGold),
                                      TextSpan(
                                          text: "OZ",
                                          style: GoogleFonts.poppins(
                                              // fontFamily: marine,
                                              color: appTheme.gold,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.fSize))
                                    ])),
                                    Column(
                                      children: [
                                        const ValueDisplayWidget(value: 0.0),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_down_fill,
                                              color: appTheme.red700,
                                            ),
                                            Text(
                                              "0.0",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const ValueDisplayWidget2(value: 0.0),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_up_fill,
                                              color: appTheme.mainGreen,
                                            ),
                                            Text(
                                              "0.0",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            space(),
                            Card(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: SizeUtils.width,
                                height: SizeUtils.height * 0.1,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: "Silver",
                                          style: CustomPoppinsTextStyles
                                              .bodyTextGold),
                                      TextSpan(
                                          text: "OZ",
                                          style: GoogleFonts.poppins(
                                              // fontFamily: marine,
                                              color: appTheme.gold,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.fSize))
                                    ])),
                                    Column(
                                      children: [
                                        const ValueDisplayWidgetSilver1(
                                            value: 0.0),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_down_fill,
                                              color: appTheme.red700,
                                            ),
                                            Text(
                                              "0.0",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const ValueDisplayWidgetSilver2(
                                            value: 0.0),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .arrowtriangle_up_fill,
                                              color: appTheme.mainGreen,
                                            ),
                                            Text(
                                              "0.0",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextSemiBold,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            space(),
                          ],
                        );
                      }
                    },
                    error: (error, stackTrace) {
                      print("###ERROR###");
                      print(error.toString());
                      print(stackTrace);
                      return const Center(
                        child: Text("Something Went Wrong"),
                      );
                    },
                    loading: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                },
              ),
              Consumer(
                builder: (context, ref2, child) => CommodityList(
                  price: ref2.watch(goldAskPrice),
                  slverPrice: ref2.watch(silverAskPrice),
                ),
              ),
              space(),
              Consumer(
                builder: (context, ref1, child) {
                  return ref1.watch(newsProvider).when(
                        data: (data123) {
                          if (data123 != null) {
                            return AutoScrollText(
                              delayBefore: const Duration(seconds: 1),
                              "${data123.news.news[0].title}                             ",
                              style: CustomPoppinsTextStyles.bodyText,
                            );
                          } else {
                            return Text(
                              "NO News",
                              style: CustomPoppinsTextStyles.bodyText,
                            );
                          }
                        },
                        error: (error, stackTrace) {
                          print(stackTrace);
                          print(error.toString());
                          return const SizedBox();
                        },
                        loading: () => const SizedBox(),
                      );
                },
              ),
              // AutoScrollText(
              //   delayBefore: Duration(seconds: 3),
              //   "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
              //   style: CustomPoppinsTextStyles.bodyText,
              // ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: CustomImageView(
            imagePath: ImageConstants.logo,
            width: 110.h,
          ),
        ),
        if (ref.watch(bannerBool))
          Positioned(
            top: 15.v,
            right: 50.h,
            child: Transform.rotate(
              angle: -Math.pi / 4,
              child: Consumer(
                builder: (context, refBanner, child) {
                  return Container(
                    width: SizeUtils.width,
                    height: 30.h,
                    color: Colors.red,
                    child: Center(
                      child: AutoScrollText(
                        delayBefore: const Duration(seconds: 1),
                        "           Market is closed. It will open soon!            ",
                        style: CustomPoppinsTextStyles.buttonText,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

///
