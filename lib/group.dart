import 'package:flutter/material.dart';
import 'createhike.dart';
import 'join.dart';

class Group extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const Group({Key? key});

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a Trip'),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/adventure.jpeg', // Replace with your asset image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateHike()),
                        );
                      },
                      child: const Text('Create Trip'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Join()),
                        );
                      },
                      child: const Text('Join Trip'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ])
          // SizedBox(
          //   height: 300,
          //   child: Center(
          //     child: OpenStreetMapSearchAndPick(
          //       buttonColor: Colors.yellow,
          //       buttonText: 'Set Current Location',
          //       onPicked: (pickedData) {
          //         // print(pickedData.latLong.latitude);
          //         // print(pickedData.latLong.longitude);
          //         // print(pickedData.address);
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
