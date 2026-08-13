const String googleWebClientId =
    '136497821478-4g20octoklkr8j9ueqsn39pc1thada1i.apps.googleusercontent.com';

/// iOS'ta `GoogleSignIn.initialize`'a doğrudan verilir — Info.plist'te
/// `GIDClientID` anahtarı olmadığı için (bkz. `ios/Runner/Info.plist`'teki
/// `CFBundleURLTypes`), kodda sağlanması gerekiyor. Değeri
/// `firebase_options.dart`'taki `ios.iosClientId` ile aynı tutulmalı.
const String googleIosClientId =
    '136497821478-p5nsthe5hjspjvc5cg3r56b9rok7cm56.apps.googleusercontent.com';
