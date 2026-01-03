import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:kitokopay/service/api_client.dart';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:pointycastle/asymmetric/api.dart' as pointycastle;
import 'package:asn1lib/asn1lib.dart';
import 'package:encrypt/encrypt.dart' as encryptPackage;
import 'package:kitokopay/service/token_storage.dart';
import 'package:kitokopay/service/public_key_service.dart';
import 'package:kitokopay/config/app_config.dart';
import 'package:kitokopay/service/sensitive_data_storage.dart'; // PHASE 2: Secure storage for CustomerId/AppId
import 'dart:html' as html; // Import html for localStorage
import 'dart:async'; // Import for Timer
// import dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ElmsSSL {
  static String basic_username = "L@T0wU8eR";
  static String basic_password = "TGF0MHdDb1IzU3Yz";

  // Cached PUBLIC_KEY for synchronous access
  static String? _cachedPublicKey;

  /// Initialize the cached PUBLIC_KEY from secure storage.
  /// This should be called once during app startup (e.g., splash screen).
  static Future<void> initializePublicKey() async {
    try {
      final publicKeyService = PublicKeyService();
      final publicKey = await publicKeyService.getPublicKey(forceRefresh: false);
      _cachedPublicKey = publicKey ?? 'No Public Key Found';
      
      if (kDebugMode) {
        debugPrint('✅ ElmsSSL cached PUBLIC_KEY initialized (${_cachedPublicKey?.length ?? 0} chars)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize PUBLIC_KEY in ElmsSSL: $e');
      }
      _cachedPublicKey = 'No Public Key Found';
    }
  }

  String get publicKeyString {
    // First try cached value
    if (_cachedPublicKey != null && _cachedPublicKey != 'No Public Key Found') {
      return _cachedPublicKey!;
    }
    
    // Fallback to compile-time variables or dotenv
    final envKey = const String.fromEnvironment('PUBLIC_KEY', defaultValue: 'No Public Key Found');
    if (envKey != 'No Public Key Found') {
      return envKey;
    }
    
    // Last resort: try dotenv
    return dotenv.env['PUBLIC_KEY'] ?? 'No Public Key Found';
  }

  void printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
  }

  Map<String, dynamic> cleanResponse(String jsonResponse) {
    try {
      // Parse the main JSON response
      final Map<String, dynamic> parsedResponse = json.decode(jsonResponse);

      // Check if the Data field exists and is a String
      if (parsedResponse.containsKey('Data') &&
          parsedResponse['Data'] is String) {
        try {
          // Attempt to parse the Data field as JSON
          final nestedData = json.decode(parsedResponse['Data']);
          // Replace the Data field with the cleaned JSON object
          parsedResponse['Data'] = nestedData;
        } catch (e) {
          // If parsing fails, log the error and retain the original value
          parsedResponse['Data'] = parsedResponse['Data'];
        }
      }

      return parsedResponse;
    } catch (e) {
      // Log or handle the error if the initial parsing fails
      throw FormatException("Invalid JSON response: $e");
    }
  }

  Future<String> getCustomer(String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uuid = const Uuid();
    String Uid = uuid.v4();

    String service = "PROFILE";
    String action = "BASE";
    String command = "GETCUSTOMER";
    String platform = "WEB";
    String CustomerId = "";
    String MobileNumber = mobileNumber;
    String device = "WEB";
    String Lat = "0.200";
    String Lon = "-1.01";

    Map<String, String> F = {
      for (var item in List.generate(41, (index) => index))
        'F${item.toString().padLeft(3, '0')}': ''
    };

    F['F000'] = service;
    F['F001'] = action;
    F['F002'] = command;
    F['F003'] = ""; // AppId
    F['F004'] = CustomerId;
    F['F005'] = MobileNumber;
    F['F009'] = device;
    F['F010'] = device;
    F['F014'] = platform;

    ApiClient apiClient = ApiClient();

    String trxData = jsonEncode(F);

    Map<String, String> appDataMap = {
      "UniqueId": Uid,
      "AppId": "", // AppId
      "device": device,
      "platform": platform,
      "CustomerId": CustomerId,
      "MobileNumber": MobileNumber,
      "Lat": Lat,
      "Lon": Lon,
    };

    String appData = jsonEncode(appDataMap);

    String hashedTrxData = hash(trxData, device);

    String strKey = apiClient.generateRandomString(16);
    String strIV = apiClient.generateRandomString(16);

    String Rsc = hashedTrxData;
    String Rrk = encrypt(strKey, publicKeyString);
    String Rrv = encrypt(strIV, publicKeyString);
    String Aad = encrypt1(appData, strKey, strIV);

    String coreData = encrypt1(trxData, strKey, strIV);

    Map<String, String> authRequest = {
      "H00": Uid,
      "H03": Rsc,
      "H01": Rrk,
      "H02": Rrv,
      "H04": Aad,
    };

    Map<String, String> coreRequest = {"Data": coreData};

    final authResultStr = await apiClient.authRequest(authRequest);

    final token = await TokenStorage().getToken();

    final coreResult = await apiClient.coreRequest(
      token as String,
      coreRequest,
      command,
    );

    int statusCode = coreResult['statusCode'];
    String responseBody = coreResult['body'];

    if (statusCode == 400) {
      // Return error JSON with the message from the 400 response
      return jsonEncode({
        "status": "error",
        "message": responseBody,
      });
    } else if (statusCode == 401 || statusCode == 200) {
      var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));

      // PHASE 2: Store CustomerId and AppId securely (with SharedPreferences backup for revert)
      final sensitiveStorage = SensitiveDataStorage();
      await sensitiveStorage.setCustomerId(parsedResponse['Data']['CustomerId']);
      await sensitiveStorage.setAppId(parsedResponse['Data']['AppId']);
      
      // Also keep in SharedPreferences for backward compatibility and easy revert
      await prefs.setString('customerId', parsedResponse['Data']['CustomerId']);
      await prefs.setString('appId', parsedResponse['Data']['AppId']);
      
      return jsonEncode({"status": "success"});
    } else {
      // Handle unexpected status codes
      return jsonEncode({
        "status": "error",
        "message": "Unexpected status code: $statusCode",
      });
    }
  }



  Future<String> selfRegisterSendOtp(String jsonFields) async {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📤 SELF REGISTER SEND OTP - STARTING');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📋 Input JSON length: ${jsonFields.length} chars');
    }

    try {
      // Step 1: Initialize SharedPreferences
      if (kDebugMode) {
        debugPrint('🔄 Step 1: Initializing SharedPreferences...');
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (kDebugMode) {
        debugPrint('✅ Step 1: SharedPreferences initialized');
      }

      // Step 2: Generate Unique ID
      if (kDebugMode) {
        debugPrint('🔄 Step 2: Generating Unique ID...');
      }
      var uuid = const Uuid();
      String Uid = uuid.v4();
      if (kDebugMode) {
        debugPrint('✅ Step 2: Unique ID generated: $Uid');
      }

      // Step 3: Parse JSON fields
      if (kDebugMode) {
        debugPrint('🔄 Step 3: Parsing JSON fields...');
      }
      Map<String, dynamic> registrationData;
      try {
        registrationData = jsonDecode(jsonFields);
        if (kDebugMode) {
          debugPrint('✅ Step 3: JSON parsed successfully');
          debugPrint('   Fields found: ${registrationData.keys.length}');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Step 3: Failed to parse JSON');
          debugPrint('   Error: $e');
        }
        return jsonEncode({
          "status": "error",
          "message": "Invalid JSON format: ${e.toString()}",
        });
      }

      // Step 4: Extract values from JSON
      if (kDebugMode) {
        debugPrint('🔄 Step 4: Extracting values from JSON...');
      }
      String FirstName = registrationData['FirstName']?.toString() ?? '';
      String MiddleName = registrationData['MiddleName']?.toString() ?? '';
      String LastName = registrationData['LastName']?.toString() ?? '';
      String MobileNumber = registrationData['MobileNumber']?.toString() ?? '';
      String IdentificationType = registrationData['IdentificationType']?.toString() ?? '';
      String Identification = registrationData['Identification']?.toString() ?? '';
      String Country = registrationData['Country']?.toString() ?? '';
      String Email = registrationData['Email']?.toString() ?? '';
      String Organization = registrationData['Organization']?.toString() ?? '';
      String Department = registrationData['Department']?.toString() ?? '';
      String EmployeeCode = registrationData['EmployeeCode']?.toString() ?? '';
      String VerificationMode = registrationData['VerificationMode']?.toString() ?? '';
      
      if (kDebugMode) {
        debugPrint('✅ Step 4: Values extracted');
        debugPrint('   FirstName: ${FirstName.isNotEmpty ? "${FirstName.substring(0, 1)}***" : "empty"}');
        debugPrint('   LastName: ${LastName.isNotEmpty ? "${LastName.substring(0, 1)}***" : "empty"}');
        debugPrint('   MobileNumber: ${MobileNumber.isNotEmpty ? "${MobileNumber.substring(0, 3)}***" : "empty"}');
        debugPrint('   Email: ${Email.isNotEmpty ? "${Email.split('@')[0]}@***" : "empty"}');
        debugPrint('   VerificationMode: $VerificationMode');
      }

      // Step 5: Set service parameters
      if (kDebugMode) {
        debugPrint('🔄 Step 5: Setting service parameters...');
      }
      String service = "PROFILE";
      String action = "BASE";
      String command = "SELFREGISTERSENDOTP";
      String platform = "WEB";
      String CustomerId = "";
      String device = "WEB";
      String Lat = "0.200";
      String Lon = "-1.01";
      if (kDebugMode) {
        debugPrint('✅ Step 5: Service parameters set');
        debugPrint('   Service: $service');
        debugPrint('   Action: $action');
        debugPrint('   Command: $command');
        debugPrint('   Platform: $platform');
        debugPrint('   Device: $device');
      }

      // Step 6: Initialize F fields array
      if (kDebugMode) {
        debugPrint('🔄 Step 6: Initializing F fields array...');
      }
      Map<String, String> F = {
        for (var item in List.generate(41, (index) => index))
          'F${item.toString().padLeft(3, '0')}': ''
      };
      if (kDebugMode) {
        debugPrint('✅ Step 6: F fields array initialized (41 fields)');
      }

      // Step 7: Set service fields
      if (kDebugMode) {
        debugPrint('🔄 Step 7: Setting service fields...');
      }
      F['F000'] = service;
      F['F001'] = action;
      F['F002'] = command;
      F['F003'] = "ELMSAFRICA"; // Hardcoded AppId
      F['F004'] = CustomerId;
      F['F005'] = MobileNumber;
      F['F007'] = "";
      F['F009'] = device;
      F['F010'] = device;
      F['F011'] = "";
      F['F014'] = platform;
      if (kDebugMode) {
        debugPrint('✅ Step 7: Service fields set');
        debugPrint('   F000: $service');
        debugPrint('   F001: $action');
        debugPrint('   F002: $command');
        debugPrint('   F003: ELMSAFRICA (hardcoded)');
        debugPrint('   F005: ${MobileNumber.isNotEmpty ? "${MobileNumber.substring(0, 3)}***" : "empty"}');
        debugPrint('   F011: YES');
      }

      // Step 8: Set registration data fields
      if (kDebugMode) {
        debugPrint('🔄 Step 8: Setting registration data fields...');
      }
      F['F021'] = MobileNumber;
      F['F022'] = Identification;
      F['F023'] = FirstName;
      F['F024'] = MiddleName;
      F['F025'] = LastName;
      F['F026'] = EmployeeCode;
      F['F027'] = VerificationMode;
      F['F028'] = Email;
      F['F029'] = IdentificationType;
      F['F030'] = Country;
      F['F031'] = Organization;
      F['F032'] = Department;
      if (kDebugMode) {
        debugPrint('✅ Step 8: Registration data fields set');
        debugPrint('   F021-F032: All registration fields populated');
      }

      // Step 9: Create ApiClient instance
      if (kDebugMode) {
        debugPrint('🔄 Step 9: Creating ApiClient instance...');
      }
      ApiClient apiClient = ApiClient();
      if (kDebugMode) {
        debugPrint('✅ Step 9: ApiClient created');
      }

      // Step 10: Encode transaction data
      if (kDebugMode) {
        debugPrint('🔄 Step 10: Encoding transaction data...');
      }
      String trxData = jsonEncode(F);
      if (kDebugMode) {
        debugPrint('✅ Step 10: Transaction data encoded');
        debugPrint('   TrxData length: ${trxData.length} chars');
      }

      // Step 11: Prepare app data
      if (kDebugMode) {
        debugPrint('🔄 Step 11: Preparing app data...');
      }
      Map<String, String> appDataMap = {
        "UniqueId": Uid,
        "AppId": "",
        "device": device,
        "platform": platform,
        "CustomerId": CustomerId,
        "MobileNumber": MobileNumber,
        "Lat": Lat,
        "Lon": Lon,
      };
      String appData = jsonEncode(appDataMap);
      if (kDebugMode) {
        debugPrint('✅ Step 11: App data prepared');
        debugPrint('   AppData length: ${appData.length} chars');
      }

      // Step 12: Hash transaction data
      if (kDebugMode) {
        debugPrint('🔄 Step 12: Hashing transaction data...');
      }
      String hashedTrxData = hash(trxData, device);
      if (kDebugMode) {
        debugPrint('✅ Step 12: Transaction data hashed');
        debugPrint('   Hash length: ${hashedTrxData.length} chars');
      }

      // Step 13: Generate encryption keys
      if (kDebugMode) {
        debugPrint('🔄 Step 13: Generating encryption keys...');
      }
      String strKey = apiClient.generateRandomString(16);
      String strIV = apiClient.generateRandomString(16);
      if (kDebugMode) {
        debugPrint('✅ Step 13: Encryption keys generated');
        debugPrint('   Key length: ${strKey.length} chars');
        debugPrint('   IV length: ${strIV.length} chars');
      }

      // Step 14: Encrypt data
      if (kDebugMode) {
        debugPrint('🔄 Step 14: Encrypting data...');
      }
      String Rsc = hashedTrxData;
      String Rrk = encrypt(strKey, publicKeyString);
      String Rrv = encrypt(strIV, publicKeyString);
      String Aad = encrypt1(appData, strKey, strIV);
      String coreData = encrypt1(trxData, strKey, strIV);
      if (kDebugMode) {
        debugPrint('✅ Step 14: Data encrypted');
        debugPrint('   Rrk length: ${Rrk.length} chars');
        debugPrint('   Rrv length: ${Rrv.length} chars');
        debugPrint('   Aad length: ${Aad.length} chars');
        debugPrint('   CoreData length: ${coreData.length} chars');
      }

      // Step 15: Prepare auth request
      if (kDebugMode) {
        debugPrint('🔄 Step 15: Preparing auth request...');
      }
      Map<String, String> authRequest = {
        "H00": Uid,
        "H03": Rsc,
        "H01": Rrk,
        "H02": Rrv,
        "H04": Aad,
      };
      if (kDebugMode) {
        debugPrint('✅ Step 15: Auth request prepared');
        debugPrint('   H00: $Uid');
        debugPrint('   H03 length: ${Rsc.length} chars');
        debugPrint('   H01 length: ${Rrk.length} chars');
        debugPrint('   H02 length: ${Rrv.length} chars');
        debugPrint('   H04 length: ${Aad.length} chars');
      }

      // Step 16: Prepare core request
      if (kDebugMode) {
        debugPrint('🔄 Step 16: Preparing core request...');
      }
      Map<String, String> coreRequest = {"Data": coreData};
      if (kDebugMode) {
        debugPrint('✅ Step 16: Core request prepared');
        debugPrint('   Data length: ${coreData.length} chars');
      }

      // Step 17: Send auth request
      if (kDebugMode) {
        debugPrint('🔄 Step 17: Sending auth request...');
      }
      try {
        await apiClient.authRequest(authRequest);
        if (kDebugMode) {
          debugPrint('✅ Step 17: Auth request successful');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Step 17: Auth request failed');
          debugPrint('   Error: $e');
        }
        rethrow;
      }

      // Step 18: Get token
      if (kDebugMode) {
        debugPrint('🔄 Step 18: Retrieving token...');
      }
      final token = await TokenStorage().getToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint('❌ Step 18: Token not found');
        }
        return jsonEncode({
          "status": "error",
          "message": "Authentication failed. Token not found.",
        });
      }
      if (kDebugMode) {
        debugPrint('✅ Step 18: Token retrieved');
        debugPrint('   Token length: ${token.length} chars');
      }

      // Step 19: Send core request
      if (kDebugMode) {
        debugPrint('🔄 Step 19: Sending core request...');
      }
      final coreResult = await apiClient.coreRequest(
        token,
        coreRequest,
        command,
      );
      if (kDebugMode) {
        debugPrint('✅ Step 19: Core request completed');
        debugPrint('   Status code: ${coreResult['statusCode']}');
        debugPrint('   Response body length: ${coreResult['body'].length} chars');
      }

      // Step 20: Process response
      if (kDebugMode) {
        debugPrint('🔄 Step 20: Processing response...');
      }
      int statusCode = coreResult['statusCode'];
      String responseBody = coreResult['body'];

      if (statusCode == 400) {
        if (kDebugMode) {
          debugPrint('⚠️ Step 20: Status code 400 (Bad Request)');
          debugPrint('   Response: $responseBody');
        }
        return jsonEncode({
          "status": "error",
          "message": responseBody,
        });
      } else if (statusCode == 401) {
        if (kDebugMode) {
          debugPrint('🔄 Step 20: Status code 401 - Decrypting response...');
        }
        try {
          var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));
          if (kDebugMode) {
            debugPrint('✅ Step 20: Response decrypted successfully');
            debugPrint('   Response keys: ${parsedResponse.keys.join(", ")}');
          }
          
          // Handle response structure: Data can be a string or an object
          String message;
          if (parsedResponse['Data'] is String) {
            // Data is a string message (e.g., "Otp created successfully")
            message = parsedResponse['Data'] as String;
            if (kDebugMode) {
              debugPrint('   Data is a string: $message');
            }
          } else if (parsedResponse['Data'] is Map) {
            // Data is an object - extract message and optionally CustomerId/AppId
            Map<String, dynamic> dataObj = parsedResponse['Data'] as Map<String, dynamic>;
            message = dataObj['Display']?.toString() ?? 'OTP sent successfully!';
            
            // PHASE 2: Store CustomerId and AppId securely (if present)
            if (kDebugMode) {
              debugPrint('🔄 Step 20.1: Storing CustomerId and AppId...');
            }
            final sensitiveStorage = SensitiveDataStorage();
            if (dataObj['CustomerId'] != null) {
              String customerIdStr = dataObj['CustomerId'].toString();
              await sensitiveStorage.setCustomerId(customerIdStr);
              await prefs.setString('customerId', customerIdStr);
              if (kDebugMode) {
                // Sanitize CustomerId for logging (show only first 3 and last 2 chars)
                String sanitized = customerIdStr.length > 5 
                    ? '${customerIdStr.substring(0, 3)}***${customerIdStr.substring(customerIdStr.length - 2)}'
                    : '***';
                debugPrint('✅ CustomerId stored: $sanitized');
              }
            }
            if (dataObj['AppId'] != null) {
              String appIdStr = dataObj['AppId'].toString();
              await sensitiveStorage.setAppId(appIdStr);
              await prefs.setString('appId', appIdStr);
              if (kDebugMode) {
                // Sanitize AppId for logging (show only first 3 and last 2 chars)
                String sanitized = appIdStr.length > 5 
                    ? '${appIdStr.substring(0, 3)}***${appIdStr.substring(appIdStr.length - 2)}'
                    : '***';
                debugPrint('✅ AppId stored: $sanitized');
              }
            }
          } else {
            message = 'OTP sent successfully!';
          }
          
          if (kDebugMode) {
            debugPrint('✅ Step 20: Success response prepared');
            debugPrint('   Message: $message');
            debugPrint('═══════════════════════════════════════════════════════════');
            debugPrint('✅ SELF REGISTER SEND OTP - SUCCESS');
            debugPrint('═══════════════════════════════════════════════════════════');
          }
          return jsonEncode({
            "status": "success",
            "message": message,
          });
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('❌ Step 20: Failed to decrypt/parse response');
            debugPrint('   Error: $e');
            debugPrint('   Stack trace: $stackTrace');
          }
          return jsonEncode({
            "status": "error",
            "message": "Failed to process response: ${e.toString()}",
          });
        }
      } else if (statusCode == 200) {
        if (kDebugMode) {
          debugPrint('🔄 Step 20: Status code 200 - Decrypting response...');
        }
        try {
          var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));
          if (kDebugMode) {
            debugPrint('✅ Step 20: Response decrypted successfully');
            debugPrint('   Response keys: ${parsedResponse.keys.join(", ")}');
            debugPrint('   Data type: ${parsedResponse['Data'].runtimeType}');
          }
          
          // Handle response structure: Data can be a string or an object
          String message;
          if (parsedResponse['Data'] is String) {
            // Data is a string message (e.g., "Otp created successfully")
            message = parsedResponse['Data'] as String;
            if (kDebugMode) {
              debugPrint('   Data is a string: $message');
            }
          } else if (parsedResponse['Data'] is Map) {
            // Data is an object - extract message and optionally CustomerId/AppId
            Map<String, dynamic> dataObj = parsedResponse['Data'] as Map<String, dynamic>;
            message = dataObj['Display']?.toString() ?? 'OTP sent successfully!';
            
            // PHASE 2: Store CustomerId and AppId securely (if present)
            if (kDebugMode) {
              debugPrint('🔄 Step 20.1: Storing CustomerId and AppId...');
            }
            final sensitiveStorage = SensitiveDataStorage();
            if (dataObj['CustomerId'] != null) {
              String customerIdStr = dataObj['CustomerId'].toString();
              await sensitiveStorage.setCustomerId(customerIdStr);
              await prefs.setString('customerId', customerIdStr);
              if (kDebugMode) {
                // Sanitize CustomerId for logging (show only first 3 and last 2 chars)
                String sanitized = customerIdStr.length > 5 
                    ? '${customerIdStr.substring(0, 3)}***${customerIdStr.substring(customerIdStr.length - 2)}'
                    : '***';
                debugPrint('✅ CustomerId stored: $sanitized');
              }
            }
            if (dataObj['AppId'] != null) {
              String appIdStr = dataObj['AppId'].toString();
              await sensitiveStorage.setAppId(appIdStr);
              await prefs.setString('appId', appIdStr);
              if (kDebugMode) {
                // Sanitize AppId for logging (show only first 3 and last 2 chars)
                String sanitized = appIdStr.length > 5 
                    ? '${appIdStr.substring(0, 3)}***${appIdStr.substring(appIdStr.length - 2)}'
                    : '***';
                debugPrint('✅ AppId stored: $sanitized');
              }
            }
          } else {
            message = 'OTP sent successfully!';
          }
          
          if (kDebugMode) {
            debugPrint('✅ Step 20: Success response prepared');
            debugPrint('   Message: $message');
            debugPrint('═══════════════════════════════════════════════════════════');
            debugPrint('✅ SELF REGISTER SEND OTP - SUCCESS');
            debugPrint('═══════════════════════════════════════════════════════════');
          }
          return jsonEncode({
            "status": "success",
            "message": message,
          });
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('❌ Step 20: Failed to decrypt/parse response');
            debugPrint('   Error: $e');
            debugPrint('   Stack trace: $stackTrace');
          }
          return jsonEncode({
            "status": "error",
            "message": "Failed to process response: ${e.toString()}",
          });
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ Step 20: Unexpected status code: $statusCode');
          debugPrint('   Response: ${responseBody.length > 200 ? responseBody.substring(0, 200) + "..." : responseBody}');
        }
        return jsonEncode({
          "status": "error",
          "message": "Unexpected status code: $statusCode",
        });
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('❌ SELF REGISTER SEND OTP - ERROR');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('❌ Error Type: ${e.runtimeType}');
        debugPrint('❌ Error Message: $e');
        debugPrint('❌ Stack Trace:');
        debugPrint('$stackTrace');
        debugPrint('═══════════════════════════════════════════════════════════');
      }
      return jsonEncode({
        "status": "error",
        "message": "An error occurred: ${e.toString()}",
      });
    }
  }

  
  Future<String> selfRegisterVerifyOtp(String jsonFields) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uuid = const Uuid();
    String Uid = uuid.v4();

    // Parse JSON fields
    Map<String, dynamic> registrationData;
    try {
      registrationData = jsonDecode(jsonFields);
    } catch (e) {
      return jsonEncode({
        "status": "error",
        "message": "Invalid JSON format: ${e.toString()}",
      });
    }

    // Extract values from JSON
    String FirstName = registrationData['FirstName']?.toString() ?? '';
    String MiddleName = registrationData['MiddleName']?.toString() ?? '';
    String LastName = registrationData['LastName']?.toString() ?? '';
    String MobileNumber = registrationData['MobileNumber']?.toString() ?? '';
    String IdentificationType = registrationData['IdentificationType']?.toString() ?? '';
    String Identification = registrationData['Identification']?.toString() ?? '';
    String Country = registrationData['Country']?.toString() ?? '';
    String Email = registrationData['Email']?.toString() ?? '';
    String Organization = registrationData['Organization']?.toString() ?? '';
    String Department = registrationData['Department']?.toString() ?? '';
    String EmployeeCode = registrationData['EmployeeCode']?.toString() ?? '';
    String VerificationMode = registrationData['VerificationMode']?.toString() ?? '';
    String OTP = registrationData['OTP']?.toString() ?? '';

    String service = "PROFILE";
    String action = "BASE";
    String command = "SELFREGISTERVERIFYOTP";
    String platform = "WEB";
    String CustomerId = "";
    String device = "WEB";
    String Lat = "0.200";
    String Lon = "-1.01";

    // Initialize F fields array
    Map<String, String> F = {
      for (var item in List.generate(41, (index) => index))
        'F${item.toString().padLeft(3, '0')}': ''
    };

    // Set service fields
    F['F000'] = service;
    F['F001'] = action;
    F['F002'] = command;
    F['F003'] = "ELMSAFRICA"; // Hardcoded AppId
    F['F004'] = CustomerId;
    F['F005'] = MobileNumber;
    F['F007'] = "";
    F['F009'] = device;
    F['F010'] = device;
    F['F011'] = "";
    F['F014'] = platform;

    // Set registration data fields
    F['F021'] = MobileNumber;
    F['F022'] = Identification;
    F['F023'] = FirstName;
    F['F024'] = MiddleName;
    F['F025'] = LastName;
    F['F026'] = EmployeeCode;
    F['F027'] = VerificationMode;
    F['F028'] = Email;
    F['F029'] = IdentificationType;
    F['F030'] = Country;
    F['F031'] = Organization;
    F['F032'] = Department;
    F['F033'] = OTP;

    ApiClient apiClient = ApiClient();

    String trxData = jsonEncode(F);

    Map<String, String> appDataMap = {
      "UniqueId": Uid,
      "AppId": "",
      "device": device,
      "platform": platform,
      "CustomerId": CustomerId,
      "MobileNumber": MobileNumber,
      "Lat": Lat,
      "Lon": Lon,
    };

    String appData = jsonEncode(appDataMap);

    String hashedTrxData = hash(trxData, device);

    String strKey = apiClient.generateRandomString(16);
    String strIV = apiClient.generateRandomString(16);

    String Rsc = hashedTrxData;
    String Rrk = encrypt(strKey, publicKeyString);
    String Rrv = encrypt(strIV, publicKeyString);
    String Aad = encrypt1(appData, strKey, strIV);

    String coreData = encrypt1(trxData, strKey, strIV);

    Map<String, String> authRequest = {
      "H00": Uid,
      "H03": Rsc,
      "H01": Rrk,
      "H02": Rrv,
      "H04": Aad,
    };

    Map<String, String> coreRequest = {"Data": coreData};

    final authResultStr = await apiClient.authRequest(authRequest);

    final token = await TokenStorage().getToken();

    final coreResult = await apiClient.coreRequest(
      token as String,
      coreRequest,
      command,
    );

    int statusCode = coreResult['statusCode'];
    String responseBody = coreResult['body'];

    if (statusCode == 400) {
      // Return error JSON with the message from the 400 response
      return jsonEncode({
        "status": "error",
        "message": responseBody,
      });
    } else if (statusCode == 401) {
      // Handle 401 response (decrypt and parse)
      try {
        var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));
        
        // Handle response structure: Data can be a string or an object
        String message;
        if (parsedResponse['Data'] is String) {
          // Data is a string message (e.g., "Otp verified successfully")
          message = parsedResponse['Data'] as String;
        } else if (parsedResponse['Data'] is Map) {
          // Data is an object - extract message and optionally CustomerId/AppId
          Map<String, dynamic> dataObj = parsedResponse['Data'] as Map<String, dynamic>;
          message = dataObj['Display']?.toString() ?? 'OTP verified successfully!';
          
          // PHASE 2: Store CustomerId and AppId securely (if present)
          final sensitiveStorage = SensitiveDataStorage();
          if (dataObj['CustomerId'] != null) {
            String customerIdStr = dataObj['CustomerId'].toString();
            await sensitiveStorage.setCustomerId(customerIdStr);
            await prefs.setString('customerId', customerIdStr);
          }
          if (dataObj['AppId'] != null) {
            String appIdStr = dataObj['AppId'].toString();
            await sensitiveStorage.setAppId(appIdStr);
            await prefs.setString('appId', appIdStr);
          }
        } else {
          message = 'OTP verified successfully!';
        }
        
        return jsonEncode({
          "status": "success",
          "message": message,
        });
      } catch (e) {
        return jsonEncode({
          "status": "error",
          "message": "Failed to process response: ${e.toString()}",
        });
      }
    } else if (statusCode == 200) {
      // Handle 200 response (decrypt and parse)
      try {
        var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));
        
        // Handle response structure: Data can be a string or an object
        String message;
        if (parsedResponse['Data'] is String) {
          // Data is a string message (e.g., "Otp verified successfully")
          message = parsedResponse['Data'] as String;
        } else if (parsedResponse['Data'] is Map) {
          // Data is an object - extract message and optionally CustomerId/AppId
          Map<String, dynamic> dataObj = parsedResponse['Data'] as Map<String, dynamic>;
          message = dataObj['Display']?.toString() ?? 'OTP verified successfully!';
          
          // PHASE 2: Store CustomerId and AppId securely (if present)
          final sensitiveStorage = SensitiveDataStorage();
          if (dataObj['CustomerId'] != null) {
            String customerIdStr = dataObj['CustomerId'].toString();
            await sensitiveStorage.setCustomerId(customerIdStr);
            await prefs.setString('customerId', customerIdStr);
          }
          if (dataObj['AppId'] != null) {
            String appIdStr = dataObj['AppId'].toString();
            await sensitiveStorage.setAppId(appIdStr);
            await prefs.setString('appId', appIdStr);
          }
        } else {
          message = 'OTP verified successfully!';
        }
        return jsonEncode({
          "status": "success",
          "message": message,
        });
      } catch (e) {
        return jsonEncode({
          "status": "error",
          "message": "Failed to process response: ${e.toString()}",
        });
      }
    } else {
      // Handle unexpected status codes
      return jsonEncode({
        "status": "error",
        "message": "Unexpected status code: $statusCode",
      });
    }
  }


  Future<String> selfRegistration(String jsonFields) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uuid = const Uuid();
    String Uid = uuid.v4();

    // Parse JSON fields
    Map<String, dynamic> registrationData;
    try {
      registrationData = jsonDecode(jsonFields);
    } catch (e) {
      return jsonEncode({
        "status": "error",
        "message": "Invalid JSON format: ${e.toString()}",
      });
    }

    // Extract values from JSON
    String FirstName = registrationData['FirstName']?.toString() ?? '';
    String MiddleName = registrationData['MiddleName']?.toString() ?? '';
    String LastName = registrationData['LastName']?.toString() ?? '';
    String MobileNumber = registrationData['MobileNumber']?.toString() ?? '';
    String IdentificationType = registrationData['IdentificationType']?.toString() ?? '';
    String Identification = registrationData['Identification']?.toString() ?? '';
    String Country = registrationData['Country']?.toString() ?? '';
    String Email = registrationData['Email']?.toString() ?? '';
    String Organization = registrationData['Organization']?.toString() ?? '';
    String Department = registrationData['Department']?.toString() ?? '';
    String EmployeeCode = registrationData['EmployeeCode']?.toString() ?? '';
    String VerificationMode = registrationData['VerificationMode']?.toString() ?? '';
    String OTP = registrationData['OTP']?.toString() ?? '';
    String PIN = registrationData['PIN']?.toString() ?? '';

    String service = "PROFILE";
    String action = "BASE";
    String command = "SELFREGISTRATION";
    String platform = "WEB";
    String CustomerId = "";
    String device = "WEB";
    String Lat = "0.200";
    String Lon = "-1.01";

    // Initialize F fields array
    Map<String, String> F = {
      for (var item in List.generate(41, (index) => index))
        'F${item.toString().padLeft(3, '0')}': ''
    };

    // Set service fields
    F['F000'] = service;
    F['F001'] = action;
    F['F002'] = command;
    F['F003'] = "ELMSAFRICA"; // Hardcoded AppId
    F['F004'] = CustomerId;
    F['F005'] = MobileNumber;
    F['F007'] = encrypt(PIN, publicKeyString);
    F['F009'] = device;
    F['F010'] = device;
    F['F011'] = "YES";
    F['F014'] = platform;

    // Set registration data fields
    F['F021'] = MobileNumber;
    F['F022'] = Identification;
    F['F023'] = FirstName;
    F['F024'] = MiddleName;
    F['F025'] = LastName;
    F['F026'] = EmployeeCode;
    F['F027'] = VerificationMode;
    F['F028'] = Email;
    F['F029'] = IdentificationType;
    F['F030'] = Country;
    F['F031'] = Organization;
    F['F032'] = Department;
    F['F033'] = OTP;

    ApiClient apiClient = ApiClient();

    String trxData = jsonEncode(F);

    Map<String, String> appDataMap = {
      "UniqueId": Uid,
      "AppId": "",
      "device": device,
      "platform": platform,
      "CustomerId": CustomerId,
      "MobileNumber": MobileNumber,
      "Lat": Lat,
      "Lon": Lon,
    };

    String appData = jsonEncode(appDataMap);

    String hashedTrxData = hash(trxData, device);

    String strKey = apiClient.generateRandomString(16);
    String strIV = apiClient.generateRandomString(16);

    String Rsc = hashedTrxData;
    String Rrk = encrypt(strKey, publicKeyString);
    String Rrv = encrypt(strIV, publicKeyString);
    String Aad = encrypt1(appData, strKey, strIV);

    String coreData = encrypt1(trxData, strKey, strIV);

    Map<String, String> authRequest = {
      "H00": Uid,
      "H03": Rsc,
      "H01": Rrk,
      "H02": Rrv,
      "H04": Aad,
    };

    Map<String, String> coreRequest = {"Data": coreData};

    final authResultStr = await apiClient.authRequest(authRequest);

    final token = await TokenStorage().getToken();

    final coreResult = await apiClient.coreRequest(
      token as String,
      coreRequest,
      command,
    );

    int statusCode = coreResult['statusCode'];
    String responseBody = coreResult['body'];

    if (statusCode == 400) {
      // Return error JSON with the message from the 400 response
      return jsonEncode({
        "status": "error",
        "message": responseBody,
      });
    } else if (statusCode == 401) {
      // Handle 401 response (decrypt and parse)
      try {
        var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));
        
        // Handle response structure: Data can be a string or an object
        String message;
        if (parsedResponse['Data'] is String) {
          // Data is a string message (e.g., "Registration successful!")
          message = parsedResponse['Data'] as String;
        } else if (parsedResponse['Data'] is Map) {
          // Data is an object - extract message and optionally CustomerId/AppId
          Map<String, dynamic> dataObj = parsedResponse['Data'] as Map<String, dynamic>;
          message = dataObj['Display']?.toString() ?? 'Registration successful!';
          
          // PHASE 2: Store CustomerId and AppId securely (if present)
          final sensitiveStorage = SensitiveDataStorage();
          if (dataObj['CustomerId'] != null) {
            String customerIdStr = dataObj['CustomerId'].toString();
            await sensitiveStorage.setCustomerId(customerIdStr);
            await prefs.setString('customerId', customerIdStr);
          }
          if (dataObj['AppId'] != null) {
            String appIdStr = dataObj['AppId'].toString();
            await sensitiveStorage.setAppId(appIdStr);
            await prefs.setString('appId', appIdStr);
          }
        } else {
          message = 'Registration successful!';
        }
        
        return jsonEncode({
          "status": "success",
          "message": message,
        });
      } catch (e) {
        return jsonEncode({
          "status": "error",
          "message": "Failed to process response: ${e.toString()}",
        });
      }
    } else if (statusCode == 200) {
      // Handle 200 response (decrypt and parse)
      try {
        var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));
        
        // Handle response structure: Data can be a string or an object
        String message;
        if (parsedResponse['Data'] is String) {
          // Data is a string message (e.g., "Registration successful!")
          message = parsedResponse['Data'] as String;
        } else if (parsedResponse['Data'] is Map) {
          // Data is an object - extract message and optionally CustomerId/AppId
          Map<String, dynamic> dataObj = parsedResponse['Data'] as Map<String, dynamic>;
          message = dataObj['Display']?.toString() ?? 'Registration successful!';
          
          // PHASE 2: Store CustomerId and AppId securely (if present)
          final sensitiveStorage = SensitiveDataStorage();
          if (dataObj['CustomerId'] != null) {
            String customerIdStr = dataObj['CustomerId'].toString();
            await sensitiveStorage.setCustomerId(customerIdStr);
            await prefs.setString('customerId', customerIdStr);
          }
          if (dataObj['AppId'] != null) {
            String appIdStr = dataObj['AppId'].toString();
            await sensitiveStorage.setAppId(appIdStr);
            await prefs.setString('appId', appIdStr);
          }
        } else {
          message = 'Registration successful!';
        }
        
        return jsonEncode({
          "status": "success",
          "message": message,
        });
      } catch (e) {
        return jsonEncode({
          "status": "error",
          "message": "Failed to process response: ${e.toString()}",
        });
      }
    } else {
      // Handle unexpected status codes
      return jsonEncode({
        "status": "error",
        "message": "Unexpected status code: $statusCode",
      });
    }
  }

  Future<String> login(String pin, String mobileNumber) async {
    var uuid = const Uuid();
    String Uid = uuid.v4();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ApiClient apiClient = ApiClient();

    // PHASE 2: Get AppId and CustomerId from secure storage (with SharedPreferences fallback)
    final sensitiveStorage = SensitiveDataStorage();
    String? AppId = await sensitiveStorage.getAppId();
    String? CustomerId = await sensitiveStorage.getCustomerId();
    
    // Fallback to SharedPreferences if secure storage returns null (for migration/revert)
    if (AppId == null || AppId.isEmpty) {
      AppId = prefs.getString("appId");
    }
    if (CustomerId == null || CustomerId.isEmpty) {
      CustomerId = prefs.getString("customerId");
    }

    // Check if AppId or CustomerId is empty; if so, fetch using getCustomer
    if (AppId == null ||
        AppId.isEmpty ||
        CustomerId == null ||
        CustomerId.isEmpty) {
      final result = await getCustomer(mobileNumber);
      Map<String, dynamic> resultMap = jsonDecode(result);

      if (resultMap['status'] == 'success') {
        // PHASE 2: Refetch AppId and CustomerId from secure storage after successful getCustomer call
        AppId = await sensitiveStorage.getAppId();
        CustomerId = await sensitiveStorage.getCustomerId();
        
        // Fallback to SharedPreferences if secure storage returns null
        if (AppId == null || AppId.isEmpty) {
          AppId = prefs.getString("appId");
        }
        if (CustomerId == null || CustomerId.isEmpty) {
          CustomerId = prefs.getString("customerId");
        }

        if (AppId == null ||
            AppId.isEmpty ||
            CustomerId == null ||
            CustomerId.isEmpty) {
          return 'Error fetching AppId or CustomerId';
        }
      } else if (resultMap['status'] == 'error') {
        return jsonEncode({"status": "error", "message": resultMap['message']});
      }
    }

    String platform = "WEB";
    String device = "WEB";
    String Lat = "0.200";
    String Lon = "-1.01";

    String strKey = apiClient.generateRandomString(16);
    String strIV = apiClient.generateRandomString(16);

    Map<String, String> fValues = {
      "F000": "PROFILE",
      "F001": "BASE",
      "F002": "LOGIN",
      "F003": AppId as String,
      "F004": CustomerId as String,
      "F005": mobileNumber,
      "F006": "",
      "F007": encrypt(pin, publicKeyString),
      "F008": "PIN",
      "F009": device,
      "F010": device,
      "F014": platform,
    };

    String trxData = jsonEncode(fValues);

    String appData = jsonEncode({
      "UniqueId": Uid,
      "AppId": AppId,
      "device": device,
      "platform": platform,
      "CustomerId": CustomerId,
      "MobileNumber": mobileNumber,
      "Lat": Lat,
      "Lon": Lon,
    });

    String hashedTrxData = hash(trxData, device);
    String Rsc = hashedTrxData;
    String Rrk = encrypt(strKey, publicKeyString);
    String Rrv = encrypt(strIV, publicKeyString);
    String Aad = encrypt1(appData, strKey, strIV);

    String coreData = encrypt1(trxData, strKey, strIV);

    Map<String, String> coreRequest = {"Data": coreData};
    Map<String, String> authRequest = {
      "H00": Uid,
      "H03": Rsc,
      "H01": Rrk,
      "H02": Rrv,
      "H04": Aad,
    };

    // Send authentication request
    final authResultStr = await apiClient.authRequest(authRequest);
    final token = await TokenStorage().getToken();

    final coreResult = await apiClient.coreRequest(
      token as String,
      coreRequest,
      "LOGIN",
    );

    int statusCode = coreResult['statusCode'];
    String responseBody = coreResult['body'];

    if (statusCode == 400) {
      return jsonEncode({
        "status": "error",
        "message": responseBody,
      });
    } else if (statusCode == 200) {
      var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));

      // Store the parsed response in preferences
      await prefs.setString('loginDetails', jsonEncode(parsedResponse));

      final loanStatus = parsedResponse['Data']['LoanStatus'];

      if (loanStatus == null || loanStatus == "") {
        return jsonEncode({"status": "success", "message": "Login successful"});
      } else {
        final loans = jsonDecode(parsedResponse['Data']['Loans']);

        final firstLoan = loans[0];

        final res = await loanDetails(firstLoan['LoanId']);

        return res;
      }
    } else {
      return jsonEncode({
        "status": "error",
        "message": "Unexpected status code: $statusCode",
      });
    }
  }

  Future<bool> isLocalStorageExpired() async {
    final expiryTimeString = html.window.localStorage['expiryTime'];
    if (expiryTimeString != null) {
      final expiryTime = DateTime.parse(expiryTimeString);
      if (DateTime.now().isAfter(expiryTime)) {
        // Expired, clear the localStorage
        html.window.localStorage.remove('appId');
        html.window.localStorage.remove('customerId');
        html.window.localStorage.remove('expiryTime');
        return true;
      }
    }
    return false;
  }

  Future<String> activate(String mobileNumber, String otp) async {
    var uuid = const Uuid();
    String Uid = uuid.v4();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ApiClient apiClient = ApiClient();

    // PHASE 2: Get AppId and CustomerId from secure storage (with SharedPreferences fallback)
    final sensitiveStorage = SensitiveDataStorage();
    String? AppId = await sensitiveStorage.getAppId();
    String? CustomerId = await sensitiveStorage.getCustomerId();
    
    // Fallback to SharedPreferences if secure storage returns null (for migration/revert)
    if (AppId == null || AppId.isEmpty) {
      AppId = prefs.getString("appId");
    }
    if (CustomerId == null || CustomerId.isEmpty) {
      CustomerId = prefs.getString("customerId");
    }

    // Check if AppId or CustomerId is empty; if so, fetch using getCustomer
    if (AppId == null ||
        AppId.isEmpty ||
        CustomerId == null ||
        CustomerId.isEmpty) {
      final result = await getCustomer(mobileNumber);
      Map<String, dynamic> resultMap = jsonDecode(result);

      if (resultMap['status'] == 'success') {
        // PHASE 2: Refetch AppId and CustomerId from secure storage after successful getCustomer call
        AppId = await sensitiveStorage.getAppId();
        CustomerId = await sensitiveStorage.getCustomerId();
        
        // Fallback to SharedPreferences if secure storage returns null
        if (AppId == null || AppId.isEmpty) {
          AppId = prefs.getString("appId");
        }
        if (CustomerId == null || CustomerId.isEmpty) {
          CustomerId = prefs.getString("customerId");
        }

        if (AppId == null ||
            AppId.isEmpty ||
            CustomerId == null ||
            CustomerId.isEmpty) {
          return 'Error fetching AppId or CustomerId';
        }
      } else {
        // Handle error message from response
        String errorMessage = resultMap['message'] ??
            'Your request cannot be processed this time, please try again later!';
        return errorMessage;
      }
    }

    String Lat = "0.200";
    String Lon = "-1.01";

    String device = "WEB";
    String strKey = apiClient.generateRandomString(16);
    String strIV = apiClient.generateRandomString(16);

    Map<String, String> fValues = {
      "F000": "PROFILE",
      "F001": "BASE",
      "F002": "ACTIVATE",
      "F003": AppId,
      "F004": CustomerId,
      "F005": mobileNumber,
      "F006": "",
      "F007": "",
      "F008": "PIN",
      "F009": "WEB", // IMEI
      "F010": "WEB",
      "F013": otp, // OTP activation code received via email
      "F014": "WEB",
    };

    for (int i = 11; i <= 40; i++) {
      if (!fValues.containsKey("F${i.toString().padLeft(3, '0')}")) {
        fValues["F${i.toString().padLeft(3, '0')}"] = "";
      }
    }

    String trxData = jsonEncode(fValues);

    String appData = jsonEncode({
      "UniqueId": Uid,
      "AppId": AppId,
      "device": "WEB",
      "platform": "WEB",
      "CustomerId": CustomerId,
      "MobileNumber": mobileNumber,
      "Lat": Lat,
      "Lon": Lon,
    });

    String hashedTrxData = hash(trxData, device);

    String Rsc = hashedTrxData;
    String Rrk = encrypt(strKey, publicKeyString);
    String Rrv = encrypt(strIV, publicKeyString);
    String Aad = encrypt1(appData, strKey, strIV);

    String coreData = encrypt1(trxData, strKey, strIV);

    Map<String, String> authRequest = {
      "H00": Uid,
      "H03": Rsc,
      "H01": Rrk,
      "H02": Rrv,
      "H04": Aad,
    };

    Map<String, String> coreRequest = {"Data": coreData};

    final authResultStr = await apiClient.authRequest(authRequest);

    final token = await TokenStorage().getToken();

    final coreResult = await apiClient.coreRequest(
      token as String,
      coreRequest,
      "ACTIVATE",
    );

    int statusCode = coreResult['statusCode'];
    String responseBody = coreResult['body'];

    if (statusCode == 400) {
      // Return the 400 error message directly
      return jsonEncode({
        "status": "error",
        "message": responseBody,
      });
    } else if (statusCode == 401) {
      // Return success message directly for 401 status
      final coreDecrypted = cleanResponse(decrypt(responseBody, strKey, strIV));

      return jsonEncode(
          {"status": "success", "message": coreDecrypted['Data']['Display']});
    } else if (statusCode == 200) {
      return jsonEncode(
          {"status": "success", "message": "Activation Successful!"});
    } else {
      // Handle unexpected status codes
      return jsonEncode({
        "status": "error",
        "message": "Unexpected status code: $statusCode",
      });
    }
  }

  Future<String> applyLoan(
      String appliedAmount, String pin, String currency) async {
    var uuid = const Uuid();
    var Uid = uuid.v4();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ApiClient apiClient = ApiClient();

    String strKey = apiClient.generateRandomString(16);
    String strIV = apiClient.generateRandomString(16);

    var serviceDetails = {
      "service": "LOAN",
      "action": "BASE",
      "command": "APPLICATION",
    };

    // PHASE 2: Get AppId and CustomerId from secure storage (with SharedPreferences fallback)
    final sensitiveStorage = SensitiveDataStorage();
    String? AppId = await sensitiveStorage.getAppId();
    String? CustomerId = await sensitiveStorage.getCustomerId();
    
    // Fallback to SharedPreferences if secure storage returns null (for migration/revert)
    if (AppId == null || AppId.isEmpty) {
      AppId = prefs.getString("appId");
    }
    if (CustomerId == null || CustomerId.isEmpty) {
      CustomerId = prefs.getString("customerId");
    }

    // Retrieve login details to get mobileNumber
    String mobileNumber = '';
    String limitAmount = "";
    String? loginResponseStr = prefs.getString('loginDetails');

    if (loginResponseStr != null) {
      final loginResponse = jsonDecode(loginResponseStr);
      mobileNumber = loginResponse['Data']['MobileNumber'] ?? '';
      // currency = loginResponse['Data']['Currency'] ?? '';
      limitAmount = loginResponse['Data']['LimitAmount'] ?? '';
    }

    var appDetails = {
      "AppId": AppId,
      "platform": "WEB",
      "CustomerId": CustomerId,
      "MobileNumber": mobileNumber,
      "device": "WEB",
      "Lat": "0.200",
      "Lon": "-1.01",
    };

    var transactionDetails = {
      "F000": serviceDetails["service"],
      "F001": serviceDetails["action"],
      "F002": serviceDetails["command"],
      "F003": AppId,
      "F004": CustomerId,
      "F005": appDetails["MobileNumber"],
      "F006": "",
      "F007": encrypt(pin, publicKeyString),
      "F008": "PIN",
      "F009": "WEB",
      "F010": "WEB",
      "F011": "YES",
      "F020": currency,
      "F021": mobileNumber,
      "F023": appliedAmount,
      "F024": limitAmount,
      "F025": apiClient.generateRandomString(16),
    };

    var trxData = jsonEncode(transactionDetails);
    var appData = jsonEncode(appDetails);

    var hashedTrxData = hash(trxData, appDetails["device"]!);

    var Rsc = hashedTrxData;
    var Rrk = encrypt(strKey, publicKeyString);
    var Rrv = encrypt(strIV, publicKeyString);
    var Aad = encrypt1(appData, strKey, strIV);

    var coreData = encrypt1(trxData, strKey, strIV);

    Map<String, String> authRequest = {
      "H00": Uid,
      "H03": Rsc,
      "H01": Rrk,
      "H02": Rrv,
      "H04": Aad,
    };

    Map<String, String> coreRequest = {"Data": coreData};

    final authResultStr = await apiClient.authRequest(authRequest);
    final token = await TokenStorage().getToken();

    final coreResult = await apiClient.coreRequest(
      token as String,
      coreRequest,
      "APPLICATION",
    );

    int statusCode = coreResult['statusCode'];
    String responseBody = coreResult['body'];

    if (statusCode == 400) {
      return jsonEncode({
        "status": "error",
        "message": responseBody,
      });
    } else if (statusCode == 200) {
      var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));

      // Store the parsed response in preferences
      await prefs.setString('applyLoanDetails', jsonEncode(parsedResponse));

      return jsonEncode(
          {"status": "success", "message": "Loan applied successfully"});
    } else {
      return jsonEncode({
        "status": "error",
        "message": "Unexpected status code: $statusCode",
      });
    }
  }

  Future<String> repayLoan(String type, String amount, String pin) async {
    var uuid = const Uuid();
    var Uid = uuid.v4();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ApiClient apiClient = ApiClient();

    String strKey = apiClient.generateRandomString(16);
    String strIV = apiClient.generateRandomString(16);

    var serviceDetails = {
      "service": "LOAN",
      "action": "BASE",
      "command": "REPAYMENT",
    };

    // Retrieve loan details from prefs
    String loanId = '';
    String principalAmount = '';
    String totalOutstanding = '';
    String mobileNumber = '';
    String currency = '';

    String? loanDetailsStr = prefs.getString('loanDetails');
    if (loanDetailsStr != null) {
      final loanDetails = jsonDecode(loanDetailsStr);
      loanId = loanDetails['Data']['Details']['id'].toString();
      principalAmount =
          loanDetails['Data']['Details']['TotalPrincipalExpected'].toString();
      totalOutstanding =
          loanDetails['Data']['Details']['TotalOutstanding'].toString();
      currency = loanDetails['Data']['Details']['Currency'] ?? '';
    }

    String? loginResponseStr = prefs.getString('loginDetails');
    if (loginResponseStr != null) {
      final loginResponse = jsonDecode(loginResponseStr);
      mobileNumber = loginResponse['Data']['MobileNumber'] ?? '';
    }

    var appDetails = {
      "AppId": prefs.getString("appId"),
      "platform": "WEB",
      "CustomerId": prefs.getString("customerId"),
      "MobileNumber": mobileNumber,
      "device": "WEB",
      "Lat": "0.200",
      "Lon": "-1.01",
    };

    var transactionDetails = {
      "F000": serviceDetails["service"],
      "F001": serviceDetails["action"],
      "F002": serviceDetails["command"],
      "F003": appDetails["AppId"],
      "F004": appDetails["CustomerId"],
      "F005": appDetails["MobileNumber"],
      "F007": encrypt(pin, publicKeyString),
      "F008": "PIN",
      "F020": currency,
      "F022": type,
      "F023": amount,
      "F024": principalAmount,
      "F025": loanId,
      "F026": totalOutstanding,
    };

    var trxData = jsonEncode(transactionDetails);
    var appData = jsonEncode(appDetails);

    var hashedTrxData = hash(trxData, appDetails["device"]!);
    var Rsc = hashedTrxData;
    var Rrk = encrypt(strKey, publicKeyString);
    var Rrv = encrypt(strIV, publicKeyString);
    var Aad = encrypt1(appData, strKey, strIV);
    var coreData = encrypt1(trxData, strKey, strIV);

    Map<String, String> authRequest = {
      "H00": Uid,
      "H03": Rsc,
      "H01": Rrk,
      "H02": Rrv,
      "H04": Aad,
    };

    Map<String, String> coreRequest = {"Data": coreData};

    final authResultStr = await apiClient.authRequest(authRequest);
    final token = await TokenStorage().getToken();

    final coreResult = await apiClient.coreRequest(
      token as String,
      coreRequest,
      serviceDetails["command"]!,
    );

    int statusCode = coreResult['statusCode'];
    String responseBody = coreResult['body'];

    if (statusCode == 400) {
      return jsonEncode({"status": "error", "message": responseBody});
    } else if (statusCode == 200) {
      var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));
      return jsonEncode(
          {"status": "success", "message": parsedResponse['Data']});
    } else {
      return jsonEncode({
        "status": "error",
        "message": "Unexpected status code: $statusCode",
      });
    }
  }

  Future<String> fetchLoanDetailsById(String loadId) async {
    var uuid = const Uuid();
    String uid = uuid.v4();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ApiClient apiClient = ApiClient();

    String service = "LOAN";
    String action = "BASE";
    String command = "DETAILS";
    String platform = "WEB";

    // PHASE 2: Retrieve appId and customerId from secure storage (with SharedPreferences fallback)
    final sensitiveStorage = SensitiveDataStorage();
    String appId = (await sensitiveStorage.getAppId()) ?? prefs.getString("appId") ?? '';
    String customerId = (await sensitiveStorage.getCustomerId()) ?? prefs.getString("customerId") ?? '';

    // Retrieve login details to get mobileNumber
    String mobileNumber = '';
    String? loginResponseStr = prefs.getString('loginDetails');

    if (loginResponseStr != null) {
      // Parse the login response to extract mobileNumber
      final loginResponse = jsonDecode(loginResponseStr);
      mobileNumber = loginResponse['Data']['MobileNumber'] ?? '';
    }

    String device = "WEB";
    String lat = "0.200";
    String lon = "-1.01";

    // Prepare transaction data (trxData) fields
    Map<String, String> trxDataMap = {
      "F000": service,
      "F001": action,
      "F002": command,
      "F003": appId,
      "F004": customerId,
      "F005": mobileNumber,
      "F009": device,
      "F010": device,
      "F014": platform,
      "F021": mobileNumber,
      "F022": loadId,
    };

    String trxData = jsonEncode(trxDataMap);

    String appData = jsonEncode({
      "UniqueId": uid,
      "AppId": appId,
      "Device": device,
      "Platform": platform,
      "CustomerId": customerId,
      "MobileNumber": mobileNumber,
      "Lat": lat,
      "Lon": lon,
    });

    String hashedTrxData = hash(trxData, device);

    // Encryption setup
    String strKey = apiClient.generateRandomString(16);
    String strIV = apiClient.generateRandomString(16);

    String rsc = hashedTrxData;
    String rrk = encrypt(strKey, publicKeyString);
    String rrv = encrypt(strIV, publicKeyString);
    String aad = encrypt1(appData, strKey, strIV);

    String coreData = encrypt1(trxData, strKey, strIV);

    Map<String, String> authRequest = {
      "H00": uid,
      "H03": rsc,
      "H01": rrk,
      "H02": rrv,
      "H04": aad,
    };

    Map<String, String> coreRequest = {"Data": coreData};

    // Perform authentication request
    await apiClient.authRequest(authRequest);

    // Get the token and perform core request
    final token = await TokenStorage().getToken();
    final coreResultStr =
        await apiClient.coreRequest(token as String, coreRequest, "DETAILS");

    final coreResult = await apiClient.coreRequest(
      token,
      coreRequest,
      "DETAILS",
    );

    int statusCode = coreResult['statusCode'];
    String responseBody = coreResult['body'];

    if (statusCode == 400) {
      return jsonEncode({"status": "error", "message": responseBody});
    } else if (statusCode == 200) {
      var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));
      await prefs.setString('fetchedLoanDetails', jsonEncode(parsedResponse));
      return jsonEncode({"status": "success"});
    } else {
      return jsonEncode({
        "status": "error",
        "message": "Unexpected status code: $statusCode",
      });
    }
  }

  Future<String> loanDetails(String loadId) async {
    var uuid = const Uuid();
    String uid = uuid.v4();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ApiClient apiClient = ApiClient();

    String service = "LOAN";
    String action = "BASE";
    String command = "DETAILS";
    String platform = "WEB";

    // PHASE 2: Retrieve appId and customerId from secure storage (with SharedPreferences fallback)
    final sensitiveStorage = SensitiveDataStorage();
    String appId = (await sensitiveStorage.getAppId()) ?? prefs.getString("appId") ?? '';
    String customerId = (await sensitiveStorage.getCustomerId()) ?? prefs.getString("customerId") ?? '';

    // Retrieve login details to get mobileNumber
    String mobileNumber = '';
    String? loginResponseStr = prefs.getString('loginDetails');

    if (loginResponseStr != null) {
      // Parse the login response to extract mobileNumber
      final loginResponse = jsonDecode(loginResponseStr);
      mobileNumber = loginResponse['Data']['MobileNumber'] ?? '';
    }

    String device = "WEB";
    String lat = "0.200";
    String lon = "-1.01";

    // Prepare transaction data (trxData) fields
    Map<String, String> trxDataMap = {
      "F000": service,
      "F001": action,
      "F002": command,
      "F003": appId,
      "F004": customerId,
      "F005": mobileNumber,
      "F009": device,
      "F010": device,
      "F014": platform,
      "F021": mobileNumber,
      "F022": loadId,
    };

    String trxData = jsonEncode(trxDataMap);

    String appData = jsonEncode({
      "UniqueId": uid,
      "AppId": appId,
      "Device": device,
      "Platform": platform,
      "CustomerId": customerId,
      "MobileNumber": mobileNumber,
      "Lat": lat,
      "Lon": lon,
    });

    String hashedTrxData = hash(trxData, device);

    // Encryption setup
    String strKey = apiClient.generateRandomString(16);
    String strIV = apiClient.generateRandomString(16);

    String rsc = hashedTrxData;
    String rrk = encrypt(strKey, publicKeyString);
    String rrv = encrypt(strIV, publicKeyString);
    String aad = encrypt1(appData, strKey, strIV);

    String coreData = encrypt1(trxData, strKey, strIV);

    Map<String, String> authRequest = {
      "H00": uid,
      "H03": rsc,
      "H01": rrk,
      "H02": rrv,
      "H04": aad,
    };

    Map<String, String> coreRequest = {"Data": coreData};

    // Perform authentication request
    await apiClient.authRequest(authRequest);

    // Get the token and perform core request
    final token = await TokenStorage().getToken();
    final coreResultStr =
        await apiClient.coreRequest(token as String, coreRequest, "DETAILS");

    final coreResult = await apiClient.coreRequest(
      token,
      coreRequest,
      "DETAILS",
    );

    int statusCode = coreResult['statusCode'];
    String responseBody = coreResult['body'];

    if (statusCode == 400) {
      return jsonEncode({"status": "error", "message": responseBody});
    } else if (statusCode == 200) {
      var parsedResponse = cleanResponse(decrypt(responseBody, strKey, strIV));
      await prefs.setString('loanDetails', jsonEncode(parsedResponse));
      return jsonEncode({"status": "success"});
    } else {
      return jsonEncode({
        "status": "error",
        "message": "Unexpected status code: $statusCode",
      });
    }
  }

