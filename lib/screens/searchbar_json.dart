import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:substring_highlight/substring_highlight.dart';

class SearchBarJson extends StatefulWidget {
  const SearchBarJson({Key? key}) : super(key: key);

  @override
  _SearchBarJsonState createState() => _SearchBarJsonState();
}

class _SearchBarJsonState extends State<SearchBarJson> {
  bool isLoading = false;

  late List<String> autoComplateData;

  late TextEditingController controller;

  Future fetchAutoCompleteData() async {
    setState(() {
      isLoading = true;
    });

    final String stringData = await rootBundle.loadString("assets/data.json");

    final List<dynamic> json = jsonDecode(stringData);

    final List<String> jsonStringData = json.cast<String>();

    setState(() {
      isLoading = false;
      autoComplateData = jsonStringData;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAutoCompleteData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Data From Json'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Autocomplete(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        } else {
                          return autoComplateData.where((word) => word
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        }
                      },
                      optionsViewBuilder:
                          (context, Function(String) onSelected, options) {
                        return Material(
                          elevation: 4,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);

                              return ListTile(
                                  title: SubstringHighlight(
                                    text: option.toString(),
                                    term: controller.text,
                                    textStyleHighlight:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  //subtitle: const Text('subtitle'),
                                  onTap: () {
                                    onSelected(option.toString());
                                  });
                            },
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: options.length,
                          ),
                        );
                      },
                      onSelected: (selectedString) {
                        print(selectedString);
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                        this.controller = controller;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            hintText: "Search Something",
                            prefixIcon: const Icon(Icons.search),
                          ),
                        );
                      },
                    ),
                  ],
                )));
  }
}
