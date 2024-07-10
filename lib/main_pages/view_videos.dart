import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment/functions.dart';
import 'package:flutter_assignment/main_pages/play_video.dart';

class ViewVideos extends StatefulWidget {
  const ViewVideos({super.key});

  @override
  State<ViewVideos> createState() => _ViewVideosState();
}

class _ViewVideosState extends State<ViewVideos> {
  List oruList = [];
  List filteredList = [];
  List dateList = [];
  List dateListRawOne = [];
  bool dataReceived = false;
  Timer? _timer;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDataRealTime();
    searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> getDataOnce() async {
    var ref = await FirebaseDatabase.instance.ref('/Videos/').once();
    setState(() {
      oruList = ref.snapshot.value as List;
      filteredList = oruList;
    });
  }

  Future<void> getDataRealTime() async {
    var ref = FirebaseDatabase.instance.ref('/Videos/');
    ref.onChildAdded.listen((event) {
      Map data = event.snapshot.value as Map;
      setState(() {
        oruList.add(data);
        dateListRawOne.add(data["uploadTime"]);
        dateList.add(CommonFunctions().calculateTimeAgo(data["uploadTime"]));
        filteredList = oruList;
        dataReceived = true;
      });

      if (_timer == null) {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      if (dataReceived) {
        minutes();
      }
    });
  }

  Future<void> minutes() async {
    for (int x = 0; x < dateListRawOne.length; x++) {
      setState(() {
        dateList[x] = CommonFunctions().calculateTimeAgo(dateListRawOne[x]);
      });
    }
  }

  void _filterList() {
    setState(() {
      filteredList = oruList.where((data) {
        final title = data["title"].toString().toLowerCase();
        final query = searchController.text.toLowerCase();
        return title.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: getDataOnce,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                String videoTitle = filteredList[index]["title"];
                String username = filteredList[index]["uid"];
                String daysAgo = dateList[index];
                String category = filteredList[index]["category"];
                String location = filteredList[index]["location"];
                String videoUrl = filteredList[index]["videoUrl"];

                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person), // Replace with user profile pic
                  ),
                  title: Text(videoTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(daysAgo),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(location, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(category, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayVideo(
                          videoTitle: videoTitle,
                          username: username,
                          daysAgo: daysAgo,
                          category: category,
                          videoUrl: videoUrl,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
