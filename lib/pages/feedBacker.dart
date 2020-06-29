import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:prochats/util/data.dart';
import 'package:prochats/util/screen_size.dart';
import 'package:prochats/util/state.dart';
import 'package:prochats/util/state_widget.dart';
import 'package:prochats/widgets/linearPercentIndicator.dart';
import 'package:prochats/widgets/post_item.dart';

class PowerFeedbacker extends StatefulWidget {
   PowerFeedbacker({Key key, this.groupId, this.groupTitle, this.groupCategories, this.votingBalletHeapData}) : super(key: key);
      final String groupId, groupTitle;
      final List groupCategories, votingBalletHeapData;
  @override
  _PowerFeedbackerState createState() => _PowerFeedbackerState();
}

class _PowerFeedbackerState extends State<PowerFeedbacker> {
  String selectedValue;
   StateModel appState; 
   List snapShot;

  @override
    void initState() {
      // votingLoading(widget.groupId);
    }
votingLoading(groupId) async{

//  snapShot = await Firestore.instance
//   .collection('votingBalletHeap')
//   .document(groupId)
//   .get();

// this creates feedback entry for newGroup or a group which does not have entry yet in DB
// if (snapShot == null || !snapShot.exists) {

// }else{
//   // votingBalletHeapData = await  snapShot.data['VotingStats'];
//   // print('full data of heap is ${votingBalletHeapData}');
//   // List reqGroupA =  data.where((i) => i["gameId"] == matchId).toList();
//   // List homeGroup =  data.where((i) => i["gameId"] != matchId).toList();
// }

}
 
