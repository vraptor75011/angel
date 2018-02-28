library angel_serialize_generator;

import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:angel_serialize/angel_serialize.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart' hide LibraryBuilder;
import 'build_context.dart';
import 'context.dart';
part 'model.dart';

/// Converts a [DartType] to a [TypeReference].
TypeReference convertTypeReference(DartType t) {
  return new TypeReference((b) {
    b..symbol = t.name;

    if (t is InterfaceType) {
      b.types.addAll(t.typeArguments.map(convertTypeReference));
    }
  });
}