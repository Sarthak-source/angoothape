import 'package:flutter/material.dart';

import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/sheet_chrome.dart';

class ProfileSheet extends StatefulWidget {
  const ProfileSheet({super.key});
  @override
  State<ProfileSheet> createState() => ProfileSheetState();
}

class ProfileSheetState extends State<ProfileSheet> {
  final name = TextEditingController();
  final shop = TextEditingController();
  final city = TextEditingController();
  final mobile = TextEditingController();
  var _filled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filled) return;
    _filled = true;
    final r = AppScope.of(context).data.retailer;
    name.text = r.name;
    shop.text = r.shop;
    city.text = r.city;
    mobile.text = r.mobileFull.isNotEmpty ? r.mobileFull : r.mobile;
  }

  @override
  void dispose() {
    name.dispose();
    shop.dispose();
    city.dispose();
    mobile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final tried = c.sheet?.tried ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHead(c.both('Edit profile', 'प्रोफ़ाइल बदलें')),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
            child: Column(
              children: [
                ApTextField(
                  label: c.both('Name', 'नाम'),
                  controller: name,
                  error: tried && name.text.trim().isEmpty
                      ? c.both('Enter your name', 'नाम लिखें')
                      : null,
                ),
                ApTextField(
                  label: c.both('Shop', 'दुकान'),
                  controller: shop,
                  error: tried && shop.text.trim().isEmpty
                      ? c.both('Enter shop name', 'दुकान का नाम लिखें')
                      : null,
                ),
                ApTextField(
                  label: c.both('City', 'शहर'),
                  controller: city,
                  error: tried && city.text.trim().isEmpty
                      ? c.both('Enter city', 'शहर लिखें')
                      : null,
                ),
                ApTextField(
                  label: c.t('mobile'),
                  controller: mobile,
                  digits: 10,
                  error: tried && !validMobile(mobile.text)
                      ? c.t('e_mobile')
                      : null,
                ),
              ],
            ),
          ),
        ),
        SheetFoot(
          children: [
            ApButton(
              label: c.both('Save', 'सेव करें'),
              expand: true,
              onPressed: () => c.submitProfile({
                'name': name.text,
                'shop': shop.text,
                'city': city.text,
                'mobile': mobile.text,
              }),
            ),
          ],
        ),
      ],
    );
  }
}
