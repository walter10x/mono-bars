import { Injectable, NotFoundException, ConflictException, Logger, ForbiddenException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Bar } from './bar.schema';
import { CreateBarDto } from './create-bar.dto';

@Injectable()
export class BarsService {
  private readonly logger = new Logger(BarsService.name);

  constructor(@InjectModel(Bar.name) private barModel: Model<Bar>) {}

  async create(createBarDto: CreateBarDto): Promise<Bar> {
    this.logger.log(`Intentando crear bar: ${createBarDto.nameBar}`);

    const existsByName = await this.barModel.findOne({ nameBar: createBarDto.nameBar });
    if (existsByName) {
      this.logger.warn(`Intento de duplicado: Bar con nombre "${createBarDto.nameBar}" ya existe`);
      throw new ConflictException('Ya existe un bar con ese nombre');
    }

    if (createBarDto.phone) {
      const existsByPhone = await this.barModel.findOne({ phone: createBarDto.phone });
      if (existsByPhone) {
        this.logger.warn(`Intento de duplicado: Bar con teléfono "${createBarDto.phone}" ya existe`);
        throw new ConflictException('Ya existe un bar con ese teléfono');
      }
    }

    if (createBarDto.socialLinks?.facebook) {
      const existsByFacebook = await this.barModel.findOne({ 'socialLinks.facebook': createBarDto.socialLinks.facebook });
      if (existsByFacebook) {
        this.logger.warn(`Intento de duplicado: Bar con Facebook "${createBarDto.socialLinks.facebook}" ya existe`);
        throw new ConflictException('Ya existe un bar con ese Facebook');
      }
    }

    if (createBarDto.socialLinks?.instagram) {
      const existsByInstagram = await this.barModel.findOne({ 'socialLinks.instagram': createBarDto.socialLinks.instagram });
      if (existsByInstagram) {
        this.logger.warn(`Intento de duplicado: Bar con Instagram "${createBarDto.socialLinks.instagram}" ya existe`);
        throw new ConflictException('Ya existe un bar con ese Instagram');
      }
    }

    if (!createBarDto.ownerId) {
      throw new ConflictException('El campo ownerId es obligatorio');
    }
    const ownerObjectId = new Types.ObjectId(createBarDto.ownerId);

    const createdBar = new this.barModel({
      ...createBarDto,
      ownerId: ownerObjectId,
    });

    this.logger.log(`Bar ${createBarDto.nameBar} creado en BD`);
    return createdBar.save();
  }

  async findAll(): Promise<Bar[]> {
    this.logger.log('Recibiendo solicitud para listar todos los bares');
    return this.barModel.find().exec();
  }

  async findByOwner(ownerId: string): Promise<Bar[]> {
    this.logger.log(`Buscando bares del propietario: ${ownerId}`);
    const ownerObjectId = new Types.ObjectId(ownerId);
    return this.barModel.find({ ownerId: ownerObjectId }).exec();
  }

  async verifyOwnership(barId: string, ownerId: string): Promise<boolean> {
    this.logger.log(`Verificando ownership del bar ${barId} para usuario ${ownerId}`);
    const bar = await this.barModel.findById(barId).exec();
    if (!bar) {
      return false;
    }
    return bar.ownerId.toString() === ownerId;
  }

  async findOne(id: string): Promise<Bar> {
    this.logger.log(`Buscando bar con id: ${id}`);
    const bar = await this.barModel.findById(id).exec();
    if (!bar) {
      this.logger.warn(`Bar con id ${id} no encontrado`);
      throw new NotFoundException(`Bar with id ${id} not found`);
    }
    return bar;
  }

