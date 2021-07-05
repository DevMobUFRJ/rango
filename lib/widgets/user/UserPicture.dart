import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserPicture extends StatelessWidget {
  const UserPicture(
    this.picture,
  );

  final String picture;

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
          if (picture != null)
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
          if (picture == null)
            FittedBox(
              fit: BoxFit.cover,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                backgroundImage: AssetImage('assets/imgs/user_placeholder.png'),
                radius: 80,
              ),
            ),
        ],
      ),
    );
  }
}
