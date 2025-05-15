import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:project_pdd/style.dart';
import 'package:project_pdd/widget/register.dart';

class TermOfServicePage extends StatefulWidget {
  const TermOfServicePage({super.key});

  @override
  TermOfServicePageState createState() => TermOfServicePageState();
}

class TermOfServicePageState extends State<TermOfServicePage> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? primaryColor
            : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36.0)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: keyboardHeight > 0
              ? MediaQuery.of(context).size.height * 0.35
              : MediaQuery.of(context).size.height * 0.05,
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 12,),
                    Text(
                      "Term of Service",
                      style: subTitleTextStyleDark(context,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "ข้อตกลงการให้บริการ",
                      style: descTextStyleDark(context,
                          fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0, right: 32.0),
                    child: Text.rich(
                      TextSpan(
                        children: 
                        <TextSpan>[
                          TextSpan(text: '''\u00A0\u00A0\u00A0\u00A0\u00A0'''),
                          TextSpan(text: '''ซอฟต์แวร์นี้เป็นผลงานที่พัฒนาขึ้นโดย นายพชรดนัย กุระกนก นายญาณภัทร ปานเกษม และ นายธัญวรัตม์ ก.วิบูลย์ศักดิ​ศร จาก มหาวิทยาลัยศรีนครินทรวิโรฒ ภายใต้การดูแลของ นางสาวบรรพตรี คมขำ ภายใต้โครงการ ใบรู้โรค ซึ่งสนับสนุนโดย สำนักงานพัฒนาวิทยาศาสตร์และเทคโนโลยีแห่งชาติ โดยมีวัตถุประสงค์เพื่อส่งเสริมให้นักเรียนและนักศึกษาได้เรียนรู้และฝึกทักษะในการพัฒนา ซอฟต์แวร์ ลิขสิทธิ์ของซอฟต์แวร์นี้จึงเป็นของผู้พัฒนา ซึ่งผู้พัฒนาได้อนุญาติให้สำนักงาน พัฒนาวิทยาศาสตร์และเทคโนโลยีแห่งชาติ เผยแพร่ซอฟต์แวร์นี้ตาม “ต้นฉบับ” โดยไม่มี การแก้ไขดัดแปลงใด ๆ ทั้งสิ้น ให้แก่บุคคลทั่วไปได้ใช้เพื่อประโยชน์ส่วนบุคคลหรือ ประโยชน์ทางการศึกษาที่ไม่มีวัตถุประสงค์ในเชิงพาณิชย์ โดยไม่คิดค่าตอบแทนการใช้ ซอฟต์แวร์ ดังนั้น สำนักงานพัฒนาวิทยาศาสตร์และเทคโนโลยีแห่งชาติ จึงไม่มีหน้าที่ใน การดูแล บำรุงรักษา จัดการอบรมการใช้งาน หรือพัฒนาประสิทธิภาพซอฟต์แวร์ รวมทั้ง ไม่รับรองความถูกต้องหรือประสิทธิภาพการทำงานของซอฟต์แวร์ ตลอดจนไม่รับประกัน ความเสียหายต่าง ๆ อันเกิดจากการใชซอฟต์แวร์นี้ทั้งสิ้น''',
                          ),
                        ]
                      ),
                      style: subDescTextStyleDark(context,
                        fontWeight: FontWeight.normal),
                      textAlign: TextAlign.justify,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showSecondModal(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context, // Allow modal to resize with keyboard
    backgroundColor: Colors.transparent, // Make modal transparent
    builder: (BuildContext context) {
      double keyboardHeight =
          MediaQuery.of(context).viewInsets.bottom; // Detect keyboard height
      return SizedBox(
        height: keyboardHeight > 0
            ? MediaQuery.of(context).size.height * 0.9
            : MediaQuery.of(context).size.height *
                0.6, // Increase height when keyboard appears
        child: Stack(
          children: [
            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.transparent,
              ),
            ),
            // Modal content
            Positioned(
              child: RegisApp(),
            ),
          ],
        ),
      );
    },
  );
}
