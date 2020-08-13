import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sobre',
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
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 25),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: Column(
                    children: [
                      Text(
                        'Rango é um aplicativo desenvolvido por pessoas que anseiam pelo momento do almoço, e o entendem como uma brecha de prazer e distração em meio a um dia corrido. \n\nFeito para ajudar o rango universitário a acontecer de forma mais organizada, nesse aplicativo conectamos quem quer comprar a quem quer vender, de modo que a comunicação seja mais clara e concisa. Assim, facilitamos o horário de almoço para todo mundo e ninguém passa fome!',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Protótipo feito por: Fernanda Arnaut, Julia Lopes e Luísa Forain.',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Aplicativo desenvolvido como TCC por Gabriel Vargas, Guilherme Franco e Rebeca Fonseca.',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Image.asset(
                          'assets/imgs/logo_devmob.png',
                          width: 125,
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
