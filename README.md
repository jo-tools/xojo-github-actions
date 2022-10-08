# Xojo GitHub Actions
Xojo Build Automation using GitHub Actions

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Description
Would you like to automate the build processes of Xojo built applications with GitHub Actions? With no user interaction the whole process is being performed: Build all Targets, CodeSign Windows executables, create and sign the installer, package the macOS app in a .dmg and notarize the app, and for Linux a .tgz package.

Included in this repository:
- Documentation: [Xojo-GitHub-Actions.pdf](./docs/Xojo-GitHub-Actions.pdf)
- Source: [Xojo IDE Communicator](./xojo-ide-communicator/)
- Example Xojo Project: ```Xojo-GitHub-Actions.xojo_project```
  - [Build Resources](./_build/)
    - Windows: CodeSigning, Installer
    - macOS: CodeSigning, DMG Creation, Notarization *(using [Xojo2DMG](https://github.com/jo-tools/xojo2dmg))*
    - Linux: Post Build Script *(to create a .tgz)*
  - [GitHub Actions Workflows](./.github/workflows/)
    - Beta Build
    - Create Release
    - Xojo *(a resuable Workflow to build Xojo applications*)

### ScreenShots
Beta Build on Pull Request:  
![ScreenShot: Beta Build on Pull Request](docs/Beta-Build.gif?raw=true)

Create Release:  
![ScreenShot: Create Release](docs/Create-Release.gif?raw=true)

## Xojo
### Requirements
[Xojo](https://www.xojo.com/) is a rapid application development for Desktop, Web, Mobile & Raspberry Pi.  

The Desktop application Xojo example project and the Xojo IDE Communicator project are using:
- Xojo 2022r2
- API 2

## About
Juerg Otter is a long term user of Xojo and working for [CM Informatik AG](https://cmiag.ch/). Their Application [CMI LehrerOffice](https://cmi-bildung.ch/) is a Xojo Design Award Winner 2018. In his leisure time Juerg provides some [bits and pieces for Xojo Developers](https://www.jo-tools.ch/).

### Contact
[![E-Mail](https://img.shields.io/static/v1?style=social&label=E-Mail&message=xojo@jo-tools.ch)](mailto:xojo@jo-tools.ch)
&emsp;&emsp;
[![Follow on Facebook](https://img.shields.io/static/v1?style=social&logo=facebook&label=Facebook&message=juerg.otter)](https://www.facebook.com/juerg.otter)
&emsp;&emsp;
[![Follow on Twitter](https://img.shields.io/twitter/follow/juergotter?style=social)](https://twitter.com/juergotter)

### Donation
Do you like this project? Does it help you? Has it saved you time and money?  
You're welcome - it's free... If you want to say thanks I'd appreciate a [message](mailto:xojo@jo-tools.ch) or a small [donation via PayPal](https://paypal.me/jotools).  

[![PayPal Dontation to jotools](https://img.shields.io/static/v1?style=social&logo=paypal&label=PayPal&message=jotools)](https://paypal.me/jotools)
