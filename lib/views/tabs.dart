import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:contextualactionbar/actions/action_mode.dart';
import 'package:contextualactionbar/contextual_scaffold.dart';
import 'package:contextualactionbar/widgets/contextual_action.dart';
import 'package:contextualactionbar/widgets/contextual_action_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stimulusep/assets/colors.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/db/firestore_db.dart';
import 'package:stimulusep/model/report.dart';
import 'package:stimulusep/model/user.dart';
import 'package:stimulusep/views/evolution_list.dart';
import 'package:stimulusep/views/forgot_password.dart';
import 'package:stimulusep/views/generic_widgets/loading_widget.dart';
import 'package:stimulusep/views/report_list.dart';
import 'package:stimulusep/views/share_report.dart';
import 'package:stimulusep/views/signup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:stimulusep/db/database.dart';

import 'modify_account.dart';


class TabsPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return new TabsPageState();
  }
}

class TabsPageState extends State<TabsPage> with SingleTickerProviderStateMixin{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _pass1Con = new TextEditingController();
  bool _combNotOK = false;
  bool _isButtonIgnored = false;
  String? _password;

  int _willPop = 0;
  BuildContext? _context;
  List<Report> _toDelete = List.empty(growable: true);
  bool _loading = false;

  final List<Tab> _myTabs = <Tab>[
    Tab(text: 'MES BILANS'),
    Tab(text: 'MON ÉVOLUTION'),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _myTabs.length);
    _tabController.addListener(onTap);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //assert(UserC().id!=null);
    //print("ID==="+UserC().id.toString());
    return Stack(
      children: [
        WillPopScope(
            child: Scaffold(
              body: ContextualScaffold<Report>(
              appBar: AppBar(
                title: Text('Fyzik'),
                automaticallyImplyLeading: false,
                backgroundColor: colorPrimary,
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  controller: _tabController,
                  tabs: _myTabs,
                ),
                actions: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: colorPrimaryLight,
                      iconTheme: IconThemeData(color: Colors.white),
                      primaryTextTheme: TextTheme().apply(bodyColor: Colors.black),
                    ),
                    child: PopupMenuButton<int>(
                      color: Colors.white,
                      onSelected: (item) => onSelected(context, item),
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                              children: [
                                Icon(Icons.share, color: colorPrimaryLight),
                                const SizedBox(width: 8),
                                Text(Strings.shareAppraisals)])
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem<int>(
                            value: 1,
                            child: Row(
                                children: [
                                  Icon(Icons.manage_accounts, color: colorPrimaryLight),
                                  const SizedBox(width: 8),
                                  Text(Strings.modifyAccount)])
                        ),
                        PopupMenuItem<int>(
                          value: 2,
                          child: Row(
                              children: [
                              Icon(Icons.logout, color: colorPrimaryLight),
                          const SizedBox(width: 8),
                          Text(Strings.logout)])
                        ),
                        PopupMenuItem<int>(
                            value: 3,
                            child: Row(
                                children: [
                                  Icon(Icons.delete_forever, color: colorPrimaryLight),
                                  const SizedBox(width: 8),
                                  Text(Strings.deleteAccount)])
                        ),
                      ]
                    )
                  )
                ]
              ),
              body: TabBarView(
                controller: _tabController,
                physics: (UserC().reports.length < 2)
                    ? NeverScrollableScrollPhysics()
                    : AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                      child: MyStack2(
                          _callBackPop, _callbackContext, _callBackSetState)),
                  Center(child: EvolutionListPage()),
                ],
              ),
              contextualAppBar: ContextualAppBar(
                elevation: 0.0,
                counterBuilder: (itemsCount) => (itemsCount == 1)
                    ? Text("$itemsCount sélectionné")
                    : Text("$itemsCount sélectionnés"),
                closeIcon: Icons.arrow_back,
                contextualActions: [
                  ContextualAction(
                    itemsHandler: (List<Report> items) =>
                        {_toDelete.addAll(items), _showDialog(context)},
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(Icons.delete)),
                  ),
                ],
              ),
            )),
            onWillPop: () async {
              switch (_willPop) {
                case 1:
                  setState(() {});
                  return false;
                case 2:
                  ActionMode.disable<Report>(_context!);
                  return false;
                default:
                  return true;
              }
            }),
        Visibility(
          visible: _loading,
          child: LoadingWithIndicator(),
        )
      ],
    );
  }

  onTap() {
    if (UserC().reports.length < 1 && _tabController.index == 1) {
      setState(() {
        _tabController.index = 0;
      });
      _disabled(Strings.stop);
    }
  }

  _callbackContext(BuildContext context) {
    _context = context;
  }

  //0 can pop, 1 stack on, 2 appbar on, 4 stack off, 3 appbar off
  _callBackPop(int newWillPop) {
    if (newWillPop == 0)
      return;
    else if (_willPop == 0 && newWillPop < 3)
      _willPop = newWillPop;
    else if (_willPop + newWillPop == 5) {
      _willPop = 0;
    }
  }

  _callBackSetState() {
    setState(() {});
  }

  Future<void> _showDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(content: Text(Strings.dialog), actions: <Widget>[
            TextButton(
                onPressed: () async {
                  await UserC().removeReports(_toDelete);
                  _toDelete.clear();
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: Text(Strings.Yes)),
            TextButton(
                onPressed: () {
                  _toDelete.clear();
                  Navigator.of(context).pop();
                },
                child: Text(Strings.No))
          ]);
        });
  }

  Future<void> _disabled(String text) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(text),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Ok"))
          ]);
      });
  }


  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        createPdf();
        break;
      case 1:
        _modifyAccount();
        break;
      case 2:
        _signOut();
        break;
      case 3:
        _deleteAccount();
        break;
    }
  }

  void createPdf() async {
    if(UserC().reports.length < 1){
      _disabled(Strings.stopShare);
      return;
    }

    setState(() {
      _loading = true;
    });
    await getChartDatas();
    exerciseNames = [];
    if (enoughData(chartData)) {
      setState(() {
        value = 0;
        print("début");
      });
      List<Uint8List> images = await getChartImages(chartData);
      setState(() { // see how many images I have
        value = 0.4;
      });
      Map map = Map();
      //map['exNames'] = chartData.map((e) => e[0].exName!).toList();
      map['exNames'] = exerciseNamesWithType;
      map['images'] = images;
      map['externalStorage'] = (await getApplicationDocumentsDirectory()).path;
      map['firstName'] = UserC().firstName!;
      map['lastName'] = UserC().lastName!;
      String completePath = await compute(createCompletePDF, map);
      setState(() {
        value = 1;
        print("1");
      });
      await Share.shareFiles([completePath]);
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
            content: Text(Strings.notEnoughData)),
      );
    }
  }

  void _modifyAccount() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ModifyAccountPage())
    );
  }

  void logOut(){
    UserC().deleteUser();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SignupPage()),
          (route) => false,
    );
  }

  Future<void> _signOut() async {
    bool doneInternal = await FDatabase.instance.deleteUser();
    if (doneInternal) logOut();
  }

  Future<void> _deleteAccount() async {
    _pass1Con.clear();
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text(Strings.deleteAccount),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(Strings.deleteInfo),
                  SizedBox(height: 20),
                  Form(
                      key: _formKey,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _pass1Con,
                        autofocus: false,
                        decoration: InputDecoration(
                          focusColor: colorPrimaryLight,
                          hintText: Strings.egPassword,
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(32.0),
                          )
                        ),
                        validator: (String? value) {
                          if (value == null) {
                            return Strings.enterPass;
                          }else if (value.length < 6){
                            return Strings.deleteWrong;
                          } else if (_combNotOK){
                            return Strings.deleteWrong;
                          }
                          _password = _pass1Con.text;
                          return null;
                        },
                        onSaved: (String? value) async{
                          if ( _formKey.currentState!.validate()){
                            if (_password != UserC().password) {
                              _combNotOK = true;
                              _formKey.currentState!.validate();
                              return;
                            } else {
                              // right password, deleting everything from internal db and external and go to signup page
                              // deleting the internal db
                              bool doneInternal = await FDatabase.instance.deleteUser();
                              if (doneInternal) {
                                // deleting the external db
                                await deleteUserExternal(context);
                                logOut();
                              } else {
                                // todo : il se peut que des account soient plus identifiés et doivent se re-auth avant de delete un account
                                print("coucou on arrive icite");
                              }
                            }
                          }
                          setState(() {_isButtonIgnored = false;});
                        }
                      )
                  ),
                  //forgotPassWidget(context, UserC().email!)
                  TextButton(
                    onPressed: () => onPress(UserC().email!, context),
                    child: Text(
                      Strings.forgotPass,
                      style: TextStyle(
                          color: colorPrimary),
                    ),
                  )
                ]
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () {Navigator.of(context).pop();},
                    child: Text("Annuler")),
                  IgnorePointer(
                    ignoring: _isButtonIgnored,
                    child: ElevatedButton(
                      onPressed: () async{
                        setState(() {_isButtonIgnored = true;});
                        FocusScope.of(context).unfocus();
                        _combNotOK = false;
                        ConnectivityResult connectivity = await Connectivity().checkConnectivity();
                        if (connectivity != ConnectivityResult.mobile
                            && connectivity != ConnectivityResult.wifi) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(Strings.wifiRequirement),
                                  backgroundColor: Colors.red)
                          );
                          setState(() {_isButtonIgnored = false;});
                          return;
                        }
                        _formKey.currentState!.save();
                      },
                      child: Text("Supprimer")))
              ]);
        });
  }

}