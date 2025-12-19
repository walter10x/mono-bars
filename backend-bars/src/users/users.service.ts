import { Injectable, ConflictException, Logger, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import * as bcrypt from 'bcrypt';
import { User } from './user.schema';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ChangePasswordDto } from './dto/change-password.dto';

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

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    this.logger.log(`Intentando actualizar usuario con id: ${id}`);

    // Si se actualizan firstName o lastName, sincronizar el campo name
    if (updateUserDto.firstName || updateUserDto.lastName) {
      const user = await this.findOne(id);
      const firstName = updateUserDto.firstName ?? user.firstName ?? '';
      const lastName = updateUserDto.lastName ?? user.lastName ?? '';
      
      // Actualizar el campo name con la combinación de firstName y lastName
      if (firstName && lastName) {
        (updateUserDto as any).name = `${firstName} ${lastName}`;
      } else if (firstName) {
        (updateUserDto as any).name = firstName;
      } else if (lastName) {
        (updateUserDto as any).name = lastName;
      }
      
      this.logger.log(`Campo 'name' sincronizado: ${(updateUserDto as any).name}`);
    }

    const updatedUser = await this.userModel.findByIdAndUpdate(id, updateUserDto, { new: true }).exec();
    if (!updatedUser) {
      this.logger.warn(`No se pudo actualizar. Usuario con id ${id} no encontrado`);
      throw new NotFoundException(`Usuario con id ${id} no encontrado`);
    }
    this.logger.log(`Usuario con id ${id} actualizado correctamente`);
    return updatedUser;
  }

  async changePassword(id: string, changePasswordDto: ChangePasswordDto): Promise<{ message: string }> {
    this.logger.log(`Intentando cambiar contraseña para usuario con id: ${id}`);

    const user = await this.findOne(id);
    
    // Verificar contraseña actual
    const isValid = await bcrypt.compare(
      changePasswordDto.currentPassword,
      user.password
    );
    
    if (!isValid) {
      this.logger.warn(`Intento de cambio de contraseña con contraseña actual incorrecta para id: ${id}`);
      throw new UnauthorizedException('La contraseña actual es incorrecta');
    }
    
    // Actualizar contraseña
    const hashedPassword = await bcrypt.hash(changePasswordDto.newPassword, 10);
    await this.userModel.findByIdAndUpdate(id, { password: hashedPassword });
    
    // Log de cambio exitoso
    console.log('🔐 CAMBIO DE CONTRASEÑA EXITOSO');
    console.log(`📧 Usuario: ${user.email}`);
    console.log(`🆔 ID: ${id}`);
    console.log(`⏰ Fecha: ${new Date().toISOString()}`);
    console.log('-----------------------------------');
    
    this.logger.log(`Contraseña cambiada exitosamente para usuario con id: ${id}`);
    return { message: 'Contraseña actualizada correctamente' };
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
