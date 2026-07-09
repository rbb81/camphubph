enum UserRole {
  camper('camper', 'Camper'),
  campOwner('camp_owner', 'Camp Owner');

  const UserRole(this.value, this.label);

  final String value;
  final String label;

  static UserRole fromValue(String? value) => UserRole.values.firstWhere(
    (role) => role.value == value,
    orElse: () => UserRole.camper,
  );
}
