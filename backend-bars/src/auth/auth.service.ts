// src/auth/auth.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async validateUser(email: string, password: string) {
    const user = await this.usersService.findByEmail(email);
    
    if (!user) {
      // Log de intento fallido por usuario no encontrado
      console.log('❌ INTENTO DE LOGIN FALLIDO');
      console.log(`📧 Email no encontrado: ${email}`);
      console.log(`⏰ Fecha: ${new Date().toISOString()}`);
      console.log('🔍 Motivo: Usuario no existe');
      console.log('-----------------------------------');
      
      throw new UnauthorizedException('Login fallido: credenciales de autenticación incorrectas');
    }

    const passwordValid = await bcrypt.compare(password, user.password);
    
    if (!passwordValid) {
      // Log de intento fallido por contraseña incorrecta
      console.log('❌ INTENTO DE LOGIN FALLIDO');
      console.log(`📧 Email: ${email}`);
      console.log(`⏰ Fecha: ${new Date().toISOString()}`);
      console.log('🔍 Motivo: Contraseña incorrecta');
      console.log('-----------------------------------');
      
      throw new UnauthorizedException('Login fallido: credenciales de autenticación incorrectas');
    }

    const { password: _, ...result } = user.toObject();
    return result;
  }

  async login(user: any) {
    // IMPORTANTE: Convertir _id a string para evitar problemas con ObjectId
    const payload = { 
      email: user.email, 
      sub: user._id.toString(), // Convertir a string
      role: user.role 
    };
    
    // Log de login exitoso
    console.log('✅ LOGIN EXITOSO');
    console.log(`📧 Usuario logueado: ${user.email}`);
    console.log(`👤 Rol: ${user.role}`);
    console.log(`🆔 ID: ${user._id.toString()}`);
    console.log('-----------------------------------');
    
    // Preparar objeto de usuario limpio (sin password)
    const userObject = {
      id: user._id.toString(),
      email: user.email,
      name: user.name,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
    
    return {
      access_token: this.jwtService.sign(payload),
      user: userObject, // ← Usuario completo incluido
    };
  }

  async logout(user: any) {
    // Log de logout exitoso
    console.log('👋 LOGOUT EXITOSO');
    console.log(`📧 Usuario: ${user.email}`);
    console.log(`👤 Rol: ${user.role}`);
    console.log(`🆔 ID: ${user.sub}`);
    console.log(`⏰ Fecha: ${new Date().toISOString()}`);
    console.log('-----------------------------------');
    
    return {
      success: true,
      message: 'Sesión cerrada correctamente',
    };
  }
}
