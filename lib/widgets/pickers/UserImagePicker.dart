import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final Function(File pickedImage) _imagePickFn;
  final String image;
  final String editText;

  UserImagePicker(
    this._imagePickFn, {
    this.image,
    this.editText,
  });

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;

  void _pickImage() async {
    bool pickImgFromGallery;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
              backgroundColor: Color(0xFFF9B152),
              actionsPadding: EdgeInsets.all(10),
              title: Text(
                'Escolha de onde pegar a imagem',
                style: GoogleFonts.montserrat(
                  fontSize: 38.nsp,
                  color: Colors.white,
                ),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      pickImgFromGallery = true;
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Galeria',
                      style: GoogleFonts.montserrat(
                          fontSize: 36.nsp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      pickImgFromGallery = false;
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Câmera',
                      style: GoogleFonts.montserrat(
                          fontSize: 36.nsp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ));
    final picker = ImagePicker();
    if (pickImgFromGallery != null) {
      try {
        final pickedImage = await picker.getImage(
          source: pickImgFromGallery ? ImageSource.gallery : ImageSource.camera,
          imageQuality: 50,
        );
        if (pickedImage != null) {
          final pickedImageFile = File(pickedImage.path);
          widget._imagePickFn(pickedImageFile);
          setState(() => _pickedImage = pickedImageFile);
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            backgroundColor: Theme.of(context).errorColor,
            content: Text(
              'Ocorreu um erro ao escolher a foto, tente novamente',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if (_pickedImage != null)
                  CircleAvatar(
                    radius: 120.w,
                    backgroundImage: FileImage(_pickedImage),
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                if (_pickedImage == null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(120.w),
                    child: CachedNetworkImage(
                      width: 120,
                      height: 120,
                      imageUrl: widget.image,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => CircleAvatar(
                        backgroundColor: Theme.of(context).accentColor,
                        backgroundImage:
                            AssetImage('assets/imgs/user_placeholder.png'),
                      ),
                      errorWidget: (ctx, url, error) => CircleAvatar(
                        backgroundColor: Theme.of(context).accentColor,
                        backgroundImage:
                            AssetImage('assets/imgs/user_placeholder.png'),
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.editText != null)
              Padding(
                padding: EdgeInsets.only(left: 0.05.wp),
                child: Text(
                  widget.editText,
                  style: GoogleFonts.montserrat(
                    fontSize: 36.nsp,
                    color: Color(0xFF609B90),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
