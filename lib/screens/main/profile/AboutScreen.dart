import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'Sobre',
          maxLines: 1,
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
            fontSize: 35.nsp,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Flexible(
              flex: 2,
              child: AutoSizeText(
                'Rango é um aplicativo desenvolvido por pessoas que anseiam pelo momento do almoço, e o entendem como uma brecha de prazer e distração em meio a um dia corrido.',
                textAlign: TextAlign.left,
                style: GoogleFonts.montserrat(
                  color: Colors.grey[600],
                  fontSize: 30.nsp,
                ),
              ),
            ),
            SizedBox(height: 0.01.hp),
            Flexible(
              flex: 3,
              child: AutoSizeText(
                'Feito para ajudar o rango universitário a acontecer de forma mais organizada, nesse aplicativo conectamos quem quer comprar a quem quer vender, de modo que a comunicação seja mais clara e concisa. Assim, facilitamos o horário de almoço para todo mundo e ninguém passa fome!',
                textAlign: TextAlign.left,
                style: GoogleFonts.montserrat(
                  color: Colors.grey[600],
                  fontSize: 35.nsp,
                ),
              ),
            ),
            SizedBox(height: 0.01.hp),
            Flexible(
              flex: 1,
              child: AutoSizeText(
                'Protótipo feito por: Fernanda Arnaut, Julia Lopes e Luísa Forain.',
                textAlign: TextAlign.left,
                style: GoogleFonts.montserrat(
                  color: Colors.grey[600],
                  fontSize: 30.nsp,
                ),
              ),
            ),
            SizedBox(height: 0.01.hp),
            Flexible(
              flex: 2,
              child: AutoSizeText(
                'Aplicativo desenvolvido como TCC por Gabriel Vargas, Guilherme Franco e Rebeca Fonseca.',
                textAlign: TextAlign.left,
                style: GoogleFonts.montserrat(
                  color: Colors.grey[600],
                  fontSize: 35.nsp,
                ),
              ),
            ),
            SizedBox(height: 0.01.hp),
            Expanded(
              flex: 4,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/imgs/logo_devmob.png',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
