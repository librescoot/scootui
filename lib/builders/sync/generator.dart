import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'settings.dart';
import 'annotations.dart';
import 'reader_helpers.dart';

class _EnumType {
  final String name;
  final List<String> fields;

  _EnumType(this.name, this.fields);

  get mapName => "\$_${name}Map";

  String generate() {
    final buf = StringBuffer();
    buf.writeln("final $mapName = {");
    for (final f in fields) {
      buf.writeln('"${camelToKebab(f)}": $name.$f,');
    }
    buf.writeln("};");

    return buf.toString();
  }
}

final _stateFieldChecker = TypeChecker.fromRuntime(StateField);
final _setFieldChecker = TypeChecker.fromRuntime(SetField);
final _stateDiscriminatorChecker = TypeChecker.fromRuntime(StateDiscriminator);

class StateGenerator extends GeneratorForAnnotation<StateClass> {
  @override
  Iterable<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) sync* {
    final fields = List<SyncFieldSettings>.empty(growable: true);
    final setFields = List<SyncSetFieldSettings>.empty(growable: true);
    final enumsFields = <String, _EnumType>{};
    String? discriminator;

    for (final child in element.children) {
      if (child is FieldElement) {
        final element = child.type.element;
        if (element == null) continue;

        if (element is EnumElement) {
          final en = _EnumType(
            child.type.getDisplayString(),
            enumFields(element),
          );

          yield en.generate();

          enumsFields[child.name] = en;
        }

        for (final ann in _stateFieldChecker.annotationsOf(child)) {
          fields.add(stateFieldFromObject(child.name, child.type, ann));
        }

        for (final ann in _setFieldChecker.annotationsOf(child)) {
          setFields.add(setFieldFromObject(child.name, child.type, ann));
        }

        for (final _ in _stateDiscriminatorChecker.annotationsOf(child)) {
          if (discriminator != null) {
            throw ArgumentError(
                "There can only be one discriminator in a state class");
          }

          discriminator = child.name;
        }

        // final meta = child.metadata;
        // for (final ann in meta) {
        //   final el = ann.element;
        //   final fann = el != null
        //       ? _stateFieldChecker.firstAnnotationOf(el)
        //       : null;
        //   final dann = el != null ? : null;
        //
        //   print("${child.name} - $ann - ${ann.computeConstantValue()} - ${ann
        //       .runtimeType} - ${fann} - ${dann}");
        //
        //   // TODO: ignore unrelated annotations
        //
      }
    }

    final state = stateFromReader(annotation, fields, setFields, discriminator);

    final buf = StringBuffer();

    buf.writeln('''
    abstract mixin class \$${element.name} implements Syncable<${element.name}> {
    ''');

    if (discriminator != null) {
      buf.writeln("dynamic get $discriminator;");
    }
    for (final f in fields) {
      buf.writeln("${f.typeName} get ${f.name};");
    }
    for (final f in setFields) {
      buf.writeln("${f.typeName} get ${f.name};");
    }

    buf.writeln('''
      get syncSettings => ${state.toString()};

      @override
      ${element.name} update(String name, String value) {
       return ${element.name}(
        ''');

    if (discriminator != null) {
      buf.writeln("$discriminator:$discriminator,");
    }

    for (final field in state.fields) {
      buf.write(
        '${field.name}: "${field.variable}" != name ? ${field.name} : ',
      );

      switch (field.type) {
        case SyncFieldType.bool:
        case SyncFieldType.num:
        case SyncFieldType.int:
        case SyncFieldType.double:
          buf.writeln("${field.type.name}.parse(value),");
        case SyncFieldType.string:
          buf.writeln("value,");
        case SyncFieldType.enum_:
          final e = enumsFields[field.name];

          buf.writeln(
            '${e!.mapName}[value] ?? ${field.typeName}.${field.defaultValue},',
          );
        case SyncFieldType.set_int:
        case SyncFieldType.set_string:
          // Set fields are handled by updateSet(), not update()
          buf.writeln("${field.name},");
      }
    }

    // Preserve Set fields in update() method
    for (final field in state.setFields) {
      buf.writeln('${field.name}: ${field.name},');
    }

    buf.writeln('''
        );
      }''');

    // Generate updateSet method for Set fields
    buf.writeln('''
      @override
      ${element.name} updateSet(String name, Set<dynamic> value) {
       return ${element.name}(
        ''');

    if (discriminator != null) {
      buf.writeln("$discriminator:$discriminator,");
    }

    for (final field in state.fields) {
      buf.writeln('${field.name}: ${field.name},');
    }

    for (final field in state.setFields) {
      buf.write('${field.name}: "${field.name}" != name ? ${field.name} : ');

      switch (field.elementType) {
        case SyncFieldType.set_int:
          buf.writeln('value.cast<int>(),');
          break;
        case SyncFieldType.set_string:
          buf.writeln('value.cast<String>(),');
          break;
        default:
          buf.writeln('value,');
      }
    }

    buf.writeln('''
        );
      }''');

    final allFields = [
      ...state.fields.map((f) => f.name),
      ...state.setFields.map((f) => f.name)
    ];
    buf.writeln(
      "List<Object?> get props => [${allFields.join(",")}];",
    );

    buf.writeln('''
      @override
      String toString() {
        final buf = StringBuffer();
        
        buf.writeln("${element.name}(");''');

    for (final field in fields) {
      buf.writeln('buf.writeln("\t${field.name} = \$${field.name}");');
    }

    for (final field in setFields) {
      buf.writeln('buf.writeln("\t${field.name} = \$${field.name}");');
    }

    buf.writeln('''
      buf.writeln(")");
      
      return buf.toString();
      }
    }
  ''');

    yield buf.toString();
  }
}
