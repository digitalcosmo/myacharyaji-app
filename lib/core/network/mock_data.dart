/// Mock data provider — returns sample data matching the API shape.
class MockData {
  MockData._();

  static Map<String, dynamic> get consultantDetails => {
    'consultantName': 'Pandit Raghunath Sharma',
    'consultantContact': '+91 98765 43210',
    'consultantEmail': 'pandit.sharma@example.com',
    'address': 'Jyotish Bhawan, Varanasi',
    'photo': '',
    'acharyaCode': 'ACH001',
  };

  static Map<String, dynamic> get profileDetails => {
    'name': 'Arjun Patel',
    'gender': 'Male',
    'dob': '15 March 1992',
    'tob': '05:30 AM',
    'pob': 'Mumbai, Maharashtra',
    'mobile': '+91 91234 56789',
    'email': 'arjun@example.com',
    'photo': '',
  };

  static Map<String, dynamic> get appDetails => {
    'appName': 'MyAcharyaji',
    'version': '2.0.0',
    'about': 'MyAcharyaji is your personal astrology companion powered by CosmoKundli CVPT methodology. Get daily, weekly and monthly predictions based on your birth chart.',
  };

  static Map<String, List<Map<String, dynamic>>> get reportList => {
    'reports': [
      {
        'reportId': 'RPT001',
        'reportName': 'CK Blueprint',
        'reportType': 'Blueprint',
        'personName': 'Arjun Patel',
        'language': 'English',
        'generatedDate': '2025-06-01',
        'status': 'ready',
      },
      {
        'reportId': 'RPT002',
        'reportName': 'CK Planner — Jul 2025',
        'reportType': 'Planner',
        'personName': 'Arjun Patel',
        'language': 'English',
        'generatedDate': '2025-07-01',
        'dateRange': '1 Jul – 31 Jul 2025',
        'status': 'ready',
      },
      {
        'reportId': 'RPT003',
        'reportName': 'CK Planner Max — Jul 2025',
        'reportType': 'Planner Max',
        'personName': 'Arjun Patel',
        'language': 'English',
        'generatedDate': '2025-07-01',
        'dateRange': '1 Jul – 31 Jul 2025',
        'status': 'ready',
      },
      {
        'reportId': 'RPT004',
        'reportName': 'CK Intensity — Jul 2025',
        'reportType': 'Intensity',
        'personName': 'Arjun Patel',
        'language': 'Hindi',
        'generatedDate': '2025-07-01',
        'dateRange': '1 Jul – 31 Jul 2025',
        'status': 'ready',
      },
      {
        'reportId': 'RPT005',
        'reportName': 'CK Vibes — Jul 2025',
        'reportType': 'Vibes',
        'personName': 'Arjun Patel',
        'language': 'English',
        'generatedDate': '2025-07-01',
        'dateRange': '1 Jul – 31 Jul 2025',
        'status': 'ready',
      },
    ],
  };

  static Map<String, dynamic> get dailyPrediction => {
    'date': '7 July 2025 — Monday',
    'overallScore': 72,
    'dimensions': [
      {'key': 'career',  'label': 'Career',  'score': 78},
      {'key': 'finance', 'label': 'Finance', 'score': 55},
      {'key': 'health',  'label': 'Health',  'score': 88},
      {'key': 'social',  'label': 'Social',  'score': 44},
      {'key': 'love',    'label': 'Love',    'score': 66},
    ],
    'rashi': {
      'name': 'Mithun',
      'englishName': 'Gemini',
      'prediction': 'Communication flows well today. A good day for negotiations and meetings. Watch your words in the afternoon.',
    },
    'generalPrediction': 'Today favours steady progress. Focus on tasks that need patience rather than speed. Evening brings a pleasant surprise.',
  };

  static Map<String, dynamic> get weeklyData => {
    'weekRange': '7 Jul – 13 Jul 2025',
    'summary': 'A balanced week ahead. Mid-week brings strong career opportunities while the weekend favours personal connections.',
    'days': [
      {'day': 'Mon', 'score': 72},
      {'day': 'Tue', 'score': 58},
      {'day': 'Wed', 'score': 81},
      {'day': 'Thu', 'score': 45},
      {'day': 'Fri', 'score': 66},
      {'day': 'Sat', 'score': 88},
      {'day': 'Sun', 'score': 74},
    ],
  };

  static Map<String, dynamic> get monthlyData => {
    'month': 'July 2025',
    'overallScore': 68,
    'dimensions': [
      {'key': 'career',  'label': 'Career',  'score': 71},
      {'key': 'finance', 'label': 'Finance', 'score': 62},
      {'key': 'health',  'label': 'Health',  'score': 79},
      {'key': 'social',  'label': 'Social',  'score': 54},
      {'key': 'love',    'label': 'Love',    'score': 69},
    ],
    'summary': 'July is a month of consolidation. Career growth is steady with a strong push in the second week. Finances stabilise after mid-month. Health remains robust — maintain your routine.',
  };

  static List<Map<String, dynamic>> get guidelines => [
    {'title': 'Understanding Zones', 'description': 'Zones range from Optimal (86-100) to Critical (0-15). They guide your daily planning — take bold action in Optimal, be cautious in Critical.'},
    {'title': 'The 5D Dimensions', 'description': 'Career, Finance, Health, Social and Love — five dimensions that shape your day. Each is scored independently.'},
    {'title': 'Reading Your Reports', 'description': 'Reports combine planetary positions with the CVPT algorithm to give you actionable insights for each day, week and month.'},
  ];

  static List<Map<String, dynamic>> get faqs => [
    {'question': 'What is CosmoKundli?', 'answer': 'CosmoKundli is a Vedic astrology system that uses the CVPT methodology for personalised predictions.'},
    {'question': 'How are predictions generated?', 'answer': 'Using your birth chart combined with current planetary transits and the CVPT algorithm.'},
    {'question': 'What do the zones mean?', 'answer': 'Zones range from Optimal (best) to Critical (most challenging), guiding your daily planning.'},
  ];
}
