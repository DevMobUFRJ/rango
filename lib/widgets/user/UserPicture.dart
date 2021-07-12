import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserPicture extends StatelessWidget {
  final String picture;
  final bool hasInternet;

  const UserPicture(
    this.picture, {
    this.hasInternet,
  });

  @override
  Widget build(BuildContext context) {
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
          if (picture == null || hasInternet == null || !hasInternet)
            FittedBox(
              fit: BoxFit.cover,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                backgroundImage: AssetImage('assets/imgs/user_placeholder.png'),
                radius: 80,
              ),
            ),
          if (picture != null && (hasInternet != null && hasInternet))
            ClipRRect(
              borderRadius: BorderRadius.circular(120),
              child: Container(
                width: 150,
                height: 150,
                color: Theme.of(context).accentColor,
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/imgs/user_placeholder.png',
                  image: picture,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
