# PowerSync Swift Demo App

A simple Swift app using the PowerSync Swift SDK. Built with KMMBridge + SKIE and using Supabase

## Features

- Using PowerSync Kotlin-Swift SDK to perform `read`, `insert`, `update`, and `watch` queries
- Integrates with Supabase via `SupabaseConnector` and email-and-password `auth`

## Set up Supabase and PowerSync projects

A step-by-step guide on Supabase<>PowerSync integration is available [here](https://docs.powersync.com/integration-guides/supabase).

## Configure The App

Open the project in XCode.

Open the “_Secrets” file and fill in the placeholder values (more info can be found [here](https://docs.powersync.com/integration-guides/supabase)).

### Finish XCode configuration

1. Clear Swift caches
```
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/org.swift.swiftpm
```

2. Run `pod install` in the project root

3. In Xcode:
- Reset Packages: File -> Packages -> Reset Package Caches
- Clean Build: Product -> Clean Build Folder.

4. Enable CasePathMacros. We are using SwiftUI Navigation for the demo which requires this.

## Run project

Build the project, launch the app and sign in with the test user you created in Supabase earlier.
