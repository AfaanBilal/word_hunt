///
/// Word Hunt
/// Guess a five-letter word in 6 attempts.
///
/// Author: Afaan Bilal
/// Website: http://afaan.dev
///

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Hunt',
      theme: ThemeData(primarySwatch: Colors.purple, fontFamily: 'Nunito'),
      home: const WordHunt(title: 'Word Hunt'),
    );
  }
}

class WordHunt extends StatefulWidget {
  const WordHunt({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<WordHunt> createState() => _WordHuntState();
}

class _WordHuntState extends State<WordHunt> {
  bool _hasWon = false;
  String _currentWord = 'HELLO';

  @override
  void initState() {
    super.initState();
    reset();
  }

  Future<void> _launchInBrowser(String url) async {
    if (!await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
    )) {
      throw 'Could not launch $url';
    }
  }

  int _tryNumber = 0;
  final List<List<String>> _guessWords = [
    [' ', ' ', ' ', ' ', ' '],
    [' ', ' ', ' ', ' ', ' '],
    [' ', ' ', ' ', ' ', ' '],
    [' ', ' ', ' ', ' ', ' '],
    [' ', ' ', ' ', ' ', ' '],
    [' ', ' ', ' ', ' ', ' '],
  ];

  void _nextTry() {
    setState(() {
      if (_hasWon) {
        reset();
        return;
      }

      if (_guessWords[_tryNumber].join().trim().characters.length < 5) {
        showAlertDialog(context, 'Error', 'Please enter 5 characters.', 'OK', () {});
        return;
      }

      for (var c in tbControllers) {
        c.clear();
      }

      var w = _guessWords[_tryNumber].join();

      _tryNumber++;

      if (w == _currentWord) {
        _hasWon = true;
        return;
      }

      if (_tryNumber > 5) {
        showAlertDialog(context, 'Oops', '😔 You lost! \n\nThe word was: $_currentWord', 'New word', reset);
      }

      firstTbFocus.requestFocus();
    });
  }

  void reset() {
    setState(() {
      _currentWord = masterWordList[(Random()).nextInt(masterWordList.length)].toUpperCase();
      _hasWon = false;
      _tryNumber = 0;

      for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 5; j++) {
          _guessWords[i][j] = ' ';
        }
      }
    });
  }

  void setWord(String character, int row, int col) {
    setState(() {
      _guessWords[row][col] = character.isNotEmpty ? character.toUpperCase() : ' ';
    });
  }

  List<TextEditingController> tbControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  FocusNode firstTbFocus = FocusNode();

  Widget buildTextBox(int row, int col) {
    return Container(
      margin: const EdgeInsets.fromLTRB(6.0, 16.0, 6.0, 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.purple),
      ),
      width: 40,
      height: 40,
      child: TextField(
        controller: tbControllers[col],
        autofocus: col == 0,
        focusNode: col == 0 ? firstTbFocus : null,
        maxLength: 1,
        onChanged: (text) {
          if (text.characters.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          } else {
            FocusScope.of(context).previousFocus();
          }

          setWord(text, row, col);
        },
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(fontSize: 25),
        decoration: const InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          counterText: "",
        ),
      ),
    );
  }

  Widget buildTextBoxRow(int row) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildTextBox(row, 0),
        buildTextBox(row, 1),
        buildTextBox(row, 2),
        buildTextBox(row, 3),
        buildTextBox(row, 4),
      ],
    );
  }

  String createShareText() {
    List<String> shareMatrix = ['WordHunt $_tryNumber/6'];
    for (int i = 0; i < _tryNumber; i++) {
      List<String> shareLine = [];
      for (int j = 0; j < 5; j++) {
        var wbColor = wordBoxColor(_guessWords[i][j], j, i);
        if (wbColor == Colors.green.shade900) {
          shareLine.add('🟩');
        } else if (wbColor == Colors.yellow.shade800) {
          shareLine.add('🟨');
        } else {
          shareLine.add('⬛');
        }
      }

      shareMatrix.add(shareLine.join());
    }

    return shareMatrix.join('\n');
  }

  Color wordBoxColor(String character, int position, int row) {
    var cWordList = _currentWord.split('');

    if (cWordList[position] == character) {
      return Colors.green.shade900;
    } else if (cWordList.contains(character)) {
      return Colors.yellow.shade800;
    } else {
      return Colors.grey.shade900;
    }
  }

  Color wordBoxTextColor(Color wbColor) {
    if (wbColor == Colors.white) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  Widget buildWordBox(String character, int position, int row) {
    var wbColor = wordBoxColor(character, position, row);
    return Container(
      margin: const EdgeInsets.all(6.0),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: wbColor,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.white),
      ),
      child: Center(
        child: Text(
          character.toUpperCase(),
          style: TextStyle(
            fontSize: 25,
            color: wordBoxTextColor(wbColor),
          ),
        ),
      ),
    );
  }

  Widget buildWordBoxRow(String word, int row) {
    if (row == _tryNumber || word.trim().characters.isEmpty) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: word.split('').asMap().entries.map((c) => buildWordBox(c.value, c.key, row)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            _launchInBrowser('https://afaan.dev');
          },
          child: const Icon(
            Icons.account_circle_rounded,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                showAlertDialog(
                    context,
                    'Guide',
                    '⬛ Letter is not present.'
                        '\n\n🟨 Letter is present but at the wrong position.'
                        '\n\n🟩 Letter is present and at the correct position.',
                    'Got it!',
                    () {});
              },
              child: const Icon(Icons.help),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(padding: EdgeInsets.all(10.0)),
                  Text(
                    'Guess a five letter word:',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Column(
                    children: _guessWords.asMap().entries.map((w) => buildWordBoxRow(w.value.join(), w.key)).toList(),
                  ),
                  _hasWon
                      ? Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Genius! Well done!',
                                style: Theme.of(context).textTheme.headline5?.copyWith(color: Colors.green),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final box = context.findRenderObject() as RenderBox?;
                                  Share.share(createShareText(), subject: "Share", sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
                                },
                                child: const Text('Share'),
                              ),
                            ],
                          ),
                        )
                      : buildTextBoxRow(_tryNumber),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('© Afaan Bilal · afaan.dev', style: TextStyle(fontSize: 14.0, color: Colors.purple)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nextTry,
        tooltip: 'Check',
        icon: const Icon(Icons.arrow_forward),
        label: Text(_hasWon ? 'New word' : 'Check', style: const TextStyle(fontSize: 18)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

showAlertDialog(BuildContext context, String title, String message, String okText, VoidCallback onOk) {
  Widget okButton = TextButton(
    child: Text(okText),
    onPressed: () {
      onOk();
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

const List<String> masterWordList = [
  'Abuse',
  'Adult',
  'Agent',
  'Anger',
  'Apple',
  'Award',
  'Basis',
  'Beach',
  'Birth',
  'Block',
  'Blood',
  'Board',
  'Brain',
  'Bread',
  'Break',
  'Brown',
  'Buyer',
  'Cause',
  'Chain',
  'Chair',
  'Chest',
  'Chief',
  'Child',
  'China',
  'Claim',
  'Class',
  'Clock',
  'Coach',
  'Coast',
  'Court',
  'Cover',
  'Cream',
  'Crime',
  'Cross',
  'Crowd',
  'Crown',
  'Cycle',
  'Dance',
  'Death',
  'Depth',
  'Doubt',
  'Draft',
  'Drama',
  'Dream',
  'Dress',
  'Drink',
  'Drive',
  'Earth',
  'Enemy',
  'Entry',
  'Error',
  'Event',
  'Faith',
  'Fault',
  'Field',
  'Fight',
  'Final',
  'Floor',
  'Focus',
  'Force',
  'Frame',
  'Frank',
  'Front',
  'Fruit',
  'Glass',
  'Grant',
  'Grass',
  'Green',
  'Group',
  'Guide',
  'Heart',
  'Henry',
  'Horse',
  'Hotel',
  'House',
  'Image',
  'Index',
  'Input',
  'Issue',
  'Japan',
  'Jones',
  'Judge',
  'Knife',
  'Laura',
  'Layer',
  'Level',
  'Lewis',
  'Light',
  'Limit',
  'Lunch',
  'Major',
  'March',
  'Match',
  'Metal',
  'Model',
  'Money',
  'Month',
  'Motor',
  'Mouth',
  'Music',
  'Night',
  'Noise',
  'North',
  'Novel',
  'Nurse',
  'Offer',
  'Order',
  'Other',
  'Owner',
  'Panel',
  'Paper',
  'Party',
  'Peace',
  'Peter',
  'Phase',
  'Phone',
  'Piece',
  'Pilot',
  'Pitch',
  'Place',
  'Plane',
  'Plant',
  'Plate',
  'Point',
  'Pound',
  'Power',
  'Press',
  'Price',
  'Pride',
  'Prize',
  'Proof',
  'Queen',
  'Radio',
  'Range',
  'Ratio',
  'Reply',
  'Right',
  'River',
  'Round',
  'Route',
  'Rugby',
  'Scale',
  'Scene',
  'Scope',
  'Score',
  'Sense',
  'Shape',
  'Share',
  'Sheep',
  'Sheet',
  'Shift',
  'Shirt',
  'Shock',
  'Sight',
  'Simon',
  'Skill',
  'Sleep',
  'Smile',
  'Smith',
  'Smoke',
  'Sound',
  'South',
  'Space',
  'Speed',
  'Spite',
  'Sport',
  'Squad',
  'Staff',
  'Stage',
  'Start',
  'State',
  'Steam',
  'Steel',
  'Stock',
  'Stone',
  'Store',
  'Study',
  'Stuff',
  'Style',
  'Sugar',
  'Table',
  'Taste',
  'Terry',
  'Theme',
  'Thing',
  'Title',
  'Total',
  'Touch',
  'Tower',
  'Track',
  'Trade',
  'Train',
  'Trend',
  'Trial',
  'Trust',
  'Truth',
  'Uncle',
  'Union',
  'Unity',
  'Value',
  'Video',
  'Visit',
  'Voice',
  'Waste',
  'Watch',
  'Water',
  'While',
  'White',
  'Whole',
  'Woman',
  'World',
  'Youth',
];
