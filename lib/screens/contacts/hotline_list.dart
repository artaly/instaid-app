import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instaid_dev/components/hotline_card.dart';
import 'package:instaid_dev/models/hotlines.dart';
import 'package:instaid_dev/resources/firestore_methods.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:instaid_dev/components/back_button.dart';

class HotlineList extends StatefulWidget {
  static const id = 'HotlineList';

  const HotlineList({Key? key}) : super(key: key);

  @override
  State<HotlineList> createState() => _HotlineListState();
}

class _HotlineListState extends State<HotlineList> {
  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Object> _hotlineList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getEmergencyHotlinesList();
  }

  Future getEmergencyHotlinesList() async {
    var hotlineData = await _firestore.collection('emergency_hotlines').orderBy('department_name').get();

    setState(() {
      _hotlineList =
          List.from(hotlineData.docs.map((doc) => Hotlines.fromSnapshot(doc)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: SizeConfig.screenHeight * .12),
                          Text(
                            "Emergency Hotlines",
                            style: TextStyle(
                              fontSize: getProportionateScreenWidth(28),
                              color: textColorBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SafeArea(
                            child: ListView.builder(

                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: _hotlineList.length,
                                itemBuilder: (context, index) {
                                  return HotlineCard(
                                      _hotlineList[index] as Hotlines);
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(top: 40, left: 0, child: ToBack()),
                ],
              ),
            ),
          );
  }
}
