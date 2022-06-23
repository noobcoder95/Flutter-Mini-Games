import 'dart:math';

abstract class TruthOrDareGenerator {
  String getQuestion();
  String getDare();
}

class TruthOrDareLocalGenerator implements TruthOrDareGenerator {
  final Random _random = Random();
  final _questions = [
    "What’s the last lie you told?",
    "What was the most embarrassing thing you’ve ever done on a date?",
    "Have you ever accidentally hit something (or someone!) with your car?",
    "Name someone you’ve pretended to like but actually couldn’t stand.",
    "What’s your most bizarre nickname?",
    "What’s been your most physically painful experience?",
    "What bridges are you glad that you burned?",
    "What’s the craziest thing you’ve done on public transportation?",
    "If you met a genie, what would your three wishes be?",
    "If you could write anyone on Earth in for President of the United States, who would it be and why?",
    "What’s the meanest thing you’ve ever said to someone else?",
    "Who was your worst kiss ever?",
    "What’s one thing you’d do if you knew there no consequences?",
    "What’s the craziest thing you’ve done in front of a mirror?",
    "What’s the meanest thing you’ve ever said about someone else?",
    "What’s something you love to do with your friends that you’d never do in front of your partner?",
    "Who are you most jealous of?",
    "What do your favorite pajamas look like?",
    "Have you ever faked sick to get out of a party?",
    "Who’s the oldest person you’ve dated?",
    "How many selfies do you take a day?",
    "Meatloaf says he’d do anything for love, but he won’t do “that.” What’s your “that?”",
    "How many times a week do you wear the same pants?",
    "Would you date your high school crush today?",
    "Where are you ticklish?",
    "Do you believe in any superstitions? If so, which ones?",
    "What’s one movie you’re embarrassed to admit you enjoy?",
    "What’s your most embarrassing grooming habit?",
    "When’s the last time you apologized? What for?",
    "How do you really feel about the Twilight saga?",
    "Where do most of your embarrassing odors come from?",
    "Have you ever considered cheating on a partner?",
    "Have you ever cheated on a partner?",
    "Boxers or briefs?",
    "Have you ever peed in a pool?",
    "What’s the weirdest place you’ve ever grown hair?",
    "If you were guaranteed to never get caught, who on Earth would you murder?",
    "What’s the cheapest gift you’ve ever gotten for someone else?",
    "What app do you waste the most time on?",
    "What’s the weirdest thing you’ve done on a plane?",
    "Have you ever been nude in public?",
    "How many gossip blogs do you read a day?",
    "What is the youngest age partner you’d date?",
    "Have you ever picked your nose in public?",
    "Have you ever lied about your age?",
    "If you had to delete one app from your phone, which one would it be?",
    "What’s your most embarrassing late night purchase?",
    "What’s the longest you’ve gone without showering?",
    "Have you ever used a fake ID?",
    "Who’s your hall pass?",
    "Be honest: Do you have a favorite child?",
    "Which of your family members annoys you the most and why?",
    "What is your greatest fear in a relationship?",
    "What’s your biggest pet peeve about the person to your left?",
    "What’s the most embarrassing text in your phone right now?",
    "Have you ever seen a dead body?",
    "What celebrity do you think is overrated?",
    "Have you ever lied to your boss?",
    "Have you ever stolen something from work?",
    "What’s the longest you’ve gone without brushing your teeth?",
    "What’s your biggest regret in life?",
    "Who would you hate to see naked?",
    "Describe the weirdest thing you’ve ever done while inebriated.",
    "Have you ever regifted a present?",
    "Would you break up with your partner for \$1 million?",
    "Have you ever had a crush on a coworker?",
    "Do you still have feelings for any of your exes?",
    "What’s the smallest tip you’ve ever left at a restaurant?",
    "Have you ever regretted something you did to get a crush or partner’s attention?",
    "What’s one job you could never do?",
    "Have you ever ghosted a friend?",
    "Have you ever ghosted a partner?",
    "What’s the most scandalous photo in your cloud?",
    "If you switched genders for a day, what would you do?",
    "How many photo editing apps do you have on your phone?",
    "How many pairs of granny panties do you own?",
    "What are your favorite and least favorite of your body parts?",
    "When’s the last time you got dumped?",
    "What’s the most childish thing you still do?",
    "When’s the last time you dumped someone?",
    "If you had to pick someone in this room to be your partner on a game show, who would it be and why?",
    "Would you date someone shorter than you?",
    "Have you ever lied for a friend?",
    "Name one thing you’d change about every person in this room.",
    "When’s the last time you made someone else cry?",
    "What’s the most embarrassing thing you’ve done in front of a crowd?",
    "If you could become invisible, what’s the worst thing you’d do?",
    "After you’ve dropped a piece of food, what’s the longest time you’ve left it on the floor before eating it?",
    "What’s one thing in your life you wish you could change?",
    "If you could date two people at once, would you do it? If so, who?",
    "What’s something that overwhelms you?",
    "What was the greatest day of your life?",
    "What’s one useless skill you’d love to learn anyway?",
    "If I went through your cabinets, what’s the weirdest thing I’d find?",
    "Have you ever farted and blamed it on someone else?",
    "What’s the worst thing you’ve ever done at work?",
    "How many people have you kissed?",
    "What’s your number?",
    "Have you ever gotten mad at a friend for posting an unflattering picture of you?",
    "What’s your most absurd dealbreaker?"
  ];

