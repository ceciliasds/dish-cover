import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MealDetailsWidget extends StatefulWidget {
  final String mealImage;
  final List<String> mealInstructions;
  final String mealName;
  final String mealCategory;
  final List<String> mealIngredients;
  final String youtubeLink;

  MealDetailsWidget({
    required this.mealImage,
    required this.mealInstructions,
    required this.mealName,
    required this.mealCategory,
    required this.mealIngredients,
    required this.youtubeLink,
  });

  @override
  _MealDetailsWidgetState createState() => _MealDetailsWidgetState();
}

class _MealDetailsWidgetState extends State<MealDetailsWidget> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Details'),
        backgroundColor: Color.fromARGB(255, 215, 132, 44),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  _showImageFullScreen(context);
                },
                child: Stack(
                  children: [
                    Image.network(
                      widget.mealImage,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    if (widget.youtubeLink.isNotEmpty)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              isHovering = true;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              isHovering = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            transform: isHovering
                                ? Matrix4.diagonal3Values(1.2, 1.2, 1)
                                : Matrix4.identity(),
                            child: ElevatedButton(
                              onPressed: () {
                                launchUrl(Uri.parse(widget.youtubeLink));
                              },
                              child: Icon(Icons.play_arrow),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildMealDetailsBox(),
              SizedBox(height: 20),
              _buildIngredientsBox(),
              SizedBox(height: 20),
              _buildInstructionsBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealDetailsBox() {
    return _buildBoxWithShadow(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Text(
                  '${widget.mealName}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Category: ${widget.mealCategory}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsBox() {
    return _buildBoxWithShadow(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0), 
            child: Text(
              'Ingredients:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(color: Colors.grey), 
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.mealIngredients.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: IngredientCapsule(ingredient: ingredient),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsBox() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: _buildBoxWithShadow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), 
              child: Text(
                'Instructions:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(color: Colors.grey), 
            Padding(
              padding: const EdgeInsets.all(16.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  widget.mealInstructions.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 8.0),
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _removeLeadingNumber(widget.mealInstructions[index]),
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxWithShadow({required Widget child}) {
    return Container(
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                offset: Offset(0, 3),
              ),
            ],
            border: Border.all(color: Color.fromARGB(255, 94, 91, 91)),
          ),
          child: child,
        ),
      ),
    );
  }

  String _removeLeadingNumber(String instruction) {
    final regex = RegExp(r'^\d+\.\s*');
    return instruction.replaceAll(regex, '');
  }

void _showImageFullScreen(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(20),
                minScale: 0.1,
                maxScale: 4.0,
                child: Image.network(
                  widget.mealImage,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8.0, 
              right: 8.0, 
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}


}

class IngredientCapsule extends StatelessWidget {
  final String ingredient;

  const IngredientCapsule({Key? key, required this.ingredient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 124, 205, 32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(ingredient),
    );
  }
}
