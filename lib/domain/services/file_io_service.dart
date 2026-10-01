import 'dart:io';

import 'package:flutter/material.dart';

abstract class FileIoService {
  Future<String?> pickFile({required List<String> allowedExtensions});
  Future<String?> saveFile({required String fileName, required String content});
}