  final _dares = [
    "Do 100 squats.",
    "Show the most embarrassing photo on your phone.",
    "Give a foot massage to the person on your right.",
    "Say something dirty to the person on your left.",
    "Let the rest of the group DM someone from your Instagram account.",
    "Eat a banana without using your hands.",
    "Twerk for a minute.",
    "Keep your eyes closed until it’s your go again.",
    "Like the first 15 posts on your Facebook newsfeed.",
    "Send a sext to the last person in your phonebook.",
    "Eat a raw onion.",
    "Keep three ice cubes in your mouth until they melt.",
    "Give a lap dance to someone of your choice.",
    "Yell out the first word that comes to your mind.",
    "Show off your orgasm face.",
    "Empty out your wallet/purse and show everyone what’s inside.",
    "Show the last five people you texted and what the messages said.",
    "Try to put your whole fist in your mouth.",
    "Remove four items of clothing.",
    "Eat a spoonful of mustard.",
    "Put 10 different available liquids into a cup and drink it.",
    "Do your best impression of a baby being born.",
    "Try to lick your elbow.",
    "Pretend to be the person to your right for 10 minutes.",
    "Be someone’s pet for the next 5 minutes.",
    "Try to drink a glass water while standing on your hands.",
    "Do your best sexy crawl.",
    "Say two honest things about everyone else in the group.",
    "Put as many snacks into your mouth at once as you can.",
    "Try and make the group laugh as quickly as possible.",
    "Let someone shave part of your body.",
    "Tell everyone an embarrassing story about yourself.",
    "Post the oldest selfie on your phone on Instagram Stories.",
    "For a guy, put on makeup. For a girl, wash off your make up.",
    "Do four cartwheels in row.",
    "Tell the saddest story you know.",
    "Belly dance like your life depended on it.",
    "Curse like sailor for 20 seconds straight.",
    "Howl like a wolf.",
    "Dance without music for one minute.",
    "Pole dance with an imaginary pole.",
    "Let someone else tickle you and try not to laugh.",
    "Serenade the person to your right.",
    "Talk in an accent for the next 3 rounds.",
    "Make every person in the group smile, keep going until everyone has cracked a smiled.",
    "Kiss the person to your left.",
    "Attempt to do a magic trick.",
    "Eat five tablespoons of a condiment.",
    "Attempt to breakdance for one minute.",
    "Let the group give you a new hairstyle.",
    "Do the worm.",
    "Take a shower with your clothes on.",
    "Break two eggs on your head.",
    "Sell a piece of trash to someone in the group using your best salesmanship.",
    "Attempt to walk on your hands for as far as you can.",
    "Imitate a celebrity every time you talk.",
    "Try to juggle 2 or 3 items of the group’s choosing.",
    "Gargle something that shouldn’t be gargled, but won’t hurt you.",
    "Get slapped on the face by the person of your choosing.",
    "Spin an imaginary hula hoop around your waist for the rest of the round.",
    "Seduce a member of the same gender in the group.",
    "Compose a poem on the spot based on something the group comes up with.",
    "Poll dance for 1 minute with an imaginary pole.",
    "Choose someone from the group to give you a spanking.",
    "Post an extremely unflattering picture of yourself to the social media outlet of your choosing.",
    "Hold a funny face for the rest of the round.",
    "Imagine something in your room. Now spell it with your nose and keep spelling it with your nose until someone from the group guesses what you are trying to spell.",
    "After the group chooses one rude word, sing a song and insert that rude word once into every line of the song.",
    "Drag your butt on the carpet like a dog from one end of the room to the other.",
    "Open a bag of snacks or candy using only your mouth, no hands or feet.",
    "Bend at the waist so that you are looking behind you between your legs. Now run backwards until you can tag someone with your butt.",
    "Go to the bathroom, take off your underwear and put it on your head. Wear it on your head for the rest of the game.",
    "Act like whatever animal someone yells out for the next 1 minute.",
    "Eat one teaspoon of the spiciest thing you have in the kitchen.",
    "Transfer an ice cube from your mouth to the person’s mouth on your right.",
    "Call the 3rd contact in your phone and sing them 30 seconds of a song that the group chooses.No talking.",
    "Pretend to be a food. Don’t pretend to eat the food, pretend to be the food. Keep pretending until someone in the group guesses the food you are.",
    "Drop something in the toilet and then reach in to get it.",
    "Find the person whose first name has the same letter as your first name or whoever’s first name’s first letter is closest to yours. Now lick their face.",
    "Sit in a spinning chair and have the group spin you for 30 seconds.",
    "Jump up and down as high as you can go for a full minute.",
    "Let two people give you a wet willy at the same time.",
    "Sing a praise song about a person of the groups choosing.",
    "Depict a human life through interpretive dance.",
    "Dance with no music for 1 minute.",
    "Write something embarrassing somewhere on your body (that can be hidden with clothing) with a permanent marker.",
    "Beg and plead the person to your right not to leave you for that other boy or girl.",
    "Put ice cubes down your pants.",
    "Stick your arm into the trash can past your elbow.",
    "Lick the floor.",
    "Switch clothes with someone of the opposite sex in the group for three rounds.",
    "Let the group pose you in an embarrassing position and take a picture.",
    "Give someone your phone and let them send one text to anyone in your contacts.",
    "Let the group look through your phone for one minute.",
    "Drink a small cup of a concoction that the group makes.",
    "Let the person to your left draw on your face with a pen.",
    "Imitate popular YouTube videos until someone can guess the video you are imitating.",
    "Grab a trash can and make a hoop with your hands above the trash can. Have other members of the group try to shoot trash through your hoop.",
    "Make up a 30-second opera about a person or people in the group and perform it.",
    "Do pushups until you can’t do any more, wait 5 seconds, and then do one more."
  ];

  int? _lastPickedQuestionNumber;

  @override
  String getQuestion() {
    int randomNumber = _random.nextInt(_questions.length);
    while (randomNumber == _lastPickedQuestionNumber) {
      randomNumber = _random.nextInt(_questions.length);
    }
    _lastPickedQuestionNumber = randomNumber;
    return _questions[randomNumber];
  }

  @override
  String getDare() {
    int randomNumber = _random.nextInt(_dares.length);
    while (randomNumber == _lastPickedQuestionNumber) {
      randomNumber = _random.nextInt(_dares.length);
    }
    _lastPickedQuestionNumber = randomNumber;
    return _dares[randomNumber];
  }
}