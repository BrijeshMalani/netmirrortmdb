# NetMirror 

A Flutter app that integrates with The Movie Database () API to browse movies and TV shows.

## Features

- **Home Screen**: Displays trending movies and TV shows
- **Movies Screen**: Browse movies by categories (Trending, Popular, Top Rated, Favorites)
- **TV Shows Screen**: Browse TV shows by categories (Trending, Popular, Top Rated, Airing Today, Favorites)
- **Search Screen**: Search for movies and TV shows
- **Favorites & Watchlist**: Add/remove items from favorites and watchlist
- **Beautiful UI**: Modern Material Design with smooth animations

## API Integration

The app integrates with  API and includes all the endpoints you provided:

### Account APIs
- Get account details
- Add/remove favorites
- Add/remove from watchlist
- Get favorite movies/TV shows
- Get rated content
- Get watchlist content

### Content APIs
- Discover movies and TV shows
- Search functionality
- Trending content
- Popular and top-rated content
- Genre lists
- Certifications

### TV Show APIs
- TV series details
- Seasons and episodes
- Credits and cast
- Images and videos
- Recommendations and similar shows

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Dependencies

- `http`: For API calls
- `provider`: For state management
- `cached_network_image`: For image caching
- `shimmer`: For loading animations
- `flutter_staggered_grid_view`: For grid layouts
- `intl`: For internationalization

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── movie.dart
│   ├── tv_show.dart
│   ├── person.dart
│   ├── genre.dart
│   └── api_response.dart
├── providers/                # State management
│   ├── movie_provider.dart
│   └── tv_provider.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── movies_screen.dart
│   ├── tv_screen.dart
│   └── search_screen.dart
├── services/                 # API services
│   └── _api_service.dart
└── widgets/                  # Reusable widgets
    ├── movie_card.dart
    ├── tv_card.dart
    └── loading_shimmer.dart
```

## API Configuration

The app uses your provided  API credentials:
- API Key: `9ec474f68acd812a132e3cd089fbb4ca`
- Bearer Token: Included in the service
- Account ID: `22358118`

## Features Implemented

✅ All  API endpoints integrated
✅ Beautiful Material Design UI
✅ State management with Provider
✅ Image caching and loading states
✅ Search functionality
✅ Favorites and watchlist management
✅ Responsive grid layouts
✅ Pull-to-refresh functionality
✅ Error handling

The app is ready to use and includes all the API endpoints you specified. You can now run it and start browsing movies and TV shows!