//   Future<String> reActivate(String otp) async {
//     var uuid = Uuid();
//     String uid = uuid.v4();

//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     publicKeyString = publicKeyString != ""
//         ? publicKeyString
//         : prefs.getString('publicKey') ?? '';

//     ApiClient apiClient = ApiClient();

//     final deviceInfo = DeviceInfoPlugin();
//     String? iMEI;

//     if (Platform.isIOS) {
//       IosDeviceInfo? iosInfo = await deviceInfo.iosInfo;
//       iMEI = iosInfo.identifierForVendor; // Use null-aware access
//     } else if (Platform.isAndroid) {
//       AndroidDeviceInfo? androidInfo = await deviceInfo.androidInfo;
//       iMEI = androidInfo.androidId; // Use null-aware access
//     }

//     String service = "PROFILE";
//     String action = "BASE";
//     String command = "REACTIVATE";

//     String appId = GlobalData().getAppId() != ''
//         ? GlobalData().getAppId()
//         : prefs.getString("appId") ??
//             ''; // returned by GETCUSTOMER call and saved in the app
//     String platform = Platform.isIOS ? "ios" : "android";

//     String customerId = GlobalData().getCustomerId() != ''
//         ? GlobalData().getCustomerId()
//         : prefs.getString("customerId") ?? ''; // stored
//     String mobileNumber = GlobalData().getMobileNumber() != ''
//         ? GlobalData().getMobileNumber()
//         : prefs.getString("mobileNumber") ?? ''; // stored
//     String device = iMEI ?? ""; // stored or read

