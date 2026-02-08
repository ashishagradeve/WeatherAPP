# WeatherApp

A SwiftUI-based weather application that fetches current conditions and a 5-day forecast, with offline resilience using SwiftData and a clean MVVM architecture.

## Features
- Current weather with themed UI based on conditions (sunny, cloudy, rainy)
- 5-day forecast summarized from 3-hour intervals
- Pull-to-refresh with graceful offline fallback and last-updated toast
- Location-based lookup with Core Location
- Persistence with SwiftData (saved locations, current weather, forecasts)
- Show offline data for saved location in case internet is not working with a toast of last updated on
- Handle different error from Location Manager and Network issue
- Unit tests using Swift Testing framework

## Architecture
The app follows a modular MVVM architecture with a clear separation of concerns:

- View (SwiftUI):
  - `WeatherContentView` renders the header, current conditions, and forecast list. It reacts to `SaveLocation` updates from the view model.
- ViewModel (Combine + async services):
  - `WeatherViewModel` orchestrates fetching current weather and forecast in parallel, handles errors, manages offline fallback, and exposes state via `@Published` properties.
- Model (Codable + SwiftData):
  - Network DTOs: `CurrentWeatherResponse`, `ForecastResponse`, `ForecastItem`, `Coordinates`, `City`, `WeatherType`.
  - Persistence models: `SaveLocation`, `CurrentWeatherModel`, `ForecastItemModel` (SwiftData `@Model` types). Relationships use `.cascade` delete rules for consistency.
- Services:
  - `WeatherAPIServiceProtocol` and its implementation handle network calls for current weather and forecast.
  - `LocationServiceProtocol` abstracts Core Location and exposes a `locationPublisher` for reactive location updates.

### Data Flow
1. The view triggers `WeatherViewModel.retry()` or `fetchWeather(for:)`.
2. The view model zips two publishers: `getCurrentWeather` and `getForecast`.
3. On success, it updates SwiftData via `SaveLocation.updateSaveLocation(...)` and also sets the in-memory `saveLocation` for immediate UI updates.
4. On failure, it shows a toast with the last updated time if cached data exists; otherwise, it surfaces an error message.

### Decoding/Encoding Strategy
- `CurrentWeatherResponse` and `ForecastItem` flatten nested JSON:
  - Read from `main.temp`, `main.temp_min`, `main.temp_max` into root properties (`temp`, `tempMin`, `tempMax`).
  - Extract the first `weather[0].main` and map to `WeatherType`. If the array is empty, default to `.cloudy`.
- Encoders recreate the original nested structure to ensure symmetry, enabling encode/decode round-trips used in tests.

### Persistence Model
- `SaveLocation` is the aggregate root for a location, containing:
  - Unique `id`, `name`, `coord`, `country`
  - One-to-many `forecasts: [ForecastItemModel]`
  - One-to-one `currentWeather: CurrentWeatherModel`
  - Convenience computed values like `sortedForecasts` and `lastupdated`
- `updateSaveLocation(...)` updates or inserts the aggregate and persists via `ModelContext`.

## Testing
- Uses the Swift Testing framework (`import Testing`).
- `CurrentWeatherResponseTests` cover:
  - Decoding valid JSON with nested `main` and `weather` array
  - Fallback to `.cloudy` when `weather` is empty
  - Encoding symmetry (round-trip encode/decode)
  - Failure when required keys are missing
- View model and services provide mock helpers for preview and unit testing (`MockWeatherAPIService`, `MockLocationService`).

## UI Overview
- `WeatherContentView`:
  - Themed background color and image based on `weatherType`
  - Header with large temperature and condition name
  - Current day row and a list of forecast rows
  - `.refreshable` to trigger `viewModel.retry()`

## Setup & Running
1. Open the project in Xcode 15+.
2. Ensure the bundle capabilities include Location and necessary network permissions (ATS if required).
3. Build and run on a device or simulator with location.
4. Pull to refresh to fetch current location weather.

### Configuration
- Weather API keys and base URLs should be configured in the `WeatherAPIService` implementation (not included here). Consider using build settings or a configuration plist for secrets.

## License
MIT License unless otherwise specified.
