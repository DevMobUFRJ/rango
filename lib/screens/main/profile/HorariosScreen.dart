import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/models/shift.dart';
import 'package:intl/intl.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/profile/HorarioRow.dart';

class HorariosScreen extends StatefulWidget {
  final Seller usuario;

  HorariosScreen(this.usuario);

  @override
  _HorariosScreenState createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  Shift _horariosFuncionamento;
  final _formKey = GlobalKey<FormState>();

  int _handleSelectedSchedule(TimeOfDay initialHorario) {
    String stringHorario = initialHorario.format(context);
    if (stringHorario.contains('AM') || stringHorario.contains("PM")) {
      stringHorario = DateFormat("HH:mm")
          .format(DateFormat("hh:mm a").parse(stringHorario));
    }
    return int.parse(stringHorario.replaceAll(':', ''));
  }

  @override
  void initState() {
    _horariosFuncionamento = widget.usuario.shift;
    if (_horariosFuncionamento == null) {
      _horariosFuncionamento = Shift(
          sunday: Weekday(open: false),
          monday: Weekday(open: false),
          tuesday: Weekday(open: false),
          wednesday: Weekday(open: false),
          thursday: Weekday(open: false),
          friday: Weekday(open: false),
          saturday: Weekday(open: false)
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 0.06.wp),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 2,
                child: AutoSizeText(
                  'Marque as caixas referentes aos dias de funcionamento e então escolha os horários de abertura/fechamento.',
                  style: GoogleFonts.montserrat(fontSize: 30.nsp),
                ),
              ),
              HorarioRow(
                day: 'Dom',
                switchOpen: (value) =>
                    setState(() => _horariosFuncionamento.sunday.open = value),
                horarioDia: _horariosFuncionamento.sunday,
                changeOpeningHour: (value) => setState(
                  () => _horariosFuncionamento.sunday.openingTime =
                      _handleSelectedSchedule(value),
                ),
                changeClosingHour: (value) => setState(
                  () => _horariosFuncionamento.sunday.closingTime =
                      _handleSelectedSchedule(value),
                ),
              ),
              HorarioRow(
                day: 'Seg',
                switchOpen: (value) =>
                    setState(() => _horariosFuncionamento.monday.open = value),
                horarioDia: _horariosFuncionamento.monday,
                changeOpeningHour: (value) => setState(
                  () => _horariosFuncionamento.monday.openingTime =
                      _handleSelectedSchedule(value),
                ),
                changeClosingHour: (value) => setState(
                  () => _horariosFuncionamento.monday.closingTime =
                      _handleSelectedSchedule(value),
                ),
              ),
              HorarioRow(
                day: 'Ter',
                switchOpen: (value) =>
                    setState(() => _horariosFuncionamento.tuesday.open = value),
                horarioDia: _horariosFuncionamento.tuesday,
                changeOpeningHour: (value) => setState(
                  () => _horariosFuncionamento.tuesday.openingTime =
                      _handleSelectedSchedule(value),
                ),
                changeClosingHour: (value) => setState(
                  () => _horariosFuncionamento.tuesday.closingTime =
                      _handleSelectedSchedule(value),
                ),
              ),
              HorarioRow(
                day: 'Qua',
                switchOpen: (value) => setState(
                    () => _horariosFuncionamento.wednesday.open = value),
                horarioDia: _horariosFuncionamento.wednesday,
                changeOpeningHour: (value) => setState(
                  () => _horariosFuncionamento.wednesday.openingTime =
                      _handleSelectedSchedule(value),
                ),
                changeClosingHour: (value) => setState(
                  () => _horariosFuncionamento.wednesday.closingTime =
                      _handleSelectedSchedule(value),
                ),
              ),
              HorarioRow(
                day: 'Qui',
                switchOpen: (value) => setState(
                    () => _horariosFuncionamento.thursday.open = value),
                horarioDia: _horariosFuncionamento.thursday,
                changeOpeningHour: (value) => setState(
                  () => _horariosFuncionamento.thursday.openingTime =
                      _handleSelectedSchedule(value),
                ),
                changeClosingHour: (value) => setState(
                  () => _horariosFuncionamento.thursday.closingTime =
                      _handleSelectedSchedule(value),
                ),
              ),
              HorarioRow(
                day: 'Sex',
                switchOpen: (value) =>
                    setState(() => _horariosFuncionamento.friday.open = value),
                horarioDia: _horariosFuncionamento.friday,
                changeOpeningHour: (value) => setState(
                  () => _horariosFuncionamento.friday.openingTime =
                      _handleSelectedSchedule(value),
                ),
                changeClosingHour: (value) => setState(
                  () => _horariosFuncionamento.friday.closingTime =
                      _handleSelectedSchedule(value),
                ),
              ),
              HorarioRow(
                day: 'Sáb',
                switchOpen: (value) => setState(
                    () => _horariosFuncionamento.saturday.open = value),
                horarioDia: _horariosFuncionamento.saturday,
                changeOpeningHour: (value) => setState(
                  () => _horariosFuncionamento.saturday.openingTime =
                      _handleSelectedSchedule(value),
                ),
                changeClosingHour: (value) => setState(
                  () => _horariosFuncionamento.saturday.closingTime =
                      _handleSelectedSchedule(value),
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  width: 0.3.wp,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        for (var weekday in _horariosFuncionamento.toJson().values) {
                          if (weekday['open'] == true && (weekday['openingTime'] == null || weekday['closingTime'] == null)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 2),
                                backgroundColor: Theme.of(context).errorColor,
                                content: Text(
                                  'Complete os horários de funcionamento',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            );
                            return;
                          }
                        }
                        Repository.instance.updateSeller(
                            widget.usuario.id,
                            {'shift': _horariosFuncionamento.toJson()}
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 2),
                            backgroundColor: Theme.of(context).accentColor,
                            content: Text(
                              'Horários salvos com sucesso',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 2),
                            backgroundColor: Theme.of(context).errorColor,
                            content: Text(
                              'Erro ao salvar horários',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                    },
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
    );
  }
}
