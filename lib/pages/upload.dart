import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feed/models/user.dart';
import 'package:feed/widgets/progress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:feed/pages/home.dart';

class Upload extends StatefulWidget {

final User currentUser;
  Upload({ this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController locationControl = TextEditingController();
  TextEditingController captionControl = TextEditingController();
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();

  takePicture() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  chooseGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentcontext) {
    return showDialog(
      context: parentcontext,
      builder: (context) {
        return SimpleDialog(
          title: Text('Create Post'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Take a Picture'),
              onPressed: takePicture,
            ),
            SimpleDialogOption(
              child: Text('Choose From Gallery'),
              onPressed: chooseGallery,
            ),
            SimpleDialogOption(
              child: Text('Cancle', textAlign: TextAlign.end, style: TextStyle(
                color: Colors.blue,
              ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      }
    );
  }

  Container buildSplashScreen() {
    return Container(
      color: Colors.teal.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260.0,),
          Padding(
              padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: StadiumBorder(),
              child: Text('Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImage = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg
      (imageFile, quality: 55));
    setState(() {
      file = compressedImage;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask = storageRef.child('post_$postId.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPost({ String mediaUrl, String location, String description}) {
    postRef.document(widget.currentUser.id).collection('userPosts')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'likes': {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPost(
      mediaUrl: mediaUrl,
      location: locationControl.text,
      description: captionControl.text,
    );
    captionControl.clear();
    locationControl.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  Scaffold uploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black,),
            onPressed: clearImage),
        title: Text('Caption Post',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text('Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(''),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width*0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file)
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0,),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: captionControl,
                decoration: InputDecoration(
                  hintText: 'Write a Caption...',
                  border: InputBorder.none
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop, color: Colors.greenAccent, size: 35.0,),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationControl,
                decoration: InputDecoration(
                  hintText: 'Your Location',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                onPressed: getLocation,
                icon: Icon(Icons.my_location, color: Colors.white,),
                label: Text('Use Current Location',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              shape: StadiumBorder(),
              color: Colors.blue,
            ),
          )
        ],
      ),
    );
  }

  getLocation() async {
    Position position = await Geolocator().
    getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates
      (position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddresss =
        '${placemark.subThoroughfare}, ${placemark.thoroughfare},'
        '${placemark.subLocality}, ${placemark.locality},'
        '${placemark.subAdministrativeArea}, ${placemark.administrativeArea},'
        '${placemark.postalCode}, ${placemark.country}';
    print(completeAddresss);
    String formatAddress = "${placemark.locality}, ${placemark.country}";
    locationControl.text = formatAddress;
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return file == null ? buildSplashScreen(): uploadForm();
  }
}
