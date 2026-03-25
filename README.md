Spend Wiser

Intelligent Expense Tracking with Behavioral Insights

Spend Wise is a modern expense tracking application built with Flutter that helps users understand their spending habits through real-time analytics, anomaly detection, and smart budgeting insights.

Instead of simply logging transactions, Spend Wise analyzes spending patterns and provides meaningful financial feedback such as health scores, daily safe limits, and unusual expense detection.

Designed with Clean Architecture principles and Bloc state management, the app ensures scalability, maintainability, and performance.


Key Features

Smart Expense Input
Log expenses quickly using natural language:
1200 for groceries
250 for lunch
800 for transport

Automatically parses:
amount
category
timestamp


Financial Health Score

Dynamic score based on:
spending pace vs time elapsed in month
adherence to budget
overall spending balance
Helps users quickly understand financial discipline.


Spending Anomaly Detection

Detects unusual spending patterns using:
absolute threshold (10% of budget)
relative comparison with past expenses
category-based deviation
cold start protection logic
Highlights transactions that may require attention.


Monthly Budget Insights

Dashboard provides:
total spent this month
remaining budget
daily safe spending limit
days left in month
category distribution


Category-based Tracking

Predefined categories:
Food
Transport
Shopping
Bills
Entertainment
Health
Other
Each category includes emoji-based visual identification.


Sticky Date Grouping

Expenses grouped by:
Today
Yesterday
specific calendar dates
Improves readability of transaction history.


Modern UI Experience

sliver-based dashboard layout
animated counters
haptic feedback interactions
floating chat-style input
dynamic hint suggestions
smooth transitions
dark / light theme support


Offline-first Architecture

All data stored locally using Hive database.
Ensures:
fast performance
offline functionality
data persistence without network dependency


Core Innovation

Expense Spike Detection Algorithm
The system detects unusual expenses using multiple protective layers:
Absolute Threshold Detection
Flags any expense exceeding 10% of total monthly budget.
Noise Filtering
Ignores micro-transactions below 2% of budget.
Cold Start Protection
Avoids unreliable alerts when insufficient historical data exists.
Relative Average Comparison
Checks deviation against:
global spending average
category-specific average
This approach minimizes false positives while detecting meaningful anomalies.


Architecture

features
 ├── expense_tracking
 │    ├── data
 │    ├── domain
 │    └── presentation
 │
 ├── settings
 │
core
 ├── error
 ├── di
 └── themes


Architecture Layers

Presentation Layer
   Flutter UI
   Bloc state management
   Cubits for business orchestration
Domain Layer
   Entities
   Use cases
   Repository contracts
Data Layer
   Hive local database
   Repository implementations
   Data models


Tech Stack

Flutter
Dart
Bloc
Hive
GetIt
Dartz
Intl
UUID


Key Packages

flutter_bloc → predictable state management
hive → local persistence
get_it → dependency injection
dartz → functional error handling
intl → currency formatting
uuid → unique identifiers
 

Data Flow

UI → Cubit → UseCase → Repository → Local Data Source → Hive
Clear separation ensures testability and maintainability.


Design Principles

separation of concerns
predictable state management
immutable domain entities
dependency inversion
offline-first strategy
reusable UI components
scalable feature structure


Screens

Expense List
<img width="735" height="1522" alt="Expense list" src="https://github.com/user-attachments/assets/98cf03d8-4efc-43a6-8ad1-5c46431d5893" />

Dashboard
<img width="735" height="1522" alt="dashboard" src="https://github.com/user-attachments/assets/641a06a9-cd6e-4b61-9550-1a5f5ac0111a" />

Settings
<img width="764" height="1508" alt="settings" src="https://github.com/user-attachments/assets/8ae6f087-3c29-4186-bccb-50e355f0bd56" />


Getting Started

Clone the repository:
git clone https://github.com/manojsrinivasan002/spend-wise.git

Install dependencies:
flutter pub get

Run the app:
flutter run

Generate Hive adapters:
flutter pub run build_runner build

Try the App
https://github.com/manojsrinivasan002/SpendWise/releases/download/v1.0/spend-wiser-v1.apk

Demo Video
https://drive.google.com/file/d/1zQxvaZozuQW4epUA08kcbqTlpdOUxFbo/view?usp=sharing

Future Improvements

cloud sync support
multi-device backup
category customization
expense editing
export to csv/pdf
visual charts
AI spending insights
recurring expense detection


Author

Manoj Kumar
Flutter Developer focused on building scalable and user-centric mobile applications.
