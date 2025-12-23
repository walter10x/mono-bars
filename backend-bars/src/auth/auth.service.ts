// src/auth/auth.service.ts
import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { User } from '../users/user.schema';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';
import { ResendService } from '../common/services/resend.service';
import * as crypto from 'crypto';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private resendService: ResendService,
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
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      favoriteBars: user.favoriteBars || [],
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

  /**
   * Solicita el restablecimiento de contraseña
   * Genera un token seguro, lo guarda en la BD y envía email
   */
  async requestPasswordReset(email: string): Promise<{ message: string }> {
    try {
      // Buscar usuario por email
      const user = await this.usersService.findByEmail(email);

      // SEGURIDAD: Siempre retornar el mismo mensaje, exista o no el usuario
      // Esto previene ataques de enumeración de emails
      if (!user) {
        console.log('🔒 Solicitud de reset para email no registrado:', email);
        console.log('⏰ Fecha:', new Date().toISOString());
        console.log('-----------------------------------');
        
        // Retornar mensaje genérico (no revelar que el email no existe)
        return {
          message: 'Si el email existe en nuestro sistema, recibirás un correo con instrucciones para restablecer tu contraseña.',
        };
      }

      // Generar token aleatorio seguro (32 bytes = 64 caracteres hexadecimales)
      const resetToken = crypto.randomBytes(32).toString('hex');

      // Hash del token para almacenarlo de forma segura en la BD
      const hashedToken = await bcrypt.hash(resetToken, 10);

      // Establecer expiración del token (1 hora desde ahora)
      const expiresAt = new Date();
      expiresAt.setHours(expiresAt.getHours() + 1);

      // Actualizar usuario con el token hasheado y su expiración
      await this.usersService.updateResetToken((user as any)._id.toString(), hashedToken, expiresAt);

      // Enviar email con el token en texto plano (solo se envía una vez)
      await this.resendService.sendPasswordResetEmail(user.email, resetToken);

      console.log('✅ SOLICITUD DE RESET DE CONTRASEÑA');
      console.log(`📧 Email: ${user.email}`);
      console.log(`🆔 User ID: ${user._id}`);
      console.log(`⏰ Token expira: ${expiresAt.toISOString()}`);
      console.log('-----------------------------------');

      return {
        message: 'Si el email existe en nuestro sistema, recibirás un correo con instrucciones para restablecer tu contraseña.',
      };
    } catch (error) {
      console.error('❌ Error en requestPasswordReset:', error);
      
      // Retornar mensaje genérico incluso si hay error (seguridad)
      return {
        message: 'Si el email existe en nuestro sistema, recibirás un correo con instrucciones para restablecer tu contraseña.',
      };
    }
  }

  /**
   * Restablece la contraseña usando el token
   */
  async resetPassword(token: string, newPassword: string): Promise<{ message: string }> {
    try {
      // Buscar usuarios con tokens de reset activos (no expirados)
      const users = await this.usersService.findUsersWithActiveResetTokens();

      if (!users || users.length === 0) {
        throw new BadRequestException('Token de restablecimiento inválido o expirado');
      }

      // Buscar el usuario cuyo token hasheado coincida con el token proporcionado
      let matchedUser: User | null = null;
      for (const user of users) {
        const isMatch = await bcrypt.compare(token, user.resetPasswordToken);
        if (isMatch) {
          matchedUser = user;
          break;
        }
      }

      if (!matchedUser) {
        throw new BadRequestException('Token de restablecimiento inválido o expirado');
      }

      // Hashear la nueva contraseña
      const hashedPassword = await bcrypt.hash(newPassword, 10);

      // Actualizar la contraseña y limpiar los campos de reset
      await this.usersService.updatePassword((matchedUser as any)._id.toString(), hashedPassword);

      console.log('✅ CONTRASEÑA RESTABLECIDA');
      console.log(`📧 Email: ${matchedUser.email}`);
      console.log(`🆔 User ID: ${matchedUser._id}`);
      console.log(`⏰ Fecha: ${new Date().toISOString()}`);
      console.log('-----------------------------------');

      return {
        message: 'Contraseña restablecida exitosamente. Ahora puedes iniciar sesión con tu nueva contraseña.',
      };
    } catch (error) {
      console.error('❌ Error en resetPassword:', error);
      
      if (error instanceof BadRequestException) {
        throw error;
      }
      
      throw new BadRequestException('Error al restablecer la contraseña. Por favor, solicita un nuevo enlace de restablecimiento.');
    }
  }
}

