import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class ProductMapList extends StatelessWidget {
  final Map<String, String> productMap;
  final String selectedId;
  final Function()? onTap;

  const ProductMapList({
    required this.productMap,
    required this.selectedId,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: kBlackColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: productMap['id'].toString() == selectedId
                  ? Border.all(color: kBlueColor, width: 2)
                  : null,
            ),
            child: ListTile(
              dense: true,
              title: Text(
                productMap['title'].toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceHanSansJP-Bold',
                ),
              ),
              subtitle: Text(
                productMap['description'].toString(),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    productMap['price'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SourceHanSansJP-Bold',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
