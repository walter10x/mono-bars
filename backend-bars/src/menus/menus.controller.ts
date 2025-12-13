import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Put,
  Delete,
  UseGuards,
  Request,
  ForbiddenException,
  Logger,
  UseInterceptors,
  UploadedFile,
  NotFoundException,
} from '@nestjs/common';
import { MenusService } from './menus.service';
import { CreateMenuDto } from './dto/create-menu.dto';
import { UpdateMenuDto } from './dto/update-menu.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles, RolesGuard } from '../auth/roles.guard';
import { BarsService } from '../bars/bars/bars.service';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';

@Controller('menus')
export class MenusController {
  private readonly logger = new Logger(MenusController.name);

  constructor(
    private readonly menusService: MenusService,
    private readonly barsService: BarsService, // Validación de propietario
  ) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async create(@Body() createMenuDto: CreateMenuDto, @Request() req) {
    // Validar ownership
    if (req.user.role !== 'admin') {
      const bar = await this.barsService.findOne(createMenuDto.barId);
      if (bar.ownerId.toString() !== req.user.userId) {
        this.logger.warn(`Usuario ${req.user.userId} intentó crear menú en bar no propio ${createMenuDto.barId}`);
        throw new ForbiddenException('No tienes permiso para crear menú en este bar');
      }
    }
    return this.menusService.create(createMenuDto);
  }

  // Imagen del menú
  @Post(':id/photo')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `menu-${uniqueSuffix}${extname(file.originalname)}`);
      },
    }),
    fileFilter: (req, file, cb) => {
      if (!file.mimetype.match(/\/(jpg|jpeg|png|gif)$/)) {
        return cb(new Error('Solo se permiten imágenes'), false);
      }
      cb(null, true);
    },
    limits: { fileSize: 5 * 1024 * 1024 },
  }))
  async uploadPhoto(@Param('id') id: string, @UploadedFile() file: any) {
    this.logger.log(`Foto subida: ${file.filename}`);
    const photoUrl = `/uploads/${file.filename}`;
    await this.menusService.updatePhotoUrl(id, photoUrl);
    return { message: 'Foto subida exitosamente', photoUrl };
  }

  // ELIMINAR SOLO LA FOTO del menú (nuevo endpoint)
  @Delete(':id/photo')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async removePhoto(@Param('id') id: string, @Request() req) {
    const menu = await this.menusService.findOne(id);

    if (req.user.role !== 'admin') {
      const bar = await this.barsService.findOne(menu.barId.toString());
      if (bar.ownerId.toString() !== req.user.userId) {
        throw new ForbiddenException('No tienes permiso para eliminar la foto de este menú');
      }
    }

    await this.menusService.removePhoto(id);
    return { message: 'Foto del menú eliminada correctamente' };
  }

  @Get()
  async findAll() {
    return this.menusService.findAll();
  }

  @Get('my-menus')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async getMyMenus(@Request() req) {
    this.logger.log(`Obteniendo menús del propietario: ${req.user.userId}`);
    return this.menusService.findByOwner(req.user.userId);
  }

  @Get('bar/:barId')
  async findByBar(@Param('barId') barId: string) {
    this.logger.log(`Obteniendo menús del bar: ${barId}`);
    return this.menusService.findAll(barId);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.menusService.findOne(id);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async update(@Param('id') id: string, @Body() updateMenuDto: UpdateMenuDto, @Request() req) {
    if (req.user.role !== 'admin') {
      const menu = await this.menusService.findOne(id);
      const bar = await this.barsService.findOne(menu.barId.toString());
      if (bar.ownerId.toString() !== req.user.userId) {
        this.logger.warn(`Usuario ${req.user.userId} intentó actualizar menú no propio ${id}`);
        throw new ForbiddenException('No tienes permiso para actualizar este menú');
      }
    }
    return this.menusService.update(id, updateMenuDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async remove(@Param('id') id: string, @Request() req) {
    if (req.user.role !== 'admin') {
      const menu = await this.menusService.findOne(id);
      const bar = await this.barsService.findOne(menu.barId.toString());
      if (bar.ownerId.toString() !== req.user.userId) {
        this.logger.warn(`Usuario ${req.user.userId} intentó eliminar menú no propio ${id}`);
        throw new ForbiddenException('No tienes permiso para eliminar este menú');
      }
    }
    return this.menusService.remove(id);
  }
}
