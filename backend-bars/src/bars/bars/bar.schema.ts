// bar.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type BarDocument = Bar & Document;

@Schema({
  timestamps: true, // Agrega createdAt y updatedAt automáticamente
  toJSON: {
    transform: function (_doc: any, ret: any) {
      ret.id = ret._id.toString();
      delete ret._id;
      delete ret.__v;
      return ret;
    },
  },
})
export class Bar extends Document {
  @Prop({ required: true, unique: true })
  nameBar: string;  // Nombre del bar para identificar

  @Prop({ required: true })
  location: string;

  @Prop()
  description: string;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  ownerId: Types.ObjectId;  // Relación con usuario (dueno del bar)

  @Prop({ unique: true })
  phone: string;

  // Quitamos el email del bar, solo está en usuario

  @Prop()
  photo: string;

  @Prop({ type: Object })
  socialLinks: {
    facebook?: string | undefined;
    instagram?: string | undefined;
    [key: string]: string | undefined;
  };

  @Prop({ type: Object })
  hours: {
    monday?: { open: string; close: string };
    tuesday?: { open: string; close: string };
    wednesday?: { open: string; close: string };
    thursday?: { open: string; close: string };
    friday?: { open: string; close: string };
    saturday?: { open: string; close: string };
    sunday?: { open: string; close: string };
  };

  @Prop({ default: 0 })
  averageRating: number;

  @Prop({ default: 0 })
  totalReviews: number;

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ default: Date.now })
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const BarSchema = SchemaFactory.createForClass(Bar);
