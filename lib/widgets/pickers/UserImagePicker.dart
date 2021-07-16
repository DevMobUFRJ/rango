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
              backgroundColor: Theme.of(ctx).backgroundColor,
              actionsPadding: EdgeInsets.all(10),
              title: Text(
                'Escolha de onde pegar a imagem',
                style: GoogleFonts.montserrat(
                  color: Theme.of(context).accentColor,
                  fontSize: 38.nsp,
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
                        color: Theme.of(context).accentColor,
                        fontSize: 36.nsp,
                      ),
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
                        color: Theme.of(context).accentColor,
                        fontSize: 36.nsp,
                      ),
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
    ScreenUtil.init(context, width: 750, height: 1334);
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 120.w,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage)
                      : widget.image != null
                          ? NetworkImage(widget.image)
                          : NetworkImage(
                              'https://ra.ac.ae/wp-content/uploads/2017/02/user-icon-placeholder.png'),
                  backgroundColor: Theme.of(context).accentColor,
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
