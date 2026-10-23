import 'package:midlandmarketing/features/users/data/models/user_model.dart';
import 'package:midlandmarketing/features/users/domain/entities/user.dart';

// Demo accounts only. A real app would never ship passwords like this.
const List<UserModel> dummyUsers = [
  UserModel(
    id: 'u1',
    name: 'Ramasubramaniyan S',
    email: 'admin@test.com',
    role: UserRole.admin,
    password: 'Admin@123',
  ),
  UserModel(
    id: 'u2',
    name: 'Priya Ragunathan',
    email: 'senior@test.com',
    role: UserRole.seniorStaff,
    password: 'Senior@123',
  ),
  UserModel(
    id: 'u3',
    name: 'Ari Ramachandran',
    email: 'senior2@test.com',
    role: UserRole.seniorStaff,
    password: 'Senior@123',
  ),
  UserModel(
    id: 'u4',
    name: 'Stalin Britto',
    email: 'senior3@test.com',
    role: UserRole.seniorStaff,
    password: 'Senior@123',
  ),
  UserModel(
    id: 'u5',
    name: 'Rahul Verma',
    email: 'staff@test.com',
    role: UserRole.staff,
    password: 'Staff@123',
  ),
];
