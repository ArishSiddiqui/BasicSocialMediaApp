import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar header(context, {bool isAppTitle = false, String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? 'Feed' : titleText,
      style: TextStyle(
        color: Colors.white,
        fontSize: isAppTitle ? 50.0 : 22.0,
        fontFamily: isAppTitle ? 'Signatra' : '',
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}