//     String lat = "0.200";
//     String lon = "-1.01";

//     String rsc; // Rsa Somme de Control
//     String rrk; // Rsa Random Key
//     String rrv; // Rsa Random Vector
//     String aad; // Aes App Data

//     String f000 = service;
//     String f001 = action;
//     String f002 = command;
//     String f003 = appId;
//     String f004 = customerId;
//     String f005 = mobileNumber;
//     String f006 = "";
//     String f007 = "";
//     String f008 = "";
//     String f009 = device; // IMEI
//     String f010 = device;
//     String f011 = "";
//     String f012 = "";
//     String f013 = otp;
//     String f014 = platform;
//     String f015 = "";
//     String f016 = "";
//     String f017 = "";
//     String f018 = "";
//     String f019 = "";
//     String f020 = "";
//     String f021 = "";
//     String f022 = "";
//     String f023 = "";
//     String f024 = "";
//     String f025 = "";
//     String f026 = "";
//     String f027 = "";
//     String f028 = "";
//     String f029 = "";
//     String f030 = "";
//     String f031 = "";
//     String f032 = "";
//     String f033 = "";
//     String f034 = "";
//     String f035 = "";
//     String f036 = "";
//     String f037 = "";
//     String f038 = "";
//     String f039 = "";
//     String f040 = "";

