# mediator_design_pattern

Define an object that encapsulates how a set of objects interact. Mediator promotes loose coupling by keeping objects from referring to each other explicitly, and it lets you vary their interaction independently.

## Applicability
* You should consider using the Mediator design pattern when there is a need to add communicating objects at run-time.
* it's possible to add or remove those dependencies later from the code just like adding a new user to the chat room.

## Problem
We will use the Mediator design pattern to implement a notification hub for the engineering team.
Send notifications to other team members. There are 3 main role: 
* admin
* developer
* tester(QA engineer)

1) There are times when the admin wants to send notifications to the whole team *or* members of a specific role.
2) Also, any other team member should be able to send a quick note
to the whole team, too.

To solve we use a notification hub. Think of it as a chat room - every team member joins the hub and later they use it to send notifications by simply calling a send method. Then, the hub distributes the message to the others - to all of them or by specific role.

Team members are completely decoupled. Also, in the case of a new team member, it is enough to add him/her to the notification hub and you could be sure that all the notifications would be delivered.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
