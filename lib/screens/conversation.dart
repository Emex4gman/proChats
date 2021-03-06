import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:prochats/controllers/notificationController.dart';
import 'package:prochats/pages/feedBacker.dart';
import 'package:prochats/pages/imageEditor.dart';
import 'package:prochats/screens/groupMembersHome.dart';
import 'package:prochats/screens/joinPremium.dart';
import 'package:prochats/screens/joinRequestApproval.dart';
import 'package:prochats/util/data.dart';
import 'dart:math';
import 'package:prochats/widgets/chat_bubble.dart';

class Conversation extends StatefulWidget {
  Conversation({Key key, this.groupFullDetails,this.chatId,this.groupSportCategory,this.userId,this.groupLogo,this.groupTitle,this.senderMailId, this.chatType, this.waitingGroups, this.approvedGroups,this.followers, this.chatOwnerId, this.approvedGroupsJson, this.AllDeviceTokens, this.FDeviceTokens});
  final String chatId, userId,chatType, chatOwnerId, senderMailId, groupTitle, groupLogo ;
  List waitingGroups, approvedGroups, AllDeviceTokens,FDeviceTokens, groupSportCategory, followers;
  List approvedGroupsJson;
  final groupFullDetails;

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
     final TextEditingController _chatMessageText = new TextEditingController();
    ScrollController _scrollController = new ScrollController();

   File _image;
   int selectedRadio;
   bool msgDeliveryMode = true;
   List votingBalletHeapData;