//     String trxData = jsonEncode({
//       'F000': f000,
//       'F001': f001,
//       'F002': f002,
//       'F003': f003,
//       'F004': f004,
//       'F005': f005,
//       'F006': f006,
//       'F007': f007,
//       'F008': f008,
//       'F009': f009,
//       'F010': f010,
//       'F011': f011,
//       'F012': f012,
//       'F013': f013,
//       'F014': f014,
//       'F015': f015,
//       'F016': f016,
//       'F017': f017,
//       'F018': f018,
//       'F019': f019,
//       'F020': f020,
//       'F021': f021,
//       'F022': f022,
//       'F023': f023,
//       'F024': f024,
//       'F025': f025,
//       'F026': f026,
//       'F027': f027,
//       'F028': f028,
//       'F029': f029,
//       'F030': f030,
//       'F031': f031,
//       'F032': f032,
//       'F033': f033,
//       'F034': f034,
//       'F035': f035,
//       'F036': f036,
//       'F037': f037,
//       'F038': f038,
//       'F039': f039,
//       'F040': f040,
//     });

//     String appData = jsonEncode({
//       'UniqueId': uid,
//       'AppId': appId,
//       'Device': device,
//       'Platform': platform,
//       'CustomerId': customerId,
//       'MobileNumber': mobileNumber,
//       'Lat': lat,
//       'Lon': lon,
//     });