  votingBallet(matchId, groupId, voterId, votedFor,category, )async{

// final snapShot = await Firestore.instance
//   .collection('votingBalletHeap')
//   .document(groupId)
//   .get();

// this creates feedback entry for newGroup or a group which does not have entry yet in DB
        print('values of real ${widget.votingBalletHeapData}');
snapShot = widget.votingBalletHeapData;
if (snapShot == null) {
  // Document with id == docId doesn't exist.
   if(votedFor == "Win"){
    Firestore.instance.collection('votingBalletHeap').document(groupId).setData({ 'VotingStats' : [{'Win': 1, 'Loss': 0, 'Even': 0, 'TotalVotes': 1, 'gameId':matchId,'VotedBy' : [voterId]}]});
   } else if(votedFor == "Even"){
    Firestore.instance.collection('votingBalletHeap').document(groupId).setData({ 'VotingStats' : FieldValue.arrayUnion([{'Win': 1, 'Loss': 0, 'Even': 0, 'TotalVotes': 1, 'gameId':matchId,'VotedBy' : FieldValue.arrayUnion([voterId])}])});
    }
   else if(votedFor == "Loss"){ 
    Firestore.instance.collection('votingBalletHeap').document(groupId).setData({ 'VotingStats' : FieldValue.arrayUnion([{'Win': 1, 'Loss': 0, 'Even': 0, 'TotalVotes': 1, 'gameId':matchId, 'VotedBy' : FieldValue.arrayUnion([voterId])}])});
   }

}else{
  print('snapshot value is ${snapShot}');
  var data = await  snapShot;

     if(votedFor == "Win"){
   List reqGroupA =  data.where((i) => i["gameId"] == matchId).toList();
   List homeGroup =  data.where((i) => i["gameId"] != matchId).toList();

   print('resGroup ${reqGroupA}');
   print('homeGroup ${homeGroup}');

   
if(reqGroupA.length == 0){
  // insert default value to 1

  var defaultBody = {'Win': 1, 'gameId':matchId, 'Loss': 0, 'Even': 0, 'TotalVotes': 1, 'VotedBy': [voterId]};
  widget.votingBalletHeapData.add(defaultBody);
 Firestore.instance.collection('votingBalletHeap').document(groupId).updateData({ 'VotingStats' : FieldValue.arrayUnion([defaultBody])});
}else{
  var reqGroup = reqGroupA[0];
  var VotersList = [voterId];
  VotersList.addAll(reqGroup['VotedBy']);
//  VotersList =reqGroup['VotedBy'].toList();
  print('VotersList ${VotersList}');
   var modifiedBody = {'Win': reqGroup['Win']+ 1, 'gameId':reqGroup['gameId'], 'Loss': 0, 'Even': 0, 'TotalVotes': reqGroup['TotalVotes']+ 1, 'VotedBy': VotersList};
   homeGroup.add(modifiedBody);
   setState(() {
     widget.votingBalletHeapData.add(modifiedBody);
   });
  

   print("readl value check ${widget.votingBalletHeapData}");
  Firestore.instance.collection('votingBalletHeap').document(groupId).setData({ 'VotingStats' : homeGroup});
}

  //        var votedData = data.map((check)=> 
  // check['gameId']==matchId ? {'Win': check['Win']+ 1, 'gameId':check['gameId'], 'Loss': 0, 'Even': 0, 'TotalVotes': check['TotalVotes']+ 1, 'VotedBy': check['VotedBy'].add('voterId')}:  check

  
  
  // ).toList();

  //print('value is ${votedData}');
          // Firestore.instance.collection('votingBalletHeap').document(groupId).updateData({'Win': FieldValue.increment(1), 'TotalVotes': FieldValue.increment(1)});
        //    Firestore.instance.collection('votingBalletHeap').document(groupId).setData({ 'VotingStats' : FieldValue.arrayUnion([{'Win': 1, 'Loss': 0, 'Even': 0, 'TotalVotes': 1, 'gameId':matchId,'VotedBy' : FieldValue.arrayUnion([voterId])}])});
       
       
       
       // Firestore.instance.collection('votingBalletHeap').document(groupId).setData({ 'VotingStats' : [votedData[0]]});
      }          
       else if(votedFor == "Even"){
          Firestore.instance.collection('votingBalletHeap').document(groupId).updateData({'Even': FieldValue.increment(1), 'TotalVotes': FieldValue.increment(1)});
      } else if(votedFor == "Loss"){
          Firestore.instance.collection('votingBalletHeap').document(groupId).updateData({'Loss': FieldValue.increment(1), 'TotalVotes': FieldValue.increment(1)});
      }
}      
  }
  @override
  Widget build(BuildContext context) {
      appState = StateWidget.of(context).state;
    final userId = appState?.firebaseUserAuth?.uid ?? '';
    final email = appState?.firebaseUserAuth?.email ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.filter_list,
            ),
            onPressed: (){},
          ),
        ],
      ),

      body: 
         StreamBuilder(
        stream:  Firestore.instance.collection('feedbackMatches').where("category", arrayContainsAny: widget.groupCategories).snapshots(),
        builder: (context,snapshot){
                     if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
          if(snapshot.hasData  && snapshot.data.documents.length >0){
      
     return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemCount: snapshot.data.documents.length,
        itemBuilder: (BuildContext context, int index) {
          var ds = snapshot.data.documents[index].data;
        print('values of real ${widget.votingBalletHeapData}');

          List reqGroupA =  widget.votingBalletHeapData.where((i) => i["gameId"] == ds['id']).toList();
          Map post = posts[index];
          if(reqGroupA.length == 0){
return QuestionCard(true,{'TotalVotes': 1,'Loss': 0, 'Even': 0, 'Win': 1},ds['team1Url'],ds['team1Name'], ds['team2Url'], ds['team2Name'], ds['category'], ds['id'], widget.groupId, userId);
          }
           return QuestionCard(!reqGroupA[0]['VotedBy'].contains(userId),reqGroupA[0],ds['team1Url'],ds['team1Name'], ds['team2Url'], ds['team2Name'], ds['category'], ds['id'], widget.groupId, userId);
          return PostItem(
            img: post['img'],
            name: post['name'],
            dp: post['dp'],
            time: post['time'],
          );
        },
      );
          }
          return Text('Loading ${widget.groupCategories}');
        }
    )
          
    );
  }
  Widget ResultBars(percent, category){
     final _media = MediaQuery.of(context).size;
     print('size is ${_media}');
    return           Container(
            margin: EdgeInsets.only(
              top: 15,
              right: 10,
            ),
            padding: EdgeInsets.all(10),
            height: screenAwareSize(45, context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 6,
                  spreadRadius: 10,
                )
              ],
            ),
            child: Row(
              children: <Widget>[
                category == "Gain" ? Image.asset(
                                                              'assets/win.png',
                                                              width: 30.0,
                                                              height: 70.0,
                                                            ) : Text(''),
                category == "Safe" ? Image.asset(
                                                              'assets/draw.png',
                                                              width: 30.0,
                                                              height: 70.0,
                                                            ) : Text(''),
                category == "Loss" ? Image.asset(
                                                              'assets/loss.png',
                                                              width: 30.0,
                                                              height: 70.0,
                                                            ) : Text(''),
              
                LinearPercentIndicator(
                  width: screenAwareSize(
                      _media.width - (_media.longestSide <= 775 ? 155 : 200),
                      context),
                    //  width: screenAwareSize(
                    //   200,
                    //   context),
                  lineHeight: 20.0,
                  percent: percent/100,
                  backgroundColor: Colors.grey.shade300,
                  progressColor: Color(0xFF1b52ff),
                  animation: true,
                  animateFromLastPercent: true,
                  alignment: MainAxisAlignment.spaceEvenly,
                  animationDuration: 1000,
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  center: Text(
                    "$percent",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
  }
  Widget QuestionCard(vistibleQuestion,votesResultsBallets,team1Url,team1Name, team2Url, team2Name, category, matchId , groupId,voterId,){
    return Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    child: Column(
                        children: <Widget>[
                          Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                                            Row(
                              children: <Widget>[
                                Container(

                          width: 30.0,
                          height: 30.0,
                          child: Image.network(
                                team1Url
                          )
                                ),
                                Text('${team1Name}'),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                          //       Container(

                          // width: 30.0,
                          // height: 30.0,
                          // child: Image.network(
                          //       team2Url
                          // )
                          //       ),
                                  Text('${category}'),
                                  Text('${matchId}'),
                              ],
                            ),
                              Row(
                              children: <Widget>[
                                Container(

                          width: 30.0,
                          height: 30.0,
                          child: Image.network(
                                team2Url
                          )
                                ),
                                Text('$team2Name'),
                              ],
                            ),
                        ]),
                           Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Column(
                        children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Container(
                                 
                                  // height: 100.0,
                                  child: Column(
                                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                                    // mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        // height: 150.0,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                             Visibility(
                                                        visible: vistibleQuestion,
                                                        child: 
                                            Column(
                                              children: <Widget>[
                                                GestureDetector(

                                                  onTapUp: (detail) {
                                                    // Navigator.of(context).push(
                                                    //     MaterialPageRoute(
                                                    //         builder:
                                                    //             (BuildContext context) =>
                                                    //                 LastPage(
                                                    //                   statusType: 'Unhappy',
                                                    //                 )));
                                                    votingBallet(matchId , groupId,voterId ,'Win', category);
                                                    if(selectedValue == null){
                                                      print('value is null');
                                                    setState(() {
                                                      selectedValue = 'Gain';
                                                    });
                                                    }
                                                    print('Gain value ${selectedValue != 'Gain'} , ${selectedValue != null}');
                                                    print('Even value ${selectedValue != 'Even'} , ${selectedValue != null}');
                                                    print('Loss value ${selectedValue != 'Even'} , ${selectedValue != null}');
                                                    //  setState(() {
                                                    //   selectedValue = 'Gain';
                                                    // });
                                                  },
                                                  child: Row(
                                                    children: <Widget>[
                                                     
                                                      Image.asset(
                                                              'assets/win.png',
                                                              width: 70.0,
                                                              height: 70.0,
                                                            ),
                                                    ],
                                                  )
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4.0),
                                                  child: Text('Gain'),
                                                )
                                              ],
                                            ),
                                             ),
                                              Visibility(
                                                        visible: vistibleQuestion,
                                                        child: 
                                            Column(
                                              children: <Widget>[
                                                 GestureDetector(

                                                  onTapUp: (detail) {
                                                    votingBallet(matchId , groupId,voterId ,'Even',category);
                                                    if(selectedValue == null){
                                                      print('value is null');
                                                    setState(() {
                                                      selectedValue = 'Even';
                                                    });
                                                    }
                                                    print('setting value ${selectedValue != 'Even'} , ${selectedValue != null}');
                                                   
                                                  },
                                                  child: Row(
                                                    children: <Widget>[
                                                    
                                                      Image.asset(
                                                              'assets/draw.png',
                                                              width: 70.0,
                                                              height: 70.0,
                                                            ),
                                                      
                                                    ],
                                                  )
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4.0),
                                                  child: Text('Safe'),
                                                )
                                              ],
                                            ),
                                              ),
                                               Visibility(
                                                        visible: vistibleQuestion,
                                                        child: 
                                            Column(
                                              children: <Widget>[
                                                 GestureDetector(
//                          
                                                  onTapUp: (detail) {
                                                   votingBallet(matchId , groupId,voterId ,'Loss', category);
                                                    if(selectedValue == null){
                                                      print('value is null');
                                                    setState(() {
                                                      selectedValue = 'Loss';
                                                    });
                                                    }
                                                    print('setting value ${selectedValue != 'Loss'} , ${selectedValue != null}');
                                                    ;
                                                  },
                                                  child: Row(
                                                    children: <Widget>[                                                    
                                                      Image.asset(
                                                              'assets/loss.png',
                                                              width: 70.0,
                                                              height: 70.0,
                                                            ),
                                                    ],
                                                  )
                                                ),

                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4.0),
                                                  child: Text('Loss'),
                                                )
                                              ],
                                            ),
                                        )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height:18),
                                  
                                  Visibility(
                                    visible: !vistibleQuestion,
                                    child:
                          Column(
                            children: <Widget>[
                              ResultBars(((votesResultsBallets['Win']/votesResultsBallets['TotalVotes'])*100).round(), 'Gain'),
                              ResultBars(((votesResultsBallets['Loss']/votesResultsBallets['TotalVotes'])*100).round(), 'Safe'),
                              ResultBars(((votesResultsBallets['Even']/votesResultsBallets['TotalVotes'])*100).round(), 'Loss'),
                            ],
                          )
                                  ),
                                 
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ],
                      )),
                          
                        ],
                      ),
                  ),
                );
  }
}


class _AnimatedLiquidLinearProgressIndicator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      _AnimatedLiquidLinearProgressIndicatorState();
}

class _AnimatedLiquidLinearProgressIndicatorState
    extends State<_AnimatedLiquidLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animationController.addListener(() => setState(() {}));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _animationController.value * 10;
    return Center(
      child: Container(
        width: double.infinity,
        height: 20.0,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: LiquidLinearProgressIndicator(
          value: _animationController.value,
          backgroundColor: Colors.white,
          valueColor: AlwaysStoppedAnimation(Colors.blue),
          borderRadius: 14.0,
          center: Text(
            "${percentage.toStringAsFixed(0)}sec",
            style: TextStyle(
              color: Colors.lightBlueAccent,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
