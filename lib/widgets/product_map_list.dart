import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class ProductMapList extends StatelessWidget {
  final String id;
  final String selectedId;
  final String title;
  final String description;
  final String price;
  final Function()? onTap;

  const ProductMapList({
    required this.id,
    required this.selectedId,
    required this.title,
    required this.description,
    required this.price,
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
              border: id == selectedId
                  ? Border.all(color: kBlueColor, width: 2)
                  : null,
            ),
            child: ListTile(
              dense: true,
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceHanSansJP-Bold',
                ),
              ),
              subtitle: Text(
                description,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    price,
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
