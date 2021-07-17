import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:rango/models/shift.dart';
import 'package:rango/utils/date_time.dart';
import 'package:rango/utils/string_formatters.dart';

class HorarioRow extends StatefulWidget {
  final String day;
  final Weekday horarioDia;
  final void Function(bool value) switchOpen;
  final void Function(TimeOfDay hour) changeOpeningHour;
  final void Function(TimeOfDay hour) changeClosingHour;

  HorarioRow({
    this.day,
    this.horarioDia,
    this.switchOpen,
    this.changeOpeningHour,
    this.changeClosingHour,
  });

  @override
  _HorarioRowState createState() => _HorarioRowState();
}

class _HorarioRowState extends State<HorarioRow> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 1,
            child: Container(
              constraints:
                  BoxConstraints(minWidth: 35, maxWidth: 35, maxHeight: 20),
              child: AutoSizeText(
                widget.day,
                style: GoogleFonts.montserrat(fontSize: 30.nsp),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Checkbox(
              value: widget.horarioDia.open,
              onChanged: (value) => widget.switchOpen(value),
            ),
          ),
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: !widget.horarioDia.open
                  ? () {}
                  : () => {
                        showTimePicker(
                          context: context,
                          initialTime: intTimeToTimeOfDay(widget.horarioDia.openingTime),
                          cancelText: 'Cancelar',
                          confirmText: 'Confirmar',
                          helpText: 'Horário de abertura',
                          builder: (BuildContext context, Widget child) =>
                              MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: child),
                        ).then(
                          (TimeOfDay value) {
                            if (value != null) {
                              if (value.hour * 100 + value.minute > widget.horarioDia.closingTime) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Theme.of(context).errorColor,
                                    content: Text(
                                      'O horário de abertura deve ser antes do horário de fechamento.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              } else {
                                widget.changeOpeningHour(value);
                              }
                            }
                          }
                        ),
                      },
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                color: widget.horarioDia.open ? Colors.white : Colors.grey[200],
                child: TextFormField(
                  enabled: false,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    errorStyle: GoogleFonts.montserrat(fontSize: 22.nsp),
                    border: InputBorder.none,
                    hintText: widget.horarioDia.open
                        ? formatTime(widget.horarioDia.openingTime)
                        : null,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: !widget.horarioDia.open
                  ? () {}
                  : () => {
                        showTimePicker(
                          context: context,
                          initialTime: intTimeToTimeOfDay(widget.horarioDia.closingTime),
                          cancelText: 'Cancelar',
                          confirmText: 'Confirmar',
                          helpText: 'Horário de fechamento',
                          builder: (BuildContext context, Widget child) =>
                              MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: child),
                        ).then(
                          (TimeOfDay value) {
                            if (value != null) {
                              if (value.hour * 100 + value.minute < widget.horarioDia.openingTime) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Theme.of(context).errorColor,
                                    content: Text(
                                      'O horário de fechamento deve ser depois do horário de abertura.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              } else {
                                widget.changeClosingHour(value);
                              }
                            }
                          },
                        ),
                      },
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                color: widget.horarioDia.open ? Colors.white : Colors.grey[200],
                child: TextFormField(
                  enabled: false,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    errorStyle: GoogleFonts.montserrat(fontSize: 22.nsp),
                    border: InputBorder.none,
                    hintText: widget.horarioDia.open
                        ? formatTime(widget.horarioDia.closingTime)
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
