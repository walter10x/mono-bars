import { IsString, IsEmail, MinLength, MaxLength, IsIn, IsOptional } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  password: string;

  @IsString()
  @MaxLength(50)
  name: string;

  @IsOptional()
  @IsString()
  @MinLength(9, { message: 'El teléfono debe tener al menos 9 dígitos' })
  @MaxLength(15, { message: 'El teléfono no puede tener más de 15 dígitos' })
  phone?: string;

  @IsOptional()
  @IsIn(['owner', 'client', 'admin'], {
    message: 'Role debe ser uno de los siguientes valores: owner, client, admin',
  })
  role?: 'owner' | 'client' | 'admin';
}
