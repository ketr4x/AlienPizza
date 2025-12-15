# AlienPizza
[![Flutter](https://github.com/ketr4x/AlienPizza/actions/workflows/flutter.yml/badge.svg)](https://github.com/ketr4x/AlienPizza/actions/workflows/flutter.yml)
[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD%202--Clause-blue.svg)](LICENSE)

An AI-powered pizza compatibility checker that evaluates pizza combinations for humans, giant raccoons, and friendly aliens. Select from randomly generated toppings and get AI-powered compatibility ratings with creative backstories.

## Features
- Random AI-generated pizza toppings
- AI-powered compatibility evaluation with ratings and backstories
- Cross-platform support (Android, Web, Windows, iOS, macOS, Linux)
- FastAPI REST API backend with OpenAI integration
- Flutter-based UI with material design

## Quick Start
[!TIP] For the best experience, consider using the Android build
### Hosted Version
**Web App**: https://alienpizza.ketrax.ovh/

**Downloads**: https://github.com/ketr4x/AlienPizza/releases/
- `.apk` - Android (Recommended)
- `build_web_*.zip` - Local browser

## Installation
### Prerequisites
- Flutter SDK 3.10.0+ (for app)
- Python 3.12+ (for server)
- OpenAI API key or HackClub AI key

### Server Setup
#### Local Development
1. Clone the repository:
```bash
git clone https://github.com/ketr4x/AlienPizza.git
cd AlienPizza
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Create a `.env` file in the root directory:
```env
API_KEY=your_api_key_here
API_URL=https://api.openai.com/v1
AI_MODEL=gpt-5-mini
PORT=8000
```

4. Run the server:
```bash
# Using uvicorn directly
uvicorn server2.main:app --host 0.0.0.0 --port 8000

# Or using Python
python server2/main.py
```

#### Heroku Deployment
1. Install Heroku CLI
2. Create a Heroku app:
```bash
heroku create your-app-name
```

3. Set environment variables:
```bash
heroku config:set API_KEY=your_api_key
heroku config:set API_URL=https://api.openai.com/v1
heroku config:set AI_MODEL=gpt-5-mini
```

4. Deploy:
```bash
git push heroku main
```

### Flutter App Setup
1. Navigate to the Flutter directory:
```bash
cd flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update the API endpoint in `lib/mainbody.dart` and `lib/page2.dart`:
```dart
// Change this line to your server URL
'https://your-server-url.com/api/toppings'
'https://your-server-url.com/api/evaluate'
```

4. Run the app:
```bash
# For debug mode
flutter run

# For Android
flutter build apk

# For Web
flutter build web
```

## Usage
1. Launch the app
2. View AI-generated topping suggestions
3. Select toppings by checking boxes
4. Use the refresh button for new suggestions
5. Click arrow button to evaluate your pizza
6. View compatibility rating, pizza name, and backstory

## API Configuration
### AI Provider Options
#### OpenAI
- **API URL**: `https://api.openai.com/v1`
- **Get API Key**: https://platform.openai.com/settings/organization/api-keys
- **Recommended Model**: `gpt-5-mini`

#### HackClub AI (Free for under 18)
- **API URL**: `https://ai.hackclub.com/proxy/v1`
- **Get API Key**: https://ai.hackclub.com/dashboard
- **Recommended Model**: `google/gemini-2.5-flash-lite-preview-09-2025`

### Environment Variables
| Variable   | Description              | Example                     |
|------------|--------------------------|-----------------------------|
| `API_KEY`  | Your AI provider API key | `sk-...`                    |
| `API_URL`  | AI API base URL          | `https://api.openai.com/v1` |
| `AI_MODEL` | AI model to use          | `gpt-3.5-turbo`             |

## Technologies
### Frontend
- **Flutter 3.10+** - Cross-platform UI framework
- **Dart** - Programming language
- **HTTP package** - API communication

### Backend
- **FastAPI** - Modern Python web framework
- **Uvicorn** - ASGI server
- **OpenAI API** - AI-powered content generation
- **Pydantic** - Data validation
- **Python-dotenv** - Environment variable management

## Contributing
Contributions are welcome! Feel free to report bugs, suggest features, submit pull requests, or improve documentation.

## License
Licensed under the BSD-2-Clause License. See [LICENSE](LICENSE) for details.

---
[![This project is part of Moonshot, a 4-day hackathon in Florida visiting Kennedy Space Center and Universal Studios!](https://hc-cdn.hel1.your-objectstorage.com/s/v3/35ad2be8c916670f3e1ac63c1df04d76a4b337d1_moonshot.png)](https://moonshot.hack.club/1016)

**This project was made for the [Moonshot](https://moonshot.hack.club/1016) hackathon organized by [HackClub](https://hackclub.com).**