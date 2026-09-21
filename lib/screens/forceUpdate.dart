import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdate extends StatefulWidget {
  const ForceUpdate({super.key});
  @override
  _ForceUpdateState createState() => _ForceUpdateState();
}

class _ForceUpdateState extends State<ForceUpdate> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Stack(
        children: [
          Image.asset("assets/icons/header.png", width: size.width),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Set the clip behavior of the card
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  // Define the child widgets of the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels
                      Image.asset(
                        'assets/main/packageimage.png',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Add a container with padding that contains the card's title, text, and buttons
                      Container(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'To ensure the smooth and optimal functioning of our application, it is necessary for all users to update to the latest version. By updating to the latest version, you will have access to enhanced features, improved performance, and important bug fixes that contribute to an overall better user experience.,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            // Add a row with two buttons spaced apart and aligned to the right side of the card
                            Row(
                              children: <Widget>[
                                // Add a spacer to push the buttons to the right side of the card
                                const Spacer(),
                                // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text

                                // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                TextButton(
                                  child: const Text(
                                    "UPDATE NOW",
                                  ),
                                  onPressed: () {
                                    // _launchURL(Platform.isIOS?'https://apps.apple.com/us/app/login2/id6450980527':'https://play.google.com/store/apps/details?id=com.login2.mentorbee');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Add a small space between the card and the next widget
                      Container(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _launchURL(String url) async {
    launchUrl(Uri.parse(url));
  }
}
