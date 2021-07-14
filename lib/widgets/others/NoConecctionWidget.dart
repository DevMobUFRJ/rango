import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/utils/constants.dart';

class NoConecctionWidget extends StatelessWidget {
  const NoConecctionWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: AutoSizeText(
              noInternetMessage,
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await Repository.instance.checkInternetConnection(context);
            },
            child: Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
