import { Controller, Post, Get, Put, Delete, Param, Body, NotFoundException, ForbiddenException, Req, UseGuards, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { User } from './user.schema';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('register')
  async register(@Body() createUserDto: CreateUserDto): Promise<User> {
    // Aquí permites opcionalmente que el role venga en createUserDto, será validado en DTO y servicio
    return this.usersService.register(createUserDto);
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
    // Debes validar que el usuario autenticado solo pueda actualizar su propia cuenta (req.user.id === id)
    // y evitar cambiar email o role (ya controlado en servicio)
    if (req.user.sub !== id) {
      throw new ForbiddenException('No tienes permiso para actualizar este usuario');
    }
    return this.usersService.update(id, updateUserDto);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id/change-password')
  async changePassword(
    @Param('id') id: string,
    @Body() changePasswordDto: ChangePasswordDto,
    @Request() req
  ): Promise<{ message: string }> {
    // Verificar que sea el mismo usuario
    if (req.user.sub !== id) {
      throw new ForbiddenException('No tienes permiso para cambiar la contraseña de otro usuario');
    }
    return this.usersService.changePassword(id, changePasswordDto);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  async remove(@Param('id') id: string, @Request() req): Promise<void> {
    // Igual que en update, validar que solo el propio usuario pueda eliminar su cuenta
    if (req.user.sub !== id) {
      throw new ForbiddenException('No tienes permiso para eliminar este usuario');
    }
    return this.usersService.remove(id);
  }
}
