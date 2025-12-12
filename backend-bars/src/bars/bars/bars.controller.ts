import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Logger,
  UseGuards,
  Request,
  UseInterceptors,
  UploadedFile,
  ForbiddenException,
} from '@nestjs/common';
import { BarsService } from './bars.service';
import { CreateBarDto } from './create-bar.dto';
import { Bar } from './bar.schema';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { RolesGuard, Roles } from '../../auth/roles.guard';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';

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

  @Get('my-bars')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async getMyBars(@Request() req): Promise<Bar[]> {
    this.logger.log(`Obteniendo bares del propietario: ${req.user.userId}`);
    return this.barsService.findByOwner(req.user.userId);
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
  async update(@Param('id') id: string, @Body() updateBarDto: Partial<CreateBarDto>, @Request() req): Promise<Bar> {
    this.logger.log(`Recibiendo solicitud para actualizar bar con id: ${id}`);
    return this.barsService.update(id, updateBarDto, req.user.userId);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async remove(@Param('id') id: string, @Request() req): Promise<void> {
    this.logger.log(`Recibiendo solicitud para eliminar bar con id: ${id}`);
    return this.barsService.remove(id, req.user.userId);
  }

  // Foto del bar
  @Post(':id/photo')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, cb) => {
          const uniqueSuffix =
            Date.now() + '-' + Math.round(Math.random() * 1e9);
          cb(null, `bar-${uniqueSuffix}${extname(file.originalname)}`);
        },
      }),
      fileFilter: (req, file, cb) => {
        if (!file.mimetype.match(/\/(jpg|jpeg|png|gif)$/)) {
          return cb(new Error('Solo se permiten imágenes'), false);
        }
        cb(null, true);
      },
      limits: { fileSize: 5 * 1024 * 1024 },
    }),
  )
  async uploadPhoto(@Param('id') id: string, @UploadedFile() file: any, @Request() req) {
    // Verificar ownership
    if (req.user.role !== 'admin') {
      const bar = await this.barsService.findOne(id);
      if (bar.ownerId.toString() !== req.user.userId) {
        this.logger.warn(
          `Usuario ${req.user.userId} intentó subir foto a bar no propio ${id}`,
        );
        throw new ForbiddenException(
          'No tienes permiso para subir foto a este bar',
        );
      }
    }

    this.logger.log(`Foto subida: ${file.filename}`);
    const photoUrl = `/uploads/${file.filename}`;
    await this.barsService.updatePhotoUrl(id, photoUrl);
    return { message: 'Foto subida exitosamente', photoUrl };
  }

  @Delete(':id/photo')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async removePhoto(@Param('id') id: string, @Request() req) {
    // Verificar ownership
    if (req.user.role !== 'admin') {
      const bar = await this.barsService.findOne(id);
      if (bar.ownerId.toString() !== req.user.userId) {
        throw new ForbiddenException(
          'No tienes permiso para eliminar la foto de este bar',
        );
      }
    }

    await this.barsService.removePhoto(id);
    return { message: 'Foto del bar eliminada correctamente' };
  }
}
