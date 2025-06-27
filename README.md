# 🦖 Kaiju Defense Force

A browser-based tactical defense game where you command elite squads against giant monsters threatening cities worldwide.

## 🚀 Quick Start

### Prerequisites
- Ruby 2.6+
- Bundler gem

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd KaijuGame
   ```

2. **Install dependencies**
   ```bash
   bundle install --path vendor/bundle
   ```

3. **Set up environment variables**
   ```bash
   # Generate a secure session secret
   ruby -e "require 'securerandom'; puts SecureRandom.hex(32)"

   # Create .env file with the generated secret
   echo "SESSION_SECRET=your_generated_secret_here" > .env
   ```

4. **Start the server**
   ```bash
   bundle exec ruby app.rb
   ```

5. **Open your browser**
   Navigate to `http://localhost:4567`

## 🎮 How to Play

### Mission Briefing
- Review kaiju physical traits, combat stats, and threat level
- Analyze the creature's skin material, weapons, and special characteristics
- Choose to **Accept** or **Reject** the mission

### Squad Selection
- **Casualty Risk Assessment**: Each squad shows estimated risk level
- **Squad Metrics**: Compare offensive, defensive, and leadership capabilities
- **Tactical Notes**: Get recommendations based on threat analysis
- Select your squad and deploy!

### Battle Results
- Watch detailed combat reports unfold
- Track soldier promotions and casualties
- Automatic recruitment replaces fallen heroes
- Continue operations with new missions

## 🔧 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SESSION_SECRET` | 32+ character secret for session encryption | Yes |
| `PORT` | Server port (default: 4567) | No |
| `RACK_ENV` | Environment (development/production) | No |

## 🏗️ Development

The game uses:
- **Backend**: Ruby + Sinatra
- **Frontend**: Vanilla JavaScript + CSS
- **Session Management**: Encrypted cookies
- **Game Logic**: Object-oriented Ruby classes

## 🎯 Features

- **Rich Kaiju Traits**: Physical materials, weapons, and characteristics
- **Tactical Combat**: Squad-based battles with detailed narratives
- **Risk Assessment**: Real-time casualty predictions
- **Soldier Progression**: Experience, levels, and promotions
- **Auto-Recruitment**: Maintain squad strength
- **Responsive UI**: Modern web interface

## 🔒 Security

- Session secrets are environment-based (never hardcoded)
- Sensitive data excluded from repository
- Secure cookie handling

---

*Defend humanity. Command your forces. Save the world.*