import 'package:wialog_erp/features/finance/data/datasources/employee_data_source.dart';

import '../../domain/entities/employee_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeDataSource dataSource;

  EmployeeRepositoryImpl(this.dataSource);

  @override
  Future<List<EmployeeEntity>> getEmployees({
    bool includeInactive = false,
  }) async {
    return await dataSource.getEmployees(includeInactive: includeInactive);
  }

  @override
  Future<EmployeeEntity> createEmployee(EmployeeEntity employee) async {
    return await dataSource.createEmployee(EmployeeModel.fromEntity(employee));
  }

  @override
  Future<EmployeeEntity> updateEmployee(EmployeeEntity employee) async {
    return await dataSource.updateEmployee(EmployeeModel.fromEntity(employee));
  }

  @override
  Future<void> deleteEmployee(int id) async {
    await dataSource.deleteEmployee(id);
  }
}
