import 'package:fluttertoast/fluttertoast.dart';

abstract class Util
{
  static showToast(String text) {
    return Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        fontSize: 16.0
    );
  }
}
