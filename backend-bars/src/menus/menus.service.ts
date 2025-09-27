import { Injectable, NotFoundException, ConflictException, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Menu, MenuDocument } from './menu.schema';
import { CreateMenuDto } from './dto/create-menu.dto';
import { UpdateMenuDto } from './dto/update-menu.dto';
import { unlink } from 'fs/promises';
import { join } from 'path';

@Injectable()
export class MenusService {
  private readonly logger = new Logger(MenusService.name);

  constructor(@InjectModel(Menu.name) private menuModel: Model<MenuDocument>) {}

  async create(createMenuDto: CreateMenuDto): Promise<Menu> {
    this.logger.log(`Creando menú: ${createMenuDto.name}`);

    const barObjectId = new Types.ObjectId(createMenuDto.barId);
    const exists = await this.menuModel.findOne({ name: createMenuDto.name, barId: barObjectId });
    if (exists) {
      throw new ConflictException('Ya existe un menú con ese nombre para este bar');
    }

    const menu = new this.menuModel({
      ...createMenuDto,
      barId: barObjectId,
    });

    return menu.save();
  }

  async findAll(barId?: string): Promise<Menu[]> {
    if (barId) {
      const barObjectId = new Types.ObjectId(barId);
      return this.menuModel.find({ barId: barObjectId }).exec();
    }
    return this.menuModel.find().exec();
  }

  async findOne(id: string): Promise<Menu> {
    const menu = await this.menuModel.findById(id).exec();
    if (!menu) {
      throw new NotFoundException(`Menú con id ${id} no encontrado`);
    }
    return menu;
  }

  async update(id: string, updateMenuDto: UpdateMenuDto): Promise<Menu> {
    const menu = await this.menuModel.findById(id).exec();
    if (!menu) {
      throw new NotFoundException(`Menú con id ${id} no encontrado`);
    }

    if (updateMenuDto.name && updateMenuDto.name !== menu.name) {
      const exists = await this.menuModel.findOne({
        name: updateMenuDto.name,
        barId: menu.barId,
        _id: { $ne: id },
      });
      if (exists) {
        throw new ConflictException('Ya existe un menú con ese nombre para este bar');
      }
    }

    Object.assign(menu, updateMenuDto);
    return menu.save();
  }

  async remove(id: string): Promise<void> {
    const menu = await this.menuModel.findById(id);
    if (!menu) {
      throw new NotFoundException(`Menú con id ${id} no encontrado`);
    }

    if (menu.photoUrl) {
      await this.deleteImageFile(menu.photoUrl);
    }

    await this.menuModel.findByIdAndDelete(id).exec();
  }

  async updatePhotoUrl(id: string, photoUrl: string): Promise<Menu> {
    const menu = await this.menuModel.findById(id);
    if (!menu) {
      throw new NotFoundException(`Menú con id ${id} no encontrado`);
    }

    if (menu.photoUrl) {
      await this.deleteImageFile(menu.photoUrl);
    }

    menu.photoUrl = photoUrl;
    return menu.save();
  }

  // NUEVO: Eliminar solo la foto de un menú
  async removePhoto(id: string): Promise<Menu> {
    const menu = await this.menuModel.findById(id);
    if (!menu) {
      throw new NotFoundException(`Menú con id ${id} no encontrado`);
    }

    if (menu.photoUrl) {
      await this.deleteImageFile(menu.photoUrl);
      menu.photoUrl = undefined;
      return menu.save();
    }

    return menu;
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