//     String hashedTrxData = hash(trxData, device);

//     String strKey = "lbXDF0000yxrG24B";
//     String strIV = "HlPGoH11117Pf5sv";

//     rsc = hashedTrxData;
//     rrk = encrypt(strKey, publicKeyString);
//     rrv = encrypt(strIV, publicKeyString);
//     aad = encrypt1(appData, strKey, strIV);

//     String coreData = encrypt1(trxData, strKey, strIV);

//     Map<String, String> authRequest = {
//       'H00': uid,
//       'H03': rsc,
//       'H01': rrk,
//       'H02': rrv,
//       'H04': aad,
//     };

//     Map<String, String> coreRequest = {'Data': coreData};

//     final authResultStr = await apiClient.authRequest(authRequest);

//     final token = TokenStorage().getToken();

//     final coreResultStr =
//         await apiClient.coreRequest(token, coreRequest, "REACTIVATE");

//     if (GlobalData().getIs401ReactivateResponse() == 401 && otp != "") {
//       final String coreDecryted =
//           decrypt(GlobalData().getReactivateCoreDataResult(), strKey, strIV);

//       Map<String, dynamic> responseBody = jsonDecode(coreDecryted);

//       if (responseBody.isNotEmpty) {
//         ActivationResponse activationResponse =
//             ActivationResponse.fromJson(responseBody);

