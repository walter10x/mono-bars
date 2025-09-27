import { Controller, Post, Get, Put, Delete, Param, Body, NotFoundException, ForbiddenException, Req } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { User } from './user.schema';

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

  @Put(':id')
  async update(@Param('id') id: string, @Body() updateUserDto: Partial<CreateUserDto>, @Req() req): Promise<User> {
    // Debes validar que el usuario autenticado solo pueda actualizar su propia cuenta (req.user.id === id)
    // y evitar cambiar email o role (ya controlado en servicio)
    // Aquí simulo el chequeo, reemplaza con guard real cuando tengas auth:
    if (req.user?.id !== id) {
      throw new ForbiddenException('No tienes permiso para actualizar este usuario');
    }
    return this.usersService.update(id, updateUserDto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string, @Req() req): Promise<void> {
    // Igual que en update, validar que solo el propio usuario pueda eliminar su cuenta
    if (req.user?.id !== id) {
      throw new ForbiddenException('No tienes permiso para eliminar este usuario');
    }
    return this.usersService.remove(id);
  }
}
