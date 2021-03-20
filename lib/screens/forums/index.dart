import 'package:codered/services/database/forums.dart';
import 'package:codered/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../utils/index.dart';

class ForumsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Forums',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              FutureBuilder(
                  future: ForumsHelper.getPosts(),
                  builder: (BuildContext context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();

                    return Text(snapshot.data.toString());
                  })
              // ListView.builder(
              //     itemCount: 20,
              //     physics: NeverScrollableScrollPhysics(),
              //     shrinkWrap: true,
              //     itemBuilder: (BuildContext context, int index) {
              //       return ForumPost();
              //     })
            ],
          ),
        ),
      ),
    );
  }
}

class ForumPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xffFAFAFA), boxShadow: [
        BoxShadow(
            offset: Offset(0, 2),
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 3)
      ]),
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          ForumPostHeader(),

          ForumPostContent(),

          ForumPostControls(),

          Container(
            color: Color(0xffeeeeee),
            child: TextField(
                autofocus: false,
                controller: TextEditingController(),
                // focusNode: _editCommentFocus,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: CodeRedColors.text),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10),
                    border: InputBorder.none,
                    hintText: "Write your comment...",
                    hintStyle:
                        TextStyle(fontSize: 14, color: CodeRedColors.text))),
          ),

          ForumPostComments(),
        ],
      ),
    );
  }
}

class ForumPostComments extends StatefulWidget {
  @override
  _ForumPostCommentsState createState() => _ForumPostCommentsState();
}

class _ForumPostCommentsState extends State<ForumPostComments> {
  int maxCommentsToDisplay = 2;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: maxCommentsToDisplay,
      itemBuilder: (BuildContext context, index) {
        return Container(
          color: index % 2 != 0 ? Color(0xffF5F5F5) : Color(0xffFFFFFF),
          padding: EdgeInsets.only(top: 6, left: 12, right: 6, bottom: 6),
          margin: EdgeInsets.only(top: 4, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                    'https://avatars.githubusercontent.com/u/54989142?s=460&u=dae5bd5b626e6e4ed70d23fe25d1eba5d510efc6&v=4'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text"),
              )
            ],
          ),
        );
      },
    );
  }
}

class ForumPostContent extends StatelessWidget {
  const ForumPostContent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12, left: 0),
      child: Column(
        children: [
          Container(
            width: getContextWidth(context) * 0.9,
            child: Text(
                'The future of medical sciences is really scary, if we continue at the current pace',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          ForumPostRichText(
              text:
                  '''Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.'''),
        ],
      ),
    );
  }
}

class ForumPostHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(
              'https://avatars.githubusercontent.com/u/54989142?s=460&u=dae5bd5b626e6e4ed70d23fe25d1eba5d510efc6&v=4'),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ishandeveloper',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text('3 hours ago',
                style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.5), fontSize: 12))
          ],
        )
      ],
    );
  }
}

class ForumPostRichText extends StatefulWidget {
  final String text;

  ForumPostRichText({Key key, @required this.text}) : super(key: key);

  @override
  _ForumPostRichTextState createState() => _ForumPostRichTextState();
}

class _ForumPostRichTextState extends State<ForumPostRichText>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      //Without this the text will appear horizontally centered
      constraints: BoxConstraints(minWidth: getContextWidth(context)),
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          color: CodeRedColors.background,
          child: Linkify(
            text: widget.text,
            maxLines: 3,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
            onOpen: (_) => openURL(_.url, context),
          )),
    );
  }
}

class ForumPostControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ForumPostControlVotes(),
          SizedBox(width: 20),
          ForumPostControlComments(),
        ],
      ),
    );
  }
}

class ForumPostControlComments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: Row(
        children: [
          Icon(
            Octicons.comment,
            size: 20,
            color: CodeRedColors.icon,
          ),
          Container(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              '4',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class ForumPostControlVotes extends StatelessWidget {
  const ForumPostControlVotes({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 50),
      child: Container(
        margin: EdgeInsets.only(top: 0),
        child: Row(
          children: [
            Icon(
              Octicons.arrow_up,
              size: 22,
              color: CodeRedColors.icon,
            ),
            Container(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                '32',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
