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
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (ctx, constraint) => SingleChildScrollView(
          child: Container(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height - kToolbarHeight - 86,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 0.01.hp,
                  horizontal: 0.08.wp,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: Column(
                    children: [
                      Flexible(
                        flex: 2,
                        child: AutoSizeText(
                          'Rango é um aplicativo desenvolvido por pessoas que anseiam pelo momento do almoço, e o entendem como uma brecha de prazer e distração em meio a um dia corrido.',
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.clip,
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(height: 0.01.hp),
                      Flexible(
                        flex: 2,
                        child: AutoSizeText(
                          'Feito para ajudar o rango universitário a acontecer de forma mais organizada, nesse aplicativo conectamos quem quer comprar a quem quer vender, de modo que a comunicação seja mais clara e concisa. Assim, facilitamos o horário de almoço para todo mundo e ninguém passa fome!',
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.clip,
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(height: 0.01.hp),
                      Flexible(
                        flex: 1,
                        child: Container(
                          child: AutoSizeText(
                            'Protótipo feito por: Fernanda Arnaut, Julia Lopes e Luísa Forain.',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.montserrat(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 0.01.hp),
                      Flexible(
                        flex: 1,
                        child: AutoSizeText(
                          'Aplicativo desenvolvido como TCC por Gabriel Vargas, Guilherme Franco e Rebeca Fonseca.',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(height: 0.01.hp),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            'assets/imgs/logo_devmob.png',
                            width: 200.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
