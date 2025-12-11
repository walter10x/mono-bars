// src/promotions/promotion.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PromotionDocument = Promotion & Document;

@Schema({
  timestamps: true,
  toJSON: {
    transform: function (_doc: any, ret: any) {
      ret.id = ret._id.toString();
      delete ret._id;
      delete ret.__v;
      return ret;
    },
  },
})
export class Promotion {
  @Prop({ required: true })
  title: string;

  @Prop()
  description?: string;

  @Prop({ type: Types.ObjectId, required: true, ref: 'Bar' })
  barId: Types.ObjectId;

  @Prop()
  discountPercentage?: number;

  @Prop({ required: true })
  validFrom: Date;

  @Prop({ required: true })
  validUntil: Date;

  @Prop({ default: true })
  isActive: boolean;

  @Prop()
  photoUrl?: string;

  @Prop()
  termsAndConditions?: string;
}

export const PromotionSchema = SchemaFactory.createForClass(Promotion);
