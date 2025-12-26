// src/auth/google-auth.dto.ts
import { IsString, IsNotEmpty } from 'class-validator';

/**
 * DTO para recibir el token de Google desde el frontend
 */
export class GoogleAuthDto {
  @IsString()
  @IsNotEmpty()
  idToken: string;
}