//         GlobalData().setDeviceId(activationResponse.data.deviceId ?? "");
//       }
//     }

//     // final String coreDecryted =
//     //     decrypt(GlobalData().getCoreDataResult(), strKey, strIV);

//     // Map<String, dynamic> responseBody = jsonDecode(coreDecryted);

//     return "";
//   }

  Future<String> resetPin() async {
    // Generate unique ID
    var uuid = const Uuid();
    String uid = uuid.v4();

    // Retrieve shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ApiClient apiClient = ApiClient();

    // PHASE 2: Retrieve appId and customerId from secure storage (with SharedPreferences fallback)
    final sensitiveStorage = SensitiveDataStorage();
    String appId = (await sensitiveStorage.getAppId()) ?? prefs.getString("appId") ?? '';
    String customerId = (await sensitiveStorage.getCustomerId()) ?? prefs.getString("customerId") ?? '';
    String mobileNumber = '';

    // Retrieve mobile number from login details
    String? loginResponseStr = prefs.getString('loginDetails');
    if (loginResponseStr != null) {
      final loginResponse = jsonDecode(loginResponseStr);
      mobileNumber = loginResponse['Data']['MobileNumber'] ?? '';
    }

    // Define constant fields
    String service = "PROFILE";
    String action = "BASE";
    String command = "RESETPIN";
    String device = "WEB";
    String platform = "WEB";
    String lat = "0.200";
    String lon = "-1.01";

    // Prepare transaction data (trxData)
    Map<String, dynamic> trxData = {
      'F000': service,
      'F001': action,
      'F002': command,
      'F003': appId,
      'F004': customerId,
      'F005': mobileNumber,
      'F006': "",
      'F007': "",
      'F008': "PIN",
      'F009': device,
      'F010': device,
      'F011': "",
      'F012': "",
      'F013': "",
      'F014': platform,
      'F015': "",
      'F016': "",
      'F017': "",
      'F018': "",
      'F019': "",
      'F020': "",
      'F021': "",
      'F022': "",
      'F023': "",
      'F024': "",
      'F025': "",
      'F026': "",
      'F027': "",
      'F028': "",
      'F029': "",
      'F030': "",
      'F031': "",
      'F032': "",
      'F033': "",
      'F034': "",
      'F035': "",
      'F036': "",
      'F037': "",
      'F038': "",
      'F039': "",
      'F040': "",
    };

    String trxDataJson = jsonEncode(trxData);

    // Encryption setup
    String strKey = apiClient.generateRandomString(16);
    String strIV = apiClient.generateRandomString(16);

    // Encrypt fields
    String coreData = encrypt1(trxDataJson, strKey, strIV);

    Map<String, String> coreRequest = {'Data': coreData};

    try {
      // Step 1: Retrieve token
      final token = await TokenStorage().getToken();

      // Step 2: Perform core request
      final coreResult = await apiClient.coreRequest(
        token as String,
        coreRequest,
        command,
      );

      // Extract status code and response body
      int statusCode = coreResult['statusCode'];
      String responseBody = coreResult['body'];

      // Handle response based on status code
      if (statusCode == 400) {
        return jsonEncode({"status": "error", "message": responseBody});
      } else if (statusCode == 200) {
        var parsedResponse =
            cleanResponse(decrypt(responseBody, strKey, strIV));
        await prefs.setString('loanDetails', jsonEncode(parsedResponse));
        return jsonEncode({"status": "success"});
      } else {
        return jsonEncode({
          "status": "error",
          "message": "Unexpected status code: $statusCode",
        });
      }
    } catch (e) {
      return jsonEncode({"status": "error", "message": e.toString()});
    }
  }

  String encrypt(String textToEncrypt, String publicKeyString) {
    try {
      final publicKey = getPublicKeyFromString(publicKeyString);
      final encryptedData = encryptData(textToEncrypt, publicKey);
      return base64.encode(encryptedData);
    } on Exception catch (ex) {
      return "Encryption failed due to: ${ex.toString()}";
    }
  }

  Uint8List encryptData(String data, pointycastle.RSAPublicKey publicKey) {
    try {
      final cipher = PKCS1Encoding(RSAEngine())
        ..init(true, PublicKeyParameter<pointycastle.RSAPublicKey>(publicKey));
      final plaintextBytes = Uint8List.fromList(data.codeUnits);
      return cipher.process(plaintextBytes);
    } on Exception {
      return Uint8List(0);
    }
  }

  RSAPublicKey getPublicKeyFromString(String publicKeyString) {
    try {
      final bytes = base64Decode(publicKeyString);
      final asn1Parser = ASN1Parser(bytes);
      final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

      if (topLevelSeq.elements.length != 2) {
        throw Exception(
            "Invalid public key string: less than two elements in ASN1 sequence");
      }

      final bitString = topLevelSeq.elements[1] as ASN1BitString;
      final publicKeyBytes = bitString
          .valueBytes()
          .sublist(1); // Skip the first byte (unused bits)
      final publicKeyAsn = ASN1Parser(publicKeyBytes);
      final publicKeySeq = publicKeyAsn.nextObject() as ASN1Sequence;

      if (publicKeySeq.elements.length != 2) {
        throw Exception(
            "Invalid public key data: less than two elements in ASN1 sequence");
      }

      final modulus = publicKeySeq.elements[0] as ASN1Integer;
      final exponent = publicKeySeq.elements[1] as ASN1Integer;

      return RSAPublicKey(
          modulus.valueAsBigInteger, exponent.valueAsBigInteger);
    } catch (ex) {
      throw Exception("Failed to parse public key: ${ex.toString()}");
    }
  }

  // END RSA

  // START AES

  String encrypt1(String data, String keyStr, String ivStr) {
    try {
      final key = encryptPackage.Key.fromUtf8(keyStr);
      final iv = encryptPackage.IV.fromUtf8(ivStr);
      final encrypter = encryptPackage.Encrypter(
          encryptPackage.AES(key, mode: encryptPackage.AESMode.gcm));
      final encrypted = encrypter.encrypt(data, iv: iv);
      return encrypted.base64;
    } catch (ex) {
      throw Exception("Failed to encrypt data: ${ex.toString()}");
    }
  }

  String decrypt(String data, String keyStr, String ivStr) {
    try {
      final key = encryptPackage.Key.fromUtf8(keyStr);
      final iv = encryptPackage.IV.fromUtf8(ivStr);
      final encrypter = encryptPackage.Encrypter(
          encryptPackage.AES(key, mode: encryptPackage.AESMode.gcm));
      final decrypted = encrypter.decrypt64(data, iv: iv);
      return decrypted;
    } catch (ex) {
      throw Exception("Failed to decrypt: ${ex.toString()}");
    }
  }

  String hash(String data, String salt) {
    final originalString = '$data$salt';
    final bytes = utf8.encode(originalString);
    final digest = sha256.convert(bytes);
    return bytesToHex(digest.bytes);
  }

  String bytesToHex(List<int> bytes) {
    final hexString = StringBuffer();
    for (var byte in bytes) {
      var hex = byte.toRadixString(16);
      if (hex.length == 1) {
        hexString.write('0');
      }
      hexString.write(hex);
    }
    return hexString.toString();
  }

  String encode(String value) {
    final encodedBytes = base64.encode(utf8.encode(value));
    return utf8.decode(encodedBytes.codeUnits);
  }
}
