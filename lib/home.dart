import 'dart:convert';

import 'package:countup/countup.dart';
import 'package:cstats/theme/images.dart';
import 'package:cstats/theme/sizeconfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();

    fetchInfo();
  }

  Map resData;
  Map miscData;
  Map stateFullName = {};

  String selectedState = "AN";
  String selectedStateForDist = "Select State";
  String selectedStateForDistKey = "";
  String selectedDistrict = "Select District";
  bool showDist = false;
  /* */
  Widget getField({Map dataSet, String entityId, double height}) {
    List<String> attr = [
      "confirmed",
      "deceased",
      "recovered",
      "tested",
      "population",
    ];
    Map attrTitle = {
      "confirmed": "Total Confirmed",
      "deceased": "Total Deceased",
      "recovered": "Total Recovered",
      "tested": "Total Tested",
      "population": "Total Population",
    };
    Map attrBGColor = {
      "confirmed": Color(0xFFFED23F),
      "deceased": Color(0xFFEB7D5B),
      "recovered": Color(0xFFB5D33D),
      "tested": Color(0xFF6CA2EA),
      // "population": Color(0xFF442288),
      "population": Colors.grey
    };

    Map attrFigBGColor = {
      "confirmed": Color(0xFFF3FBD2),
      "deceased": Color(0xFFF2C7CC),
      "recovered": Color(0xFFD7F2CE),
      "tested": Color(0xFFC2E7F1),
      "population": Color(0xFFC0C2E2),
    };
    return Container(
      height: height,
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: attr.map((attribute) {
          String key = attribute == "population" ? "meta" : "total";
          String value = dataSet[entityId][key][attribute].toString();
          value = value == "null"
              ? (attr.indexOf(attribute) != 4 ? "No " + attribute + " yet" : "")
              : value;
          return Container(
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
              // color: attrBGColor[attribute],
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF303030),
                  blurRadius: 25.0, // soften the shadow
                  spreadRadius: -3.0, //extend the shadow
                  offset: Offset(
                    10.0, // Move to right 10  horizontally
                    10.0, // Move to bottom 10 Vertically
                  ),
                )
              ],
            ),
            // height: height / 6,
            height: height / 10,
            child: Stack(
              children: [
                /* label */
                Container(
                  // color: Colors.pink,
                  alignment: Alignment.centerLeft,
                  // padding: EdgeInsets.only(left: 10, top: 10),
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    attrTitle[attribute],
                    style: TextStyle(
                      fontSize: 18,
                      // color: Colors.white,
                    ),
                  ),
                ),
                /* value */
                Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: value.contains(attribute) || value == ""
                      ? Text(
                          value,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Countup(
                          begin: 0,
                          end: double.tryParse(value),
                          duration: Duration(seconds: 1),
                          separator: ",",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  // child: Text(
                  //   value,
                  //   style: TextStyle(
                  //     fontSize: 30,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  fetchInfo() async {
    final miscCall = await http.get("http://192.168.0.5:5500/misc.json");
    if (miscCall.statusCode == 200) {
      miscData = json.decode(miscCall.body);
      miscData["state_meta_data"].forEach((value) {
        stateFullName.putIfAbsent(value["abbreviation"], () => value["stateut"]);
      });
    }
    // get data
    final res = await http.get("http://192.168.0.5:5500/data.json");
    if (res.statusCode == 200) {
      // print("res:::" + res.body);
      var test = res.body;
      resData = json.decode(test);
      print(resData.toString());
      print(resData.length);
    } else {
      print("error:::" + res.statusCode.toString());
    }
  }

  Widget defaultView = Container(
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );

  Widget stateData = Container();
  Widget distData = Container();

  Future<void> _showOptionsDialog({
    @required String title,
    @required List dataSource,
    // @required Function onTapAction,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0.0),
          // title: Text(title),
          content: Container(
            // color: Colors.pink,
            child: SingleChildScrollView(
              child: ListBody(
                children: dataSource,
              ),
            ),
          ),
          // actions: <Widget>[
          //   TextButton(
          //     child: Text('Approve'),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          // ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    double contentH = (SizeConfig.safeBlockVertical * 100) - (AppBar().preferredSize.height * 2);
    double boxHeightInd = contentH / 6;
    double boxHeightSt = contentH;
    if (resData != null) {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Color(0xFFE8E8E8),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(AppBar().preferredSize.height * 2),
            child: AppBar(
              title: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: (SizeConfig.screenWidth / 2) - 50,
                      alignment: Alignment.centerRight,
                      child: Text(
                        "COVID19",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      child: Image.asset(
                        Images.covid19Image,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Container(
                      width: (SizeConfig.screenWidth / 2) - 50,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "INDIA",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                labelPadding: EdgeInsets.all(15.0),
                // isScrollable: true,
                tabs: [
                  Text(
                    "India",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "State",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Disctrict",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              /* All over India */
              Align(
                alignment: Alignment.center,
                child: getField(dataSet: resData, entityId: "TT", height: contentH),
              ),
              /* Selected State */
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: boxHeightSt,
                  child: Column(
                    children: [
                      /* dropdown */
                      Container(
                        // color: Colors.yellow,
                        alignment: Alignment.center,
                        height: AppBar().preferredSize.height,
                        child: DropdownButtonHideUnderline(
                          child: new DropdownButton<String>(
                            value: selectedState,
                            hint: Text("Select State"),
                            items: stateFullName.keys
                                .toList()
                                .where((stateKey) => stateKey != "TT")
                                .toList()
                                .map((value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child: new Text(stateFullName[value.toString()].toString()),
                              );
                            }).toList(),
                            onChanged: (_) {
                              print(_);
                              setState(() {
                                selectedState = _;
                                stateData = getField(
                                  dataSet: resData,
                                  height: (boxHeightSt - AppBar().preferredSize.height),
                                  entityId: _.toString(),
                                );
                              });
                            },
                          ),
                        ),
                      ),
                      /* content */
                      stateData,
                    ],
                  ),
                ),
              ),
              /* Selected District(by state) */
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: boxHeightSt,
                  child: Column(
                    children: [
                      /* dropdown */
                      Container(
                        width: SizeConfig.screenWidth - 40,
                        // color: Colors.yellow,
                        alignment: Alignment.center,
                        height: AppBar().preferredSize.height,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /* select state */
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.pink,
                                onTap: () {
                                  List<Widget> state = [];
                                  stateFullName.forEach((key, value) {
                                    if (key != "TT") {
                                      Widget stateOption = Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          child: Container(
                                            width: SizeConfig.screenWidth * 0.8,
                                            margin: EdgeInsets.all(7.5),
                                            padding: EdgeInsets.all(7.5),
                                            child: Text(
                                              value,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: SizeConfig.safeBlockHorizontal * 3.75,
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            print(key);
                                            Navigator.of(context).pop();
                                            setState(() {
                                              distData = Container();
                                              selectedStateForDist = stateFullName[key];
                                              selectedStateForDistKey = key;
                                              selectedDistrict = "Select District";
                                              showDist = true;
                                            });
                                          },
                                          splashColor: Colors.grey,
                                        ),
                                      );
                                      state.add(stateOption);
                                    }
                                  });
                                  _showOptionsDialog(title: "Select State", dataSource: state);
                                },
                                child: Container(
                                  width: (SizeConfig.screenWidth - 60) / 2,
                                  alignment: Alignment.center,
                                  // color: Colors.blue,
                                  child: Text(
                                    selectedStateForDist,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            /* select district */
                            Visibility(
                              visible: showDist,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.greenAccent,
                                  onTap: () {
                                    print(selectedStateForDistKey);
                                    List<Widget> dists = [];
                                    resData[selectedStateForDistKey]["districts"]
                                        .forEach((key, value) {
                                      Widget distOption = Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          child: Container(
                                            width: SizeConfig.screenWidth * 0.8,
                                            margin: EdgeInsets.all(7.5),
                                            padding: EdgeInsets.all(7.5),
                                            child: Text(
                                              key,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: SizeConfig.safeBlockHorizontal * 3.75,
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            print(key);
                                            Navigator.of(context).pop();
                                            setState(() {
                                              selectedDistrict = key;
                                              distData = getField(
                                                dataSet: resData[selectedStateForDistKey]
                                                    ["districts"],
                                                height:
                                                    (boxHeightSt - AppBar().preferredSize.height),
                                                entityId: key,
                                              );
                                            });
                                          },
                                          splashColor: Colors.grey,
                                        ),
                                      );
                                      dists.add(distOption);
                                    });
                                    setState(() {
                                      distData = Container();
                                    });
                                    _showOptionsDialog(title: "Select District", dataSource: dists);
                                  },
                                  child: Container(
                                    width: (SizeConfig.screenWidth - 60) / 2,
                                    alignment: Alignment.center,
                                    // color: Colors.pink,
                                    child: Text(selectedDistrict),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      /* content */
                      distData,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
  }
}