   // Changes the selected value on 'onChanged' click on each radio button
setSelectedRadio(int val) {
  setState(() {
    selectedRadio = val;
  });
}
setDeliveryModeCheckBox(bool val) {
  setState(() {
    msgDeliveryMode = val;
  });
}



scrollToBottomFun(){
  SchedulerBinding.instance.addPostFrameCallback((_) {
  _scrollController.animateTo(
    _scrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 10),
    curve: Curves.easeOut,);
  });
}
  static Random random = Random();
  String name = names[random.nextInt(10)];

  Color backgroundColor(){
    if(Theme.of(context).brightness == Brightness.dark){
      return Colors.grey[700];
    }else{
      return Colors.grey[50];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      appBar: AppBar(
        elevation: 3,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_backspace,
          ),
          onPressed: ()=>Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: InkWell(
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 0.0, right: 10.0),
                child: CircleAvatar(
                  backgroundImage: AssetImage(
                    "assets/cm${random.nextInt(10)}.jpeg",
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${widget.groupTitle}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "${widget.followers.length} Followers",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          onTap: (){},
        ),
        actions: <Widget>[
             IconButton(
            icon: Icon(
              Icons.notifications,
            ),
            onPressed: () async{
             var  snapShot = await Firestore.instance
  .collection('votingBalletHeap')
  .document(widget.chatId)
  .get();

// this creates feedback entry for newGroup or a group which does not have entry yet in DB
if (snapShot == null || !snapShot.exists) {

}else{
  votingBalletHeapData = await  snapShot.data['VotingStats'];
  print('full data of heap is ${votingBalletHeapData}');
  // List reqGroupA =  data.where((i) => i["gameId"] == matchId).toList();
  // List homeGroup =  data.where((i) => i["gameId"] != matchId).toList();
}
              // powerPredictor
             await   Navigator.push(
                                  context,
                                 new  MaterialPageRoute(
                                      builder: (BuildContext context) => PowerFeedbacker(groupCategories: widget.groupSportCategory ,groupId: widget.chatId,groupTitle: widget.groupTitle, votingBalletHeapData: votingBalletHeapData ?? []),
                                      ),
                               );
            },
          ),

          // display for group members
          Visibility(
            visible: widget.chatOwnerId != widget.userId,
            child:
          new PopupMenuButton(
            onSelected: (value){
              print('selected value si   $value');
              if(value == "Profile"){
                   Navigator.push(
                                  context,
                                 new  MaterialPageRoute(
                                      builder: (BuildContext context) => JoinPremiumGroup(chatId: widget.chatId,userId: widget.userId,lock: false,title: widget.groupTitle,feeArray: widget.groupFullDetails['FeeDetails'] ?? [], paymentScreenshotNo: widget.groupFullDetails['paymentNo'] ?? "", avatarUrl: widget.groupFullDetails['logo']?? "" ),
                                      ),
                               );
              }
            },
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    const 
                    PopupMenuItem(
                      value: "Profile",
                      child: Text("Profile"),
                    ),
                    PopupMenuItem(
                      value: "Report",
                      child: Text("Report"),
                    ),
                    PopupMenuItem(
                      value: "Exit Group",
                      child: Text("Exit Group"),
                    ),
                  ]),
          ),
          // display for group owners
          Visibility(
            visible: widget.chatOwnerId == widget.userId,
            child:
          new PopupMenuButton(
            onSelected: (value){
              print('selected value si   $value');
              if(value == "Approve Payments"){
               Navigator.push(
                                    context,
                                   new  MaterialPageRoute(
                                        builder: (BuildContext context) => 
                                        JoinRequestApproval(chatId: widget.chatId,),
                                        ),
                                 );
              } else if (value == "Expired Memberships"){
                 Navigator.push(
                                    context,
                                   new  MaterialPageRoute(
                                        builder: (BuildContext context) => 
                                        GroupMembersHome(groupMembersJson : widget.approvedGroupsJson ?? [], chatId: widget.chatId),
                                        ),
                                 );
              }
            },
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    const 
                    PopupMenuItem(
                      value: "Approve Payments",
                      child: Text("Approve Payments"),
                    ),
                    PopupMenuItem(
                      value: "Expired Memberships",
                      child: Text("Expired Membersips"),
                    ),
                    PopupMenuItem(
                      value: "Member Feedback",
                      child: Text("Member Feedback"),
                    ),
                    PopupMenuItem(
                      value: "Edit Details",
                      child: Text("Starred message"),
                    ),
                  ]),
          )
        
        ],
      ),


      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Flexible(
              child: StreamBuilder(
        stream:  Firestore.instance.collection('groups').document(widget.chatId).snapshots(),
        builder: (context,snapshot){
                     if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
          if(snapshot.hasData && snapshot.data['messages'].length > 0){
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: snapshot.data['messages'].length,
                controller: _scrollController,
                // reverse: true,
                itemBuilder: (BuildContext context, int index) {
             //     Map msg = conversation[index];
                      DocumentSnapshot ds = snapshot.data;
                      var indexVal = index;
                      print('value of messages are ${ds['messages'] ?? "empty"}');
                      scrollToBottomFun();
                        // var datestamp = new DateFormat("dd-MM'T'HH:mm");
                        var datestamp = new DateFormat("HH:mm");

          

                     return ChatBubble(
                    message: snapshot.data['messages'][indexVal]['type'] == "text"
                        ?snapshot.data['messages'][indexVal]['messageBody']
                        :snapshot.data['messages'][indexVal]['imageUrl'],
                    username: widget.userId,
                    time: datestamp.format(snapshot.data['messages'][indexVal]['date'].toDate()).toString(),
                    //time: Jiffy(snapshot.data['messages'][indexVal]['date'].toDate()).fromNow().toString(),
                    type: snapshot.data['messages'][indexVal]['type'],
                    replyText:"",
                    isMe: true,
                    isGroup: true,
                    isReply: false,
                    replyName: widget.userId,
                  );

                },
              );
          }
          return Text('Empty Chat'); 
          }
              )
            ),

            Visibility(
               visible: widget.chatOwnerId == widget.userId,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: BottomAppBar(
                  elevation: 10,
                  color: Theme.of(context).primaryColor,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 100,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                         Checkbox(
      value: msgDeliveryMode,
      onChanged: setDeliveryModeCheckBox
    ),
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: (){
                                 Navigator.push(
                                    context,
                                   new  MaterialPageRoute(
                                        builder: (BuildContext context) => ImageEditorPage(chatId: widget.chatId,userId: widget.userId,chatType: "Image", groupLogo: widget.groupLogo),
                                        ),
                                 );
                          },
                        ),

                        Flexible(
                          child: TextField(
//                                                     onTap: () {
// Timer(
// Duration(milliseconds: 300),
// () => _scrollController
//     .jumpTo(_scrollController.position.maxScrollExtent));
// },
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Theme.of(context).textTheme.title.color,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              hintText: "Write your message...",
                              hintStyle: TextStyle(
                                fontSize: 15.0,
                                color: Theme.of(context).textTheme.title.color,
                              ),
                            ),
                            controller: _chatMessageText,
                            maxLines: null,
                          ),
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Theme.of(context).accentColor,
                          ),
                              onPressed: () {
                        print('user send tis message ${_chatMessageText.text}');
                        var now = new DateTime.now();
                        var alt =  now.add(Duration(days: 1));
                        print('time was ${alt}');
                        try {
                          var now = new DateTime.now();
                          var body ={ "messageBody":_chatMessageText.text, "date": now,"author": widget.userId, "type": "text" , "premium": msgDeliveryMode  };
                         var lastMessageBody ={"lastMsg":_chatMessageText.text, "lastMsgTime": now};
                          Firestore.instance.collection('groups').document(widget.chatId).updateData({ 'lastMessageDetails':lastMessageBody, 'messages' : FieldValue.arrayUnion([body])});
                          _chatMessageText.text ="";
                          for(final e in widget.AllDeviceTokens){
  //
  var currentDeviceToken = e;

                          NotificationController.instance.sendNotificationMessageToPeerUser(10, "text", _chatMessageText.text, "Admin", widget.chatId, currentDeviceToken);
                          }
                            Timer(Duration(milliseconds: 500),
            () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
                        } catch (e) {
                        }
                      },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      
      floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
     floatingActionButton: Row(
       
       children: <Widget>[
         Visibility(
           visible: !widget.waitingGroups.contains(widget.chatId) && !widget.approvedGroups.contains(widget.chatId) ,
           child:
         FloatingActionButton.extended(
  onPressed: () {
          Navigator.push(
                                  context,
                                 new  MaterialPageRoute(
                                      builder: (BuildContext context) => JoinPremiumGroup(chatId: widget.chatId,userId: widget.userId,lock: false,title: widget.groupTitle,feeArray: widget.groupFullDetails['FeeDetails'] ?? [], paymentScreenshotNo: widget.groupFullDetails['paymentNo'] ?? "", avatarUrl: widget.groupFullDetails['logo']?? "" ),
                                      ),
                               );
  },
  icon: Icon(Icons.save),
  label: Text(!widget.waitingGroups.contains(widget.chatId) ? "Subscribe Rs 100/-" : "Under Review"),
),
         ),
     Visibility(
      visible: widget.approvedGroups.contains(widget.chatId), 
      child:
      FloatingActionButton.extended(
  onPressed: () async {
           var  snapShot = await Firestore.instance
  .collection('votingBalletHeap')
  .document(widget.chatId)
  .get();

// this creates feedback entry for newGroup or a group which does not have entry yet in DB
if (snapShot == null || !snapShot.exists) {

}else{
  votingBalletHeapData = await  snapShot.data['VotingStats'];
  print('full data of heap is ${votingBalletHeapData}');
  // List reqGroupA =  data.where((i) => i["gameId"] == matchId).toList();
  // List homeGroup =  data.where((i) => i["gameId"] != matchId).toList();
}
              // powerPredictor
             await   Navigator.push(
                                  context,
                                 new  MaterialPageRoute(
                                      builder: (BuildContext context) => PowerFeedbacker(groupCategories: widget.groupSportCategory ,groupId: widget.chatId,groupTitle: widget.groupTitle, votingBalletHeapData: votingBalletHeapData ?? []),
                                      ),
                               );
  },
  icon: Icon(Icons.save),
  label: Text("Feedback"),
),
     ),
       ],
     ),

    );
  }
}
