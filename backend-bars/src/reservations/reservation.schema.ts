import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export enum ReservationStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  CANCELLED = 'cancelled',
  COMPLETED = 'completed',
}

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
export class Reservation extends Document {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Bar', required: true })
  barId: Types.ObjectId;

  @Prop({ required: true })
  reservationDate: Date;

  @Prop({ required: true, min: 1 })
  numberOfPeople: number;

  @Prop({ required: true })
  customerName: string;

  @Prop({ required: true })
  customerPhone: string;

  @Prop()
  comments: string;

  @Prop({
    type: String,
    enum: Object.values(ReservationStatus),
    default: ReservationStatus.PENDING,
  })
  status: ReservationStatus;
}

export const ReservationSchema = SchemaFactory.createForClass(Reservation);
