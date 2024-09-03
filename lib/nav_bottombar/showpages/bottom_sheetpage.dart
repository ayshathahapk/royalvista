import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:royalvista/nav_bottombar/showpages/bank_details.dart';
import 'package:royalvista/nav_bottombar/showpages/news.dart';
import '../../main.dart';

List a = [
  {'text': 'News', 'icon': Icon(Icons.newspaper, color: Color(0xFFBFA13A),)},
  {'text': "Bank details", 'icon': Icon(Icons.shopping_cart, color:Color(0xFFBFA13A))},
];

List b = [
  News(),
  BankDetails(),
];

class Bottomsheet extends StatefulWidget {
  const Bottomsheet({Key? key}) : super(key: key);

  @override
  State<Bottomsheet> createState() => _BottomsheetState();
}

class _BottomsheetState extends State<Bottomsheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height * 0.3,
      width: width,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: a.length,
          itemBuilder: (context, index) {
            return
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => b[index]),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.10),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: height * 0.10,
                            width: width * 0.20,
                            color: Colors.grey[400],
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      a[index]['icon'],
                                      SizedBox(height: height * 0.01),
                                      Text(
                                        a[index]['text'],
                                        style: GoogleFonts.urbanist(color: Colors.white, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
          },
        ),
      ),
    );
  }
}