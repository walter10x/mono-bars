import { Controller, Post, Delete, Get, Param, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { FavoritesService } from './favorites.service';

@Controller('favorites')
@UseGuards(JwtAuthGuard)
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  @Post(':barId')
  async addToFavorites(@Request() req, @Param('barId') barId: string) {
    return this.favoritesService.addToFavorites(req.user.userId, barId);
  }

  @Delete(':barId')
  async removeFromFavorites(@Request() req, @Param('barId') barId: string) {
    return this.favoritesService.removeFromFavorites(req.user.userId, barId);
  }

  @Get()
  async getFavorites(@Request() req) {
    return this.favoritesService.getFavorites(req.user.userId);
  }
}
