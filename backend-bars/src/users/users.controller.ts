import { Controller, Post, Get, Put, Patch, Delete, Param, Body, NotFoundException, ForbiddenException, Req, UseGuards, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { User } from './user.schema';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('register')
  async register(@Body() createUserDto: CreateUserDto): Promise<{ user: User; message: string }> {
    // Aquí permites opcionalmente que el role venga en createUserDto, será validado en DTO y servicio
    const user = await this.usersService.register(createUserDto);
    return {
      user,
      message: 'Usuario creado exitosamente. Ya puedes iniciar sesión con tus credenciales.'
    };
  }

  @Get()
  async findAll(): Promise<User[]> {
    // Este endpoint debería protegerse para admins solo, sino cualquiera puede obtener todos usuarios
    return this.usersService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<User> {
    const user = await this.usersService.findOne(id);
    if (!user) {
      throw new NotFoundException(`Usuario con id ${id} no encontrado`);
    }
    return user;
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id')
  async update(@Param('id') id: string, @Body() updateUserDto: Partial<CreateUserDto>, @Request() req): Promise<User> {
    // Validar que el usuario solo pueda actualizar su propia cuenta (comparando como strings)
    if (String(req.user.userId) !== String(id)) {
      throw new ForbiddenException('No tienes permiso para actualizar este usuario');
    }
    return this.usersService.update(id, updateUserDto);
  }

  /**
   * Endpoint PATCH para actualizaciones parciales (ej: cambio de rol)
   * Permite al usuario autenticado actualizar sus propios datos
   */
  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() updateUserDto: Partial<CreateUserDto>, @Request() req): Promise<User> {
    // Validar que el usuario solo pueda actualizar su propia cuenta
    if (String(req.user.userId) !== String(id)) {
      throw new ForbiddenException('No tienes permiso para actualizar este usuario');
    }
    
    console.log('🔄 PATCH - Actualizando usuario:');
    console.log('ID:', id);
    console.log('Datos:', updateUserDto);
    console.log('-----------------------------------');
    
    return this.usersService.update(id, updateUserDto);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id/change-password')
  async changePassword(
    @Param('id') id: string,
    @Body() changePasswordDto: ChangePasswordDto,
    @Request() req
  ): Promise<{ message: string }> {
    // NOTA: No validamos ID aquí porque la seguridad está en el servicio
    // que valida la contraseña actual. Solo el usuario con la contraseña
    // correcta puede cambiarla, independientemente del ID en la URL.
    // El usuario autenticado solo puede cambiar su propia contraseña porque
    // solo él conoce su contraseña actual.
    
    console.log('🔐 CAMBIAR CONTRASEÑA');
    console.log('Usuario autenticado:', req.user.email);
    console.log('ID del usuario:', req.user.userId);
    console.log('-----------------------------------');

    // Usamos el ID del JWT (usuario autenticado) en lugar del parámetro
    return this.usersService.changePassword(req.user.userId, changePasswordDto);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  async remove(@Param('id') id: string, @Request() req): Promise<void> {
    // Validar que solo el usuario pueda eliminar su propia cuenta (comparando como strings)
    if (String(req.user.userId) !== String(id)) {
      throw new ForbiddenException('No tienes permiso para eliminar este usuario');
    }
    return this.usersService.remove(id);
  }
}
