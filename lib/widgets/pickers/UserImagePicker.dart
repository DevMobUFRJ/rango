import 'package:flutter/material.dart';
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
                ),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      pickImgFromGallery = true;
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Galeria',
                      style: GoogleFonts.montserrat(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      pickImgFromGallery = false;
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Câmera',
                      style: GoogleFonts.montserrat(
                        color: Theme.of(context).accentColor,
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
          maxWidth: 150,
        );
        if (pickedImage != null) {
          final pickedImageFile = File(pickedImage.path);
          widget._imagePickFn(pickedImageFile);
          setState(() => _pickedImage = pickedImageFile);
        }
      } catch (error) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Ocorreu um erro ao escolher a foto, tente novmanete'),
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
                CircleAvatar(
                  radius: 55,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage)
                      : widget.image != null
                          ? NetworkImage(widget.image)
                          : null,
                  backgroundColor: Theme.of(context).accentColor,
                ),
                if (_pickedImage == null && widget.image == null)
                  Icon(
                    Icons.person,
                    color: Theme.of(context).backgroundColor,
                    size: 85,
                  ),
              ],
            ),
            if (widget.editText != null)
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  widget.editText,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
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
