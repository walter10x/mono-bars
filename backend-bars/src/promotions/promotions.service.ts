import { Injectable, NotFoundException, ConflictException, Logger, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Promotion, PromotionDocument } from './promotion.schema';
import { CreatePromotionDto } from './dto/create-promotion.dto';
import { UpdatePromotionDto } from './dto/update-promotion.dto';
import { unlink } from 'fs/promises';
import { join } from 'path';

@Injectable()
export class PromotionsService {
  private readonly logger = new Logger(PromotionsService.name);

  constructor(@InjectModel(Promotion.name) private promotionModel: Model<PromotionDocument>) {}

  async create(createPromotionDto: CreatePromotionDto): Promise<Promotion> {
    this.logger.log(`Creando promoción: ${createPromotionDto.title}`);

    // Validar fechas
    const validFrom = new Date(createPromotionDto.validFrom);
    const validUntil = new Date(createPromotionDto.validUntil);

    if (validFrom >= validUntil) {
      throw new BadRequestException('La fecha de inicio debe ser anterior a la fecha de fin');
    }

    const barObjectId = new Types.ObjectId(createPromotionDto.barId);

    const promotion = new this.promotionModel({
      ...createPromotionDto,
      barId: barObjectId,
      validFrom,
      validUntil,
    });

    return promotion.save();
  }

  async findAll(barId?: string): Promise<Promotion[]> {
    if (barId) {
      const barObjectId = new Types.ObjectId(barId);
      return this.promotionModel.find({ barId: barObjectId }).exec();
    }
    return this.promotionModel.find().exec();
  }

  async findByOwner(ownerId: string): Promise<Promotion[]> {
    this.logger.log(`Buscando promociones del propietario: ${ownerId}`);
    
    // Obtener promociones de todos los bares del owner usando aggregation
    const ownerObjectId = new Types.ObjectId(ownerId);
    
    return this.promotionModel
      .aggregate([
        {
          $lookup: {
            from: 'bars',
            localField: 'barId',
            foreignField: '_id',
            as: 'bar',
          },
        },
        {
          $unwind: '$bar',
        },
        {
          $match: {
            'bar.ownerId': ownerObjectId,
          },
        },
        {
          $project: {
            _id: 0, // Excluir _id original
            id: { $toString: '$_id' }, // Convertir _id a string como 'id'
            title: 1,
            description: 1,
            type: { $literal: 'discount' }, // Tipo por defecto para compatibilidad con frontend
            barId: { $toString: '$barId' }, // Convertir barId ObjectId a string
            discountPercentage: 1,
            validFrom: 1,
            validUntil: 1,
            isActive: 1,
            photoUrl: 1,
            termsAndConditions: 1,
            createdAt: 1,
            updatedAt: 1,
          },
        },
      ])
      .exec();
  }

  async findOne(id: string): Promise<Promotion> {
    const promotion = await this.promotionModel.findById(id).exec();
    if (!promotion) {
      throw new NotFoundException(`Promoción con id ${id} no encontrada`);
    }
    return promotion;
  }

  async update(id: string, updatePromotionDto: UpdatePromotionDto): Promise<Promotion> {
    const promotion = await this.promotionModel.findById(id).exec();
    if (!promotion) {
      throw new NotFoundException(`Promoción con id ${id} no encontrada`);
    }

    // Validar fechas si se están actualizando
    if (updatePromotionDto.validFrom || updatePromotionDto.validUntil) {
      const validFrom = updatePromotionDto.validFrom 
        ? new Date(updatePromotionDto.validFrom) 
        : promotion.validFrom;
      const validUntil = updatePromotionDto.validUntil 
        ? new Date(updatePromotionDto.validUntil) 
        : promotion.validUntil;

      if (validFrom >= validUntil) {
        throw new BadRequestException('La fecha de inicio debe ser anterior a la fecha de fin');
      }

      if (updatePromotionDto.validFrom) {
        updatePromotionDto.validFrom = validFrom.toISOString();
      }
      if (updatePromotionDto.validUntil) {
        updatePromotionDto.validUntil = validUntil.toISOString();
      }
    }

    Object.assign(promotion, updatePromotionDto);
    return promotion.save();
  }

  async remove(id: string): Promise<void> {
    const promotion = await this.promotionModel.findById(id);
    if (!promotion) {
      throw new NotFoundException(`Promoción con id ${id} no encontrada`);
    }

    if (promotion.photoUrl) {
      await this.deleteImageFile(promotion.photoUrl);
    }

    await this.promotionModel.findByIdAndDelete(id).exec();
  }

  async updatePhotoUrl(id: string, photoUrl: string): Promise<Promotion> {
    const promotion = await this.promotionModel.findById(id);
    if (!promotion) {
      throw new NotFoundException(`Promoción con id ${id} no encontrada`);
    }

    if (promotion.photoUrl) {
      await this.deleteImageFile(promotion.photoUrl);
    }

    promotion.photoUrl = photoUrl;
    return promotion.save();
  }

  async removePhoto(id: string): Promise<Promotion> {
    const promotion = await this.promotionModel.findById(id);
    if (!promotion) {
      throw new NotFoundException(`Promoción con id ${id} no encontrada`);
    }

    if (promotion.photoUrl) {
      await this.deleteImageFile(promotion.photoUrl);
      promotion.photoUrl = undefined;
      return promotion.save();
    }

    return promotion;
  }

  private async deleteImageFile(photoUrl: string) {
    if (!photoUrl) return;
    const filePath = join(__dirname, '..', '..', photoUrl);
    try {
      await unlink(filePath);
      this.logger.log(`Archivo eliminado: ${filePath}`);
    } catch (error) {
      this.logger.warn(`No se pudo borrar archivo: ${filePath}. Error: ${error.message}`);
    }
  }
}
