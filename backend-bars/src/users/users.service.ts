import { Injectable, ConflictException, Logger, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import * as bcrypt from 'bcrypt';
import { User } from './user.schema';
import { CreateUserDto } from './dto/create-user.dto';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(@InjectModel(User.name) private userModel: Model<User>) {}

  async register(createUserDto: CreateUserDto): Promise<User> {
    this.logger.log(`Intentando registrar usuario: ${createUserDto.email}`);

    const existing = await this.userModel.findOne({ email: createUserDto.email });
    if (existing) {
      this.logger.warn(`Intento de registro duplicado para email: ${createUserDto.email}`);
      throw new ConflictException('Este correo ya está registrado');
    }

    const hashedPassword = await bcrypt.hash(createUserDto.password, 10);
    const role = createUserDto.role ?? 'client';

    const newUser = new this.userModel({
      ...createUserDto,
      password: hashedPassword,
      role,
    });

    const savedUser = await newUser.save();
    
    // Log detallado de registro exitoso
    console.log('✅ REGISTRO EXITOSO');
    console.log(`📧 Usuario registrado: ${savedUser.email}`);
    console.log(`👤 Nombre: ${savedUser.name}`);
    console.log(`🎭 Rol: ${savedUser.role}`);
    console.log(`🆔 ID: ${savedUser._id}`);
    console.log('-----------------------------------');
    
    return savedUser;
  }

  async findByEmail(email: string): Promise<User | null> {
    this.logger.log(`Buscando usuario por email: ${email}`);
    return this.userModel.findOne({ email }).exec();
  }

  async findAll(): Promise<User[]> {
    this.logger.log('Obteniendo todos los usuarios');
    return this.userModel.find().exec();
  }

  async findOne(id: string): Promise<User> {
    this.logger.log(`Buscando usuario con id: ${id}`);
    const user = await this.userModel.findById(id).exec();
    if (!user) {
      this.logger.warn(`Usuario con id ${id} no encontrado`);
      throw new NotFoundException(`Usuario con id ${id} no encontrado`);
    }
    return user;
  }

  async update(id: string, updateUserDto: Partial<CreateUserDto>): Promise<User> {
    this.logger.log(`Intentando actualizar usuario con id: ${id}`);

    // No permitir cambio de email ni role en esta función
    if ('email' in updateUserDto) {
      delete updateUserDto.email;
      this.logger.warn(`Intento de cambiar email bloqueado para usuario con id: ${id}`);
    }
    if ('role' in updateUserDto) {
      delete updateUserDto.role;
      this.logger.warn(`Intento de cambiar rol bloqueado para usuario con id: ${id}`);
    }

    if (updateUserDto.password) {
      updateUserDto.password = await bcrypt.hash(updateUserDto.password, 10);
      this.logger.log(`Contraseña encriptada para usuario con id: ${id}`);
    }

    const updatedUser = await this.userModel.findByIdAndUpdate(id, updateUserDto, { new: true }).exec();
    if (!updatedUser) {
      this.logger.warn(`No se pudo actualizar. Usuario con id ${id} no encontrado`);
      throw new NotFoundException(`Usuario con id ${id} no encontrado`);
    }
    this.logger.log(`Usuario con id ${id} actualizado correctamente`);
    return updatedUser;
  }

  async remove(id: string): Promise<void> {
    this.logger.log(`Intentando eliminar usuario con id: ${id}`);

    const result = await this.userModel.findByIdAndDelete(id).exec();

    if (!result) {
      this.logger.warn(`No se pudo eliminar. Usuario con id ${id} no encontrado`);
      throw new NotFoundException(`Usuario con id ${id} no encontrado`);
    }

    this.logger.log(`Usuario con id ${id} eliminado correctamente`);
  }
}
