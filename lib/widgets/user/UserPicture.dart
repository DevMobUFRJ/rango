import 'package:flutter/material.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/resources/repository.dart';

class UserPicture extends StatefulWidget {
  final String picture;
  final bool hasInternet;

  const UserPicture(
    this.picture, {
    this.hasInternet,
  });

  @override
  _UserPictureState createState() => _UserPictureState();
}

class _UserPictureState extends State<UserPicture> {
  bool _hasInternet;
  @override
  void initState() {
    if (widget.hasInternet == null) {
      _checkInternet();
    } else {
      setState(() => _hasInternet = widget.hasInternet);
    }
    super.initState();
  }

  Future<void> _checkInternet() async {
    bool hasInternet = await Repository.instance.getInternetConnection();
    setState(() => _hasInternet = hasInternet);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasInternet == null) {
      Repository.instance.checkInternetConnection(context);
    }
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 40, bottom: 40),
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setSp(30)),
              color: Color(0xFFF9B152),
            ),
          ),
          if (widget.picture == null || _hasInternet == null || !_hasInternet)
            FittedBox(
              fit: BoxFit.cover,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                backgroundImage: AssetImage('assets/imgs/user_placeholder.png'),
                radius: 70,
              ),
            ),
          if (widget.picture != null && (_hasInternet != null && _hasInternet))
            ClipRRect(
              borderRadius: BorderRadius.circular(120),
              child: Container(
                width: 150,
                height: 150,
                color: Theme.of(context).accentColor,
                child: FadeInImage(
                  placeholder: AssetImage('assets/imgs/user_placeholder.png'),
                  image: FirebaseImage(widget.picture),
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
