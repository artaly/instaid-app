class Hotlines {
  String? department_name;
  String? department_number;

  Hotlines();

  Map<String, dynamic> toJson() => {
        'department_name': department_name,
        'department_number': department_number
      };

  Hotlines.fromSnapshot(snapshot)
      : department_name = snapshot.data()['department_name'],
        department_number = snapshot.data()['department_number'];
}
