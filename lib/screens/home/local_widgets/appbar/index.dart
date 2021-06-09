import 'package:cached_network_image/cached_network_image.dart';
import 'package:codered/utils/index.dart';
import 'package:flutter/material.dart';

import '../../../indicator.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    Key? key,
    this.drawerKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState>? drawerKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 12, top: 18, bottom: 18, right: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      drawerKey!.currentState!.openDrawer();
                    },
                    child:
                        Icon(Icons.menu, size: 26, color: CodeRedColors.icon)),
                Container(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.username!,
                          style: TextStyle(
                              fontSize: 14,
                              color: CodeRedColors.text,
                              fontWeight: FontWeight.w500),
                        ),
                        Row(children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                          ),
                          Text('Jalandhar, India',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: CodeRedColors.secondaryText))
                        ])
                      ],
                    ),
                    SizedBox(width: 5),
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: CachedNetworkImageProvider(user
                              .photoURL ??
                          'https://api.hello-avatar.com/adorables/ishandeveloper'),
                    )
                  ],
                ))
              ],
            ))
      ],
    );
  }
}
