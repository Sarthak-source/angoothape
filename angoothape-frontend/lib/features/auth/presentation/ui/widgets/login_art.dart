
import 'package:flutter/material.dart';


class LoginArt extends StatelessWidget {
  const LoginArt({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Image(
        image: AssetImage('assets/images/login_side.jpg'),
        fit: BoxFit.cover,
      ),
    );
  }
}
