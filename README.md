# AZIS

A finance and IA project on Flutter.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

Lab: Write your first Flutter app
Cookbook: Useful Flutter samples
For help getting started with Flutter development, view the
online documentation, which offers tutorials,
samples, guidance on mobile development, and a full API reference.

A few resources to get you started if this is your first Flutter project:

## Table of Contents
1.Introduction
2.Development Environment Setup
3.Project Structure
4.Main Features
5.Dependencies
6.Usage Instructions
7.Contributing
8.License

## Introduction
Azis is a mobile application developed in Flutter aimed at business Solutions. 
This project is designed for assist on legal and gerencial issues.

## Development Environment Setup

To start working with Azis, you need to set up your development environment with the following tools:

Flutter SDK: Flutter installation guide
Dart SDK: Included with the Flutter SDK.
Code Editor: Recommended Visual Studio Code or Android Studio.
Target Platforms: iOS and Android. Ensure you have emulators or physical devices set up.

## Installation
Clone the repository

bash
git clone https://github.com/axelsot0/azis.git
cd azis
Install dependencies

bash
flutter pub get
Run the application

bash
flutter run

## Project Structure
The project follows a typical Flutter structure. Below is the main structure:


models/: Contains data classes and models.
screens/: Contains the main application screens.
widgets/: Contains reusable widgets.
main.dart: Entry point of the application.

## Maiin Features
User Authentication: Registration, login, and password recovery.
Navigation: Navigation between different screens using Navigator.
State Management: Using Provider for state management.
User Interface: Responsive and user-friendly design.
API Integration: Communication with a REST API to use the GPT 4o Openai Model.

## Dependences
The main dependencies used in the project are listed in pubspec.yaml. Some of them include:

provider: ^6.0.0
http: ^0.14.0
flutter_secure_storage: ^5.0.0
shared_preferences: ^2.0.6
