# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The changes documented here do not include those from the original repository.

## [Unreleased]

### 2022-11-08
- Fix: [iOS] Replace the old `OSCore` framework for the new `OSCommonPluginLib` pod.

## [Version 1.0.0]

### 2022-08-17
- Android - implement setDetails (triggerPayment) for Android, using Google Pay (https://outsystemsrd.atlassian.net/browse/RMET-1009)

### 2022-08-09
- Android - implemented isReadyToPay for Google Pay (https://outsystemsrd.atlassian.net/browse/RMET-790)

### 2022-08-08
- Android - added field verification to fail build if fields are missing in JSON config file (https://outsystemsrd.atlassian.net/browse/RMET-1721)

### 2022-08-03
- Android - implementated setupConfiguration method for Android (https://outsystemsrd.atlassian.net/browse/RMET-1721)
- Feat: Set Payment Details (https://outsystemsrd.atlassian.net/browse/RMET-1723).

### 2022-08-02
- Feat: Check Wallet Availability for Payment (https://outsystemsrd.atlassian.net/browse/RMET-1695).

### 2022-08-01
- Android - implemented hook to copy configuration data from JSON resource file. (https://outsystemsrd.atlassian.net/browse/RMET-1721)
- Feat: Setup Apple Pay Configurations (https://outsystemsrd.atlassian.net/browse/RMET-1722).
