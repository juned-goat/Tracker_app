# Tracker Architecture Rules

This repository is a SwiftUI calorie tracker. Every human or AI contributor must read this file before changing code.

## Branching

- `master` is production.
- `development` is the integration branch.
- Feature work starts from `development` using `feature/<name>`.
- Feature branches merge back into `development`; `development` merges into `master` only for deploy-ready code.

## Architecture

- Use Clean MVVM with `App`, `Core`, `Domain`, `Data`, and `Presentation` layers.
- `Domain` owns app business concepts and must not import SwiftUI, SwiftData, Firebase, or other SDKs.
- `Presentation` owns SwiftUI views and ViewModels. ViewModels depend on use cases or protocols, never concrete SDK adapters.
- `Data` owns concrete repository implementations and SDK adapters.
- `Core` owns shared app utilities such as analytics, errors, and dependency helpers.
- Prefer small protocols and value types. Keep abstractions purposeful and easy to test.

## SOLID And Dependency Injection

- Follow SOLID principles at all times.
- Inject dependencies through initializers or SwiftUI environment values.
- Do not introduce global service singletons for app features.
- `AppDependencyContainer` is the composition root. Add new dependencies there when features need them.

## Auth Direction

- V1 login targets Firebase Authentication for email/password and Google sign-in.
- Reserve auth boundaries for Sign in with Apple because App Store review can require an equivalent privacy-focused login option when Google login is offered.
- Keep Firebase types out of `Domain` and `Presentation`.

## Meals And Macros

- Meals and daily progress are local-first.
- SwiftData is the planned persistence adapter, but it must stay behind repository protocols.
- Macro calculations belong in use cases or domain services, not SwiftUI views.

## Analytics And Event Logging

- User interaction events must use the app-owned `EventLogger` interface.
- Events must be typed with stable names and simple properties.
- Do not call Firebase Analytics directly from views or ViewModels.
- Firebase Analytics is the planned default free provider once Firebase is configured.

## Testing

- Add unit tests for use cases, ViewModels, repositories, and event logging behavior whenever logic changes.
- Use the existing Swift Testing target.
- Do not add UI tests unless explicitly requested.
- Tests should use mocks/fakes and must not require Firebase, Google login, network access, or user credentials.

## Dependencies

- Prefer Swift Package Manager.
- Planned Firebase packages: `FirebaseCore`, `FirebaseAuth`, and `FirebaseAnalytics`.
- Google sign-in should follow Firebase's official Apple-platform Google sign-in guidance.
- Do not add third-party libraries directly to feature code; wrap them in `Data` adapters behind protocols.
