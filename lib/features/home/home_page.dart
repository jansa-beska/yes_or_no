import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yesno/features/home/repo/home_repo.dart';
import 'package:yesno/features/premium/premium_page.dart';
import 'package:yesno/features/tutorial/tutorial_page.dart';

const _productIds = {'weekly1'};

class HomePage extends StatefulWidget {
  final bool isPro;
  const HomePage({
    Key? key,
    required this.isPro,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String link = 'google.com';
  String answer = '';
  late bool isPremium = widget.isPro;

  late StreamSubscription<dynamic> _subscription;
  List<ProductDetails> _products = [];
  InAppPurchase inAppPurchase = InAppPurchase.instance;

  @override
  void initState() {
    if (Platform.isAndroid) {
      final Stream purchaseUpdated = inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {});
      initStoreInfo();
      super.initState();
    }
    super.initState();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: const Text('Error purchasing subscription'),
              action: SnackBarAction(
                label: 'Close',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          setState(() {
            isPremium = true;
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            date,
            (DateTime.now().add(
              const Duration(days: 7),
            )).toIso8601String(),
          );
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  initStoreInfo() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {}
    ProductDetailsResponse productDetailResponse = await inAppPurchase.queryProductDetails(
      _productIds,
    );
    if (productDetailResponse.error == null) {
      setState(() {
        _products = productDetailResponse.productDetails;
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          isPremium
              ? Container()
              : CupertinoButton(
                  child: Row(
                    children: [
                      const Text(
                        'Go',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Container(
                        height: 27,
                        width: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'Pro',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PremiumPage(
                          productDetails: _products[0],
                          onPurchase: () async {
                            final res = await inAppPurchase.buyNonConsumable(
                              purchaseParam: PurchaseParam(
                                productDetails: _products[0],
                              ),
                            );
                            if (res) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    );
                  },
                )
        ],
      ),
      body: Stack(
        children: [
          SvgPicture.asset('assets/Union.svg'),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'YES or NO?',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 26,
                ),
                SizedBox(
                  height: 64,
                  width: 124,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.white,
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          children: [
                            SizedBox(
                              width: 330,
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Answer is...',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    FutureBuilder(
                                      future: HomeRepo.getData(),
                                      builder: (context, AsyncSnapshot<DataModel> snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          link = snapshot.data!.giflink;
                                          answer = snapshot.data!.answer + '!'.toUpperCase();
                                          if (isPremium) {
                                            return Column(
                                              children: [
                                                Text(
                                                  '${snapshot.data!.answer}!'.toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 45,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Image.network(
                                                  snapshot.data!.giflink,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      return child;
                                                    } else {
                                                      return const CircularProgressIndicator(
                                                        color: Colors.black,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Text(
                                              '${snapshot.data!.answer}!'.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 45,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            );
                                          }
                                        } else {
                                          return const CircularProgressIndicator(
                                            color: Colors.black,
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(
                                      height: 50,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 20,
                                      ),
                                      child: isPremium
                                          ? Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                SizedBox(
                                                  height: 64,
                                                  width: 124,
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      await Share.shareWithResult(link, subject: answer);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      shadowColor: Colors.white,
                                                      primary: Colors.black,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(18),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Share',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 64,
                                                  width: 124,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      shadowColor: Colors.white,
                                                      primary: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(18),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Close',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : SizedBox(
                                              width: double.infinity,
                                              height: 64,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shadowColor: Colors.white,
                                                  primary: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(18),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Close',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Tap',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
