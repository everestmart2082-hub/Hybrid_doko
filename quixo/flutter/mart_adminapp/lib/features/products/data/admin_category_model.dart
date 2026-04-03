import 'package:equatable/equatable.dart';

// ─── Category List Item (public endpoint) ───────────────────────────────────
// GET /category/all returns: {"id": 1, "name": "...", "_id": ObjectID}

class CategoryListItem extends Equatable {
  final int id;
  final String name;
  final String objectId; // the MongoDB _id
  final String deliveryType;
  final String requiredFields;
  final String otherFields;

  const CategoryListItem({
    required this.id,
    required this.name,
    required this.objectId,
    this.deliveryType = '',
    this.requiredFields = '',
    this.otherFields = '',
  });

  factory CategoryListItem.fromMap(Map<String, dynamic> map) => CategoryListItem(
        id: (map['id'] as num?)?.toInt() ?? 0,
        name: map['name'] as String? ?? '',
        objectId: map['_id']?.toString() ?? '',
        deliveryType: map['delivery_type']?.toString() ?? '',
        requiredFields: map['required_fields']?.toString() ?? '',
        otherFields: map['other_fields']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [id, name, objectId, deliveryType, requiredFields, otherFields];
}

// ─── Category Add/Edit Request ───────────────────────────────────────────────
// Server reads: c.PostForm("name"), "quick/normal", "required", "others"
// For edit: also "category id"

class AdminCategoryRequest extends Equatable {
  final String name;
  final String deliveryType; // "quick" or "normal" — field name: "quick/normal"
  final String requiredFields;
  final String otherFields;

  const AdminCategoryRequest({
    required this.name,
    required this.deliveryType,
    required this.requiredFields,
    required this.otherFields,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'quick/normal': deliveryType, // exact server field name with slash
        'required': requiredFields,
        'others': otherFields,
      };

  @override
  List<Object?> get props => [name, deliveryType, requiredFields, otherFields];
}
