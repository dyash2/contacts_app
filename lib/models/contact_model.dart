class Contact {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? company;
  final String? notes;
  final bool isFavorite;
  final String? avatarColor;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.company,
    this.notes,
    this.isFavorite = false,
    this.avatarColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'company': company,
      'notes': notes,
      'is_favorite': isFavorite ? 1 : 0,
      'avatar_color': avatarColor,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      company: map['company'] as String?,
      notes: map['notes'] as String?,
      isFavorite: (map['is_favorite'] as int) == 1,
      avatarColor: map['avatar_color'] as String?,
    );
  }

  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? company,
    String? notes,
    bool? isFavorite,
    String? avatarColor,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  String toString() => 'Contact(id: $id, name: $name, phone: $phone)';
}
