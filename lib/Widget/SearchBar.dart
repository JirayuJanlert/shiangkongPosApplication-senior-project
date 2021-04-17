
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SearchBar extends StatelessWidget {
  final String label;
  final FocusNode searchNode;
  final TextEditingController searchTxt;
  final Function searchFunction;
  const SearchBar ({
    Key key,
    this.searchFunction,
    this.searchTxt,
    this.searchNode,
    this.label,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.black,
      autofocus: false,
      focusNode: searchNode,
      controller: searchTxt,
      onChanged: (text) {
        // c.setSearchKey(text);
        searchFunction(text);
      },

      style: TextStyle(color: Colors.black54),
      decoration: InputDecoration(
        prefixIcon: new Icon(Icons.search),
        suffix: searchNode.hasFocus
            ? SizedBox(
          height: 15.0,
          child: GestureDetector(
            child: Icon(
              MdiIcons.closeCircle,
              color: Colors.grey,
            ),
            onTap: () {
              searchTxt.text = "";
              searchFunction("");
              searchNode.unfocus();
            },
          ),
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.black54,
            style: BorderStyle.solid,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: Colors.transparent,
            style: BorderStyle.solid,
          ),
        ),
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding:
        EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        hintText: label,
        filled: true,
        fillColor: Colors.white,
      ),
    );
  } //ef
} //ec
