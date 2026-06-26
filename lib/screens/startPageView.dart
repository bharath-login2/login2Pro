import '../../widgets/login_button_widget.dart';
import '../../widgets/register_button_widget.dart';
import '../../widgets/size_config.dart';
import 'package:flutter/material.dart';



class StartPageView extends StatefulWidget {
  const StartPageView({super.key});

  @override
  _StartPageViewState createState() => _StartPageViewState();
}

class _StartPageViewState extends State<StartPageView> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            height: SizeConfig.screenHeight!/2.732,    /// 250.0
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/main/bg.png'),
                    fit: BoxFit.fill
                )
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: SizeConfig.screenWidth!/1.83,     /// 225.0
                height: SizeConfig.screenHeight!/5.174,  /// 132.0
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/main/funriders.png",),
                        fit: BoxFit.cover
                    )
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    0,
                    SizeConfig.screenHeight!/68.3,               /// 10.0
                    0,
                    SizeConfig.screenHeight!/11.38               /// 60.0
                ),
                child: Column(
                    children:[
                      Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text('WELCOME', style: TextStyle(color: Colors.white, fontSize: SizeConfig.screenHeight!/30,fontWeight: FontWeight.bold),),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth!/10.28, vertical: SizeConfig.screenHeight!/136.6),    /// 40.0 - 5.0
                        child: const Center(child: Text("Bizzlog is Simple application to store  your visitors/enquiries details and promote your business through whatsapp marketing tools and Bulksms.", style: TextStyle(color: Colors.white60),
                          textAlign: TextAlign.center,),),
                      )
                    ]
                ),
              ),
              const LoginButton(),
              const RegisterButtonWidget()
            ],
          )
        ],
      ),
    );
  }
}