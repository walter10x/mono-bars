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
} from '@nestjs/common';
import { PromotionsService } from './promotions.service';
import { CreatePromotionDto } from './dto/create-promotion.dto';
import { UpdatePromotionDto } from './dto/update-promotion.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles, RolesGuard } from '../auth/roles.guard';
import { BarsService } from '../bars/bars/bars.service';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';

@Controller('promotions')
export class PromotionsController {
  private readonly logger = new Logger(PromotionsController.name);

  constructor(
    private readonly promotionsService: PromotionsService,
    private readonly barsService: BarsService, // Validación de propietario
  ) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async create(@Body() createPromotionDto: CreatePromotionDto, @Request() req) {
    // Validar ownership
    if (req.user.role !== 'admin') {
      const bar = await this.barsService.findOne(createPromotionDto.barId);
      if (bar.ownerId.toString() !== req.user.userId) {
        this.logger.warn(`Usuario ${req.user.userId} intentó crear promoción en bar no propio ${createPromotionDto.barId}`);
        throw new ForbiddenException('No tienes permiso para crear promoción en este bar');
      }
    }
    return this.promotionsService.create(createPromotionDto);
  }

  // Imagen de la promoción
  @Post(':id/photo')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `promotion-${uniqueSuffix}${extname(file.originalname)}`);
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
    await this.promotionsService.updatePhotoUrl(id, photoUrl);
    return { message: 'Foto subida exitosamente', photoUrl };
  }

  // ELIMINAR SOLO LA FOTO de la promoción
  @Delete(':id/photo')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async removePhoto(@Param('id') id: string, @Request() req) {
    const promotion = await this.promotionsService.findOne(id);

    if (req.user.role !== 'admin') {
      const bar = await this.barsService.findOne(promotion.barId.toString());
      if (bar.ownerId.toString() !== req.user.userId) {
        throw new ForbiddenException('No tienes permiso para eliminar la foto de esta promoción');
      }
    }

    await this.promotionsService.removePhoto(id);
    return { message: 'Foto de la promoción eliminada correctamente' };
  }

  @Get()
  async findAll() {
    return this.promotionsService.findAll();
  }

  @Get('my-promotions')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async getMyPromotions(@Request() req) {
    this.logger.log(`Obteniendo promociones del propietario: ${req.user.userId}`);
    return this.promotionsService.findByOwner(req.user.userId);
  }

  @Get('bar/:barId')
  async findByBar(@Param('barId') barId: string) {
    return this.promotionsService.findAll(barId);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.promotionsService.findOne(id);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async update(@Param('id') id: string, @Body() updatePromotionDto: UpdatePromotionDto, @Request() req) {
    if (req.user.role !== 'admin') {
      const promotion = await this.promotionsService.findOne(id);
      const bar = await this.barsService.findOne(promotion.barId.toString());
      if (bar.ownerId.toString() !== req.user.userId) {
        this.logger.warn(`Usuario ${req.user.userId} intentó actualizar promoción no propia ${id}`);
        throw new ForbiddenException('No tienes permiso para actualizar esta promoción');
      }
    }
    return this.promotionsService.update(id, updatePromotionDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  async remove(@Param('id') id: string, @Request() req) {
    if (req.user.role !== 'admin') {
      const promotion = await this.promotionsService.findOne(id);
      const bar = await this.barsService.findOne(promotion.barId.toString());
      if (bar.ownerId.toString() !== req.user.userId) {
        this.logger.warn(`Usuario ${req.user.userId} intentó eliminar promoción no propia ${id}`);
        throw new ForbiddenException('No tienes permiso para eliminar esta promoción');
      }
    }
    return this.promotionsService.remove(id);
  }
}
