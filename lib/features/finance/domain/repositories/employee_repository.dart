import '../entities/employee_entity.dart';

abstract class EmployeeRepository {
  Future<List<EmployeeEntity>> getEmployees({bool includeInactive = false});
  Future<EmployeeEntity> createEmployee(EmployeeEntity employee);
  Future<EmployeeEntity> updateEmployee(EmployeeEntity employee);
  Future<void> deleteEmployee(int id);
}
