import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/dayShift.dart';
import 'package:rango/models/shift.dart';
import 'package:intl/intl.dart';

class HorariosScreen extends StatefulWidget {
  @override
  _HorariosScreenState createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  Shift _horariosFuncionamento = Shift(
    friday: DayShift(open: true, openingTime: '10:00', closingTime: '18:00'),
    monday: DayShift(open: true, openingTime: '10:00', closingTime: '18:00'),
    saturday: DayShift(open: false),
    sunday: DayShift(open: false),
    thursday: DayShift(open: true, openingTime: '12:00', closingTime: '18:00'),
    tuesday: DayShift(open: true, openingTime: '10:00', closingTime: '18:00'),
    wednesday: DayShift(open: true, openingTime: '12:00', closingTime: '18:00'),
  );
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'Horários de funcionamento',
          style: GoogleFonts.montserrat(
            color: Theme.of(context).accentColor,
            fontSize: 35.nsp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 0.8.hp,
          margin: EdgeInsets.symmetric(horizontal: 0.06.wp),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 1,
                  child: AutoSizeText(
                    'Selecione as caixas referentes aos dias de abertura e então selecione os horários de funcionamento',
                    style: GoogleFonts.montserrat(fontSize: 30.nsp),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth: 35, maxWidth: 35, maxHeight: 20),
                          child: AutoSizeText(
                            'Dom',
                            style: GoogleFonts.montserrat(fontSize: 30.nsp),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Checkbox(
                          value: _horariosFuncionamento.sunday.open,
                          onChanged: (value) => {
                            setState(() =>
                                _horariosFuncionamento.sunday.open = value),
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.sunday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .sunday.openingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.sunday.open
                                    ? _horariosFuncionamento.sunday.openingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.sunday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now())
                                        .then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .sunday.closingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.sunday.open
                                    ? _horariosFuncionamento.sunday.closingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth: 35, maxWidth: 35, maxHeight: 20),
                          child: AutoSizeText(
                            'Seg',
                            style: GoogleFonts.montserrat(
                              fontSize: 30.nsp,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Checkbox(
                          value: _horariosFuncionamento.monday.open,
                          onChanged: (value) => {
                            setState(() =>
                                _horariosFuncionamento.monday.open = value),
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.monday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .monday.openingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.monday.open
                                    ? _horariosFuncionamento.monday.openingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.monday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .monday.closingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.monday.open
                                    ? _horariosFuncionamento.monday.closingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth: 35, maxWidth: 35, maxHeight: 20),
                          child: AutoSizeText('Ter',
                              style: GoogleFonts.montserrat(fontSize: 30.nsp)),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Checkbox(
                          value: _horariosFuncionamento.tuesday.open,
                          onChanged: (value) => setState(() =>
                              _horariosFuncionamento.tuesday.open = value),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.tuesday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .tuesday.openingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.tuesday.open
                                    ? _horariosFuncionamento.tuesday.openingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.tuesday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .tuesday.closingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.tuesday.open
                                    ? _horariosFuncionamento.tuesday.closingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth: 35, maxWidth: 35, maxHeight: 20),
                          child: AutoSizeText(
                            'Qua',
                            style: GoogleFonts.montserrat(fontSize: 30.nsp),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Checkbox(
                          value: _horariosFuncionamento.wednesday.open,
                          onChanged: (value) => setState(() =>
                              _horariosFuncionamento.wednesday.open = value),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.wednesday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .wednesday.openingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.wednesday.open
                                    ? _horariosFuncionamento
                                        .wednesday.openingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.wednesday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .wednesday.closingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.wednesday.open
                                    ? _horariosFuncionamento
                                        .wednesday.closingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth: 35, maxWidth: 35, maxHeight: 20),
                          child: AutoSizeText(
                            'Qui',
                            style: GoogleFonts.montserrat(fontSize: 30.nsp),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Checkbox(
                          value: _horariosFuncionamento.thursday.open,
                          onChanged: (value) => setState(() =>
                              _horariosFuncionamento.thursday.open = value),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.thursday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .thursday.openingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.thursday.open
                                    ? _horariosFuncionamento
                                        .thursday.openingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.thursday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .thursday.closingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.thursday.open
                                    ? _horariosFuncionamento
                                        .thursday.closingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth: 35, maxWidth: 35, maxHeight: 20),
                          child: AutoSizeText(
                            'Sex',
                            style: GoogleFonts.montserrat(fontSize: 30.nsp),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Checkbox(
                          value: _horariosFuncionamento.friday.open,
                          onChanged: (value) => setState(
                              () => _horariosFuncionamento.friday.open = value),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.friday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .friday.openingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.friday.open
                                    ? _horariosFuncionamento.friday.openingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.friday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .friday.closingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.friday.open
                                    ? _horariosFuncionamento.friday.closingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth: 35, maxWidth: 35, maxHeight: 20),
                          child: AutoSizeText(
                            'Sab',
                            style: GoogleFonts.montserrat(fontSize: 30.nsp),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Checkbox(
                          value: _horariosFuncionamento.saturday.open,
                          onChanged: (value) => setState(() =>
                              _horariosFuncionamento.saturday.open = value),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.saturday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .saturday.openingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.saturday.open
                                    ? _horariosFuncionamento
                                        .saturday.openingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: !_horariosFuncionamento.saturday.open
                              ? () {}
                              : () => {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => setState(
                                        () => _horariosFuncionamento
                                                .saturday.closingTime =
                                            DateFormat("HH:mm").format(
                                          DateFormat("hh:mm a").parse(
                                            value.format(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                          child: Material(
                            shape: RoundedRectangleBorder(),
                            elevation: 1,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                errorStyle:
                                    GoogleFonts.montserrat(fontSize: 22.nsp),
                                border: InputBorder.none,
                                hintText: _horariosFuncionamento.saturday.open
                                    ? _horariosFuncionamento
                                        .saturday.closingTime
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    width: 0.3.wp,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: AutoSizeText(
                        'Salvar',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(fontSize: 36.nsp),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
