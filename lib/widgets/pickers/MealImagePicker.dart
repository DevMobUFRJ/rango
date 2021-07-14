import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';

class MealImagePicker extends StatefulWidget {
  final Function(File pickedImage) _imagePickFn;
  final String image;
  final String editText;

  MealImagePicker(this._imagePickFn, {
    this.image,
    this.editText,
  });

  @override
  _MealImagePickerState createState() => _MealImagePickerState();
}

class _MealImagePickerState extends State<MealImagePicker> {
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
                onPressed: () async {
                  try {
                    //await Permission.photosAddOnly.request();
                    pickImgFromGallery = true;
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        Text('Ocorreu um erro ao escolher a foto, tente novamanete'),
                      ),
                    );
                  }
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
                onPressed: () async {
                  try {
                    //await Permission.camera.request();
                    pickImgFromGallery = false;
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        Text('Ocorreu um erro ao escolher a foto, tente novamanete'),
                      ),
                    );
                  }
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
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Ocorreu um erro ao escolher a foto, tente novamanete'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        children: [
          if (widget.editText != null)
            Text(
              widget.editText,
              style: GoogleFonts.montserrat(
                fontSize: 36.nsp,
                color: Theme.of(context).accentColor,
                decoration: TextDecoration.underline,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_pickedImage != null || widget.image != null)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  constraints:
                      BoxConstraints(maxHeight: 0.7.hp, maxWidth: 0.9.wp),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image(
                      image: _pickedImage != null
                          ? FileImage(_pickedImage)
                          : FirebaseImage(widget.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (_pickedImage == null && widget.image == null)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    color: Theme.of(context).accentColor,
                  ),
                  width: 0.9.wp,
                  height: 0.5.wp,
                  child: Icon(
                    Icons.photo,
                    color: Colors.white,
                    size: 160.nsp,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
