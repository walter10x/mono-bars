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
  @IsIn(['owner', 'client', 'admin'], {
    message: 'Role debe ser uno de los siguientes valores: owner, client, admin',
  })
  role?: 'owner' | 'client' | 'admin';
}
