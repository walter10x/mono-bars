import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User } from '../users/user.schema';
import { Bar } from '../bars/bars/bar.schema';

@Injectable()
export class FavoritesService {
  constructor(
    @InjectModel(User.name) private userModel: Model<User>,
    @InjectModel(Bar.name) private barModel: Model<Bar>,
  ) {}

  async addToFavorites(userId: string, barId: string) {
    // Verificar que el bar existe
    const bar = await this.barModel.findById(barId);
    if (!bar) {
      throw new NotFoundException(`Bar con id ${barId} no encontrado`);
    }

    // Verificar que el barId es válido
    if (!Types.ObjectId.isValid(barId)) {
      throw new BadRequestException('ID de bar inválido');
    }

    // Agregar a favoritos si no está ya
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException(`Usuario con id ${userId} no encontrado`);
    }

    const barObjectId = new Types.ObjectId(barId);
    
    // Verificar si ya está en favoritos
    const alreadyFavorite = user.favoriteBars.some(
      (id) => id.toString() === barId
    );

    if (alreadyFavorite) {
      return { message: 'El bar ya está en favoritos', isFavorite: true };
    }

    // Agregar a favoritos
    user.favoriteBars.push(barObjectId);
    await user.save();

    return { message: 'Bar agregado a favoritos', isFavorite: true };
  }

  async removeFromFavorites(userId: string, barId: string) {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new NotFoundException(`Usuario con id ${userId} no encontrado`);
    }

    // Remover de favoritos
    user.favoriteBars = user.favoriteBars.filter(
      (id) => id.toString() !== barId
    ) as Types.Array<Types.ObjectId>;

    await user.save();

    return { message: 'Bar eliminado de favoritos', isFavorite: false };
  }

  async getFavorites(userId: string) {
    const user = await this.userModel
      .findById(userId)
      .populate('favoriteBars')
      .exec();

    if (!user) {
      throw new NotFoundException(`Usuario con id ${userId} no encontrado`);
    }

    return {
      favorites: user.favoriteBars,
      total: user.favoriteBars.length,
    };
  }
}
