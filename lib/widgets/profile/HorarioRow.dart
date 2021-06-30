import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:rango/models/shift.dart';

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
                          initialTime: TimeOfDay.now(),
                          cancelText: 'Cancelar',
                          confirmText: 'Confirmar',
                          helpText: 'Horário de abertura',
                          builder: (BuildContext context, Widget child) =>
                              MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: child),
                        ).then(
                          (value) => value == null
                              ? null
                              : widget.changeOpeningHour(value),
                        ),
                      },
              child: Material(
                shape: RoundedRectangleBorder(),
                color: widget.horarioDia.open ? Colors.white : Colors.grey[200],
                elevation: 1,
                child: TextFormField(
                  enabled: false,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    errorStyle: GoogleFonts.montserrat(fontSize: 22.nsp),
                    border: InputBorder.none,
                    hintText: widget.horarioDia.open
                    //TODO Adicionar :
                        ? widget.horarioDia.openingTime.toString()
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
                          initialTime: TimeOfDay.now(),
                          cancelText: 'Cancelar',
                          confirmText: 'Confirmar',
                          helpText: 'Horário de fechamento',
                          builder: (BuildContext context, Widget child) =>
                              MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: child),
                        ).then(
                          (value) => value == null
                              ? null
                              : widget.changeClosingHour(value),
                        ),
                      },
              child: Material(
                shape: RoundedRectangleBorder(),
                color: widget.horarioDia.open ? Colors.white : Colors.grey[200],
                elevation: 1,
                child: TextFormField(
                  enabled: false,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    errorStyle: GoogleFonts.montserrat(fontSize: 22.nsp),
                    border: InputBorder.none,
                    hintText: widget.horarioDia.open
                    //TODO Adicionar :
                        ? widget.horarioDia.closingTime.toString()
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
