import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserPicture extends StatefulWidget {
  final String picture;

  const UserPicture(this.picture);

  @override
  _UserPictureState createState() => _UserPictureState();
}

class _UserPictureState extends State<UserPicture> {
  @override
  void initState() {
    super.initState();
  }

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
          if (widget.picture == null)
            FittedBox(
              fit: BoxFit.cover,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                backgroundImage: AssetImage('assets/imgs/user_placeholder.png'),
                radius: 150.w,
              ),
            ),
          if (widget.picture != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(120),
              child: Container(
                width: 150,
                height: 150,
                color: Theme.of(context).accentColor,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.picture,
                  placeholder: (ctx, url) => Image(
                    image: AssetImage('assets/imgs/user_placeholder.png'),
                  ),
                  errorWidget: (ctx, url, error) => Image(
                    image: AssetImage('assets/imgs/user_placeholder.png'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
