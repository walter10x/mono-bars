// src/menus/menu.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type MenuDocument = Menu & Document;

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
export class Menu {
  @Prop({ required: true })
  name: string;

  @Prop()
  description?: string;

  @Prop({ type: Types.ObjectId, required: true, ref: 'Bar' })
  barId: Types.ObjectId;

  @Prop([{ 
    name: String,
    description: String,
    price: Number,
    photoUrl: String,
  }])
  items: {
    name: string;
    description?: string;
    price: number;
    photoUrl?: string;
  }[];

  @Prop()
  photoUrl?: string; // Imagen general del menú
}

export const MenuSchema = SchemaFactory.createForClass(Menu);
