import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yesno/features/home/home_page.dart';

const date = 'DATE';

class TutorialPage extends StatelessWidget {
  const TutorialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.black,
      floatingActionButton: SizedBox(
        width: 314,
        height: 64,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            shadowColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: () async {
            if (Platform.isIOS) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomePage(isPro: true),
                ),
              );
            } else {
              final shared = await SharedPreferences.getInstance();
              final res = shared.getString(date);
              if (res != null) {
                final a = DateTime.now().compareTo(DateTime.parse(res));
                if (a < 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(isPro: true),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(isPro: false),
                    ),
                  );
                }
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(isPro: false),
                  ),
                );
              }
            }
          },
          child: const Text(
            'Get start',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Spacer(),
            SvgPicture.asset('assets/zoom.svg'),
            const Spacer(),
            const Text(
              "Can't decide what to do? Our app is here to help you",
              style: TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
