import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feed/models/user.dart';
import 'package:feed/pages/home.dart';
import 'package:feed/pages/timeline.dart';
import 'package:feed/widgets/progress.dart';
import "package:flutter/material.dart";

class EditProfile extends StatefulWidget {
  final String currentUseId;
  EditProfile({ this.currentUseId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameControl = TextEditingController();
  TextEditingController bioControl = TextEditingController();
  bool isLoading = false;
  User user;
  bool _bioValid = true;
  bool _displayNameValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUseId).get();
    user = User.fromDocument(doc);
    displayNameControl.text = user.displayName;
    bioControl.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 12.0),
          child: Text('Display Name',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: displayNameControl,
          decoration: InputDecoration(
            hintText: 'Edit Display Name',
            errorText: _displayNameValid ? null : 'Name is too short',
          ),
        )
      ],
    );
  }

  Column buildBio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 12.0),
          child: Text('Bio',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: bioControl,
          decoration: InputDecoration(
            hintText: 'Update Your Bio',
            errorText: _bioValid ? null : 'Bio is too long',
          ),
        )
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNameControl.text.trim().length < 3 ||
      displayNameControl.text.isEmpty ? _displayNameValid = false :
          _displayNameValid = true;
      bioControl.text.trim().length > 100 ? _bioValid = false :
          _bioValid = true;
    });

    if (_bioValid && _displayNameValid) {
      usersRef.document(widget.currentUseId).updateData({
        'displayName': displayNameControl.text,
        'bio': bioControl.text,
      });
      SnackBar snackbar = SnackBar(content: Text('Profile Updated !'));
      _scaffoldkey.currentState.showSnackBar(snackbar);
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Edit Profile', style: TextStyle(
          color: Colors.black,
        ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.done,
                size: 30.0,
                color: Colors.green,
              ),
              onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: isLoading ? circularProgress() : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      buildDisplayName(),
                      buildBio(),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: updateProfileData,
                  child: Text('Update', style: TextStyle(
                    color: Colors.orange,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(16.0),
                  child: FlatButton.icon(
                      onPressed: logout,
                      icon: Icon(Icons.cancel, color: Colors.red,),
                      label: Text('Logout', style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                      ),
                      ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
