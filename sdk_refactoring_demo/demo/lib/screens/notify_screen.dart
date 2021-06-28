import 'package:flutter/material.dart';
import 'package:at_demo_data/at_demo_data.dart' as at_demo_data;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:verbsTesting/services/server_demo_service.dart';

class NotifyScreen extends StatefulWidget {
  const NotifyScreen({Key key}) : super(key: key);

  @override
  _NotifyScreenState createState() => _NotifyScreenState();
}

enum ButtonType { myList, sentList }

class _NotifyScreenState extends State<NotifyScreen> {
  TextEditingController _messageController = TextEditingController();
  // TextEditingController _keyController = TextEditingController();

  String receiverAtsign;
  ServerDemoService _serverDemoService = ServerDemoService.getInstance();
  bool showSpinner = false;
  String result;
  ButtonType activeButton = ButtonType.sentList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(' Notify Testing'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  Text('Hi, ${_serverDemoService.atSign}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Receiver:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          )),
                      DropdownButton<String>(
                        hint: Text('\tPick an @sign'),
                        icon: Icon(Icons.keyboard_arrow_down),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black87,
                        ),
                        underline: Container(
                          height: 2,
                          color: Colors.blueAccent,
                        ),
                        onChanged: (String newValue) async {
                          //TODO:put validations
                          // if(newValue == _serverDemoService.atSign){

                          // }
                          setState(() {
                            receiverAtsign = newValue;
                          });
                        },
                        value: receiverAtsign,
                        //!= null ? atSign : null,
                        items: at_demo_data.allAtsigns
                            .map<DropdownMenuItem<String>>(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        hintText: 'Eg: Hello!',
                        labelText: 'Enter any text to notify'),
                  ),
                  MaterialButton(
                      color: Colors.blue,
                      minWidth: double.infinity,
                      onPressed: _notify,
                      child: Text(
                        'Notify',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      )),
                ],
              ),
              Expanded(
                  child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black87)),
                          color: activeButton == ButtonType.myList
                              ? Colors.blue
                              : Colors.white,
                          minWidth: MediaQuery.of(context).size.width * 0.45,
                          onPressed: () async {
                            await _serverDemoService.myNotifications();
                            setState(() {
                              activeButton = ButtonType.myList;
                            });
                          },
                          child: Text(
                            'Received',
                            style: TextStyle(
                                fontSize: 14,
                                color: activeButton == ButtonType.myList
                                    ? Colors.white
                                    : Colors.black),
                          )),
                      MaterialButton(
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black87)),
                          minWidth: MediaQuery.of(context).size.width * 0.45,
                          color: activeButton == ButtonType.sentList
                              ? Colors.blue
                              : Colors.white,
                          onPressed: () async {
                            setState(() {
                              activeButton = ButtonType.sentList;
                            });
                          },
                          child: Text('Sent',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: activeButton == ButtonType.sentList
                                      ? Colors.white
                                      : Colors.black))),
                    ],
                  ),
                  ..._getList()
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  _getList() {
    List<AtNotification> listData = [];
    listData = activeButton == ButtonType.myList
        ? _serverDemoService.myNotificationsList
        : _serverDemoService.sentNotificationsList;

    return <Widget>[
      SizedBox(height: 10),
      if (listData.isNotEmpty)
        for (var data in listData)
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.blueGrey)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activeButton == ButtonType.myList) ...[
                      CustomText(keyTitle: 'From', value: data.fromAtSign),
                      CustomText(keyTitle: 'Title', value: data.key),
                      CustomText(keyTitle: 'operation', value: data.operation),
                    ],
                    if (activeButton == ButtonType.sentList) ...[
                      CustomText(keyTitle: 'To', value: data.toAtSign),
                      // CustomText(keyTitle: 'Title', value: data.key),
                      CustomText(keyTitle: 'Message', value: data.value),
                      CustomText(
                          keyTitle: 'Status', value: data.status ?? 'Unknown')
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () async {
                          await _showNotificationDetails(data);
                        },
                        icon: Icon(Icons.info_outline)),
                    if (activeButton == ButtonType.sentList)
                      IconButton(
                          onPressed: () async {
                            await _serverDemoService.notifyStatus(data.id,
                                doneCallBack: (value) {
                                  setState(() {
                                    data.status = value;
                                  });
                                },
                                errorCallBack: (err) => print('$err'));
                          },
                          icon: Icon(Icons.refresh)),
                  ],
                ),
              ),
            ),
          ),
      if (listData.isEmpty && activeButton != null)
        Center(child: Text('No Data Found!!'))
    ];
  }

  _showNotificationDetails(AtNotification data) async {
    if (data.value != null && this.activeButton == ButtonType.myList) {
      data.value = await _serverDemoService.getFromNotification(data);
    }
    showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(builder: (_, stateSet) {
            return AlertDialog(
              content: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (data.id != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.0,
                      ),
                      child: CustomText(keyTitle: 'Id', value: data.id),
                    ),
                  if (data.key != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CustomText(keyTitle: 'Key', value: data.key),
                    ),
                  if (data.value != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CustomText(keyTitle: 'Value', value: data.value),
                    ),
                  if (data.fromAtSign != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CustomText(
                          keyTitle: 'FromAtSign', value: data.fromAtSign),
                    ),
                  if (data.dateTime != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CustomText(
                          keyTitle: 'DateTime',
                          value: DateFormat('dd-MM-yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      data.dateTime)) +
                              ' ' +
                              DateFormat.jm().format(
                                  (DateTime.fromMillisecondsSinceEpoch(
                                      data.dateTime)))),
                    ),
                  if (data.operation != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CustomText(
                          keyTitle: 'Operation', value: data.operation),
                    ),
                  if (data.status != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CustomText(keyTitle: 'Status', value: data.status),
                    ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(_), child: Text('Close'))
              ],
            );
          });
        });
  }

  Future<void> _notify() async {
    FocusScope.of(context).unfocus();

    setState(() {
      showSpinner = true;
    });
    try {
      await _serverDemoService.notify(_messageController.text, receiverAtsign,
          doneCallBack: (value) {
        print('value is $value');
        Fluttertoast.showToast(
            msg: 'Notified Succesfully!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.black,
            fontSize: 16.0);
        setState(() {
          showSpinner = false;
        });
      }, errorCallBack: (error) {
        result = 'error is:\n$error';

        Fluttertoast.showToast(
            msg: 'Failed to notify!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.black,
            fontSize: 16.0);

        print('error is $error');
        setState(() {
          showSpinner = false;
        });
      });
    } catch (err, stackTrace) {
      print('$stackTrace');
      setState(() {
        showSpinner = false;
      });
    }
  }
}

class CustomText extends StatelessWidget {
  final String keyTitle;
  final String value;
  final Color color;
  const CustomText(
      {@required this.keyTitle,
      @required this.value,
      this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: TextStyle(color: this.color, fontSize: 16),
            children: [
          TextSpan(
              text: keyTitle + ': ',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value)
        ]));
  }
}