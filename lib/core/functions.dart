import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' as io;

import 'package:device_info_plus/device_info_plus.dart';
import "package:pointycastle/export.dart";
import 'package:pointycastle/src/platform_check/platform_check.dart';

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair({
  int bitLength = 2048,
}) {
  // Create an RSA key generator and initialize it

  // final keyGen = KeyGenerator('RSA'); // Get using registry
  final keyGen = RSAKeyGenerator();

  final secureRandom = SecureRandom(
    'Fortuna',
  )..seed(KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));

  keyGen.init(
    ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
      secureRandom,
    ),
  );

  // Use the generator

  final pair = keyGen.generateKeyPair();

  // Cast the generated key pair into the RSA key types

  final myPublic = pair.publicKey;
  final myPrivate = pair.privateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

// Convert RSA public key to a string for storage
String encodePublicKeyToString(RSAPublicKey publicKey) {
  final Map<String, String> data = {
    'modulus': publicKey.modulus.toString(),
    'exponent': publicKey.exponent.toString(),
  };
  return jsonEncode(data);
}

// Convert RSA private key to a string for storage
String encodePrivateKeyToString(RSAPrivateKey privateKey) {
  final Map<String, String> data = {
    'modulus': privateKey.modulus.toString(),
    'privateExponent': privateKey.privateExponent.toString(),
    'p': privateKey.p?.toString() ?? '',
    'q': privateKey.q?.toString() ?? '',
  };
  return jsonEncode(data);
}

// Recreate RSA public key from a stored string
RSAPublicKey decodePublicKeyFromString(String encodedKey) {
  final Map<String, dynamic> data = jsonDecode(encodedKey);
  return RSAPublicKey(
    BigInt.parse(data['modulus']),
    BigInt.parse(data['exponent']),
  );
}

// Recreate RSA private key from a stored string
RSAPrivateKey decodePrivateKeyFromString(String encodedKey) {
  final Map<String, dynamic> data = jsonDecode(encodedKey);

  BigInt? p;
  BigInt? q;

  if (data['p'] != null && data['p'].isNotEmpty) {
    p = BigInt.parse(data['p']);
  }

  if (data['q'] != null && data['q'].isNotEmpty) {
    q = BigInt.parse(data['q']);
  }

  return RSAPrivateKey(
    BigInt.parse(data['modulus']),
    BigInt.parse(data['privateExponent']),
    p,
    q,
  );
}

// Encrypt a message using the recipient's public key
String encryptWithRSA(String plainText, RSAPublicKey publicKey) {
  final cipher = PKCS1Encoding(RSAEngine());
  cipher.init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

  // RSA has a size limit, so we need to ensure our message isn't too long
  // For a 2048-bit key, the maximum message length is about 245 bytes
  final inputBytes = utf8.encode(plainText);

  // For real applications, you'd want to implement chunking for longer messages
  // This is a simplified version for demonstration
  if (inputBytes.length > 245) {
    // Use hybrid encryption for larger data
    return hybridEncrypt(plainText, publicKey);
  }

  final encrypted = cipher.process(Uint8List.fromList(inputBytes));
  return base64.encode(encrypted);
}

// Decrypt a message using your private key
String decryptWithRSA(String encryptedText, RSAPrivateKey privateKey) {
  // Try to decrypt with hybrid method first if the message format indicates it
  if (encryptedText.startsWith('HYBRID:')) {
    return hybridDecrypt(encryptedText, privateKey);
  }

  final cipher = PKCS1Encoding(RSAEngine());
  cipher.init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

  final encrypted = base64.decode(encryptedText);
  final decrypted = cipher.process(Uint8List.fromList(encrypted));

  return utf8.decode(decrypted);
}

// Hybrid encryption for large data (like images)
// Uses AES for the data and RSA for the AES key
String hybridEncrypt(String plainText, RSAPublicKey publicKey) {
  // Generate a random AES key
  final secureRandom = SecureRandom("Fortuna")..seed(
    KeyParameter(Platform.instance.platformEntropySource().getBytes(32)),
  ); // Using 32 bytes (256 bits) as required by Fortuna
  final aesKey = secureRandom.nextBytes(
    32,
  ); // 256-bit AES key for better security

  // Encrypt the data with AES
  // Use a block cipher directly with padding rather than PaddedBlockCipher
  final iv = secureRandom.nextBytes(16); // Use a random IV for better security
  final cbcCipher = CBCBlockCipher(AESEngine())
    ..init(true, ParametersWithIV(KeyParameter(aesKey), iv));

  // Manual PKCS7 padding implementation
  final dataBytes = utf8.encode(plainText);
  final paddedData = _addPKCS7Padding(
    dataBytes,
    16,
  ); // AES block size is 16 bytes
  final encryptedData = Uint8List(paddedData.length);

  // Perform the encryption block by block
  for (var i = 0; i < paddedData.length; i += 16) {
    cbcCipher.processBlock(paddedData, i, encryptedData, i);
  }

  // Encrypt the AES key with RSA
  final rsaCipher = PKCS1Encoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
  final encryptedKey = rsaCipher.process(aesKey);

  // Combine everything in a format that we can parse later
  // Format: HYBRID:<base64_encrypted_key>:<base64_iv>:<base64_encrypted_data>
  final result =
      'HYBRID:${base64.encode(encryptedKey)}:${base64.encode(iv)}:${base64.encode(encryptedData)}';

  return result;
}

// Helper function to add PKCS7 padding
Uint8List _addPKCS7Padding(Uint8List data, int blockSize) {
  final padLength = blockSize - (data.length % blockSize);
  final padded = Uint8List(data.length + padLength);
  padded.setRange(0, data.length, data);
  padded.fillRange(data.length, padded.length, padLength);
  return padded;
}

// Helper function to remove PKCS7 padding
Uint8List _removePKCS7Padding(Uint8List data) {
  final padLength = data[data.length - 1];
  return data.sublist(0, data.length - padLength);
}

// Decrypt data that was encrypted with hybrid encryption
String hybridDecrypt(String encryptedText, RSAPrivateKey privateKey) {
  // Parse the format: HYBRID:<base64_encrypted_key>:<base64_iv>:<base64_encrypted_data>
  final parts = encryptedText.split(':');
  if (parts.length != 4 || parts[0] != 'HYBRID') {
    throw Exception('Invalid hybrid encrypted format');
  }

  final encryptedKey = base64.decode(parts[1]);
  final iv = base64.decode(parts[2]);
  final encryptedData = base64.decode(parts[3]);

  // Decrypt the AES key with RSA
  final rsaCipher = PKCS1Encoding(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
  final aesKey = rsaCipher.process(Uint8List.fromList(encryptedKey));

  // Decrypt the data with AES
  final cbcCipher = CBCBlockCipher(AESEngine())..init(
    false,
    ParametersWithIV(KeyParameter(Uint8List.fromList(aesKey)), iv),
  );

  final decryptedData = Uint8List(encryptedData.length);

  // Perform the decryption block by block
  for (var i = 0; i < encryptedData.length; i += 16) {
    cbcCipher.processBlock(encryptedData, i, decryptedData, i);
  }

  // Remove padding
  final unpaddedData = _removePKCS7Padding(decryptedData);

  return utf8.decode(unpaddedData);
}

Future<String?> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();

  if (io.Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    // On Android this is a 64‑bit hex string that survives app reinstalls
    return androidInfo.id;
  } else if (io.Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    // On iOS this is the identifierForVendor
    return iosInfo.identifierForVendor;
  } else {
    // Web, desktop, etc. don’t have a stable device ID via this plugin
    return null;
  }
}
