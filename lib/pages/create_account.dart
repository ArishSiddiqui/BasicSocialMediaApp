import 'dart:async';
import 'package:feed/widgets/header.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  @override
  Widget build(BuildContext parentContext) {
    var _scaffoldKey = GlobalKey<ScaffoldState>();
    final _formKey = GlobalKey<FormState>();
    String username;
    
    submit() {
      final form = _formKey.currentState;
      form.save();
      SnackBar snackbar = SnackBar(content: Center(child: Text('Welcome $username')));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2),() {
        Navigator.pop(context, username);
      });

    }
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, titleText: 'Create Account', removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0,),
                  child: Center(
                    child: Text('Create A Username', style: TextStyle(
                      fontSize: 25.0,
                    ),),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                        autovalidate: true,
                        child: TextFormField(
                          validator: (val) {
                            if(val.trim().length < 3) {
                              return 'Username is too short';
                            } else if(val.trim().length > 12) {
                              return "Username is too long";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => username = val,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                            labelStyle: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 250.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text('Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
