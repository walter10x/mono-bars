import { IsNotEmpty, IsString, MinLength, MaxLength } from 'class-validator';

export class OwnerResponseDto {
  @IsNotEmpty({ message: 'La respuesta es requerida' })
  @IsString()
  @MinLength(10, { message: 'La respuesta debe tener al menos 10 caracteres' })
  @MaxLength(300, { message: 'La respuesta no puede exceder 300 caracteres' })
  response: string;
}
