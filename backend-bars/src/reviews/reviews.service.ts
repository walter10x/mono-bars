import { Injectable, Logger, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Review, ReviewDocument } from './review.schema';
import { CreateReviewDto, UpdateReviewDto, OwnerResponseDto } from './dto';
import { Bar, BarDocument } from '../bars/bars/bar.schema';

@Injectable()
export class ReviewsService {
  private readonly logger = new Logger(ReviewsService.name);

  constructor(
    @InjectModel(Review.name) private reviewModel: Model<ReviewDocument>,
    @InjectModel(Bar.name) private barModel: Model<BarDocument>,
  ) {}

  /**
   * Crear una nueva reseña
   */
  async create(userId: string, createReviewDto: CreateReviewDto): Promise<Review> {
    this.logger.log(`Usuario ${userId} creando reseña para bar ${createReviewDto.barId}`);

    // Verificar que el bar existe
    const bar = await this.barModel.findById(createReviewDto.barId);
    if (!bar) {
      throw new NotFoundException('Bar no encontrado');
    }

    // Verificar que el usuario no sea el dueño del bar
    if (bar.ownerId.toString() === userId) {
      throw new BadRequestException('No puedes escribir una reseña de tu propio bar');
    }

    // Verificar que no existe ya una reseña de este usuario para este bar
    const existingReview = await this.reviewModel.findOne({
      userId: new Types.ObjectId(userId),
      barId: new Types.ObjectId(createReviewDto.barId),
    });

    if (existingReview) {
      throw new BadRequestException('Ya has escrito una reseña para este bar');
    }

    // Crear la reseña
    const review = new this.reviewModel({
      userId: new Types.ObjectId(userId),
      barId: new Types.ObjectId(createReviewDto.barId),
      rating: createReviewDto.rating,
      comment: createReviewDto.comment,
    });

    const savedReview = await review.save();

    // Actualizar rating promedio del bar
    await this.updateBarAverageRating(createReviewDto.barId);

    return savedReview;
  }

  /**
   * Obtener todas las reseñas de un bar
   */
  async findByBar(barId: string): Promise<Review[]> {
    this.logger.log(`Obteniendo reseñas del bar ${barId}`);

    return this.reviewModel
      .find({ barId: new Types.ObjectId(barId), isVisible: true })
      .populate('userId', 'fullName email')
      .sort({ createdAt: -1 })
      .exec();
  }

  /**
   * Obtener reseñas del usuario actual
   */
  async findByUser(userId: string): Promise<Review[]> {
    this.logger.log(`Obteniendo reseñas del usuario ${userId}`);

    return this.reviewModel
      .find({ userId: new Types.ObjectId(userId) })
      .populate('barId', 'nameBar location photo')
      .sort({ createdAt: -1 })
      .exec();
  }

  /**
   * Obtener una reseña por ID
   */
  async findOne(id: string): Promise<Review> {
    const review = await this.reviewModel
      .findById(id)
      .populate('userId', 'fullName email')
      .populate('barId', 'nameBar location ownerId')
      .exec();

    if (!review) {
      throw new NotFoundException('Reseña no encontrada');
    }

    return review;
  }

  /**
   * Actualizar una reseña (solo el autor puede hacerlo)
   */
  async update(id: string, userId: string, updateReviewDto: UpdateReviewDto): Promise<Review> {
    this.logger.log(`Usuario ${userId} actualizando reseña ${id}`);

    const review = await this.reviewModel.findById(id);

    if (!review) {
      throw new NotFoundException('Reseña no encontrada');
    }

    if (review.userId.toString() !== userId) {
      throw new ForbiddenException('No tienes permiso para editar esta reseña');
    }

    // Actualizar campos
    if (updateReviewDto.rating !== undefined) {
      review.rating = updateReviewDto.rating;
    }
    if (updateReviewDto.comment !== undefined) {
      review.comment = updateReviewDto.comment;
    }

    const updatedReview = await review.save();

    // Actualizar rating promedio del bar
    await this.updateBarAverageRating(review.barId.toString());

    return updatedReview;
  }

  /**
   * Eliminar una reseña (solo el autor puede hacerlo)
   */
  async delete(id: string, userId: string): Promise<void> {
    this.logger.log(`Usuario ${userId} eliminando reseña ${id}`);

    const review = await this.reviewModel.findById(id);

    if (!review) {
      throw new NotFoundException('Reseña no encontrada');
    }

    if (review.userId.toString() !== userId) {
      throw new ForbiddenException('No tienes permiso para eliminar esta reseña');
    }

    const barId = review.barId.toString();
    await this.reviewModel.findByIdAndDelete(id);

    // Actualizar rating promedio del bar
    await this.updateBarAverageRating(barId);
  }

  /**
   * Añadir respuesta del owner a una reseña
   */
  async addOwnerResponse(reviewId: string, ownerId: string, ownerResponseDto: OwnerResponseDto): Promise<Review> {
    this.logger.log(`Owner ${ownerId} respondiendo a reseña ${reviewId}`);

    const review = await this.reviewModel
      .findById(reviewId)
      .populate('barId', 'ownerId')
      .exec();

    if (!review) {
      throw new NotFoundException('Reseña no encontrada');
    }

    // Verificar que el usuario es el dueño del bar
    const bar = review.barId as any;
    if (bar.ownerId.toString() !== ownerId) {
      throw new ForbiddenException('Solo el dueño del bar puede responder a esta reseña');
    }

    // Añadir respuesta
    review.ownerResponse = ownerResponseDto.response;
    review.responseDate = new Date();

    return review.save();
  }

  /**
   * Obtener estadísticas de reseñas de un bar
   */
  async getBarStats(barId: string): Promise<{ averageRating: number; totalReviews: number; ratingDistribution: Record<number, number> }> {
    const reviews = await this.reviewModel.find({ 
      barId: new Types.ObjectId(barId), 
      isVisible: true 
    });

    if (reviews.length === 0) {
      return {
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 },
      };
    }

    const totalRating = reviews.reduce((sum, r) => sum + r.rating, 0);
    const averageRating = Math.round((totalRating / reviews.length) * 10) / 10;

    const ratingDistribution: Record<number, number> = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    reviews.forEach(r => {
      ratingDistribution[r.rating]++;
    });

    return {
      averageRating,
      totalReviews: reviews.length,
      ratingDistribution,
    };
  }

  /**
   * Actualizar el rating promedio de un bar
   */
  private async updateBarAverageRating(barId: string): Promise<void> {
    const stats = await this.getBarStats(barId);

    await this.barModel.findByIdAndUpdate(barId, {
      averageRating: stats.averageRating,
      totalReviews: stats.totalReviews,
    });

    this.logger.log(`Bar ${barId} actualizado: rating ${stats.averageRating}, reviews ${stats.totalReviews}`);
  }

  /**
   * Obtener reseñas de los bares de un owner
   */
  async findByOwnerBars(ownerId: string): Promise<Review[]> {
    this.logger.log(`Obteniendo reseñas de los bares del owner ${ownerId}`);

    // Primero obtener los bares del owner
    const bars = await this.barModel.find({ ownerId: new Types.ObjectId(ownerId) });
    const barIds = bars.map(bar => bar._id);

    // Obtener las reseñas de esos bares
    return this.reviewModel
      .find({ barId: { $in: barIds }, isVisible: true })
      .populate('userId', 'fullName email')
      .populate('barId', 'nameBar location photo')
      .sort({ createdAt: -1 })
      .exec();
  }
}
