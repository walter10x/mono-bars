import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto, UpdateReviewDto, OwnerResponseDto } from './dto';

@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  /**
   * Crear una nueva reseña (requiere autenticación)
   * POST /reviews
   */
  @Post()
  @UseGuards(JwtAuthGuard)
  async create(@Request() req, @Body() createReviewDto: CreateReviewDto) {
    const review = await this.reviewsService.create(req.user.userId, createReviewDto);
    return {
      message: '¡Reseña creada exitosamente!',
      review,
    };
  }

  /**
   * Obtener reseñas de un bar específico (público)
   * GET /reviews/bar/:barId
   */
  @Get('bar/:barId')
  async findByBar(@Param('barId') barId: string) {
    const reviews = await this.reviewsService.findByBar(barId);
    return {
      reviews,
      total: reviews.length,
    };
  }

  /**
   * Obtener estadísticas de reseñas de un bar (público)
   * GET /reviews/bar/:barId/stats
   */
  @Get('bar/:barId/stats')
  async getBarStats(@Param('barId') barId: string) {
    return this.reviewsService.getBarStats(barId);
  }

  /**
   * Obtener mis reseñas (requiere autenticación)
   * GET /reviews/my-reviews
   */
  @Get('my-reviews')
  @UseGuards(JwtAuthGuard)
  async findMyReviews(@Request() req) {
    const reviews = await this.reviewsService.findByUser(req.user.userId);
    return {
      reviews,
      total: reviews.length,
    };
  }

  /**
   * Obtener reseñas de mis bares (para owners)
   * GET /reviews/my-bars
   */
  @Get('my-bars')
  @UseGuards(JwtAuthGuard)
  async findMyBarsReviews(@Request() req) {
    const reviews = await this.reviewsService.findByOwnerBars(req.user.userId);
    return {
      reviews,
      total: reviews.length,
    };
  }

  /**
   * Obtener una reseña por ID (público)
   * GET /reviews/:id
   */
  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.reviewsService.findOne(id);
  }

  /**
   * Actualizar mi reseña (requiere autenticación)
   * PUT /reviews/:id
   */
  @Put(':id')
  @UseGuards(JwtAuthGuard)
  async update(
    @Param('id') id: string,
    @Request() req,
    @Body() updateReviewDto: UpdateReviewDto,
  ) {
    const review = await this.reviewsService.update(id, req.user.userId, updateReviewDto);
    return {
      message: 'Reseña actualizada exitosamente',
      review,
    };
  }

  /**
   * Eliminar mi reseña (requiere autenticación)
   * DELETE /reviews/:id
   */
  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async delete(@Param('id') id: string, @Request() req) {
    await this.reviewsService.delete(id, req.user.userId);
    return {
      message: 'Reseña eliminada exitosamente',
    };
  }

  /**
   * Responder a una reseña (solo owner del bar)
   * POST /reviews/:id/response
   */
  @Post(':id/response')
  @UseGuards(JwtAuthGuard)
  async addOwnerResponse(
    @Param('id') id: string,
    @Request() req,
    @Body() ownerResponseDto: OwnerResponseDto,
  ) {
    const review = await this.reviewsService.addOwnerResponse(
      id,
      req.user.userId,
      ownerResponseDto,
    );
    return {
      message: 'Respuesta añadida exitosamente',
      review,
    };
  }
}
