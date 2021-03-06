import 'dart:async';
import 'dart:io';

import 'package:prochats/bid365_app_theme.dart';
import 'package:prochats/util/state.dart';
import 'package:prochats/util/state_widget.dart';
import 'package:prochats/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';


class JoinPremiumGroup extends StatefulWidget {
    JoinPremiumGroup({Key key, this.chatId, this.userId, this.lock, this.title, this.feeArray, this.paymentScreenshotNo, this.avatarUrl}) : super(key: key);
   final String chatId, userId,title,  paymentScreenshotNo, avatarUrl;
   final feeArray;

   bool lock;
  @override
  _JoinPremiumGroupState createState() =>
      _JoinPremiumGroupState();
}

class _JoinPremiumGroupState extends State<JoinPremiumGroup> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isProsses = false;
  bool isFirstTime = true;
  bool approved = false;
  bool uploadedLock = false;
  String pancard_approve_status, payment_approve_status;
  StateModel appState;
  File _image;
  bool kycData = false;
  String panCardImageUrl,panHolderName, panNo;

  var date = DateTime.now();
  bool _loadingVisible = false;


  var panNameController = new TextEditingController();
  var panNoController = new TextEditingController();

  @override
  void initState() {
    // getPancardData();
    super.initState();
  }

  // void getPancardData() async {
  //   setState(() {
  //     isProsses = true;
  //     panNoController.text = '';
  //     panNameController.text = '';
  //     date = DateFormat('dd/MM/yyyy').parse('30/05/1990');
  //     approved = true;
  //   });

  //   setState(() {
  //     isFirstTime = false;
  //     isProsses = false;
  //   });
  // }

  
 Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  @override
  Widget build(BuildContext context) {

       appState = StateWidget.of(context).state;
    final userId = appState?.firebaseUserAuth?.uid ?? '';
    final email = appState?.firebaseUserAuth?.email ?? '';

  
        // var kycLock = kycData??['pancardLock'] ?? false;
    //  getKycDetails(userId);
     return Scaffold(
       body: LoadingScreen(
            inAsyncCall: _loadingVisible,
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                           SizedBox(height: 60),
                   CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xff476cfb),
                      child: ClipOval(
                        child: new SizedBox(
                          width: 180.0,
                          height: 180.0,
                          child: Image.network(
                            widget.avatarUrl,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 10),
              Text(
                '${widget.title}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Send Payment Screenshot to ${widget.paymentScreenshotNo}",
                style: TextStyle(
                ),
              ),
              SizedBox(height: 20),

                    Container(
                      child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: <Widget>[
                                  priceDispUI('1000', '30 days'),
                                  priceDispUI('1500', '45 days'),
                                  priceDispUI('100', '10 days'),
                                ],
                              ),
                            ),
                    ),
                    // uploadDocContent(context,"payment_approve_status",userId, "http://www.pngall.com/wp-content/uploads/2/Upload-PNG.png", widget.lock ,_image),
                     StreamBuilder(
          stream: Firestore.instance.collection('KYC').where("chatId", isEqualTo: widget.chatId).where("uid", isEqualTo: widget.userId).where("approve_status", isEqualTo: 'Review_Waiting').snapshots(),
          builder: (context,snapshot){
                    if(snapshot.hasError) {
                                  return Center(child: Text('Error: '));
                    }
                                else if(snapshot.hasData && snapshot.data.documents.length > 0){
                                  print('yo yo ${snapshot.data.documents.length}');
                                return   ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (_, int index) {
                              DocumentSnapshot doc = snapshot.data.documents[index];
                              print(' data is ${doc.data}');
                                          DocumentSnapshot kycDetailsSnap = snapshot.data.documents[index];
                    panCardImageUrl = kycDetailsSnap.data['pancardDocUrl'] ?? "http://www.pngall.com/wp-content/uploads/2/Upload-PNG.png";
                    payment_approve_status = kycDetailsSnap.data['payment_approve_status'] ?? "NA";
        
        if(payment_approve_status == "Rejected" || payment_approve_status == "Review_Waiting"){
          print('iwas inside clearr');
          widget.lock = true;     
        }else{
          widget.lock = false;
          
        }
      //  return uploadDocContent(context,payment_approve_status,userId, panCardImageUrl,widget.lock,_image );
                              return new Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text('Your Documents is ${doc.data["payment_approve_status"] ?? "NULL"}'),
                                      SizedBox(height: 10,),
                                                 Container(
      height: 220.0,
      width: 220.0,
       decoration: BoxDecoration(
         color: Colors.red,
                    image: DecorationImage(
                      image: NetworkImage(panCardImageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  )
    )
                                    ],
                                  ));
                          },
                        );

        
        }
        // return Container(child: Text('check'));
        return uploadDocContent(context,"payment_approve_status",userId, "http://www.pngall.com/wp-content/uploads/2/Upload-PNG.png", widget.lock ,_image);
          }
        ),
                  ],
                ),
              ],
            )
        ),
     );
     
  }
