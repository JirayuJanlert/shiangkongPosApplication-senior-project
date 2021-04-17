<p align="center">
  <a href="https://github.com/JirayuJanlert/shiangkongPosApplication-senior-project">
    <img src="https://storage.googleapis.com/first_singto_bucket/senior_project/logo.png" alt="Logo" width=72 height=72>
  </a>

  <h3 align="center">S. Shiangkong Motor Sales Order and Billing Mobile Application</h3>

  <p align="center">
    Part or BIS4996 BIS Senior Project
    <br>
    This POS application is developed to computerize <br>and speed up business process of S. Shiangkong Motor Spare Parts Store
  </p>
</p>


## Table of contents

- [Quick start](#quick-start)
- [What's included](#whats-included)
- [Prerequisites](#prerequisites)
- [Supported platforms](#supported-platforms)
- [Run the application](#Run-the-application)
- [Creators](#creators)
- [Thanks](#thanks)

## Quick start

This application is developed using Flutter. You should follow the instructions in the [official documentation](https://flutter.io/docs/get-started/install).

## What's included

* Add new product page
* Update product information page
* Main POS page
* Check out page
* Order confirmation 
* Order summary page
* Printing receipt function on POS blutooth thermal printer
* Scan product barcode
* Add and retreive customer
* Order history page
* Order reordering 
* Product detail page
* Claim accepting form
* Verify and approve claim
* Stock Management page
* Management report dashboard

## Prerequisites
This application makes use of a backend, to setup a backend and make it reachable on the internet we decided
to use Node-Red which is installed on AWS EC2 in this project. Therefore, you don't need to do some setup steps to get this application up and
running. However, we will be running the AWS EC2 only untill 31/04/2021. You can access Node-Red console at [http://13.250.64.212:1880](http://13.250.64.212:1880),

After that period, If you wish to use this application:
1. Install Node-Red on your local machine
2. You must import the Node-Red project file which included in Resource folder "node-red.json" at Node-Red console which can be access at [http://127.0.0.1:1880](http://127.0.0.1:1880) on your browser.
3. Install Xammp or Mamp to run MySql server
4. The sql database file "sqldb.sql" is also located in Resource folder. You must also import the sql database file at [PhpMyadmin](http://127.0.0.1/phpmyadmin) on your local machine.
5. You may need to configure port number, username, and password of MySql node on Node-Red according to your MySql server.

Moreover, you need to install Flutter sdk version >2.0, Android Studio, and Xcode for IOS. You can visit the documentation for the mentioned prerequisite tools at the below links. 

1. [Install Node-Red](https://nodered.org/docs/)
2. [Install Mamp](https://www.mamp.info/en/downloads/)
3. [Install Xammp](https://www.apachefriends.org/download.html)
4. [Install Flutter](https://flutter.dev/docs/get-started/install)
5. [Install Xcode](https://developer.apple.com/xcode/)
6. [Install Android Studio](https://developer.android.com/studio)

## Supported platforms
* Android (mobile and tablet)
* iOS (mobile and tablet)
* ~~Web~~ (not yet)


### Run the application
Connect a device and/or emulator and run the Flutter application on it.

Run the following command:
1. `flutter pub get`
2. `flutter run`

## Creators

**Jirayu Janlert**
<br>
**Tanaporn Tipnate**
<br>
**Thitima Suthakulwirat**

- <https://github.com/JirayuJanlert>


## Thanks

Thanks to A.Tanakom Tantontrakul for his support

