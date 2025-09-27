import { Controller, Get, Post, Put, Delete, Param, Body, Logger, UseGuards, Request } from '@nestjs/common';
import { BarsService } from './bars.service';
import { CreateBarDto } from './create-bar.dto';
import { Bar } from './bar.schema';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { RolesGuard, Roles } from '../../auth/roles.guard';

@Controller('bars')
export class BarsController {
  private readonly logger = new Logger(BarsController.name);

  constructor(private readonly barsService: BarsService) {}

 @Post()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('owner', 'admin')

async create(@Body() createBarDto: CreateBarDto, @Request() req): Promise<Bar> {
  
  this.logger.log(`Intentando crear bar: ${createBarDto.nameBar}`);

  // Debugging: imprimir usuario autenticado obtenido del token JWT
  console.log('BarsController - Usuario autenticado req.user:', req.user);

  try {
    // Asignar automáticamente el ownerId desde el usuario autenticado
    createBarDto.ownerId = req.user.userId;

    const bar = await this.barsService.create(createBarDto);
    this.logger.log(`Bar creado exitosamente: ${bar.nameBar}`);
    return bar;
  } catch (error) {
    this.logger.error(`Error al crear bar: ${error.message}`);
    throw error;
  }
}


  @Get()
  async findAll(): Promise<Bar[]> {
    this.logger.log('Recibiendo solicitud para listar todos los bares');
    return this.barsService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<Bar> {
    this.logger.log(`Recibiendo solicitud para obtener bar con id: ${id}`);
    return this.barsService.findOne(id);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async update(@Param('id') id: string, @Body() updateBarDto: Partial<CreateBarDto>): Promise<Bar> {
    this.logger.log(`Recibiendo solicitud para actualizar bar con id: ${id}`);
    return this.barsService.update(id, updateBarDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async remove(@Param('id') id: string): Promise<void> {
    this.logger.log(`Recibiendo solicitud para eliminar bar con id: ${id}`);
    return this.barsService.remove(id);
  }
}
