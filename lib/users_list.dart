import 'dart:core';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {

  final _baseUrl = 'https://randomuser.me/api/';

  int _page = 0;
  int _limit = 10;

  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;

  List _posts = [];

  late ScrollController _controller;

  @override
  void initState() {
    // TODO: implement initState
    _firstLoad();
    _controller = new ScrollController()..addListener(_loadMore);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshLoad();
        },
        child: Container(
          child: _isFirstLoadRunning
          ? Center(child: CircularProgressIndicator(),)
              : Column(
            children: [
              Expanded(
                  child: ListView.builder(
                    controller: _controller,
                      itemCount: _posts.length,
                      itemBuilder: (_, index) => Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child : ListTile(
                              leading: CircleAvatar(
                                  radius: 30.0,
                                  backgroundImage: NetworkImage(_posts[index]['picture']['large'])),
                              title: Text(_posts[index]['name']['first']),
                              subtitle: Text(_posts[index]['location']['city']),
                            ),
                      ),
                  ),
              ),
              if(_isLoadMoreRunning == true)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (_hasNextPage == false)
                Container(
                  padding: const EdgeInsets.only(top: 30, bottom: 40),
                  color: Colors.amber,
                  child: Center(
                    child: Text('You have fetched all of the content'),
                  ),
                ),
            ],
          ),
        ),
      )
      ,
    );
  }

  void _firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try{
      final res = await http.get(Uri.parse("$_baseUrl?page=$_page&results=$_limit"));
      final result = json.decode(res.body);
      print(result);
      //final List fetchedPosts =result['results'];
      print(result['results']);
      setState(() {
        _posts = result['results'];
      });
    }
    catch (err) {
      print('Something went wrong');
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _loadMore() async {
    if(_hasNextPage == true &&
    _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300
    ) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      _page += 1;
      try {
        final res = await http.get(Uri.parse("$_baseUrl?page=$_page&results=$_limit"));
        final result = json.decode(res.body);
        print(result);
        final List fetchedPosts =result['results'];
        print(result['results']);

        if (fetchedPosts.length > 0){
          setState(() {
            _posts.addAll(fetchedPosts);
          });
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      }
      catch (err) {
        print('Something went wrong!');
      }
      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  Future<void> _refreshLoad() async {
    try{
      final res = await http.get(Uri.parse("$_baseUrl?page=$_page&results=$_limit"));
      final result = json.decode(res.body);
      print(result);
      //final List fetchedPosts =result['results'];
      print(result['results']);
      setState(() {
        _posts = result['results'];
      });
    }
    catch (err) {
      print('Something went wrong');
    }
  }
}
