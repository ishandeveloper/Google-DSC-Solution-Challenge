import 'package:flutter/material.dart';

class HalfWidthHomeCard extends StatelessWidget {
  final String subText;
  final String header;
  final String imagePath;
  final Function onTap;
  final Color background;
  final String path;

  const HalfWidthHomeCard({
    @required this.subText,
    @required this.header,
    @required this.imagePath,
    @required this.background,
    this.path,
    this.onTap,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap == null
          ? Navigator.pushNamed(context, path)
          : onTap(),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.445,
        height: 150,
        decoration: BoxDecoration(boxShadow:const  [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 6,
              offset: Offset(0, 2))
        ], borderRadius: BorderRadius.circular(8), color: background),
        child: Stack(
          children: [
            Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(imagePath))))),
            Positioned(
                top: 12,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subText, style: const TextStyle(fontSize: 21)),
                    Text(header, style: const TextStyle(fontSize: 26)),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
