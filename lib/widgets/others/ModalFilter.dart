import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/widgets/auth/CustomTextFormField.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModalFilter extends StatefulWidget {
  final int range;
  ModalFilter(this.range);

  @override
  ModalFilterState createState() => ModalFilterState();
}

class ModalFilterState extends State<ModalFilter> {
  final int sellerRang = 10;
  final _formKey = GlobalKey<FormState>();
  final _focusNodeVendedor = FocusNode();
  final _focusNodeQuentinha = FocusNode();
  TextEditingController _buscaVendedor = TextEditingController();
  TextEditingController _buscaQuentinha = TextEditingController();
  String _errorBuscavendedorMessage;
  String _errorBuscaQuentinhaMessage;
  int raio;

  @override
  void initState() {
    raio = widget.range;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 15.0),
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 0.05.wp, bottom: 0.01.hp),
                child: Text(
                  "Raio de vendedores (por KM)",
                  style: TextStyle(
                    fontSize: 38.nsp,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              )),
          _sliderRange(context),
          SizedBox(height: 5.0),
          Flexible(
            flex: 2,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: CustomTextFormField(
                textCapitalization: TextCapitalization.sentences,
                labelText: 'Buscar por vendedor',
                controller: _buscaVendedor,
                key: ValueKey('buscaVendedor'),
                validator: (String value) {
                  // if (value.trim() != '' && value.trim().length != 11) {
                  //   setState(() => _telefoneErrorMessage =
                  //       'Telefone precisa ter 11 números');
                  // }
                  return null;
                },
                errorText: _errorBuscavendedorMessage,
                focusNode: _focusNodeVendedor,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onSaved: (value) => _buscaVendedor.text = value,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
            ),
          ),
          SizedBox(height: 5.0),
          Flexible(
            flex: 2,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: CustomTextFormField(
                labelText: 'Buscar por quentinha',
                controller: _buscaQuentinha,
                key: ValueKey('buscaQuentinha'),
                validator: (String value) {
                  // if (value.trim() != '' && value.trim().length != 11) {
                  //   setState(() => _telefoneErrorMessage =
                  //       'Telefone precisa ter 11 números');
                  // }
                  return null;
                },
                errorText: _errorBuscaQuentinhaMessage,
                focusNode: _focusNodeQuentinha,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onSaved: (value) => _buscaQuentinha.text = value,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  print("filtrar");
                  print(_buscaQuentinha == null);
                  Navigator.pop(context, {
                    "vendedor": '',
                    'quentinha': '',
                  });
                  print("buscando por" + _buscaVendedor.text);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.1.wp),
                  child: AutoSizeText(
                    'Reiniciar filtro',
                    style: GoogleFonts.montserrat(
                      fontSize: 32.nsp,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print("filtrar");
                  print(_buscaQuentinha == null);
                  Navigator.pop(context, {
                    "vendedor": _buscaVendedor.text,
                    "quentinha": _buscaQuentinha.text,
                    "filtrando": true,
                  });
                  print("buscando por" + _buscaVendedor.text);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.1.wp),
                  child: AutoSizeText(
                    'Filtrar',
                    style: GoogleFonts.montserrat(
                      fontSize: 32.nsp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12)
        ],
      ),
    ));
  }

  mainBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return;
        });
  }

  Widget _sliderRange(BuildContext contextGeral) {
    return Slider(
      value: raio.toDouble(),
      onChanged: (novo) {
        setState(() {
          raio = novo.round();
        });
      },
      onChangeEnd: (novo) {
        print("ESCOLHI O NOVO VALOR =" + novo.toString());
        setState(() {
          raio = novo.round();
        });
      },
      min: 1.0,
      max: 50.0,
      divisions: 100,
      activeColor: Theme.of(contextGeral).accentColor,
      label: "$raio",
    );
  }
}
