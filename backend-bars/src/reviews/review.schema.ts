import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ReviewDocument = Review & Document;

@Schema({ timestamps: true })
export class Review {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Bar', required: true })
  barId: Types.ObjectId;

  @Prop({ required: true, min: 1, max: 5 })
  rating: number;

  @Prop({ required: true, minlength: 10, maxlength: 500 })
  comment: string;

  @Prop({ default: null })
  ownerResponse: string;

  @Prop({ default: null })
  responseDate: Date;

  @Prop({ default: true })
  isVisible: boolean;

  // Campos virtuales para populate
  @Prop({ type: Types.ObjectId, ref: 'User' })
  user?: any;

  @Prop({ type: Types.ObjectId, ref: 'Bar' })
  bar?: any;
}

export const ReviewSchema = SchemaFactory.createForClass(Review);

// Índice compuesto para asegurar 1 reseña por usuario por bar
ReviewSchema.index({ userId: 1, barId: 1 }, { unique: true });

// Índice para búsquedas por bar
ReviewSchema.index({ barId: 1, createdAt: -1 });
