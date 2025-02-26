import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:recipo/models.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<RecipeModel> recipeList = [];
  TextEditingController searchController = TextEditingController();

  // Function to fetch recipes
  getRecipes(String query) async {
    String url =
        "https://api.edamam.com/search?q=$query&app_id=ebb6041c&app_key=3c33ad913ab23b8554082bfb5fdd78b5";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data["hits"] != null && data["hits"].isNotEmpty) {
          setState(() {
            recipeList.clear();
            data["hits"].forEach((element) {
              RecipeModel recipeModel = RecipeModel.fromMap(element["recipe"]);
              recipeList.add(recipeModel);
            });
          });

          log("Recipes fetched: ${recipeList.length}");
        } else {
          log("No recipes found!");
        }
      } else {
        log("Error fetching data: ${response.statusCode}");
      }
    } catch (e) {
      log("Error: $e");
    }
  }

  // Function to open recipe URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      log("Could not open URL: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff213A50), Color(0xff071938)],
              ),
            ),
          ),

          Column(
            children: [
              // Search Bar
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (searchController.text.trim().isNotEmpty) {
                            getRecipes(searchController.text);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(3, 0, 7, 0),
                          child: const Icon(Icons.search, color: Colors.blueAccent),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Let's Cook Something!",
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              getRecipes(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title Text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Let's Cook Something New!",
                      style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Recipe List
              Expanded(
                child: recipeList.isEmpty
                    ? const Center(
                  child: Text(
                    "Search for recipes...",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
                    : ListView.builder(
                  itemCount: recipeList.length,
                  itemBuilder: (context, index) {
                    RecipeModel recipe = recipeList[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            recipe.appimgUrl ?? "",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset("assets/download.jpeg", width: 60, height: 60),
                          ),
                        ),
                        title: Text(
                          recipe.applabel ?? "No Name",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${recipe.appcalories?.toStringAsFixed(2)} kcal",
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new, color: Colors.blue),
                          onPressed: () => _launchURL(recipe.appurl ?? ""),
                        ),
                        onTap: () => _launchURL(recipe.appurl),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
