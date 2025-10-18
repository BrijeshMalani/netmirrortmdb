import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/ad_manager.dart';
import '../widgets/WorkingNativeAdWidget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _showResult = false;
  bool _isAnswered = false;
  bool _showCategorySelection = true;
  String _selectedCategory = "";

  // Movie & TV Show Questions (Original List)
  final List<QuizQuestion> _movieTvQuestions = [
    QuizQuestion(
      question: "Which movie won the Academy Award for Best Picture in 2020?",
      options: ["Parasite", "1917", "Joker", "Once Upon a Time in Hollywood"],
      correctAnswer: 0,
      category: "Movies",
    ),
    QuizQuestion(
      question: "Who directed the movie 'Inception'?",
      options: [
        "Steven Spielberg",
        "Christopher Nolan",
        "Martin Scorsese",
        "Quentin Tarantino",
      ],
      correctAnswer: 1,
      category: "Movies",
    ),
    QuizQuestion(
      question: "Which TV series is known for the phrase 'Winter is Coming'?",
      options: [
        "The Witcher",
        "Game of Thrones",
        "Vikings",
        "The Last Kingdom",
      ],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "What is the highest-grossing movie of all time?",
      options: [
        "Avatar",
        "Avengers: Endgame",
        "Titanic",
        "Star Wars: The Force Awakens",
      ],
      correctAnswer: 0,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which streaming platform originally produced 'Stranger Things'?",
      options: ["Hulu", "Netflix", "Amazon Prime", "Disney+"],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "Who played the role of Tony Stark/Iron Man in the MCU?",
      options: [
        "Chris Evans",
        "Robert Downey Jr.",
        "Chris Hemsworth",
        "Mark Ruffalo",
      ],
      correctAnswer: 1,
      category: "Movies",
    ),
    QuizQuestion(
      question: "Which TV series features the character 'Walter White'?",
      options: ["Better Call Saul", "Breaking Bad", "The Sopranos", "The Wire"],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "What year was the first 'Star Wars' movie released?",
      options: ["1975", "1977", "1979", "1981"],
      correctAnswer: 1,
      category: "Movies",
    ),
    QuizQuestion(
      question: "Which TV series is set in the fictional town of Hawkins?",
      options: ["The OA", "Stranger Things", "Dark", "Twin Peaks"],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "Who composed the music for 'The Lord of the Rings' trilogy?",
      options: ["John Williams", "Hans Zimmer", "Howard Shore", "Danny Elfman"],
      correctAnswer: 2,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series features the character 'Eleven' with psychokinetic abilities?",
      options: ["The OA", "Stranger Things", "Dark", "The Umbrella Academy"],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question:
          "What is the name of the fictional newspaper in 'The Daily Planet'?",
      options: [
        "Metropolis Times",
        "The Daily Planet",
        "Gotham Gazette",
        "Central City News",
      ],
      correctAnswer: 1,
      category: "Movies",
    ),
    QuizQuestion(
      question: "Which actor played the Joker in 'The Dark Knight'?",
      options: [
        "Joaquin Phoenix",
        "Heath Ledger",
        "Jared Leto",
        "Jack Nicholson",
      ],
      correctAnswer: 1,
      category: "Movies",
    ),
    QuizQuestion(
      question: "What is the name of the fictional kingdom in 'Frozen'?",
      options: ["Arendelle", "Corona", "Agrabah", "Atlantica"],
      correctAnswer: 0,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series is based on George R.R. Martin's 'A Song of Ice and Fire'?",
      options: [
        "The Witcher",
        "Game of Thrones",
        "Vikings",
        "The Last Kingdom",
      ],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "Who directed the movie 'Pulp Fiction'?",
      options: [
        "Martin Scorsese",
        "Quentin Tarantino",
        "Steven Spielberg",
        "Christopher Nolan",
      ],
      correctAnswer: 1,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series features the character 'Sherlock Holmes' in modern London?",
      options: ["Elementary", "Sherlock", "The Mentalist", "Psych"],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "What is the highest-grossing animated movie of all time?",
      options: [
        "Frozen II",
        "The Lion King (2019)",
        "Incredibles 2",
        "Toy Story 4",
      ],
      correctAnswer: 0,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series features the character 'Rick Sanchez' and his grandson Morty?",
      options: ["Futurama", "Rick and Morty", "The Simpsons", "Family Guy"],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question:
          "Who played the role of Captain Jack Sparrow in 'Pirates of the Caribbean'?",
      options: [
        "Orlando Bloom",
        "Johnny Depp",
        "Geoffrey Rush",
        "Keira Knightley",
      ],
      correctAnswer: 1,
      category: "Movies",
    ),
    QuizQuestion(
      question: "Which TV series is set in the fictional town of Twin Peaks?",
      options: ["The X-Files", "Twin Peaks", "Northern Exposure", "Eureka"],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "What is the name of the fictional school in 'Harry Potter'?",
      options: ["Hogwarts", "Beauxbatons", "Durmstrang", "Ilvermorny"],
      correctAnswer: 0,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series features the character 'Dexter Morgan' who is a blood spatter analyst?",
      options: ["Dexter", "Hannibal", "The Following", "True Detective"],
      correctAnswer: 0,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "Who directed the movie 'The Shawshank Redemption'?",
      options: [
        "Frank Darabont",
        "Steven Spielberg",
        "Martin Scorsese",
        "Quentin Tarantino",
      ],
      correctAnswer: 0,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series features the character 'Don Draper' in the advertising world?",
      options: ["The Sopranos", "Mad Men", "Breaking Bad", "The Wire"],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "What is the name of the fictional planet in 'Avatar'?",
      options: ["Pandora", "Endor", "Tatooine", "Krypton"],
      correctAnswer: 0,
      category: "Movies",
    ),
    QuizQuestion(
      question: "Which TV series features the character 'Tyrion Lannister'?",
      options: [
        "The Witcher",
        "Game of Thrones",
        "Vikings",
        "The Last Kingdom",
      ],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "Who played the role of Wolverine in the X-Men movies?",
      options: [
        "Ryan Reynolds",
        "Hugh Jackman",
        "Chris Evans",
        "Robert Downey Jr.",
      ],
      correctAnswer: 1,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series features the character 'Saul Goodman' as a criminal lawyer?",
      options: ["Breaking Bad", "Better Call Saul", "The Good Wife", "Suits"],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "What is the name of the fictional city in 'Batman'?",
      options: ["Metropolis", "Gotham City", "Central City", "Star City"],
      correctAnswer: 1,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series features the character 'Eleanor Shellstrop' in the afterlife?",
      options: ["The Good Place", "Upload", "Dead Like Me", "Pushing Daisies"],
      correctAnswer: 0,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "Who directed the movie 'Inception'?",
      options: [
        "Steven Spielberg",
        "Christopher Nolan",
        "Martin Scorsese",
        "Quentin Tarantino",
      ],
      correctAnswer: 1,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series features the character 'Jon Snow' as a member of the Night's Watch?",
      options: [
        "The Witcher",
        "Game of Thrones",
        "Vikings",
        "The Last Kingdom",
      ],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question: "What is the name of the fictional school in 'X-Men'?",
      options: [
        "Xavier's School for Gifted Youngsters",
        "Avengers Academy",
        "S.H.I.E.L.D. Academy",
        "Stark Industries",
      ],
      correctAnswer: 0,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series features the character 'Michael Scott' as a regional manager?",
      options: [
        "Parks and Recreation",
        "The Office",
        "Brooklyn Nine-Nine",
        "30 Rock",
      ],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question:
          "Who played the role of Hermione Granger in the 'Harry Potter' movies?",
      options: ["Emma Watson", "Emma Stone", "Emma Roberts", "Emma Thompson"],
      correctAnswer: 0,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series features the character 'Walter White' as a high school chemistry teacher?",
      options: ["Better Call Saul", "Breaking Bad", "The Sopranos", "The Wire"],
      correctAnswer: 1,
      category: "TV Shows",
    ),
    QuizQuestion(
      question:
          "What is the name of the fictional planet in 'Star Wars' where Luke Skywalker grew up?",
      options: ["Tatooine", "Endor", "Hoth", "Dagobah"],
      correctAnswer: 0,
      category: "Movies",
    ),
    QuizQuestion(
      question:
          "Which TV series features the character 'Sheldon Cooper' as a theoretical physicist?",
      options: [
        "The Big Bang Theory",
        "Young Sheldon",
        "Silicon Valley",
        "Community",
      ],
      correctAnswer: 0,
      category: "TV Shows",
    ),
  ];

  // Bollywood & Indian Cinema Questions
  final List<QuizQuestion> _bollywoodQuestions = [
    QuizQuestion(
      question: "Who directed the movie 'Dangal'?",
      options: [
        "Rajkumar Hirani",
        "Nitesh Tiwari",
        "Aamir Khan",
        "Anurag Kashyap",
      ],
      correctAnswer: 1,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Which movie features the song 'Chaiyya Chaiyya'?",
      options: ["Dil Se", "Taal", "Lagaan", "Swades"],
      correctAnswer: 0,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Who played the role of 'Munna Bhai' in the Munna Bhai series?",
      options: ["Aamir Khan", "Shah Rukh Khan", "Sanjay Dutt", "Salman Khan"],
      correctAnswer: 2,
      category: "Bollywood",
    ),
    QuizQuestion(
      question:
          "Which movie won the National Film Award for Best Feature Film in 2019?",
      options: [
        "Gully Boy",
        "Uri: The Surgical Strike",
        "Article 15",
        "The Tashkent Files",
      ],
      correctAnswer: 1,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Who composed the music for '3 Idiots'?",
      options: [
        "A.R. Rahman",
        "Shankar-Ehsaan-Loy",
        "Pritam",
        "Vishal-Shekhar",
      ],
      correctAnswer: 1,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Which TV series is based on the life of 'Scam 1992'?",
      options: ["The Family Man", "Scam 1992", "Sacred Games", "Mirzapur"],
      correctAnswer: 1,
      category: "Indian TV",
    ),
    QuizQuestion(
      question: "Who directed 'Lagaan'?",
      options: [
        "Ashutosh Gowariker",
        "Rajkumar Hirani",
        "Sanjay Leela Bhansali",
        "Karan Johar",
      ],
      correctAnswer: 0,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Which movie features the character 'PK'?",
      options: ["3 Idiots", "PK", "Dangal", "Secret Superstar"],
      correctAnswer: 1,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Who played the role of 'Gangubai' in 'Gangubai Kathiawadi'?",
      options: [
        "Deepika Padukone",
        "Alia Bhatt",
        "Priyanka Chopra",
        "Kangana Ranaut",
      ],
      correctAnswer: 1,
      category: "Bollywood",
    ),
    QuizQuestion(
      question:
          "Which TV series features 'Srikant Tiwari' as the main character?",
      options: ["The Family Man", "Sacred Games", "Mirzapur", "Scam 1992"],
      correctAnswer: 0,
      category: "Indian TV",
    ),
    QuizQuestion(
      question: "Who directed 'Gully Boy'?",
      options: ["Zoya Akhtar", "Anurag Kashyap", "Imtiaz Ali", "Kabir Khan"],
      correctAnswer: 0,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Which movie features the song 'Jai Ho'?",
      options: ["My Name is Khan", "Slumdog Millionaire", "Dil Se", "Lagaan"],
      correctAnswer: 1,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Who played the role of 'Sultan' in the movie 'Sultan'?",
      options: ["Aamir Khan", "Salman Khan", "Shah Rukh Khan", "Akshay Kumar"],
      correctAnswer: 1,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Which TV series is set in the fictional town of 'Mirzapur'?",
      options: ["Sacred Games", "Mirzapur", "The Family Man", "Scam 1992"],
      correctAnswer: 1,
      category: "Indian TV",
    ),
    QuizQuestion(
      question: "Who composed the music for 'Rockstar'?",
      options: [
        "A.R. Rahman",
        "Pritam",
        "Vishal-Shekhar",
        "Shankar-Ehsaan-Loy",
      ],
      correctAnswer: 0,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Which movie features 'Ranbir Kapoor' as 'Jordan'?",
      options: ["Yeh Jawaani Hai Deewani", "Rockstar", "Barfi", "Tamasha"],
      correctAnswer: 1,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Who directed 'Queen'?",
      options: ["Zoya Akhtar", "Vikas Bahl", "Anurag Kashyap", "Imtiaz Ali"],
      correctAnswer: 1,
      category: "Bollywood",
    ),
    QuizQuestion(
      question:
          "Which TV series features 'Sartaj Singh' as the main character?",
      options: ["Sacred Games", "The Family Man", "Mirzapur", "Scam 1992"],
      correctAnswer: 0,
      category: "Indian TV",
    ),
    QuizQuestion(
      question: "Who played the role of 'Bajirao' in 'Bajirao Mastani'?",
      options: ["Shah Rukh Khan", "Ranveer Singh", "Aamir Khan", "Salman Khan"],
      correctAnswer: 1,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Which movie features the song 'Tum Hi Ho'?",
      options: [
        "Aashiqui 2",
        "Ek Villain",
        "Humpty Sharma Ki Dulhania",
        "2 States",
      ],
      correctAnswer: 0,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Who directed 'Andhadhun'?",
      options: [
        "Sriram Raghavan",
        "Anurag Kashyap",
        "Vishal Bhardwaj",
        "Tigmanshu Dhulia",
      ],
      correctAnswer: 0,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Which TV series features 'Ganesh Gaitonde' as a gangster?",
      options: ["Sacred Games", "Mirzapur", "The Family Man", "Scam 1992"],
      correctAnswer: 0,
      category: "Indian TV",
    ),
    QuizQuestion(
      question: "Who played the role of 'Padmavati' in 'Padmaavat'?",
      options: [
        "Deepika Padukone",
        "Priyanka Chopra",
        "Kangana Ranaut",
        "Alia Bhatt",
      ],
      correctAnswer: 0,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Which movie features the song 'Gerua'?",
      options: ["Dilwale", "Chennai Express", "Happy New Year", "Raees"],
      correctAnswer: 0,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Who composed the music for 'Dilwale Dulhania Le Jayenge'?",
      options: ["A.R. Rahman", "Jatin-Lalit", "Pritam", "Vishal-Shekhar"],
      correctAnswer: 1,
      category: "Bollywood",
    ),
    QuizQuestion(
      question:
          "Which TV series features 'Kaleen Bhaiya' as the main antagonist?",
      options: ["Sacred Games", "Mirzapur", "The Family Man", "Scam 1992"],
      correctAnswer: 1,
      category: "Indian TV",
    ),
    QuizQuestion(
      question: "Who directed 'Zindagi Na Milegi Dobara'?",
      options: ["Zoya Akhtar", "Imtiaz Ali", "Anurag Kashyap", "Kabir Khan"],
      correctAnswer: 0,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Which movie features 'Aamir Khan' as 'Mahavir Singh Phogat'?",
      options: ["Dangal", "PK", "3 Idiots", "Secret Superstar"],
      correctAnswer: 0,
      category: "Bollywood",
    ),
    QuizQuestion(
      question: "Who played the role of 'Munna' in 'Mirzapur'?",
      options: [
        "Ali Fazal",
        "Vikrant Massey",
        "Divyendu Sharma",
        "Pankaj Tripathi",
      ],
      correctAnswer: 2,
      category: "Indian TV",
    ),
    QuizQuestion(
      question: "Which movie features the song 'Senorita'?",
      options: [
        "Zindagi Na Milegi Dobara",
        "Dil Chahta Hai",
        "Rock On!!",
        "Wake Up Sid",
      ],
      correctAnswer: 0,
      category: "Bollywood",
    ),
  ];

  // Hollywood Blockbusters Questions
  final List<QuizQuestion> _hollywoodQuestions = [
    QuizQuestion(
      question: "Which movie features 'Tony Stark' as Iron Man?",
      options: ["Iron Man", "The Avengers", "Captain America", "Thor"],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who directed 'The Dark Knight'?",
      options: [
        "Christopher Nolan",
        "Zack Snyder",
        "Joss Whedon",
        "Russo Brothers",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features the character 'Jack Dawson'?",
      options: ["Avatar", "Titanic", "Inception", "Interstellar"],
      correctAnswer: 1,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who played 'Captain America' in the MCU?",
      options: [
        "Chris Evans",
        "Chris Hemsworth",
        "Robert Downey Jr.",
        "Mark Ruffalo",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features the phrase 'May the Force be with you'?",
      options: [
        "Star Trek",
        "Star Wars",
        "Guardians of the Galaxy",
        "The Matrix",
      ],
      correctAnswer: 1,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who directed 'Avatar'?",
      options: [
        "Steven Spielberg",
        "James Cameron",
        "Christopher Nolan",
        "Peter Jackson",
      ],
      correctAnswer: 1,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features 'Neo' as the main character?",
      options: ["The Matrix", "Inception", "Interstellar", "Blade Runner"],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who played 'Thor' in the MCU?",
      options: [
        "Chris Evans",
        "Chris Hemsworth",
        "Tom Hiddleston",
        "Anthony Hopkins",
      ],
      correctAnswer: 1,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features the character 'Forrest Gump'?",
      options: [
        "The Shawshank Redemption",
        "Forrest Gump",
        "Pulp Fiction",
        "Goodfellas",
      ],
      correctAnswer: 1,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who directed 'Jurassic Park'?",
      options: [
        "Steven Spielberg",
        "George Lucas",
        "James Cameron",
        "Peter Jackson",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features 'Luke Skywalker' as the main character?",
      options: [
        "Star Trek",
        "Star Wars",
        "Guardians of the Galaxy",
        "The Matrix",
      ],
      correctAnswer: 1,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who played 'Spider-Man' in the MCU?",
      options: [
        "Andrew Garfield",
        "Tobey Maguire",
        "Tom Holland",
        "Jake Gyllenhaal",
      ],
      correctAnswer: 2,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features the character 'Indiana Jones'?",
      options: [
        "Indiana Jones",
        "National Treasure",
        "The Mummy",
        "Tomb Raider",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who directed 'The Lord of the Rings' trilogy?",
      options: [
        "Steven Spielberg",
        "Peter Jackson",
        "Christopher Nolan",
        "James Cameron",
      ],
      correctAnswer: 1,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features 'Marty McFly' as the main character?",
      options: [
        "Back to the Future",
        "The Terminator",
        "Blade Runner",
        "Total Recall",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who played 'Black Widow' in the MCU?",
      options: [
        "Scarlett Johansson",
        "Elizabeth Olsen",
        "Brie Larson",
        "Zoe Saldana",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features the character 'E.T.'?",
      options: [
        "E.T. the Extra-Terrestrial",
        "Close Encounters",
        "Alien",
        "Predator",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who directed 'Terminator 2: Judgment Day'?",
      options: [
        "James Cameron",
        "Steven Spielberg",
        "Christopher Nolan",
        "Peter Jackson",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features 'John McClane' as the main character?",
      options: ["Die Hard", "Lethal Weapon", "Rambo", "Commando"],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who played 'Wonder Woman' in the DCEU?",
      options: ["Gal Gadot", "Margot Robbie", "Amy Adams", "Diane Lane"],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features the character 'Rocky Balboa'?",
      options: ["Rocky", "Rambo", "The Expendables", "Creed"],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who directed 'Jaws'?",
      options: [
        "Steven Spielberg",
        "George Lucas",
        "James Cameron",
        "Peter Jackson",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features 'Ellen Ripley' as the main character?",
      options: ["Alien", "Predator", "Terminator", "Blade Runner"],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who played 'Superman' in 'Man of Steel'?",
      options: ["Henry Cavill", "Brandon Routh", "Tom Welling", "Dean Cain"],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features the character 'James Bond'?",
      options: ["Mission: Impossible", "James Bond", "Bourne", "Kingsman"],
      correctAnswer: 1,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who directed 'The Godfather'?",
      options: [
        "Martin Scorsese",
        "Francis Ford Coppola",
        "Steven Spielberg",
        "Quentin Tarantino",
      ],
      correctAnswer: 1,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features 'Maverick' as the main character?",
      options: [
        "Top Gun",
        "Days of Thunder",
        "Mission: Impossible",
        "Jack Reacher",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who played 'Batman' in 'The Dark Knight'?",
      options: [
        "Christian Bale",
        "Ben Affleck",
        "Michael Keaton",
        "Val Kilmer",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Which movie features the character 'Hannibal Lecter'?",
      options: [
        "The Silence of the Lambs",
        "Hannibal",
        "Red Dragon",
        "Manhunter",
      ],
      correctAnswer: 0,
      category: "Hollywood",
    ),
    QuizQuestion(
      question: "Who directed 'Pulp Fiction'?",
      options: [
        "Martin Scorsese",
        "Quentin Tarantino",
        "Steven Spielberg",
        "Christopher Nolan",
      ],
      correctAnswer: 1,
      category: "Hollywood",
    ),
  ];

  // Anime & Animation Questions
  final List<QuizQuestion> _animeQuestions = [
    QuizQuestion(
      question: "Which anime features 'Naruto Uzumaki' as the main character?",
      options: ["One Piece", "Naruto", "Dragon Ball", "Bleach"],
      correctAnswer: 1,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who is the main character in 'Dragon Ball Z'?",
      options: ["Vegeta", "Goku", "Piccolo", "Krillin"],
      correctAnswer: 1,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Monkey D. Luffy' as the main character?",
      options: ["One Piece", "Naruto", "Dragon Ball", "Bleach"],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who directed 'Spirited Away'?",
      options: [
        "Hayao Miyazaki",
        "Isao Takahata",
        "Mamoru Hosoda",
        "Makoto Shinkai",
      ],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Ichigo Kurosaki' as the main character?",
      options: ["One Piece", "Naruto", "Dragon Ball", "Bleach"],
      correctAnswer: 3,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who is the main character in 'Attack on Titan'?",
      options: ["Levi", "Eren Yeager", "Mikasa", "Armin"],
      correctAnswer: 1,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Light Yagami' as the main character?",
      options: ["Death Note", "Code Geass", "Psycho-Pass", "Monster"],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who directed 'My Neighbor Totoro'?",
      options: [
        "Hayao Miyazaki",
        "Isao Takahata",
        "Mamoru Hosoda",
        "Makoto Shinkai",
      ],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Edward Elric' as the main character?",
      options: ["Fullmetal Alchemist", "Naruto", "One Piece", "Dragon Ball"],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who is the main character in 'Demon Slayer'?",
      options: ["Zenitsu", "Tanjiro Kamado", "Inosuke", "Nezuko"],
      correctAnswer: 1,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Gon Freecss' as the main character?",
      options: ["Hunter x Hunter", "Naruto", "One Piece", "Dragon Ball"],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who directed 'Your Name'?",
      options: [
        "Hayao Miyazaki",
        "Isao Takahata",
        "Mamoru Hosoda",
        "Makoto Shinkai",
      ],
      correctAnswer: 3,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Saitama' as the main character?",
      options: ["One Punch Man", "Mob Psycho 100", "Dragon Ball", "Naruto"],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who is the main character in 'Tokyo Ghoul'?",
      options: ["Touka", "Kaneki Ken", "Hide", "Rize"],
      correctAnswer: 1,
      category: "Anime",
    ),
    QuizQuestion(
      question:
          "Which anime features 'Lelouch vi Britannia' as the main character?",
      options: ["Death Note", "Code Geass", "Psycho-Pass", "Monster"],
      correctAnswer: 1,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who directed 'Princess Mononoke'?",
      options: [
        "Hayao Miyazaki",
        "Isao Takahata",
        "Mamoru Hosoda",
        "Makoto Shinkai",
      ],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Kirito' as the main character?",
      options: [
        "Sword Art Online",
        "Log Horizon",
        "Overlord",
        "No Game No Life",
      ],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who is the main character in 'One Piece'?",
      options: ["Zoro", "Monkey D. Luffy", "Sanji", "Nami"],
      correctAnswer: 1,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Deku' as the main character?",
      options: ["My Hero Academia", "Naruto", "One Piece", "Dragon Ball"],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who directed 'Howl's Moving Castle'?",
      options: [
        "Hayao Miyazaki",
        "Isao Takahata",
        "Mamoru Hosoda",
        "Makoto Shinkai",
      ],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Meliodas' as the main character?",
      options: [
        "The Seven Deadly Sins",
        "Fairy Tail",
        "Black Clover",
        "Fire Force",
      ],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who is the main character in 'Dragon Ball'?",
      options: ["Vegeta", "Goku", "Piccolo", "Krillin"],
      correctAnswer: 1,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Kakashi Hatake' as a teacher?",
      options: ["One Piece", "Naruto", "Dragon Ball", "Bleach"],
      correctAnswer: 1,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who directed 'Castle in the Sky'?",
      options: [
        "Hayao Miyazaki",
        "Isao Takahata",
        "Mamoru Hosoda",
        "Makoto Shinkai",
      ],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Natsu Dragneel' as the main character?",
      options: ["Fairy Tail", "One Piece", "Naruto", "Dragon Ball"],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who is the main character in 'Bleach'?",
      options: ["Rukia", "Ichigo Kurosaki", "Orihime", "Uryu"],
      correctAnswer: 1,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'All Might' as a teacher?",
      options: ["My Hero Academia", "Naruto", "One Piece", "Dragon Ball"],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who directed 'Kiki's Delivery Service'?",
      options: [
        "Hayao Miyazaki",
        "Isao Takahata",
        "Mamoru Hosoda",
        "Makoto Shinkai",
      ],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Which anime features 'Roronoa Zoro' as a swordsman?",
      options: ["One Piece", "Naruto", "Dragon Ball", "Bleach"],
      correctAnswer: 0,
      category: "Anime",
    ),
    QuizQuestion(
      question: "Who is the main character in 'Demon Slayer'?",
      options: ["Zenitsu", "Tanjiro Kamado", "Inosuke", "Nezuko"],
      correctAnswer: 1,
      category: "Anime",
    ),
  ];

  List<QuizQuestion> get _questions {
    switch (_selectedCategory) {
      case "Movies & TV Shows":
        return _movieTvQuestions;
      case "Bollywood & Indian Cinema":
        return _bollywoodQuestions;
      case "Hollywood Blockbusters":
        return _hollywoodQuestions;
      case "Anime & Animation":
        return _animeQuestions;
      default:
        return _movieTvQuestions;
    }
  }

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = answerIndex;
      _isAnswered = true;
    });

    HapticFeedback.lightImpact();

    if (answerIndex == _questions[_currentQuestionIndex].correctAnswer) {
      _score++;
    }

    _progressController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _nextQuestion();
      });
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      if (_currentQuestionIndex % 3 == 0) {
        AdManager().showInterstitialAd();
      }
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
        _showResult = false;
      });
      _progressController.reset();
      _fadeController.reset();
      _fadeController.forward();
    } else {
      _showFinalResult();
    }
  }

  void _showFinalResult() {
    setState(() {
      _showResult = true;
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _isAnswered = false;
      _showResult = false;
      _showCategorySelection = true;
      _selectedCategory = "";
    });
    _progressController.reset();
    _fadeController.reset();
    _fadeController.forward();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _showCategorySelection = false;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _isAnswered = false;
      _showResult = false;
    });
    _progressController.reset();
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return _buildResultScreen();
    }

    if (_showCategorySelection) {
      return _buildCategorySelectionScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              Expanded(child: _buildQuestionCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelectionScreen() {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.deepPurple.withOpacity(0.1),
                              Colors.deepPurpleAccent.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.quiz,
                                color: Colors.deepPurple,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Choose Your Quiz Category',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select a category to start your quiz',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Category Options
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                          children: [
                            _buildCategoryCard(
                              "Movies & TV Shows",
                              Icons.movie,
                              Colors.blue,
                              "Test your knowledge of popular movies and TV series",
                            ),
                            _buildCategoryCard(
                              "Bollywood & Indian Cinema",
                              Icons.theater_comedy,
                              Colors.orange,
                              "Questions about Bollywood movies and Indian TV shows",
                            ),
                            _buildCategoryCard(
                              "Hollywood Blockbusters",
                              Icons.star,
                              Colors.red,
                              "Classic and modern Hollywood blockbuster movies",
                            ),
                            _buildCategoryCard(
                              "Anime & Animation",
                              Icons.animation,
                              Colors.purple,
                              "Anime series and animated movies knowledge",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const WorkingNativeAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectCategory(title),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: Colors.black45, fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
            ),
            child: Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _questions[_currentQuestionIndex].category,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${((_currentQuestionIndex + 1) / _questions.length * 100).round()}%',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(3),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_currentQuestionIndex + 1) / _questions.length,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = _questions[_currentQuestionIndex];

    return Container(
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.withOpacity(0.1),
                    Colors.deepPurpleAccent.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.quiz,
                      color: Colors.deepPurple,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    question.question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: question.options.asMap().entries.map((entry) {
                int index = entry.key;
                String option = entry.value;
                bool isCorrect = index == question.correctAnswer;
                bool isSelected = _selectedAnswer == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectAnswer(index),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _isAnswered
                                ? isSelected
                                      ? isCorrect
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2)
                                      : isCorrect
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey[800]?.withOpacity(0.5)
                                : Colors.grey[800]?.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isAnswered
                                  ? isSelected
                                        ? isCorrect
                                              ? Colors.green
                                              : Colors.red
                                        : isCorrect
                                        ? Colors.green.withOpacity(0.5)
                                        : Colors.grey[600]!
                                  : Colors.grey[600]!,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _isAnswered
                                      ? isSelected
                                            ? isCorrect
                                                  ? Colors.green
                                                  : Colors.red
                                            : isCorrect
                                            ? Colors.green.withOpacity(0.3)
                                            : Colors.grey[700]
                                      : Colors.grey[700],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: _isAnswered && isSelected
                                      ? Icon(
                                          isCorrect ? Icons.check : Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : _isAnswered && isCorrect
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : Text(
                                          String.fromCharCode(65 + index),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: _isAnswered
                                        ? isSelected
                                              ? isCorrect
                                                    ? Colors.green[300]
                                                    : Colors.red[300]
                                              : isCorrect
                                              ? Colors.green[300]
                                              : Colors.white
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    double percentage = (_score / _questions.length) * 100;
    String resultText;
    Color resultColor;
    IconData resultIcon;

    if (percentage >= 80) {
      resultText = "Excellent!";
      resultColor = Colors.green;
      resultIcon = Icons.emoji_events;
    } else if (percentage >= 60) {
      resultText = "Good Job!";
      resultColor = Colors.blue;
      resultIcon = Icons.thumb_up;
    } else if (percentage >= 40) {
      resultText = "Not Bad!";
      resultColor = Colors.orange;
      resultIcon = Icons.sentiment_neutral;
    } else {
      resultText = "Keep Trying!";
      resultColor = Colors.red;
      resultIcon = Icons.sentiment_dissatisfied;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [resultColor, resultColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: resultColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(resultIcon, size: 60, color: Colors.white),
              ),

              const SizedBox(height: 30),

              // Result Text
              Text(
                resultText,
                style: TextStyle(
                  color: resultColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Score
              Text(
                'You scored $_score out of ${_questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // Percentage
              Text(
                '${percentage.round()}%',
                style: TextStyle(
                  color: resultColor,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // Performance Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[800]?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[600]!, width: 1),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.analytics, color: Colors.white, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      _getPerformanceMessage(percentage),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _restartQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPerformanceMessage(double percentage) {
    if (percentage >= 90) {
      return "Outstanding! You're a true movie and TV show expert!";
    } else if (percentage >= 80) {
      return "Excellent work! You have great knowledge of entertainment!";
    } else if (percentage >= 70) {
      return "Well done! You know your movies and shows well!";
    } else if (percentage >= 60) {
      return "Good job! Keep watching and learning!";
    } else if (percentage >= 50) {
      return "Not bad! There's always room to improve!";
    } else {
      return "Keep exploring movies and TV shows to improve your knowledge!";
    }
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String category;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
  });
}