  async update(id: string, updateBarDto: Partial<CreateBarDto>, userId?: string): Promise<Bar> {
    this.logger.log(`Actualizando bar con id: ${id}`);

    const barIdObj = new Types.ObjectId(id);
    const barActual = await this.barModel.findById(barIdObj).exec();
    if (!barActual) {
      this.logger.warn(`Bar con id ${id} no encontrado`);
      throw new NotFoundException(`Bar with id ${id} not found`);
    }

    // Verificar ownership si se proporciona userId
    if (userId && barActual.ownerId.toString() !== userId) {
      this.logger.warn(`Usuario ${userId} intentó actualizar bar ${id} que no le pertenece`);
      throw new ForbiddenException('No tienes permiso para actualizar este bar');
    }

    // Validar nombre solo si cambia
    if (updateBarDto.nameBar && updateBarDto.nameBar !== barActual.nameBar) {
      const existsByName = await this.barModel.findOne({ nameBar: updateBarDto.nameBar, _id: { $ne: barIdObj } });
      if (existsByName) {
        this.logger.warn(`Intento de actualizar con nombre duplicado: "${updateBarDto.nameBar}"`);
        throw new ConflictException('Ya existe un bar con ese nombre');
      }
    }

    // Validar teléfono solo si cambia
    if (updateBarDto.phone && updateBarDto.phone !== barActual.phone) {
      const existsByPhone = await this.barModel.findOne({ phone: updateBarDto.phone, _id: { $ne: barIdObj } });
      if (existsByPhone) {
        this.logger.warn(`Intento de actualizar con teléfono duplicado: "${updateBarDto.phone}"`);
        throw new ConflictException('Ya existe un bar con ese teléfono');
      }
    }

    // Validar Facebook solo si cambia
    if (updateBarDto.socialLinks?.facebook && updateBarDto.socialLinks.facebook !== barActual.socialLinks?.facebook) {
      const existsByFacebook = await this.barModel.findOne({ 'socialLinks.facebook': updateBarDto.socialLinks.facebook, _id: { $ne: barIdObj } });
      if (existsByFacebook) {
        this.logger.warn(`Intento de actualizar con Facebook duplicado: "${updateBarDto.socialLinks.facebook}"`);
        throw new ConflictException('Ya existe un bar con ese Facebook');
      }
    }

    // Validar Instagram solo si cambia
    if (updateBarDto.socialLinks?.instagram && updateBarDto.socialLinks.instagram !== barActual.socialLinks?.instagram) {
      const existsByInstagram = await this.barModel.findOne({ 'socialLinks.instagram': updateBarDto.socialLinks.instagram, _id: { $ne: barIdObj } });
      if (existsByInstagram) {
        this.logger.warn(`Intento de actualizar con Instagram duplicado: "${updateBarDto.socialLinks.instagram}"`);
        throw new ConflictException('Ya existe un bar con ese Instagram');
      }
    }

    Object.assign(barActual, updateBarDto);

    this.logger.log(`Bar con id ${id} actualizado correctamente`);
    return barActual.save();
  }

  async remove(id: string, userId?: string): Promise<void> {
    this.logger.log(`Eliminando bar con id: ${id}`);
    
    // Verificar ownership si se proporciona userId
    if (userId) {
      const bar = await this.barModel.findById(id).exec();
      if (!bar) {
        this.logger.warn(`No se pudo eliminar. Bar con id ${id} no encontrado`);
        throw new NotFoundException(`Bar with id ${id} not found`);
      }
      if (bar.ownerId.toString() !== userId) {
        this.logger.warn(`Usuario ${userId} intentó eliminar bar ${id} que no le pertenece`);
        throw new ForbiddenException('No tienes permiso para eliminar este bar');
      }
    }
    
    const result = await this.barModel.findByIdAndDelete(id).exec();
    if (!result) {
      this.logger.warn(`No se pudo eliminar. Bar con id ${id} no encontrado`);
      throw new NotFoundException(`Bar with id ${id} not found`);
    }
    this.logger.log(`Bar con id ${id} eliminado correctamente`);
  }

  async updatePhotoUrl(id: string, photoUrl: string): Promise<Bar> {
    this.logger.log(`Actualizando foto del bar ${id}`);
    const bar = await this.barModel.findById(id).exec();
    if (!bar) {
      throw new NotFoundException(`Bar with id ${id} not found`);
    }
    bar.photo = photoUrl;
    return bar.save();
  }

  async removePhoto(id: string): Promise<Bar> {
    this.logger.log(`Eliminando foto del bar ${id}`);
    const bar = await this.barModel.findById(id).exec();
    if (!bar) {
      throw new NotFoundException(`Bar with id ${id} not found`);
    }
    bar.photo = '';
    return bar.save();
  }
}
