import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _giftController;
  late final AnimationController _confettiController;
  late final AnimationController _hintBounceController;
  late final Animation<Offset> _hintBounceAnimation;

  bool hasGiftOpened = false;
  bool showMessage = false;
  bool showTapHint = true;

  @override
  void initState() {
    super.initState();

    _giftController = AnimationController(vsync: this);
    _confettiController = AnimationController(vsync: this);

    // 🎈 Bouncing animation for hint
    _hintBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _hintBounceAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -0.50), // slight upward bounce
        ).animate(
          CurvedAnimation(
            parent: _hintBounceController,
            curve: Curves.easeInOut,
          ),
        );

    _giftController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !hasGiftOpened) {
        setState(() {
          hasGiftOpened = true;
        });

        _confettiController.forward(from: 0);

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            showMessage = true;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _giftController.dispose();
    _confettiController.dispose();
    _hintBounceController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!hasGiftOpened) {
      setState(() {
        showTapHint = false;
      });
      _hintBounceController.stop(); // stop bounce after tap
      _giftController.forward(from: 0);
    } else {
      _confettiController.forward(from: 0); // replay confetti
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🎉 Confetti background
            Lottie.asset(
              'assets/confetti.json',
              controller: _confettiController,
              onLoaded: (composition) {
                _confettiController.duration = composition.duration;
              },
              width: MediaQuery.of(context).size.width,
              repeat: false,
            ),

            // 🎁 Gift & message column
            Center(
              child: GestureDetector(
                onTap: _onTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 👆 Bouncing hint above gift
                    if (showTapHint)
                      SlideTransition(
                        position: _hintBounceAnimation,
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            '🎁 下のプレゼントをタップしてね!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    // 🎁 Gift animation
                    Lottie.asset(
                      'assets/gift_opening.json',
                      controller: _giftController,
                      onLoaded: (composition) {
                        _giftController.duration = composition.duration;
                      },
                      width: 250,
                    ),

                    const SizedBox(height: 20),

                    // 🎂 Birthday message
                    if (showMessage)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          '🎉 山田さん、お誕生日おめでとうございます! 🎉',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