Widget uploadDocContent(context, payment_approve_status,userId,panCardImageUrl, lock, _image ){
                      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
          ),
        ),
        child:Stack(
          
                                  alignment: AlignmentDirectional.bottomCenter,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        
                                           Container(
                                            child: expandData(context, lock, _image, panCardImageUrl),
                                          ),
                                        
                                      ],
                                    ),
                                      (widget.lock)
                                        ? Positioned(
                                            bottom: 32,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  top: 8, left: 32, right: 32),
                                              child: Text(
                                                "Your Join Request is ${payment_approve_status} ${userId}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.green),
                                              ),
                                            )
                                            )
                                          
                                        : SizedBox(
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(height:10),
                                              RaisedButton(
    onPressed: () async {
        if(widget.lock){
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text("Doc already uploaded"),));
                          }else if (_image == null){
                             Scaffold.of(context).showSnackBar(SnackBar(content: Text("Wanted Payment screenshot for Owner"),));
                          }
                          else{
                           
           await _changeLoadingVisible();
        // uplaod the detail of this in user details table
        // with details of uid, emailid, pandcard no, pancard holder name,approve status 
        // 
        // upload to approve
        DateTime now = new DateTime.now();
          var datestamp = new DateFormat("yyyyMMdd'T'HHmmss");
          String currentdate = datestamp.format(now);
        
    final StorageReference firebaseStorageRef = await FirebaseStorage.instance.ref().child('myimage1.jpg');
    final StorageUploadTask uploadTask = await firebaseStorageRef.putFile(_image);
       var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    print('uploaded url is $url ${panNoController.text}');

    // return url; 

    // StorageTaskSnapshot taskSnapshot =  uploadTask.onComplete;

    

        var body ={
          "uid": userId,
          "chatId": widget.chatId,
          "pancardDocUrl": url,
          "uploadedTime": currentdate,
          "payment_approve_status": "Review_Waiting",
          "approve_status": "Review_Waiting",
        };

        print("submitted details are ${body} ");
        final collRef = await Firestore.instance.collection('KYC');
                                                       DocumentReference docReferance = collRef.document();
                                                       docReferance.setData(body); 
        final userTable = await Firestore.instance.collection('IAM');
                                                       DocumentReference userTableDocRef = userTable.document(userId);
                                                       userTableDocRef.updateData({ 'WaitingGroups' : FieldValue.arrayUnion([widget.chatId]),  'WaitingGroupsJson' : FieldValue.arrayUnion([body])}); 
        // 
        await _changeLoadingVisible();
        setState(() {
        widget.lock = true;
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Doc Uploaded Successfully"),));
    });
}

    },
    child: Text("Submit For Verification"),
  ),
                                            ],
                                          ),
                                        ),
                                  ],
                                ),
                     
        );
}
  Widget expandData(context, lock, _image,panCardImageUrl) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 38, left: 16, right: 16, bottom: 8),
            child: Container(
              height: 48,
              decoration: new BoxDecoration(
                color: Bid365AppTheme.nearlyBlue,
                borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0),
                                        ),
                 boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: Bid365AppTheme
                                                  .nearlyBlue
                                                  .withOpacity(0.5),
                                              offset: const Offset(1.1, 1.1),
                                              blurRadius: 10.0),
                                        ],
              ),
              child: InkWell(
                onTap: () {
                if(lock){
                  // showInSnackBar('Doc already uploaded');
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Doc already uploaded"),));
                }else{
                  getImage();
                }

                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.attach_file,
                      color: Colors.white,
                    ),
                    Text(
                      'Upload Payment Screenshot',
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(
            height: 20,
          ),
    //       Visibility(
    //         visible: _image == null ,
    //         child: 
    //       Container(
    //   height: 220.0,
    //   width: 220.0,
    //    decoration: BoxDecoration(
    //      color: Colors.red,
    //                 image: DecorationImage(
    //                   image: NetworkImage(panCardImageUrl),
    //                   fit: BoxFit.cover,
    //                 ),
    //                 borderRadius: BorderRadius.circular(20.0),
    //               )
    // )
    //       ),
           Container(
                  //           height: screenHeight * 0.6,
                  // width: screenWidth,
                            child: _image == null ? Text('No payment deatail is upload') : 
                              Container(
      height: 220.0,
      width: 220.0,
      decoration: BoxDecoration(
                  
                    borderRadius: BorderRadius.circular(20.0),
                  ),
  child: Image.file(_image, height:250, width: 250),
    )
                            
                            
                          ),
                           SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Future getImage() async {
   print("launching image picker");
var image = await ImagePicker.pickImage(source: ImageSource.gallery);
  print('ending image picker');

      setState(() {
          _image = image;
        });
    // if (image != null) {
    //   File cropimage = await cropImage(image);
    //   if (cropimage != null) {
    //     if (!mounted) return;
    //     setState(() {
    //       _image = cropimage;
    //     });
    //   }
    // }
  }

  Future<File> cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      maxWidth: 512,
      maxHeight: 512,
    );
    return croppedFile;
  }

  void showInSnackBar(String value, {bool isGreen = false}) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          value,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
        ),
        backgroundColor: isGreen ? Colors.green : Colors.red,
      ),
    );
  }
    Widget priceDispUI(String text1, String txt2) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Bid365AppTheme.nearlyWhite,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Bid365AppTheme.grey.withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 8.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                text1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: Bid365AppTheme.nearlyBlue,
                ),
              ),
              Text(
                txt2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: Bid365AppTheme.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
