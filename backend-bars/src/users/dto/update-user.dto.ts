import { IsString, IsOptional, MinLength, MaxLength } from 'class-validator';

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  @MaxLength(50)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  firstName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  lastName?: string;

  @IsOptional()
  @IsString()
  @MinLength(9, { message: 'El teléfono debe tener al menos 9 dígitos' })
  @MaxLength(15, { message: 'El teléfono no puede tener más de 15 dígitos' })
  phone?: string;
}
