import 'dart:convert';
import 'dart:typed_data';

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
    throw Exception('Message too long for RSA encryption without chunking');
  }

  final encrypted = cipher.process(Uint8List.fromList(inputBytes));
  return base64.encode(encrypted);
}

// Decrypt a message using your private key
String decryptWithRSA(String encryptedText, RSAPrivateKey privateKey) {
  final cipher = PKCS1Encoding(RSAEngine());
  cipher.init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

  final encrypted = base64.decode(encryptedText);
  final decrypted = cipher.process(Uint8List.fromList(encrypted));

  return utf8.decode(decrypted);
}

// For End-to-End encryption in a chat app:
// 1. Each user generates their own key pair (public & private)
// 2. Each user stores their private key securely and shares their public key
// 3. To send a message, encrypt it with the recipient's public key
// 4. The recipient decrypts it with their private key
